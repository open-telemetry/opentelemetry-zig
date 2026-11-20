const std = @import("std");
const ProfileExporter = @import("profile_exporter.zig").ProfileExporter;
const proto = @import("opentelemetry-proto");
const pbcollector_profiles = proto.collector_profiles_v1development;

/// ProfileProcessor allows hooks for processing and exporting profiles.
pub const ProfileProcessor = struct {
    ptr: *anyopaque,
    vtable: *const VTable,

    const Self = @This();

    pub const VTable = struct {
        onProfileFn: *const fn (
            ctx: *anyopaque,
            request: *pbcollector_profiles.ExportProfilesServiceRequest,
        ) anyerror!void,
        shutdownFn: *const fn (ctx: *anyopaque) anyerror!void,
        forceFlushFn: *const fn (ctx: *anyopaque) anyerror!void,
    };

    pub fn onProfile(
        self: Self,
        request: *pbcollector_profiles.ExportProfilesServiceRequest,
    ) anyerror!void {
        return self.vtable.onProfileFn(self.ptr, request);
    }

    pub fn shutdown(self: Self) anyerror!void {
        return self.vtable.shutdownFn(self.ptr);
    }

    pub fn forceFlush(self: Self) anyerror!void {
        return self.vtable.forceFlushFn(self.ptr);
    }
};

/// SimpleProfileProcessor synchronously passes profiles to the configured exporter.
pub const SimpleProfileProcessor = struct {
    exporter: ProfileExporter,

    const Self = @This();

    pub fn init(exporter: ProfileExporter) Self {
        return .{
            .exporter = exporter,
        };
    }

    pub fn asProfileProcessor(self: *Self) ProfileProcessor {
        return ProfileProcessor{
            .ptr = self,
            .vtable = &.{
                .onProfileFn = onProfile,
                .shutdownFn = shutdown,
                .forceFlushFn = forceFlush,
            },
        };
    }

    fn onProfile(
        ctx: *anyopaque,
        request: *pbcollector_profiles.ExportProfilesServiceRequest,
    ) anyerror!void {
        const self: *Self = @ptrCast(@alignCast(ctx));
        return self.exporter.exportProfiles(request);
    }

    fn shutdown(ctx: *anyopaque) anyerror!void {
        const self: *Self = @ptrCast(@alignCast(ctx));
        return self.exporter.shutdown();
    }

    fn forceFlush(_: *anyopaque) anyerror!void {
        return;
    }
};

test "SimpleProfileProcessor exports synchronously" {
    const MockExporter = struct {
        count: usize = 0,

        pub fn exportProfiles(
            ctx: *anyopaque,
            _: *pbcollector_profiles.ExportProfilesServiceRequest,
        ) anyerror!void {
            const self: *@This() = @ptrCast(@alignCast(ctx));
            self.count += 1;
        }

        pub fn shutdown(_: *anyopaque) anyerror!void {}

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
    var processor = SimpleProfileProcessor.init(mock.asProfileExporter());
    const proc = processor.asProfileProcessor();

    var dummy_req = pbcollector_profiles.ExportProfilesServiceRequest{};
    try proc.onProfile(&dummy_req);
    try std.testing.expectEqual(@as(usize, 1), mock.count);

    try proc.forceFlush();
    try proc.shutdown();
}
