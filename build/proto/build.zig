const std = @import("std");
const protobuf = @import("protobuf");
const helpers = @import("../helpers.zig");

const BuildError = helpers.BuildError;
const BuildModules = helpers.BuildModules;
const CompilationInfo = helpers.CompilationInfo;

// Path of the vendored opentelemetry-proto module (generated bindings) relative to build.zig.
const proto_root = "opentelemetry-proto";

// OpenTelemetry proto definitions to generate Zig bindings from, relative to
// the opentelemetry_proto dependency root. Add entries here as the API grows.
const proto_files = [_][]const u8{
    // Signals
    "opentelemetry/proto/common/v1/common.proto",
    "opentelemetry/proto/resource/v1/resource.proto",
    "opentelemetry/proto/metrics/v1/metrics.proto",
    "opentelemetry/proto/trace/v1/trace.proto",
    "opentelemetry/proto/logs/v1/logs.proto",
    "opentelemetry/proto/profiles/v1development/profiles.proto",
    // Collector types for OTLP
    "opentelemetry/proto/collector/metrics/v1/metrics_service.proto",
    "opentelemetry/proto/collector/trace/v1/trace_service.proto",
    "opentelemetry/proto/collector/logs/v1/logs_service.proto",
    "opentelemetry/proto/collector/profiles/v1development/profiles_service.proto",
};

// Sets up the opentelemetry-proto module from the vendored generated bindings
// and registers its build steps. The created module is added to `dependencies`
// so other modules (e.g. the SDK) can import it.
pub fn Setup(
    b: *std.Build,
    info: CompilationInfo,
    dependencies: *BuildModules,
) !void {
    const protobuf_mod = dependencies.get("protobuf") orelse return BuildError.ModuleNotFound;

    const proto_mod = b.addModule("opentelemetry-proto", .{
        .root_source_file = b.path(proto_root ++ "/src/root.zig"),
        .target = info.target,
        .optimize = info.optimize,
        .imports = &.{
            .{ .name = "protobuf", .module = protobuf_mod },
        },
    });
    try dependencies.put("opentelemetry-proto", proto_mod);

    _ = try addTestStep(b, proto_mod);
    _ = addUpdateTagStep(b);
    try addGenerateStep(b, info);
}

// Registers the "proto-generate" step, regenerating the Zig bindings under
// src/ with protoc from the pinned opentelemetry_proto sources. Those sources
// are a lazy dependency (see build.zig.zon): Zig fetches them on demand the
// first time this step is configured. Bump the pin with "proto-update-tag".
fn addGenerateStep(b: *std.Build, info: CompilationInfo) !void {
    const step = b.step("proto-generate", "Regenerate proto bindings from the opentelemetry_proto sources (requires protoc)");

    // Null on the first pass: Zig fetches the lazy dep and re-runs the build.
    const proto_dep = b.lazyDependency("opentelemetry_proto", .{}) orelse return;

    var source_files: [proto_files.len]std.Build.LazyPath = undefined;
    for (&source_files, proto_files) |*src, rel| {
        src.* = proto_dep.path(rel);
    }

    // protoc code generation is driven by the protobuf dependency's builder.
    const protobuf_dep = b.dependency("protobuf", .{
        .target = info.target,
        .optimize = info.optimize,
    });
    const protoc_step = protobuf.RunProtocStep.create(protobuf_dep.builder, info.target, .{
        .destination_directory = b.path(proto_root ++ "/src"),
        .source_files = &source_files,
        .include_directories = &.{
            // Imports in proto files resolve against the dependency root.
            proto_dep.path("."),
        },
    });
    protoc_step.verbose = info.optimize == .Debug;

    step.dependOn(&protoc_step.step);
}

// Registers the "proto-update-tag" step, re-pinning the opentelemetry_proto
// dependency in build.zig.zon to a given tag (or the tracked branch, main).
// It shells out to `zig fetch --save`, which rewrites the url and hash.
// Regenerate the bindings from the updated pin afterwards (proto-generate).
fn addUpdateTagStep(b: *std.Build) *std.Build.Step {
    const tag = b.option([]const u8, "tag",
        \\Tag or ref of the OpenTelemetry proto repo to pin in build.zig.zon.
        \\If not set, the tracked branch (main) is used.
    ) orelse "main";

    const url = b.fmt("git+https://github.com/open-telemetry/opentelemetry-proto#{s}", .{tag});
    const fetch = b.addSystemCommand(&.{ b.graph.zig_exe, "fetch", "--save=opentelemetry_proto", url });

    const update_step = b.step("proto-update-tag", "Re-pin the opentelemetry_proto dependency in build.zig.zon to -Dtag (or main)");
    update_step.dependOn(&fetch.step);

    return update_step;
}

// Registers the "proto-test" step, building and running the proto unit tests.
fn addTestStep(b: *std.Build, proto_mod: *std.Build.Module) !*std.Build.Step {
    const step = b.step("proto-test", "Run opentelemetry-proto unit tests");

    const proto_tests = b.addTest(.{
        .root_module = proto_mod,
        .filters = b.args orelse &[0][]const u8{},
    });
    const run_proto_tests = b.addRunArtifact(proto_tests);
    step.dependOn(&run_proto_tests.step);

    return step;
}
