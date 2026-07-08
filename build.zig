const std = @import("std");
const zon = @import("build.zig.zon");
const helpers = @import("build/sdk/helpers.zig");

const sdk_root = "opentelemetry-sdk";

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{ .preferred_optimize_mode = .ReleaseSafe });

    const test_verbose = b.option(bool, "test-verbose", "Show verbose test output") orelse false;
    const test_fail_first = b.option(bool, "test-fail-first", "Stop on first test failure") orelse false;
    const test_show_logs = b.option(bool, "test-show-logs", "Show captured log output for tests") orelse false;
    const benchmark_output = b.option([]const u8, "benchmark-output", "Path to write benchmark results to a file");
    const benchmark_debug = b.option(bool, "benchmark-debug", "Enable debug build mode for benchmarks") orelse false;

    // Dependencies section
    // Benchmarks lib
    const benchmarks_dep = b.dependency("zbench", .{});

    // OpenTelemetry proto package ships protobuf as a dependency so we'll use it.
    const otel_pb_dep = b.dependency("opentelemetry_proto", .{
        .optimize = optimize,
        .target = target,
    });
    const otel_proto_mod = otel_pb_dep.module("opentelemetry-proto");
    const protobuf_mod = otel_pb_dep.builder.dependency("protobuf", .{
        .optimize = optimize,
        .target = target,
    }).module("protobuf");
    const clock_mod = b.addModule("clock", .{
        .root_source_file = b.path(sdk_root ++ "/src/clock.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    // Modules section
    const sdk_mod = b.addModule("sdk", .{
        .root_source_file = b.path(sdk_root ++ "/src/sdk.zig"),
        .target = target,
        .optimize = optimize,
        .strip = false,
        .unwind_tables = .sync,
        .link_libc = true,
        .imports = &.{
            .{ .name = "protobuf", .module = protobuf_mod },
            .{ .name = "opentelemetry-proto", .module = otel_proto_mod },
            .{ .name = "clock", .module = clock_mod },
        },
    });

    { // Build info
        const build_info = b.addOptions();
        build_info.addOption([]const u8, "version", zon.version);
        build_info.addOption([]const u8, "name", @tagName(zon.name));
        sdk_mod.addOptions("build_info", build_info);
    }

    // Static library for the OpenTelemetry SDK C users
    const sdk_c_lib_mod = b.createModule(.{
        .root_source_file = b.path(sdk_root ++ "/src/c.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .imports = &.{
            .{ .name = "protobuf", .module = protobuf_mod },
            .{ .name = "opentelemetry-proto", .module = otel_proto_mod },
            .{ .name = "clock", .module = clock_mod },
        },
    });
    const sdk_lib = b.addLibrary(.{
        .name = "opentelemetry-sdk",
        .linkage = .static,
        .root_module = sdk_c_lib_mod,
    });

    b.installArtifact(sdk_lib);

    // Install include headers for C users
    b.installDirectory(.{
        .source_dir = b.path(sdk_root ++ "/include"),
        .install_dir = .header,
        .install_subdir = "",
    });

    // Providing a way for the user to request running the unit tests.
    const test_step = b.step("test", "Run unit tests");

    // Creates a step for unit testing the SDK.
    // This only builds the test executable but does not run it.
    const sdk_unit_tests = b.addTest(.{
        .root_module = sdk_mod,
        // Use custom test runner to capture log output
        .test_runner = .{ .path = b.path(sdk_root ++ "/src/test_runner.zig"), .mode = .simple },
        // Allow passing test filter using the build args.
        .filters = b.args orelse &[0][]const u8{},
    });

    // Pass test options as build options
    const test_options = b.addOptions();
    test_options.addOption(bool, "verbose", test_verbose);
    test_options.addOption(bool, "fail_first", test_fail_first);
    test_options.addOption(bool, "show_logs", test_show_logs);
    sdk_unit_tests.root_module.addOptions("test_options", test_options);

    const run_sdk_unit_tests = b.addRunArtifact(sdk_unit_tests);
    test_step.dependOn(&run_sdk_unit_tests.step);

    // Examples
    const examples_step = b.step("examples", "Build and run all examples");
    const examples_filter = b.option([]const u8, "examples-filter", "Filter examples to build");

    // Attach an OTLP stub module to allow examples to use it.
    const otel_stub_mod = b.createModule(.{
        .root_source_file = b.path(sdk_root ++ "/examples/otlp_stub/server.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "opentelemetry-sdk", .module = sdk_mod },
            .{ .name = "protobuf", .module = protobuf_mod },
            .{ .name = "opentelemetry-proto", .module = otel_proto_mod },
        },
    });
    // TODO add examples for other signals

    const examples_dirs: []const []const u8 = &.{ "metrics", "trace", "logs", "baggage", "propagation" };
    for (examples_dirs) |example_dir| {
        const example = helpers.buildExamples(
            b,
            b.path(b.pathJoin(&.{ sdk_root, "examples", example_dir })),
            sdk_mod,
            otel_stub_mod,
            otel_proto_mod,
            clock_mod,
            examples_filter,
        ) catch |err| {
            std.debug.print("Error building metrics examples: {}\n", .{err});
            return err;
        };
        defer b.allocator.free(example);
        for (example) |step| {
            const run_example = b.addRunArtifact(step);
            examples_step.dependOn(&run_example.step);
        }
    }

    // C examples
    const c_example_step = b.step("examples-c", "Build and run C examples");

    const c_examples = [_][]const u8{
        "logs",
        "metrics",
        "trace",
    };

    for (c_examples) |example_name| {
        const c_example_exe = b.addExecutable(.{
            .name = example_name,
            .root_module = b.createModule(.{
                .target = target,
                .optimize = optimize,
                .link_libc = true,
            }),
        });

        c_example_exe.root_module.addCSourceFile(.{
            .file = b.path(b.pathJoin(&.{
                sdk_root,
                "examples",
                "c",
                b.fmt("{s}.c", .{example_name}),
            })),
            .flags = &.{
                "-std=c11",
                "-Wall",
                "-Wextra",
            },
        });
        c_example_exe.root_module.addIncludePath(b.path(sdk_root ++ "/include"));
        c_example_exe.root_module.linkLibrary(sdk_lib);

        const run_c_example = b.addRunArtifact(c_example_exe);
        c_example_step.dependOn(&run_c_example.step);

        // Also install each C example executable
        b.installArtifact(c_example_exe);
    }

    // Benchmarks
    const benchmarks_step = b.step("benchmarks", "Build and run all benchmarks");

    const benchmark_mod = benchmarks_dep.module("zbench");

    var captured_stderr: std.ArrayList(std.Build.LazyPath) = .empty;
    defer captured_stderr.deinit(b.allocator);

    const benchmarked_signals: []const []const u8 = &.{ "logs", "metrics", "trace" };
    for (benchmarked_signals) |signal| {
        const signal_benchmarks = helpers.buildBenchmarks(b, b.path(b.pathJoin(&.{ sdk_root, "benchmarks", signal })), sdk_mod, benchmark_mod, clock_mod, benchmark_debug) catch |err| {
            std.debug.print("Error building {s} benchmarks: {}\n", .{ signal, err });
            return err;
        };
        defer b.allocator.free(signal_benchmarks);
        for (signal_benchmarks) |step| {
            const run_signal_benchmark = b.addRunArtifact(step);

            if (benchmark_output != null) {
                try captured_stderr.append(b.allocator, run_signal_benchmark.captureStdErr(.{}));
            }

            benchmarks_step.dependOn(&run_signal_benchmark.step);
        }
    }

    if (benchmark_output) |output_path| {
        const concat = b.addSystemCommand(&.{"cat"});
        for (captured_stderr.items) |p| concat.addFileArg(p);
        const merged = concat.captureStdOut(.{});

        const write = b.addUpdateSourceFiles();
        write.addCopyFileToSource(merged, output_path);
        benchmarks_step.dependOn(&write.step);
    }

    // Integration tests step
    const integration_step = b.step("integration", "Run integration tests (requires Docker)");
    const integration_tests = helpers.buildIntegrationTests(b, b.path(sdk_root ++ "/integration_tests"), sdk_mod, clock_mod) catch |build_err| {
        std.debug.print("Error building integration tests: {}\n", .{build_err});
        return build_err;
    };
    defer b.allocator.free(integration_tests);
    for (integration_tests) |step| {
        const run_integration_test = b.addRunArtifact(step);
        integration_step.dependOn(&run_integration_test.step);
    }

    // Documentation webiste with autodoc
    const sdk_docs = b.addObject(.{
        .name = "sdk",
        .root_module = b.createModule(.{
            .root_source_file = b.path(sdk_root ++ "/src/sdk.zig"),
            .target = target,
            // Doc emission is independent of optimize mode; pin to Debug
            // for the fastest doc builds.
            .optimize = .Debug,
            .link_libc = true,
            .imports = &.{
                .{ .name = "protobuf", .module = protobuf_mod },
                .{ .name = "opentelemetry-proto", .module = otel_proto_mod },
                .{ .name = "clock", .module = clock_mod },
            },
        }),
    });
    const install_docs = b.addInstallDirectory(.{
        .source_dir = sdk_docs.getEmittedDocs(),
        .install_dir = .prefix,
        .install_subdir = "docs",
    });

    const docs_step = b.step("docs", "Copy documentation artifacts to prefix path");
    docs_step.dependOn(&sdk_lib.step);
    docs_step.dependOn(&install_docs.step);
}
