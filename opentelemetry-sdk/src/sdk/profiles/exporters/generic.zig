const std = @import("std");
const ProfileExporter = @import("../profile_exporter.zig").ProfileExporter;
const proto = @import("opentelemetry-proto");
const pbcollector_profiles = proto.collector_profiles_v1development;

/// InMemoryProfileExporter records exported profile batches in-memory for testing and inspection.
pub const InMemoryProfileExporter = struct {
    allocator: std.mem.Allocator,
    export_count: usize = 0,
    sample_count: usize = 0,
    last_profile_id: [16]u8 = @splat(0),

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator) Self {
        return .{
            .allocator = allocator,
        };
    }

    pub fn deinit(_: *Self) void {}

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
        self.export_count += 1;

        for (request.resource_profiles.items) |res_prof| {
            for (res_prof.scope_profiles.items) |scope_prof| {
                for (scope_prof.profiles.items) |prof| {
                    self.sample_count += prof.samples.items.len;
                    if (prof.profile_id.len == 16) {
                        @memcpy(&self.last_profile_id, prof.profile_id[0..16]);
                    }
                }
            }
        }
    }

    fn shutdown(_: *anyopaque) anyerror!void {
        return;
    }
};

test "InMemoryProfileExporter counts exports and samples" {
    const allocator = std.testing.allocator;
    var exporter = InMemoryProfileExporter.init(allocator);
    defer exporter.deinit();

    const prof_exporter = exporter.asProfileExporter();

    var dummy_req = pbcollector_profiles.ExportProfilesServiceRequest{};
    try prof_exporter.exportProfiles(&dummy_req);
    try std.testing.expectEqual(@as(usize, 1), exporter.export_count);
    try std.testing.expectEqual(@as(usize, 0), exporter.sample_count);
}
