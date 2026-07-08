const std = @import("std");

pub fn buildExamples(
    b: *std.Build,
    examples_dir: std.Build.LazyPath,
    otel_sdk_mod: *std.Build.Module,
    otlp_stub_mod: *std.Build.Module,
    proto_mod: *std.Build.Module,
    clock_mod: *std.Build.Module,
    name_filter: ?[]const u8,
) ![]*std.Build.Step.Compile {
    var exes: std.ArrayList(*std.Build.Step.Compile) = .empty;
    errdefer exes.deinit(b.allocator);

    var ex_dir = try examples_dir.getPath3(b, null).openDir(std.Options.debug_io, "", .{ .iterate = true });
    defer ex_dir.close(std.Options.debug_io);

    var ex_dir_iter = ex_dir.iterate();
    while (try ex_dir_iter.next(std.Options.debug_io)) |file| {
        if (getZigFileName(file.name)) |name| {
            // Discard the modules that do not match the filter
            if (name_filter) |filter| {
                if (std.mem.indexOf(u8, name, filter) == null) continue;
            }
            const file_name = try examples_dir.join(b.allocator, file.name);

            const b_mod = b.createModule(.{
                .root_source_file = file_name,
                .target = otel_sdk_mod.resolved_target.?,
                .optimize = otel_sdk_mod.optimize.?,
                .imports = &.{
                    .{ .name = "opentelemetry-sdk", .module = otel_sdk_mod },
                    .{ .name = "otlp-stub", .module = otlp_stub_mod },
                    .{ .name = "opentelemetry-proto", .module = proto_mod },
                    .{ .name = "clock", .module = clock_mod },
                },
            });
            try exes.append(b.allocator, b.addExecutable(.{
                .name = name,
                .root_module = b_mod,
            }));
        }
    }

    return exes.toOwnedSlice(b.allocator);
}

pub fn buildBenchmarks(
    b: *std.Build,
    bench_dir: std.Build.LazyPath,
    otel_mod: *std.Build.Module,
    benchmark_mod: *std.Build.Module,
    clock_mod: *std.Build.Module,
    debug_mode: bool,
) ![]*std.Build.Step.Compile {
    var bench_tests: std.ArrayList(*std.Build.Step.Compile) = .empty;
    errdefer bench_tests.deinit(b.allocator);

    var test_dir = try bench_dir.getPath3(b, null).openDir(std.Options.debug_io, "", .{ .iterate = true });
    defer test_dir.close(std.Options.debug_io);

    var iter = test_dir.iterate();
    while (try iter.next(std.Options.debug_io)) |file| {
        if (getZigFileName(file.name)) |name| {
            const file_name = try bench_dir.join(b.allocator, file.name);

            const b_mod = b.createModule(.{
                .root_source_file = file_name,
                .target = otel_mod.resolved_target.?,
                // We set the optimization level to ReleaseFast for benchmarks
                // because we want to have the best performance.
                .optimize = if (debug_mode) .Debug else .ReleaseFast,
                .strip = !debug_mode,
                .imports = &.{
                    .{ .name = "opentelemetry-sdk", .module = otel_mod },
                    .{ .name = "benchmark", .module = benchmark_mod },
                    .{ .name = "clock", .module = clock_mod },
                },
            });

            // Provide dummy test_options so the custom test runner compiles
            const benchmark_test_options = b.addOptions();
            benchmark_test_options.addOption(bool, "verbose", false);
            benchmark_test_options.addOption(bool, "fail_first", false);
            benchmark_test_options.addOption(bool, "show_logs", false);
            b_mod.addOptions("test_options", benchmark_test_options);

            const test_step = b.addTest(.{
                .name = name,
                .root_module = b_mod,
                // Use custom test runner to avoid server protocol (--listen=-)
                .test_runner = .{ .path = b.path("opentelemetry-sdk/src/test_runner.zig"), .mode = .simple },
                // Allow passing benchmark filter using the build args.
                .filters = b.args orelse &[0][]const u8{},
            });

            try bench_tests.append(b.allocator, test_step);
        }
    }

    return bench_tests.toOwnedSlice(b.allocator);
}

pub fn buildIntegrationTests(
    b: *std.Build,
    integration_dir: std.Build.LazyPath,
    otel_mod: *std.Build.Module,
    clock_mod: *std.Build.Module,
) ![]*std.Build.Step.Compile {
    var integration_tests: std.ArrayList(*std.Build.Step.Compile) = .empty;
    errdefer integration_tests.deinit(b.allocator);

    var test_dir = integration_dir.getPath3(b, null).openDir(std.Options.debug_io, "", .{ .iterate = true }) catch |err| switch (err) {
        error.FileNotFound => return integration_tests.toOwnedSlice(b.allocator),
        else => return err,
    };
    defer test_dir.close(std.Options.debug_io);

    // Create common module for shared integration test utilities
    const common_path = try integration_dir.join(b.allocator, "common.zig");
    const common_mod = b.createModule(.{
        .root_source_file = common_path,
        .target = otel_mod.resolved_target.?,
        .optimize = otel_mod.optimize.?,
        .imports = &.{
            .{ .name = "opentelemetry-sdk", .module = otel_mod },
            .{ .name = "clock", .module = clock_mod },
        },
    });

    var iter = test_dir.iterate();
    while (try iter.next(std.Options.debug_io)) |file| {
        if (getZigFileName(file.name)) |name| {
            // Skip common.zig as it's not a test executable
            if (std.mem.eql(u8, name, "common")) continue;

            // If integration filter is specified, skip non-matching tests
            const integration_filter = b.args;

            const file_name = try integration_dir.join(b.allocator, file.name);
            if (integration_filter) |filter| {
                for (filter) |filter_entry| {
                    if (std.mem.eql(u8, name, filter_entry)) {
                        const b_mod = b.createModule(.{
                            .root_source_file = file_name,
                            .target = otel_mod.resolved_target.?,
                            .optimize = otel_mod.optimize.?,
                            .imports = &.{
                                .{ .name = "opentelemetry-sdk", .module = otel_mod },
                                .{ .name = "common", .module = common_mod },
                                .{ .name = "clock", .module = clock_mod },
                            },
                        });

                        try integration_tests.append(b.allocator, b.addExecutable(.{
                            .name = name,
                            .root_module = b_mod,
                        }));
                    }
                }
            } else {
                const b_mod = b.createModule(.{
                    .root_source_file = file_name,
                    .target = otel_mod.resolved_target.?,
                    .optimize = otel_mod.optimize.?,
                    .imports = &.{
                        .{ .name = "opentelemetry-sdk", .module = otel_mod },
                        .{ .name = "common", .module = common_mod },
                        .{ .name = "clock", .module = clock_mod },
                    },
                });

                try integration_tests.append(b.allocator, b.addExecutable(.{
                    .name = name,
                    .root_module = b_mod,
                }));
            }
        }
    }

    return integration_tests.toOwnedSlice(b.allocator);
}

pub fn getZigFileName(file_name: []const u8) ?[]const u8 {
    // Get the file name without extension, checking if it ends with '.zig'.
    // If it doesn't end in 'zig' then ignore.
    const index = std.mem.lastIndexOfScalar(u8, file_name, '.') orelse return null;
    if (index == 0) return null; // discard dotfiles
    if (!std.mem.eql(u8, file_name[index + 1 ..], "zig")) return null;
    return file_name[0..index];
}
