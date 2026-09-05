const std = @import("std");

pub fn getZigFileName(file_name: []const u8) ?[]const u8 {
    // Get the file name without extension, checking if it ends with '.zig'.
    // If it doesn't end in 'zig' then ignore.
    const index = std.mem.lastIndexOfScalar(u8, file_name, '.') orelse return null;
    if (index == 0) return null; // discard dotfiles
    if (!std.mem.eql(u8, file_name[index + 1 ..], "zig")) return null;
    return file_name[0..index];
}

pub const BuildModules = std.StringHashMap(*std.Build.Module);

// Generates a ist of imports from a BuildModules map, only including the modules whose names are in the `include` list.
// It returns an error if an entry in `include` is not found in the `source` map.
pub fn ImportsFromBuildModules(allocator: std.mem.Allocator, source: *const BuildModules, include_list: [][]const u8) ![]std.Build.Module.Import {
    var imports: std.ArrayList(std.Build.Module.Import) = .empty;
    errdefer imports.deinit(allocator);

    for (include_list) |name| {
        const mod = source.get(name) orelse {
            std.debug.print("Failed to find module {s} for imports\n", .{name});
            return BuildError.ModuleNotFound;
        };
        try imports.append(allocator, .{ .name = name, .module = mod });
    }

    return try imports.toOwnedSlice(allocator);
}

pub const BuildError = error{
    DependencyNotFound,
    ModuleNotFound,
};

pub const CompilationInfo = struct {
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    version: []const u8,
    pkg_name: []const u8,
};

/// Installs `exe` to zig-out/<install_subdir>/ and hooks that install into
/// `build_step`, so building never implies running. `run_step` additionally
/// runs the installed binary, depending on `cwd` for executables (e.g.
/// integration tests) that must run from a specific working directory.
///
/// `shared_libs` lists installs of shared libraries `exe` links: they are
/// installed before it, and it is given an rpath to find them in zig-out/lib.
pub fn wireExample(
    b: *std.Build,
    exe: *std.Build.Step.Compile,
    install_subdir: []const u8,
    build_step: *std.Build.Step,
    run_step: *std.Build.Step,
    cwd: ?std.Build.LazyPath,
    shared_libs: []const *std.Build.Step.InstallArtifact,
) void {
    // Windows has no rpath: there the run step puts the DLL directories on PATH.
    if (shared_libs.len > 0 and exe.rootModuleTarget().os.tag != .windows) {
        exe.root_module.addRPathSpecial(installedLibRpath(b, install_subdir, exe.rootModuleTarget()));
    }

    const install = b.addInstallArtifact(exe, .{
        .dest_dir = .{ .override = .{ .custom = install_subdir } },
    });
    for (shared_libs) |shared_lib| install.step.dependOn(&shared_lib.step);
    build_step.dependOn(&install.step);

    const run = b.addRunArtifact(exe);
    if (cwd) |c| run.setCwd(c);
    run.step.dependOn(&install.step);
    run_step.dependOn(&run.step);
}

// Rpath letting a binary installed in zig-out/<install_subdir>/ load the shared
// libraries installed in zig-out/lib/, whatever its working directory is: Zig
// only records a build-root-relative rpath for the libraries it builds in the
// cache, which the binary cannot resolve once run from elsewhere.
fn installedLibRpath(b: *std.Build, install_subdir: []const u8, target: std.Target) []const u8 {
    // "@executable_path" is the Mach-O spelling of ELF's "$ORIGIN".
    var rpath: []const u8 = if (target.os.tag.isDarwin()) "@executable_path" else "$ORIGIN";
    var components = std.mem.tokenizeScalar(u8, install_subdir, '/');
    while (components.next()) |_| rpath = b.fmt("{s}/..", .{rpath});
    return b.fmt("{s}/lib", .{rpath});
}
