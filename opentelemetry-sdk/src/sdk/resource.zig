const std = @import("std");
const builtin = @import("builtin");
const build_info = @import("build_info");
const semconv = @import("opentelemetry-semconv");
const Attribute = @import("../attributes.zig").Attribute;
const fromPairs = @import("../attributes.zig").fromPairs;
const Configuration = @import("config.zig").Configuration;
const ResourceDetector = @import("config.zig").ResourceDetector;
const ResourceDetectors = @import("config.zig").ResourceDetectors;
const PercentDecodedCommaSeparatedAssignmentIterator = @import("key_value_sequence_iterator.zig").PercentDecodedCommaSeparatedAssignmentIterator;

// The well-known values MUST be used when one applies, the sets are open otherwise:
// targets without one are reported under their Zig name.
const OsType = @TypeOf(semconv.attribute.os_type).well_known_values;
const os_type: []const u8 = switch (builtin.os.tag) {
    .windows => OsType.windows.toString(),
    .linux => OsType.linux.toString(),
    .driverkit, .ios, .maccatalyst, .macos, .tvos, .visionos, .watchos => OsType.darwin.toString(),
    .freebsd => OsType.freebsd.toString(),
    .netbsd => OsType.netbsd.toString(),
    .openbsd => OsType.openbsd.toString(),
    .dragonfly => OsType.dragonflybsd.toString(),
    .illumos => OsType.solaris.toString(),
    else => @tagName(builtin.os.tag),
};

const HostArch = @TypeOf(semconv.attribute.host_arch).well_known_values;
const host_arch: []const u8 = switch (builtin.cpu.arch) {
    .x86_64 => HostArch.amd64.toString(),
    .x86 => HostArch.x86.toString(),
    .aarch64, .aarch64_be => HostArch.arm64.toString(),
    .arm, .armeb, .thumb, .thumbeb => HostArch.arm32.toString(),
    .powerpc, .powerpcle => HostArch.ppc32.toString(),
    .powerpc64, .powerpc64le => HostArch.ppc64.toString(),
    .s390x => HostArch.s390x.toString(),
    else => @tagName(builtin.cpu.arch),
};

/// An attribute the SDK detects on its own, and the detectors it is tagged with.
const Detected = struct {
    tags: ResourceDetectors,
    attribute: Attribute,
};

fn detected(tags: []const ResourceDetector, definition: anytype, value: anytype) Detected {
    return .{ .tags = .initMany(tags), .attribute = fromPairs(.{.{ definition, value }})[0] };
}

/// Every attribute the detectors provide. One is added when any of its tags is an enabled
/// detector, unless OTEL_RESOURCE_ATTRIBUTES already sets its key.
const detected_attributes = [_]Detected{
    detected(&.{ .sdk, .@"comptime", .required }, semconv.attribute.telemetry_sdk_name, build_info.name),
    // Not one of the well-known languages of the semantic conventions, which is an open set.
    detected(&.{ .sdk, .@"comptime", .required }, semconv.attribute.telemetry_sdk_language, "zig"),
    detected(&.{ .sdk, .@"comptime", .required }, semconv.attribute.telemetry_sdk_version, build_info.version),
    detected(&.{ .os, .@"comptime", .required }, semconv.attribute.os_type, os_type),
    detected(&.{ .host, .@"comptime", .recommended }, semconv.attribute.host_arch, host_arch),
    detected(&.{ .process, .@"comptime", .recommended }, semconv.attribute.process_runtime_name, "zig"),
    detected(&.{ .process, .@"comptime", .recommended }, semconv.attribute.process_runtime_version, builtin.zig_version_string),
};

/// Build resource attributes from configuration
/// Combines OTEL_SERVICE_NAME, OTEL_RESOURCE_ATTRIBUTES and the attributes of the enabled
/// detectors. The configured attributes take precedence over the detected ones.
pub fn buildFromConfig(allocator: std.mem.Allocator, config: *const Configuration) ![]Attribute {
    const has_service_name = config.service_name != null;

    // `parseResourceAttributes` reserves its own capacity, so this only covers
    // the service.name entry below: its append then cannot fail and orphan a
    // duped attribute.
    var attributes: std.ArrayList(Attribute) = try .initCapacity(allocator, @intFromBool(has_service_name));
    errdefer {
        for (attributes.items) |attr| {
            allocator.free(attr.key);
            if (attr.value == .string) {
                allocator.free(attr.value.string);
            }
        }
        attributes.deinit(allocator);
    }

    // Add service.name if configured
    if (config.service_name) |service_name| {
        const service_name_attribute = fromPairs(.{.{ semconv.attribute.service_name, service_name }});
        attributes.appendAssumeCapacity(try Attribute.dupe(allocator, service_name_attribute[0]));
    }

    // Parse and add resource attributes
    // Skip service.name from resource_attributes if OTEL_SERVICE_NAME is set (it takes precedence)
    if (config.resource_attributes) |resource_attrs| {
        try parseResourceAttributes(allocator, resource_attrs, &attributes, has_service_name);
    }

    // Same as above, for the detected attributes.
    try attributes.ensureUnusedCapacity(allocator, detected_attributes.len);
    const configured = attributes.items.len;
    for (detected_attributes) |line| {
        if (line.tags.intersectWith(config.resource_detectors).count() == 0) continue;
        if (containsAttributeKey(attributes.items[0..configured], line.attribute.key)) continue;
        attributes.appendAssumeCapacity(try Attribute.dupe(allocator, line.attribute));
    }

    return try attributes.toOwnedSlice(allocator);
}

/// Parse resource attributes from comma-separated key=value pairs
/// Format: "key1=value1,key2=value2"
/// Keys and values are percent-decoded according to RFC 3986.
/// If skip_service_name is true, service.name entries will be skipped (OTEL_SERVICE_NAME takes precedence)
fn parseResourceAttributes(
    allocator: std.mem.Allocator,
    attrs_str: []const u8,
    attributes: *std.ArrayList(Attribute),
    skip_service_name: bool,
) !void {
    // At most one attribute per entry, and a comma-separated list holds at most
    // one more entry than it has commas. Reserving up front makes the appends
    // below infallible, so a duped attribute is never orphaned mid-append.
    try attributes.ensureUnusedCapacity(allocator, std.mem.countScalar(u8, attrs_str, ',') + 1);

    // Decoding never grows a string, so `attrs_str.len` bytes is always enough
    // room for the decoded name and value of any one entry.
    const scratch = try allocator.alloc(u8, attrs_str.len);
    defer allocator.free(scratch);

    var iter: PercentDecodedCommaSeparatedAssignmentIterator = .init(attrs_str, scratch);
    while (iter.next() catch unreachable) |entry| {
        const value = entry.value orelse {
            std.log.warn("Invalid resource attribute (missing '='): {s}", .{entry.name});
            continue;
        };

        if (entry.name.len == 0) {
            std.log.warn("Invalid resource attribute (empty key): ={s}", .{value});
            continue;
        }

        // Skip service.name if OTEL_SERVICE_NAME is set (it takes precedence)
        if (skip_service_name and std.mem.eql(u8, entry.name, semconv.attribute.service_name.name)) continue;

        attributes.appendAssumeCapacity(try Attribute.dupe(allocator, .{
            .key = entry.name,
            .value = .{ .string = value },
        }));
    }
}

/// Free resource attributes
pub fn freeResource(allocator: std.mem.Allocator, resource: []const Attribute) void {
    for (resource) |attr| {
        allocator.free(attr.key);
        if (attr.value == .string) {
            allocator.free(attr.value.string);
        }
    }
    allocator.free(resource);
}

fn containsAttributeKey(slice: []const Attribute, key: []const u8) bool {
    for (slice) |attr| {
        if (std.mem.eql(u8, attr.key, key)) return true;
    }
    return false;
}

/// Merge two resource attribute slices into a new one.
/// If a key exists in both slices, the attribute from res1 takes precedence.
/// Caller is responsible for freeing the returned slice with freeResource.
pub fn mergeResources(
    allocator: std.mem.Allocator,
    res1: []const Attribute,
    res2: []const Attribute,
) !?[]Attribute {
    var merged: std.ArrayList(Attribute) = try .initCapacity(allocator, res1.len + res2.len);
    errdefer {
        for (merged.items) |attr| {
            allocator.free(attr.key);
            if (attr.value == .string) {
                allocator.free(attr.value.string);
            }
        }
        merged.deinit(allocator);
    }

    for (res1) |attr| {
        if (!containsAttributeKey(merged.items, attr.key)) {
            merged.appendAssumeCapacity(try Attribute.dupe(allocator, attr));
        }
    }
    for (res2) |attr| {
        if (!containsAttributeKey(merged.items, attr.key)) {
            merged.appendAssumeCapacity(try Attribute.dupe(allocator, attr));
        }
    }

    if (merged.items.len > 0) {
        return try merged.toOwnedSlice(allocator);
    } else {
        merged.deinit(allocator);
        return null;
    }
}

test "buildFromConfig with service name only" {
    const allocator = std.testing.allocator;

    var config = Configuration{
        .allocator = allocator,
        .sdk_disabled = false,
        .resource_detectors = .empty,
        .service_name = "my-service",
        .resource_attributes = null,
        .log_level = .info,
        .trace_propagators = &.{},
        .trace_config = undefined,
        .metrics_config = undefined,
        .logs_config = undefined,
    };

    const resource = try buildFromConfig(allocator, &config);
    defer freeResource(allocator, resource);

    try std.testing.expectEqual(@as(usize, 1), resource.len);
    try std.testing.expectEqualStrings(semconv.attribute.service_name.name, resource[0].key);
    try std.testing.expectEqualStrings("my-service", resource[0].value.string);
}

test "buildFromConfig with resource attributes only" {
    const allocator = std.testing.allocator;

    var config = Configuration{
        .allocator = allocator,
        .sdk_disabled = false,
        .resource_detectors = .empty,
        .service_name = null,
        .resource_attributes = "key1=value1,key2=value2",
        .log_level = .info,
        .trace_propagators = &.{},
        .trace_config = undefined,
        .metrics_config = undefined,
        .logs_config = undefined,
    };

    const resource = try buildFromConfig(allocator, &config);
    defer freeResource(allocator, resource);

    try std.testing.expectEqual(@as(usize, 2), resource.len);
    try std.testing.expectEqualStrings("key1", resource[0].key);
    try std.testing.expectEqualStrings("value1", resource[0].value.string);
    try std.testing.expectEqualStrings("key2", resource[1].key);
    try std.testing.expectEqualStrings("value2", resource[1].value.string);
}

test "buildFromConfig with both service name and resource attributes" {
    const allocator = std.testing.allocator;

    var config = Configuration{
        .allocator = allocator,
        .sdk_disabled = false,
        .resource_detectors = .empty,
        .service_name = "test-service",
        .resource_attributes = "deployment.environment.name=production,host.name=server-1",
        .log_level = .info,
        .trace_propagators = &.{},
        .trace_config = undefined,
        .metrics_config = undefined,
        .logs_config = undefined,
    };

    const resource = try buildFromConfig(allocator, &config);
    defer freeResource(allocator, resource);

    try std.testing.expectEqual(@as(usize, 3), resource.len);
    try std.testing.expectEqualStrings(semconv.attribute.service_name.name, resource[0].key);
    try std.testing.expectEqualStrings("test-service", resource[0].value.string);
    try std.testing.expectEqualStrings(semconv.attribute.deployment_environment_name.name, resource[1].key);
    try std.testing.expectEqualStrings("production", resource[1].value.string);
    try std.testing.expectEqualStrings(semconv.attribute.host_name.name, resource[2].key);
    try std.testing.expectEqualStrings("server-1", resource[2].value.string);
}

test "parseResourceAttributes with whitespace and empty values" {
    const allocator = std.testing.allocator;

    var config = Configuration{
        .allocator = allocator,
        .sdk_disabled = false,
        .resource_detectors = .empty,
        .service_name = null,
        .resource_attributes = " key1 = value1 , key2=value2,  ,key3=",
        .log_level = .info,
        .trace_propagators = &.{},
        .trace_config = undefined,
        .metrics_config = undefined,
        .logs_config = undefined,
    };

    const resource = try buildFromConfig(allocator, &config);
    defer freeResource(allocator, resource);

    // Should parse 3 valid attributes (key3 has empty value which is valid)
    try std.testing.expectEqual(@as(usize, 3), resource.len);
    try std.testing.expectEqualStrings("key1", resource[0].key);
    try std.testing.expectEqualStrings("value1", resource[0].value.string);
    try std.testing.expectEqualStrings("key2", resource[1].key);
    try std.testing.expectEqualStrings("value2", resource[1].value.string);
    try std.testing.expectEqualStrings("key3", resource[2].key);
    try std.testing.expectEqualStrings("", resource[2].value.string);
}

test "buildFromConfig with every detector disabled" {
    const allocator = std.testing.allocator;

    var config = Configuration{
        .allocator = allocator,
        .sdk_disabled = false,
        .resource_detectors = .empty,
        .service_name = null,
        .resource_attributes = null,
        .log_level = .info,
        .trace_propagators = &.{},
        .trace_config = undefined,
        .metrics_config = undefined,
        .logs_config = undefined,
    };

    const resource = try buildFromConfig(allocator, &config);
    defer freeResource(allocator, resource);

    try std.testing.expectEqual(@as(usize, 0), resource.len);
}

test "buildFromConfig runs every detector by default" {
    const allocator = std.testing.allocator;

    var config = Configuration{
        .allocator = allocator,
        .sdk_disabled = false,
        .resource_detectors = .full,
        .service_name = null,
        .resource_attributes = null,
        .log_level = .info,
        .trace_propagators = &.{},
        .trace_config = undefined,
        .metrics_config = undefined,
        .logs_config = undefined,
    };

    const resource = try buildFromConfig(allocator, &config);
    defer freeResource(allocator, resource);

    try std.testing.expectEqual(detected_attributes.len, resource.len);
    try std.testing.expectEqualStrings(semconv.attribute.telemetry_sdk_name.name, resource[0].key);
    try std.testing.expectEqualStrings("opentelemetry", resource[0].value.string);
    try std.testing.expectEqualStrings(semconv.attribute.telemetry_sdk_language.name, resource[1].key);
    try std.testing.expectEqualStrings("zig", resource[1].value.string);
    try std.testing.expectEqualStrings(semconv.attribute.telemetry_sdk_version.name, resource[2].key);
    try std.testing.expectEqualStrings(semconv.attribute.os_type.name, resource[3].key);
    try std.testing.expectEqualStrings(os_type, resource[3].value.string);
    try std.testing.expectEqualStrings(semconv.attribute.host_arch.name, resource[4].key);
    try std.testing.expectEqualStrings(host_arch, resource[4].value.string);
    try std.testing.expectEqualStrings(semconv.attribute.process_runtime_name.name, resource[5].key);
    try std.testing.expectEqualStrings("zig", resource[5].value.string);
    try std.testing.expectEqualStrings(semconv.attribute.process_runtime_version.name, resource[6].key);
    try std.testing.expectEqualStrings(builtin.zig_version_string, resource[6].value.string);
}

test "buildFromConfig with a single detector opted out" {
    const allocator = std.testing.allocator;

    var config = Configuration{
        .allocator = allocator,
        .sdk_disabled = false,
        .resource_detectors = .init(.{ .host = true, .os = true, .process = true }),
        .service_name = null,
        .resource_attributes = null,
        .log_level = .info,
        .trace_propagators = &.{},
        .trace_config = undefined,
        .metrics_config = undefined,
        .logs_config = undefined,
    };

    const resource = try buildFromConfig(allocator, &config);
    defer freeResource(allocator, resource);

    try std.testing.expectEqual(@as(usize, 4), resource.len);
    try std.testing.expectEqualStrings(semconv.attribute.os_type.name, resource[0].key);
    try std.testing.expectEqualStrings(semconv.attribute.host_arch.name, resource[1].key);
    try std.testing.expectEqualStrings(semconv.attribute.process_runtime_name.name, resource[2].key);
}

test "buildFromConfig with a single detector opted in" {
    const allocator = std.testing.allocator;

    var config = Configuration{
        .allocator = allocator,
        .sdk_disabled = false,
        .resource_detectors = .initOne(.os),
        .service_name = null,
        .resource_attributes = null,
        .log_level = .info,
        .trace_propagators = &.{},
        .trace_config = undefined,
        .metrics_config = undefined,
        .logs_config = undefined,
    };

    const resource = try buildFromConfig(allocator, &config);
    defer freeResource(allocator, resource);

    try std.testing.expectEqual(@as(usize, 1), resource.len);
    try std.testing.expectEqualStrings(semconv.attribute.os_type.name, resource[0].key);
}

test "buildFromConfig adds an attribute when any of its tags is enabled" {
    const allocator = std.testing.allocator;

    var config = Configuration{
        .allocator = allocator,
        .sdk_disabled = false,
        .resource_detectors = .initOne(.@"comptime"),
        .service_name = null,
        .resource_attributes = null,
        .log_level = .info,
        .trace_propagators = &.{},
        .trace_config = undefined,
        .metrics_config = undefined,
        .logs_config = undefined,
    };

    const resource = try buildFromConfig(allocator, &config);
    defer freeResource(allocator, resource);

    // Every attribute is known at compile time for now.
    try std.testing.expectEqual(detected_attributes.len, resource.len);
}

test "detected attributes are tagged with their requirement level" {
    // The requirement levels of the resource definitions, which can differ from the registry's.
    const definitions = .{
        semconv.resource.telemetry_sdk_name,
        semconv.resource.telemetry_sdk_language,
        semconv.resource.telemetry_sdk_version,
        semconv.resource.os_type,
        semconv.resource.host_arch,
        semconv.resource.process_runtime_name,
        semconv.resource.process_runtime_version,
    };
    comptime std.debug.assert(definitions.len == detected_attributes.len);

    inline for (definitions, detected_attributes) |definition, line| {
        try std.testing.expectEqualStrings(definition.name, line.attribute.key);
        try std.testing.expectEqual(definition.requirement_level == .required, line.tags.contains(.required));
        try std.testing.expectEqual(definition.requirement_level == .recommended, line.tags.contains(.recommended));
    }
}

test "buildFromConfig with the required attributes only" {
    const allocator = std.testing.allocator;

    var config = Configuration{
        .allocator = allocator,
        .sdk_disabled = false,
        .resource_detectors = .initOne(.required),
        .service_name = null,
        .resource_attributes = null,
        .log_level = .info,
        .trace_propagators = &.{},
        .trace_config = undefined,
        .metrics_config = undefined,
        .logs_config = undefined,
    };

    const resource = try buildFromConfig(allocator, &config);
    defer freeResource(allocator, resource);

    try std.testing.expectEqual(@as(usize, 4), resource.len);
    try std.testing.expectEqualStrings(semconv.attribute.telemetry_sdk_name.name, resource[0].key);
    try std.testing.expectEqualStrings(semconv.attribute.telemetry_sdk_language.name, resource[1].key);
    try std.testing.expectEqualStrings(semconv.attribute.telemetry_sdk_version.name, resource[2].key);
    try std.testing.expectEqualStrings(semconv.attribute.os_type.name, resource[3].key);
}

test "OTEL_RESOURCE_ATTRIBUTES overrides detected attributes" {
    const allocator = std.testing.allocator;

    var config = Configuration{
        .allocator = allocator,
        .sdk_disabled = false,
        .resource_detectors = .init(.{ .os = true, .host = true }),
        .service_name = null,
        .resource_attributes = "os.type=custom",
        .log_level = .info,
        .trace_propagators = &.{},
        .trace_config = undefined,
        .metrics_config = undefined,
        .logs_config = undefined,
    };

    const resource = try buildFromConfig(allocator, &config);
    defer freeResource(allocator, resource);

    try std.testing.expectEqual(@as(usize, 2), resource.len);
    try std.testing.expectEqualStrings(semconv.attribute.os_type.name, resource[0].key);
    try std.testing.expectEqualStrings("custom", resource[0].value.string);
    try std.testing.expectEqualStrings(semconv.attribute.host_arch.name, resource[1].key);
    try std.testing.expectEqualStrings(host_arch, resource[1].value.string);
}

fn buildAndFreeResource(allocator: std.mem.Allocator, config: *const Configuration) !void {
    freeResource(allocator, try buildFromConfig(allocator, config));
}

test "buildFromConfig cleanup on allocation failure does not leak" {
    var config = Configuration{
        .allocator = std.testing.allocator,
        .sdk_disabled = false,
        .resource_detectors = .full,
        .service_name = "my-service",
        .resource_attributes = "key1=value1,os.type=custom",
        .log_level = .info,
        .trace_propagators = &.{},
        .trace_config = undefined,
        .metrics_config = undefined,
        .logs_config = undefined,
    };

    try std.testing.checkAllAllocationFailures(std.testing.allocator, buildAndFreeResource, .{&config});
}

test "OTEL_SERVICE_NAME overrides service.name from OTEL_RESOURCE_ATTRIBUTES" {
    const allocator = std.testing.allocator;

    var config = Configuration{
        .allocator = allocator,
        .sdk_disabled = false,
        .resource_detectors = .empty,
        .service_name = "override-service",
        .resource_attributes = "service.name=original-service,key1=value1",
        .log_level = .info,
        .trace_propagators = &.{},
        .trace_config = undefined,
        .metrics_config = undefined,
        .logs_config = undefined,
    };

    const resource = try buildFromConfig(allocator, &config);
    defer freeResource(allocator, resource);

    try std.testing.expectEqual(@as(usize, 2), resource.len);

    // service.name should be from OTEL_SERVICE_NAME
    try std.testing.expectEqualStrings(semconv.attribute.service_name.name, resource[0].key);
    try std.testing.expectEqualStrings("override-service", resource[0].value.string);

    // key1 should be from OTEL_RESOURCE_ATTRIBUTES
    try std.testing.expectEqualStrings("key1", resource[1].key);
    try std.testing.expectEqualStrings("value1", resource[1].value.string);
}

test "service.name from OTEL_RESOURCE_ATTRIBUTES when OTEL_SERVICE_NAME not set" {
    const allocator = std.testing.allocator;

    var config = Configuration{
        .allocator = allocator,
        .sdk_disabled = false,
        .resource_detectors = .empty,
        .service_name = null,
        .resource_attributes = "service.name=from-resource-attrs,key1=value1",
        .log_level = .info,
        .trace_propagators = &.{},
        .trace_config = undefined,
        .metrics_config = undefined,
        .logs_config = undefined,
    };

    const resource = try buildFromConfig(allocator, &config);
    defer freeResource(allocator, resource);

    try std.testing.expectEqual(@as(usize, 2), resource.len);

    // service.name should be from OTEL_RESOURCE_ATTRIBUTES
    try std.testing.expectEqualStrings(semconv.attribute.service_name.name, resource[0].key);
    try std.testing.expectEqualStrings("from-resource-attrs", resource[0].value.string);

    try std.testing.expectEqualStrings("key1", resource[1].key);
    try std.testing.expectEqualStrings("value1", resource[1].value.string);
}

test "service.name from OTEL_RESOURCE_ATTRIBUTES survives resource building" {
    const allocator = std.testing.allocator;

    var env_map = std.process.Environ.Map.init(allocator);
    defer env_map.deinit();
    try env_map.put("OTEL_RESOURCE_ATTRIBUTES", "service.name=checkout,host.name=server-1");
    // Keep the detectors out of the way, they have their own tests.
    try env_map.put("OTEL_EXPERIMENTAL_RESOURCE_DETECTORS", "none");

    const config = try Configuration.init(allocator, std.testing.io, &env_map);
    defer config.deinit();

    const resource = try buildFromConfig(allocator, config);
    defer freeResource(allocator, resource);

    // service.name is resolved once in the configuration, so it is emitted exactly once.
    try std.testing.expectEqual(@as(usize, 2), resource.len);
    try std.testing.expectEqualStrings(semconv.attribute.service_name.name, resource[0].key);
    try std.testing.expectEqualStrings("checkout", resource[0].value.string);
    try std.testing.expectEqualStrings(semconv.attribute.host_name.name, resource[1].key);
    try std.testing.expectEqualStrings("server-1", resource[1].value.string);
}

test "service.name defaults to unknown_service when nothing is configured" {
    const allocator = std.testing.allocator;

    var env_map = std.process.Environ.Map.init(allocator);
    defer env_map.deinit();
    // Keep the detectors out of the way, they have their own tests.
    try env_map.put("OTEL_EXPERIMENTAL_RESOURCE_DETECTORS", "none");

    const config = try Configuration.init(allocator, std.testing.io, &env_map);
    defer config.deinit();

    const resource = try buildFromConfig(allocator, config);
    defer freeResource(allocator, resource);

    try std.testing.expectEqual(@as(usize, 1), resource.len);
    try std.testing.expectEqualStrings(semconv.attribute.service_name.name, resource[0].key);
    try std.testing.expect(std.mem.startsWith(u8, resource[0].value.string, "unknown_service"));
}

test "mergeResources with distinct attributes" {
    const allocator = std.testing.allocator;

    const res1 = fromPairs(.{
        .{ semconv.attribute.service_name, "auth-service" },
        .{ semconv.attribute.service_version, "1.0.0" },
    });
    const res2 = fromPairs(.{
        .{ semconv.attribute.deployment_environment_name, "production" },
    });

    const merged = (try mergeResources(allocator, &res1, &res2)).?;
    defer freeResource(allocator, merged);

    try std.testing.expectEqual(@as(usize, 3), merged.len);
    try std.testing.expectEqualStrings(semconv.attribute.service_name.name, merged[0].key);
    try std.testing.expectEqualStrings("auth-service", merged[0].value.string);
    try std.testing.expectEqualStrings(semconv.attribute.service_version.name, merged[1].key);
    try std.testing.expectEqualStrings("1.0.0", merged[1].value.string);
    try std.testing.expectEqualStrings(semconv.attribute.deployment_environment_name.name, merged[2].key);
    try std.testing.expectEqualStrings("production", merged[2].value.string);
}

test "mergeResources deduplicates keys with res1 precedence" {
    const allocator = std.testing.allocator;

    const res1 = fromPairs(.{
        .{ semconv.attribute.service_name, "custom-service" },
        .{ semconv.attribute.host_name, "primary-host" },
    });
    const res2 = fromPairs(.{
        .{ semconv.attribute.service_name, "default-service" },
        .{ "region", "us-east-1" },
    });

    const merged = (try mergeResources(allocator, &res1, &res2)).?;
    defer freeResource(allocator, merged);

    try std.testing.expectEqual(@as(usize, 3), merged.len);
    try std.testing.expectEqualStrings(semconv.attribute.service_name.name, merged[0].key);
    try std.testing.expectEqualStrings("custom-service", merged[0].value.string);
    try std.testing.expectEqualStrings(semconv.attribute.host_name.name, merged[1].key);
    try std.testing.expectEqualStrings("primary-host", merged[1].value.string);
    try std.testing.expectEqualStrings("region", merged[2].key);
    try std.testing.expectEqualStrings("us-east-1", merged[2].value.string);
}

test "mergeResources with empty inputs" {
    const allocator = std.testing.allocator;

    const empty: []const Attribute = &.{};
    const merged = try mergeResources(allocator, empty, empty);
    try std.testing.expect(merged == null);
}

test "mergeResources cleanup on allocation failure does not leak" {
    const res1 = [_]Attribute{
        .{ .key = "k1", .value = .{ .string = "v1" } },
        .{ .key = "k2", .value = .{ .string = "v2" } },
    };
    const res2 = [_]Attribute{
        .{ .key = "k3", .value = .{ .string = "v3" } },
    };

    // Test failure at each allocation step to verify no memory leak occurs
    for (1..7) |fail_index| {
        var failing = std.testing.FailingAllocator.init(std.testing.allocator, .{
            .fail_index = fail_index,
        });
        const allocator = failing.allocator();

        _ = mergeResources(allocator, &res1, &res2) catch {};
    }
}

test "parseResourceAttributes percent-decodes keys and values" {
    const allocator = std.testing.allocator;

    var config = Configuration{
        .allocator = allocator,
        .sdk_disabled = false,
        .resource_detectors = .empty,
        .service_name = null,
        .resource_attributes = "deployment.environment.name=prod%20east,custom%2Etag=val%2C1,equation=a%3Db,path=%2Fvar%2Flog,math=1+1,literal%2=kept",
        .log_level = .info,
        .trace_propagators = &.{},
        .trace_config = undefined,
        .metrics_config = undefined,
        .logs_config = undefined,
    };

    const resource = try buildFromConfig(allocator, &config);
    defer freeResource(allocator, resource);

    try std.testing.expectEqual(@as(usize, 6), resource.len);
    try std.testing.expectEqualStrings(semconv.attribute.deployment_environment_name.name, resource[0].key);
    try std.testing.expectEqualStrings("prod east", resource[0].value.string);

    try std.testing.expectEqualStrings("custom.tag", resource[1].key);
    try std.testing.expectEqualStrings("val,1", resource[1].value.string);

    try std.testing.expectEqualStrings("equation", resource[2].key);
    try std.testing.expectEqualStrings("a=b", resource[2].value.string);

    try std.testing.expectEqualStrings("path", resource[3].key);
    try std.testing.expectEqualStrings("/var/log", resource[3].value.string);

    try std.testing.expectEqualStrings("math", resource[4].key);
    try std.testing.expectEqualStrings("1+1", resource[4].value.string);

    try std.testing.expectEqualStrings("literal%2", resource[5].key);
    try std.testing.expectEqualStrings("kept", resource[5].value.string);
}

test "service.name percent-decoded from OTEL_RESOURCE_ATTRIBUTES in Configuration.init" {
    const allocator = std.testing.allocator;

    var env_map = std.process.Environ.Map.init(allocator);
    defer env_map.deinit();
    try env_map.put("OTEL_RESOURCE_ATTRIBUTES", "service.name=my%20special%20service,host=localhost");
    // Keep the detectors out of the way, they have their own tests.
    try env_map.put("OTEL_EXPERIMENTAL_RESOURCE_DETECTORS", "none");

    const config = try Configuration.init(allocator, std.testing.io, &env_map);
    defer config.deinit();

    try std.testing.expectEqualStrings("my special service", config.service_name.?);

    const resource = try buildFromConfig(allocator, config);
    defer freeResource(allocator, resource);

    try std.testing.expectEqual(@as(usize, 2), resource.len);
    try std.testing.expectEqualStrings(semconv.attribute.service_name.name, resource[0].key);
    try std.testing.expectEqualStrings("my special service", resource[0].value.string);
    try std.testing.expectEqualStrings("host", resource[1].key);
    try std.testing.expectEqualStrings("localhost", resource[1].value.string);
}
