const std = @import("std");
const proto = @import("opentelemetry-proto");
const pbprofiles = proto.profiles_v1development;
const pbcollector_profiles = proto.collector_profiles_v1development;
const pbcommon = proto.common_v1;
const pbresource = proto.resource_v1;

const api = @import("../../api.zig");
const ProfileID = api.profiles.ProfileID;
const ValueType = api.profiles.ValueType;
const StackFrame = api.profiles.StackFrame;
const trace = api.trace;
const Attribute = @import("../../attributes.zig").Attribute;
const AttributeValue = @import("../../attributes.zig").AttributeValue;
const InstrumentationScope = @import("../../scope.zig").InstrumentationScope;

const FunctionKey = struct {
    name_strindex: i32,
    filename_strindex: i32,
    start_line: i64,
};

const LocationKey = struct {
    address: u64,
    function_index: i32,
    line: i64,
    column: i64,
};

const LinkKey = struct {
    trace_id: [16]u8,
    span_id: [8]u8,
};

const IntSliceContext = struct {
    pub fn hash(_: IntSliceContext, key: []const i32) u64 {
        return std.hash.Wyhash.hash(0, std.mem.sliceAsBytes(key));
    }
    pub fn eql(_: IntSliceContext, a: []const i32, b: []const i32) bool {
        return std.mem.eql(i32, a, b);
    }
};

const StackHashMapUnmanaged = std.HashMapUnmanaged([]const i32, i32, IntSliceContext, std.hash_map.default_max_load_percentage);

/// ProfileBuilder manages deduplication of strings, functions, locations, stacks,
/// and links into an OpenTelemetry ProfilesDictionary and builds OTLP ExportProfilesServiceRequests.
pub const ProfileBuilder = struct {
    backing_allocator: std.mem.Allocator,
    arena: std.heap.ArenaAllocator,

    // Tables in the ProfilesDictionary
    string_table: std.ArrayList([]const u8),
    function_table: std.ArrayList(pbprofiles.Function),
    location_table: std.ArrayList(pbprofiles.Location),
    stack_table: std.ArrayList(pbprofiles.Stack),
    mapping_table: std.ArrayList(pbprofiles.Mapping),
    link_table: std.ArrayList(pbprofiles.Link),
    attribute_table: std.ArrayList(pbprofiles.KeyValueAndUnit),

    // Deduplication lookup maps (Unmanaged to avoid capturing dangling arena pointers)
    string_map: std.StringHashMapUnmanaged(i32),
    func_map: std.AutoHashMapUnmanaged(FunctionKey, i32),
    loc_map: std.AutoHashMapUnmanaged(LocationKey, i32),
    stack_map: StackHashMapUnmanaged,
    link_map: std.AutoHashMapUnmanaged(LinkKey, i32),

    // Profile data
    samples: std.ArrayList(pbprofiles.Sample),
    profile_id: ProfileID,
    sample_type: ?ValueType = null,
    period_type: ?ValueType = null,
    period: i64 = 0,
    start_time_unix_nano: u64 = 0,
    duration_nano: u64 = 0,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator) !Self {
        var self = Self{
            .backing_allocator = allocator,
            .arena = std.heap.ArenaAllocator.init(allocator),
            .string_table = .empty,
            .function_table = .empty,
            .location_table = .empty,
            .stack_table = .empty,
            .mapping_table = .empty,
            .link_table = .empty,
            .attribute_table = .empty,
            .string_map = .empty,
            .func_map = .empty,
            .loc_map = .empty,
            .stack_map = .empty,
            .link_map = .empty,
            .samples = .empty,
            .profile_id = ProfileID.zero(),
        };

        try self.initZeroEntries();
        return self;
    }

    pub fn deinit(self: *Self) void {
        self.arena.deinit();
        self.* = undefined;
    }

    pub fn reset(self: *Self) !void {
        _ = self.arena.reset(.retain_capacity);

        self.string_table = .empty;
        self.function_table = .empty;
        self.location_table = .empty;
        self.stack_table = .empty;
        self.mapping_table = .empty;
        self.link_table = .empty;
        self.attribute_table = .empty;

        self.string_map = .empty;
        self.func_map = .empty;
        self.loc_map = .empty;
        self.stack_map = .empty;
        self.link_map = .empty;

        self.samples = .empty;
        self.profile_id = ProfileID.zero();
        self.sample_type = null;
        self.period_type = null;
        self.period = 0;
        self.start_time_unix_nano = 0;
        self.duration_nano = 0;

        try self.initZeroEntries();
    }

    fn initZeroEntries(self: *Self) !void {
        const arena_alloc = self.arena.allocator();

        // Index 0 in string_table MUST be ""
        try self.string_table.append(arena_alloc, "");
        try self.string_map.put(arena_alloc, "", 0);

        // Index 0 in all other tables MUST be the zero-value message
        try self.function_table.append(arena_alloc, pbprofiles.Function{});
        try self.location_table.append(arena_alloc, pbprofiles.Location{});
        try self.stack_table.append(arena_alloc, pbprofiles.Stack{});
        try self.mapping_table.append(arena_alloc, pbprofiles.Mapping{});
        try self.link_table.append(arena_alloc, pbprofiles.Link{});
        try self.attribute_table.append(arena_alloc, pbprofiles.KeyValueAndUnit{});
    }

    pub fn setSampleType(self: *Self, type_name: []const u8, unit: []const u8) void {
        self.sample_type = .{ .type_name = type_name, .unit = unit };
    }

    pub fn setPeriod(self: *Self, period: i64, type_name: []const u8, unit: []const u8) void {
        self.period = period;
        self.period_type = .{ .type_name = type_name, .unit = unit };
    }

    pub fn setProfileID(self: *Self, id: ProfileID) void {
        self.profile_id = id;
    }

    pub fn setTimestamps(self: *Self, start_time_unix_nano: u64, duration_nano: u64) void {
        self.start_time_unix_nano = start_time_unix_nano;
        self.duration_nano = duration_nano;
    }

    pub fn internString(self: *Self, str: []const u8) !i32 {
        if (self.string_map.get(str)) |idx| {
            return idx;
        }
        const arena_alloc = self.arena.allocator();
        const duped = try arena_alloc.dupe(u8, str);
        const idx: i32 = @intCast(self.string_table.items.len);
        try self.string_table.append(arena_alloc, duped);
        try self.string_map.put(arena_alloc, duped, idx);
        return idx;
    }

    pub fn internFunction(self: *Self, name: []const u8, filename: []const u8, start_line: i64) !i32 {
        const name_idx = try self.internString(name);
        const file_idx = if (filename.len > 0) try self.internString(filename) else 0;
        const key = FunctionKey{
            .name_strindex = name_idx,
            .filename_strindex = file_idx,
            .start_line = start_line,
        };
        if (self.func_map.get(key)) |idx| {
            return idx;
        }
        const arena_alloc = self.arena.allocator();
        const idx: i32 = @intCast(self.function_table.items.len);
        try self.function_table.append(arena_alloc, pbprofiles.Function{
            .name_strindex = name_idx,
            .filename_strindex = file_idx,
            .start_line = start_line,
        });
        try self.func_map.put(arena_alloc, key, idx);
        return idx;
    }

    pub fn internLocation(self: *Self, address: u64, func_idx: ?i32, line: i64, column: i64) !i32 {
        const f_idx = func_idx orelse 0;
        const key = LocationKey{
            .address = address,
            .function_index = f_idx,
            .line = line,
            .column = column,
        };
        if (self.loc_map.get(key)) |idx| {
            return idx;
        }
        const arena_alloc = self.arena.allocator();
        const idx: i32 = @intCast(self.location_table.items.len);
        var lines: std.ArrayList(pbprofiles.Line) = .empty;
        if (f_idx > 0 or line > 0 or column > 0) {
            try lines.append(arena_alloc, pbprofiles.Line{
                .function_index = f_idx,
                .line = line,
                .column = column,
            });
        }
        try self.location_table.append(arena_alloc, pbprofiles.Location{
            .address = address,
            .lines = lines,
        });
        try self.loc_map.put(arena_alloc, key, idx);
        return idx;
    }

    pub fn internStack(self: *Self, location_indices: []const i32) !i32 {
        if (location_indices.len == 0) return 0;
        if (self.stack_map.get(location_indices)) |idx| {
            return idx;
        }
        const arena_alloc = self.arena.allocator();
        const duped = try arena_alloc.dupe(i32, location_indices);
        const idx: i32 = @intCast(self.stack_table.items.len);
        var loc_list: std.ArrayList(i32) = .empty;
        try loc_list.ensureTotalCapacityPrecise(arena_alloc, duped.len);
        for (duped) |l_idx| {
            loc_list.appendAssumeCapacity(l_idx);
        }
        try self.stack_table.append(arena_alloc, pbprofiles.Stack{
            .location_indices = loc_list,
        });
        try self.stack_map.put(arena_alloc, duped, idx);
        return idx;
    }

    pub fn internLink(self: *Self, trace_id: ?[16]u8, span_id: ?[8]u8) !i32 {
        const tid = trace_id orelse @as([16]u8, @splat(0));
        const sid = span_id orelse @as([8]u8, @splat(0));

        var all_zero = true;
        for (tid) |b| {
            if (b != 0) {
                all_zero = false;
                break;
            }
        }
        if (all_zero) {
            for (sid) |b| {
                if (b != 0) {
                    all_zero = false;
                    break;
                }
            }
        }
        if (all_zero) return 0;

        const key = LinkKey{ .trace_id = tid, .span_id = sid };
        if (self.link_map.get(key)) |idx| {
            return idx;
        }
        const arena_alloc = self.arena.allocator();
        const idx: i32 = @intCast(self.link_table.items.len);
        const duped_trace = try arena_alloc.dupe(u8, &tid);
        const duped_span = try arena_alloc.dupe(u8, &sid);
        try self.link_table.append(arena_alloc, pbprofiles.Link{
            .trace_id = duped_trace,
            .span_id = duped_span,
        });
        try self.link_map.put(arena_alloc, key, idx);
        return idx;
    }

    pub fn internAttribute(self: *Self, key: []const u8, val: AttributeValue, unit: []const u8) !i32 {
        const key_idx = try self.internString(key);
        const unit_idx = if (unit.len > 0) try self.internString(unit) else 0;
        const arena_alloc = self.arena.allocator();

        const any_val: ?pbcommon.AnyValue = switch (val) {
            .string => |v| .{ .value = .{ .string_value = try arena_alloc.dupe(u8, v) } },
            .bool => |v| .{ .value = .{ .bool_value = v } },
            .int => |v| .{ .value = .{ .int_value = v } },
            .double => |v| .{ .value = .{ .double_value = v } },
            .baggage => .{ .value = .{ .string_value = &.{} } },
        };

        const idx: i32 = @intCast(self.attribute_table.items.len);
        try self.attribute_table.append(arena_alloc, pbprofiles.KeyValueAndUnit{
            .key_strindex = key_idx,
            .value = any_val,
            .unit_strindex = unit_idx,
        });
        return idx;
    }

    pub fn addSample(
        self: *Self,
        stack_idx: i32,
        values: []const i64,
        timestamps_unix_nano: []const u64,
        link_idx: ?i32,
    ) !void {
        const arena_alloc = self.arena.allocator();
        var val_list: std.ArrayList(i64) = .empty;
        if (values.len > 0) {
            try val_list.ensureTotalCapacityPrecise(arena_alloc, values.len);
            for (values) |v| val_list.appendAssumeCapacity(v);
        }

        var ts_list: std.ArrayList(u64) = .empty;
        if (timestamps_unix_nano.len > 0) {
            try ts_list.ensureTotalCapacityPrecise(arena_alloc, timestamps_unix_nano.len);
            for (timestamps_unix_nano) |ts| ts_list.appendAssumeCapacity(ts);
        }

        try self.samples.append(arena_alloc, pbprofiles.Sample{
            .stack_index = stack_idx,
            .link_index = link_idx orelse 0,
            .values = val_list,
            .timestamps_unix_nano = ts_list,
        });
    }

    pub fn addStackSample(
        self: *Self,
        frames: []const StackFrame,
        values: []const i64,
        timestamp_unix_nano: ?u64,
        trace_id: ?[16]u8,
        span_id: ?[8]u8,
    ) !void {
        const arena_alloc = self.arena.allocator();
        const loc_indices = try arena_alloc.alloc(i32, frames.len);
        for (frames, 0..) |frame, i| {
            const func_idx = try self.internFunction(frame.function_name, frame.filename, frame.line);
            loc_indices[i] = try self.internLocation(frame.address, func_idx, frame.line, frame.column);
        }
        const stack_idx = try self.internStack(loc_indices);
        const link_idx = try self.internLink(trace_id, span_id);

        const ts_slice = if (timestamp_unix_nano) |ts| &[_]u64{ts} else &[_]u64{};
        try self.addSample(stack_idx, values, ts_slice, if (link_idx > 0) link_idx else null);
    }

    pub fn addStackSampleWithSpanContext(
        self: *Self,
        frames: []const StackFrame,
        values: []const i64,
        timestamp_unix_nano: ?u64,
        span_context: ?trace.SpanContext,
    ) !void {
        if (span_context) |sc| {
            if (sc.isValid()) {
                return self.addStackSample(
                    frames,
                    values,
                    timestamp_unix_nano,
                    sc.getTraceId().toBinary(),
                    sc.getSpanId().value,
                );
            }
        }
        return self.addStackSample(frames, values, timestamp_unix_nano, null, null);
    }

    pub fn build(
        self: *Self,
        resource_attrs: ?[]const Attribute,
        scope_info: ?InstrumentationScope,
    ) !pbcollector_profiles.ExportProfilesServiceRequest {
        const arena_alloc = self.arena.allocator();

        var profile = pbprofiles.Profile{
            .time_unix_nano = self.start_time_unix_nano,
            .duration_nano = self.duration_nano,
            .period = self.period,
            .profile_id = try arena_alloc.dupe(u8, &self.profile_id.value),
            .samples = self.samples,
        };

        if (self.sample_type) |st| {
            const type_idx = try self.internString(st.type_name);
            const unit_idx = try self.internString(st.unit);
            profile.sample_type = pbprofiles.ValueType{
                .type_strindex = type_idx,
                .unit_strindex = unit_idx,
            };
        }

        if (self.period_type) |pt| {
            const type_idx = try self.internString(pt.type_name);
            const unit_idx = try self.internString(pt.unit);
            profile.period_type = pbprofiles.ValueType{
                .type_strindex = type_idx,
                .unit_strindex = unit_idx,
            };
        }

        var profiles_list: std.ArrayList(pbprofiles.Profile) = .empty;
        try profiles_list.append(arena_alloc, profile);

        var scope_profiles_list: std.ArrayList(pbprofiles.ScopeProfiles) = .empty;
        const scope_profile = pbprofiles.ScopeProfiles{
            .scope = if (scope_info) |si|
                pbcommon.InstrumentationScope{
                    .name = try arena_alloc.dupe(u8, si.name),
                    .version = if (si.version) |v| try arena_alloc.dupe(u8, v) else &.{},
                }
            else
                null,
            .profiles = profiles_list,
        };
        try scope_profiles_list.append(arena_alloc, scope_profile);

        var resource_attributes: std.ArrayList(pbcommon.KeyValue) = .empty;
        if (resource_attrs) |attrs| {
            try resource_attributes.ensureTotalCapacityPrecise(arena_alloc, attrs.len);
            for (attrs) |attr| {
                const any_val: ?pbcommon.AnyValue = switch (attr.value) {
                    .string => |v| .{ .value = .{ .string_value = try arena_alloc.dupe(u8, v) } },
                    .bool => |v| .{ .value = .{ .bool_value = v } },
                    .int => |v| .{ .value = .{ .int_value = v } },
                    .double => |v| .{ .value = .{ .double_value = v } },
                    .baggage => .{ .value = .{ .string_value = &.{} } },
                };
                resource_attributes.appendAssumeCapacity(.{
                    .key = try arena_alloc.dupe(u8, attr.key),
                    .value = any_val,
                });
            }
        }

        var resource_profiles_list: std.ArrayList(pbprofiles.ResourceProfiles) = .empty;
        try resource_profiles_list.append(arena_alloc, pbprofiles.ResourceProfiles{
            .resource = if (resource_attrs != null)
                pbresource.Resource{
                    .attributes = resource_attributes,
                }
            else
                null,
            .scope_profiles = scope_profiles_list,
        });

        const dictionary = pbprofiles.ProfilesDictionary{
            .string_table = self.string_table,
            .function_table = self.function_table,
            .location_table = self.location_table,
            .stack_table = self.stack_table,
            .link_table = self.link_table,
            .mapping_table = self.mapping_table,
            .attribute_table = self.attribute_table,
        };

        return pbcollector_profiles.ExportProfilesServiceRequest{
            .resource_profiles = resource_profiles_list,
            .dictionary = dictionary,
        };
    }
};

test "ProfileBuilder dictionary indexing and deduplication" {
    const allocator = std.testing.allocator;

    var builder = try ProfileBuilder.init(allocator);
    defer builder.deinit();

    // Verify index 0 for all tables
    try std.testing.expectEqualStrings("", builder.string_table.items[0]);
    try std.testing.expectEqual(@as(usize, 1), builder.string_table.items.len);
    try std.testing.expectEqual(@as(usize, 1), builder.function_table.items.len);
    try std.testing.expectEqual(@as(usize, 1), builder.location_table.items.len);
    try std.testing.expectEqual(@as(usize, 1), builder.stack_table.items.len);
    try std.testing.expectEqual(@as(usize, 1), builder.link_table.items.len);
    try std.testing.expectEqual(@as(usize, 1), builder.attribute_table.items.len);

    // Test string deduplication
    const s1 = try builder.internString("alloc_space");
    const s2 = try builder.internString("bytes");
    const s3 = try builder.internString("alloc_space"); // should deduplicate
    try std.testing.expectEqual(@as(i32, 1), s1);
    try std.testing.expectEqual(@as(i32, 2), s2);
    try std.testing.expectEqual(s1, s3);
    try std.testing.expectEqual(@as(usize, 3), builder.string_table.items.len);

    // Test function deduplication
    const f1 = try builder.internFunction("main", "src/main.zig", 10);
    const f2 = try builder.internFunction("alloc", "src/mem.zig", 50);
    const f3 = try builder.internFunction("main", "src/main.zig", 10); // should deduplicate
    try std.testing.expectEqual(@as(i32, 1), f1);
    try std.testing.expectEqual(@as(i32, 2), f2);
    try std.testing.expectEqual(f1, f3);

    // Test location deduplication
    const l1 = try builder.internLocation(0x1000, f1, 12, 5);
    const l2 = try builder.internLocation(0x2000, f2, 55, 1);
    const l3 = try builder.internLocation(0x1000, f1, 12, 5); // should deduplicate
    try std.testing.expectEqual(@as(i32, 1), l1);
    try std.testing.expectEqual(@as(i32, 2), l2);
    try std.testing.expectEqual(l1, l3);

    // Test stack deduplication
    const stack_indices = [_]i32{ l2, l1 };
    const st1 = try builder.internStack(&stack_indices);
    const st2 = try builder.internStack(&stack_indices); // should deduplicate
    try std.testing.expectEqual(@as(i32, 1), st1);
    try std.testing.expectEqual(st1, st2);

    // Test link deduplication
    const tid = [16]u8{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 };
    const sid = [8]u8{ 9, 8, 7, 6, 5, 4, 3, 2 };
    const link1 = try builder.internLink(tid, sid);
    const link2 = try builder.internLink(tid, sid); // should deduplicate
    try std.testing.expectEqual(@as(i32, 1), link1);
    try std.testing.expectEqual(link1, link2);

    // Test sample adding and build
    builder.setSampleType("alloc_space", "bytes");
    builder.setPeriod(1, "count", "samples");
    builder.setTimestamps(1000, 500);

    try builder.addSample(st1, &[_]i64{1024}, &[_]u64{1050}, link1);

    const resource_attrs = [_]Attribute{
        .{ .key = "service.name", .value = .{ .string = "test-service" } },
    };
    const req = try builder.build(&resource_attrs, .{ .name = "test-scope" });

    try std.testing.expect(req.dictionary != null);
    try std.testing.expectEqual(@as(usize, 1), req.resource_profiles.items.len);
    const res_prof = req.resource_profiles.items[0];
    try std.testing.expect(res_prof.resource != null);
    try std.testing.expectEqualStrings("service.name", res_prof.resource.?.attributes.items[0].key);

    const scope_prof = res_prof.scope_profiles.items[0];
    try std.testing.expectEqualStrings("test-scope", scope_prof.scope.?.name);
    try std.testing.expectEqual(@as(usize, 1), scope_prof.profiles.items.len);

    const prof = scope_prof.profiles.items[0];
    try std.testing.expectEqual(@as(usize, 1), prof.samples.items.len);
    try std.testing.expectEqual(@as(i32, 1), prof.samples.items[0].stack_index);
    try std.testing.expectEqual(@as(i64, 1024), prof.samples.items[0].values.items[0]);
    try std.testing.expectEqual(@as(i32, 1), prof.samples.items[0].link_index);
}

test "ProfileBuilder addStackSample with SpanContext and reset" {
    const allocator = std.testing.allocator;

    var builder = try ProfileBuilder.init(allocator);
    defer builder.deinit();

    const frames = [_]StackFrame{
        .{
            .function_name = "calculate",
            .filename = "src/math.zig",
            .line = 42,
            .column = 8,
            .address = 0x401000,
        },
        .{
            .function_name = "main",
            .filename = "src/main.zig",
            .line = 10,
            .column = 4,
            .address = 0x400500,
        },
    };

    const tid = trace.TraceID.init([16]u8{ 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4 });
    const sid = trace.SpanID.init([8]u8{ 5, 5, 5, 5, 6, 6, 6, 6 });
    var ts = trace.TraceState.init(allocator);
    defer ts.deinit();
    const sc = trace.SpanContext.init(tid, sid, trace.TraceFlags.sampled(), ts, false);

    try builder.addStackSampleWithSpanContext(&frames, &[_]i64{256}, 2000, sc);

    const req = try builder.build(null, null);
    try std.testing.expectEqual(@as(usize, 1), req.resource_profiles.items.len);
    const prof = req.resource_profiles.items[0].scope_profiles.items[0].profiles.items[0];
    try std.testing.expectEqual(@as(usize, 1), prof.samples.items.len);
    try std.testing.expect(prof.samples.items[0].link_index > 0);

    // Verify reset clears data and retains index 0 defaults
    try builder.reset();
    try std.testing.expectEqual(@as(usize, 1), builder.string_table.items.len);
    try std.testing.expectEqual(@as(usize, 0), builder.samples.items.len);
}
