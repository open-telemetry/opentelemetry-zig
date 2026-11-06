const std = @import("std");
const proto = @import("opentelemetry-proto");
const pbcollector_profiles = proto.collector_profiles_v1development;

/// ProfileExporter defines the interface that protocol-specific exporters must implement.
/// see: https://opentelemetry.io/docs/specs/otel/profiles/
pub const ProfileExporter = struct {
    ptr: *anyopaque,
    vtable: *const VTable,

    const Self = @This();

    pub const VTable = struct {
        exportProfilesFn: *const fn (
            ctx: *anyopaque,
            request: *pbcollector_profiles.ExportProfilesServiceRequest,
        ) anyerror!void,
        shutdownFn: *const fn (ctx: *anyopaque) anyerror!void,
    };

    pub fn exportProfiles(
        self: Self,
        request: *pbcollector_profiles.ExportProfilesServiceRequest,
    ) anyerror!void {
        return self.vtable.exportProfilesFn(self.ptr, request);
    }

    pub fn shutdown(self: Self) anyerror!void {
        return self.vtable.shutdownFn(self.ptr);
    }
};

test "ProfileExporter interface call dispatch" {
    const MockExporter = struct {
        exported: usize = 0,
        shut_down: bool = false,

        pub fn exportProfiles(
            ctx: *anyopaque,
            _: *pbcollector_profiles.ExportProfilesServiceRequest,
        ) anyerror!void {
            const self: *@This() = @ptrCast(@alignCast(ctx));
            self.exported += 1;
        }

        pub fn shutdown(ctx: *anyopaque) anyerror!void {
            const self: *@This() = @ptrCast(@alignCast(ctx));
            self.shut_down = true;
        }

        pub fn asProfileExporter(self: *@This()) ProfileExporter {
            return .{
                .ptr = self,
                .vtable = &.{
                    .exportProfilesFn = exportProfiles,
                    .shutdownFn = shutdown,
                },
            };
        }
    };

    var mock = MockExporter{};
    const exporter = mock.asProfileExporter();

    var dummy_req = pbcollector_profiles.ExportProfilesServiceRequest{};
    try exporter.exportProfiles(&dummy_req);
    try std.testing.expectEqual(@as(usize, 1), mock.exported);

    try exporter.shutdown();
    try std.testing.expect(mock.shut_down);
}
