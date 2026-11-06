//! OpenTelemetry Profiles SDK.

pub const ProfileBuilder = @import("profiles/profile_builder.zig").ProfileBuilder;

// Allocator
pub const ProfilingAllocator = @import("profiles/profiling_allocator.zig").ProfilingAllocator;
pub const ProfilingAllocatorOptions = @import("profiles/profiling_allocator.zig").ProfilingAllocatorOptions;

// Exporters
pub const ProfileExporter = @import("profiles/profile_exporter.zig").ProfileExporter;
pub const InMemoryProfileExporter = @import("profiles/exporters/generic.zig").InMemoryProfileExporter;
pub const OTLPProfileExporter = @import("profiles/exporters/otlp.zig").OTLPProfileExporter;

// Processors
pub const ProfileProcessor = @import("profiles/profile_processor.zig").ProfileProcessor;
pub const SimpleProfileProcessor = @import("profiles/profile_processor.zig").SimpleProfileProcessor;

test {
    _ = @import("profiles/profile_builder.zig");
    _ = @import("profiles/profiling_allocator.zig");
    _ = @import("profiles/profile_exporter.zig");
    _ = @import("profiles/profile_processor.zig");
    _ = @import("profiles/exporters/generic.zig");
    _ = @import("profiles/exporters/otlp.zig");
}
