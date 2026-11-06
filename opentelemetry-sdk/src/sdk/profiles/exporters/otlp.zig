const std = @import("std");
const ProfileExporter = @import("../profile_exporter.zig").ProfileExporter;
const otlp = @import("../../../otlp.zig");
const proto = @import("opentelemetry-proto");
const pbcollector_profiles = proto.collector_profiles_v1development;

/// OTLPProfileExporter exports profile data using the OpenTelemetry Protocol (OTLP).
pub const OTLPProfileExporter = struct {
    allocator: std.mem.Allocator,
    io: std.Io,
    config: *otlp.ConfigOptions,

    const Self = @This();

    pub fn init(
        allocator: std.mem.Allocator,
        io: std.Io,
        config: *otlp.ConfigOptions,
    ) !*Self {
        const self = try allocator.create(Self);
        self.* = Self{
            .allocator = allocator,
            .io = io,
            .config = config,
        };
        return self;
    }

    pub fn deinit(self: *Self) void {
        self.allocator.destroy(self);
    }

    pub fn asProfileExporter(self: *Self) ProfileExporter {
        return ProfileExporter{
            .ptr = self,
            .vtable = &.{
                .exportProfilesFn = exportProfiles,
                .shutdownFn = shutdown,
            },
        };
    }

    fn exportProfiles(
        ctx: *anyopaque,
        request: *pbcollector_profiles.ExportProfilesServiceRequest,
    ) anyerror!void {
        const self: *Self = @ptrCast(@alignCast(ctx));
        const otlp_data = otlp.Signal.Data{ .profiles = request.* };
        return otlp.Export(self.allocator, self.io, self.config, otlp_data);
    }

    fn shutdown(_: *anyopaque) anyerror!void {
        return;
    }
};

test "OTLPProfileExporter initialization" {
    const allocator = std.testing.allocator;
    const io = std.testing.io;

    var env_map = std.process.Environ.Map.init(allocator);
    defer env_map.deinit();

    var config = try otlp.ConfigOptions.init(allocator, &env_map);
    defer config.deinit();

    var exporter = try OTLPProfileExporter.init(allocator, io, config);
    defer exporter.deinit();

    const prof_exporter = exporter.asProfileExporter();
    try prof_exporter.shutdown();
}
