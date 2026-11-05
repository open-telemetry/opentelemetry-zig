const std = @import("std");
const sdk = @import("opentelemetry-sdk");
const profiles = sdk.profiles;
const trace = sdk.api.trace;

pub fn main(init: std.process.Init) !void {
    const allocator = init.gpa;

    std.debug.print("Initializing OpenTelemetry Profiles memory profiler example...\n", .{});

    // 1. Initialize a ProfilingAllocator wrapping the general purpose allocator
    var prof_alloc = try profiles.ProfilingAllocator.init(allocator, .{
        .min_sample_bytes = 0,
        .sample_rate = 1,
        .sample_type_name = "alloc_space",
        .sample_unit = "bytes",
    });
    defer prof_alloc.deinit();

    const mem = prof_alloc.allocator();

    // 2. Set up an in-memory exporter and processor to capture exported profiles
    var in_memory_exporter = profiles.InMemoryProfileExporter.init(allocator);
    defer in_memory_exporter.deinit();

    var processor = profiles.SimpleProfileProcessor.init(in_memory_exporter.asProfileExporter());

    // 3. Simulate trace context for trace-profile correlation
    const tid = trace.TraceID.init([16]u8{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 });
    const sid = trace.SpanID.init([8]u8{ 8, 7, 6, 5, 4, 3, 2, 1 });
    var ts = trace.TraceState.init(allocator);
    defer ts.deinit();
    const sc = trace.SpanContext.init(tid, sid, trace.TraceFlags.sampled(), ts, false);

    prof_alloc.setActiveSpanContext(sc);

    // 4. Perform application work with memory allocations
    std.debug.print("Performing memory allocations with active trace context...\n", .{});
    const block1 = try mem.alloc(u8, 1024);
    defer mem.free(block1);
    @memset(block1, 0xAA);

    const block2 = try mem.alloc(u64, 128);
    defer mem.free(block2);
    @memset(block2, 42);

    // 5. Switch off trace context and perform background allocations
    prof_alloc.setActiveSpanContext(null);
    const background_block = try mem.alloc(u8, 256);
    defer mem.free(background_block);

    // 6. Flush the recorded profile to the processor
    const resource_attrs = [_]sdk.Attribute{
        .{ .key = "service.name", .value = .{ .string = "memory-profiler-example" } },
        .{ .key = "service.version", .value = .{ .string = "0.1.0" } },
    };

    try prof_alloc.flush(
        processor.asProfileProcessor(),
        &resource_attrs,
        .{ .name = "example.memory_profiling", .version = "1.0.0" },
    );

    std.debug.print("Profile exported successfully!\n", .{});
    std.debug.print("Total batches exported: {}\n", .{in_memory_exporter.export_count});
    std.debug.print("Total samples collected: {}\n", .{in_memory_exporter.sample_count});
    std.debug.print("Total bytes tracked: {} bytes\n", .{prof_alloc.total_allocated_bytes});
}
