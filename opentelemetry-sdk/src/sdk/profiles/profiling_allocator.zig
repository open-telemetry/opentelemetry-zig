const std = @import("std");
const ProfileBuilder = @import("profile_builder.zig").ProfileBuilder;
const ProfileProcessor = @import("profile_processor.zig").ProfileProcessor;
const api = @import("../../api.zig");
const StackFrame = api.profiles.StackFrame;
const trace = api.trace;
const Attribute = @import("../../attributes.zig").Attribute;
const InstrumentationScope = @import("../../scope.zig").InstrumentationScope;
const proto = @import("opentelemetry-proto");
const pbcollector_profiles = proto.collector_profiles_v1development;

/// Configuration options for the ProfilingAllocator.
pub const ProfilingAllocatorOptions = struct {
    /// Sample every allocation >= min_sample_bytes (0 = all allocations)
    min_sample_bytes: usize = 0,
    /// Sample rate: 1 in N allocations (1 = sample every allocation)
    sample_rate: usize = 1,
    /// Sample type name for the profile (default: "alloc_space")
    sample_type_name: []const u8 = "alloc_space",
    /// Sample unit for the profile (default: "bytes")
    sample_unit: []const u8 = "bytes",
};

/// ProfilingAllocator wraps an existing std.mem.Allocator to track memory allocations
/// and generate OpenTelemetry continuous profiles correlated with active trace context.
pub const ProfilingAllocator = struct {
    backing_allocator: std.mem.Allocator,
    builder: ProfileBuilder,
    options: ProfilingAllocatorOptions,
    lock: std.atomic.Mutex = .unlocked,

    total_allocated_bytes: usize = 0,
    total_allocation_count: usize = 0,
    allocation_counter: usize = 0,
    active_span_context: ?trace.SpanContext = null,

    const Self = @This();

    fn acquireLock(self: *Self) void {
        while (!self.lock.tryLock()) {
            std.atomic.spinLoopHint();
        }
    }

    fn releaseLock(self: *Self) void {
        self.lock.unlock();
    }

    pub fn init(backing_allocator: std.mem.Allocator, options: ProfilingAllocatorOptions) !Self {
        var builder = try ProfileBuilder.init(backing_allocator);
        builder.setSampleType(options.sample_type_name, options.sample_unit);

        return Self{
            .backing_allocator = backing_allocator,
            .builder = builder,
            .options = options,
        };
    }

    pub fn deinit(self: *Self) void {
        self.builder.deinit();
        self.* = undefined;
    }

    /// Returns an std.mem.Allocator interface that tracks memory allocations.
    pub fn allocator(self: *Self) std.mem.Allocator {
        return std.mem.Allocator{
            .ptr = self,
            .vtable = &.{
                .alloc = alloc,
                .resize = resize,
                .remap = remap,
                .free = free,
            },
        };
    }

    /// Sets the active SpanContext for trace-profile correlation.
    pub fn setActiveSpanContext(self: *Self, span_context: ?trace.SpanContext) void {
        self.acquireLock();
        defer self.releaseLock();
        self.active_span_context = span_context;
    }

    /// Collects the recorded memory allocation profile as an OTLP ExportProfilesServiceRequest.
    pub fn collect(
        self: *Self,
        resource_attrs: ?[]const Attribute,
        scope_info: ?InstrumentationScope,
    ) !pbcollector_profiles.ExportProfilesServiceRequest {
        self.acquireLock();
        defer self.releaseLock();
        return self.builder.build(resource_attrs, scope_info);
    }

    /// Flushes the current memory profile to a ProfileProcessor and resets the builder.
    pub fn flush(
        self: *Self,
        processor: ProfileProcessor,
        resource_attrs: ?[]const Attribute,
        scope_info: ?InstrumentationScope,
    ) !void {
        self.acquireLock();
        defer self.releaseLock();

        var req = try self.builder.build(resource_attrs, scope_info);
        try processor.onProfile(&req);
        try self.builder.reset();
        self.builder.setSampleType(self.options.sample_type_name, self.options.sample_unit);
    }

    fn recordAllocation(self: *Self, len: usize, ret_addr: usize) void {
        self.acquireLock();
        defer self.releaseLock();

        self.allocation_counter += 1;
        if (self.options.min_sample_bytes > 0 and len < self.options.min_sample_bytes) {
            return;
        }
        if (self.options.sample_rate > 1 and (self.allocation_counter % self.options.sample_rate) != 0) {
            return;
        }

        self.total_allocated_bytes += len;
        self.total_allocation_count += 1;

        const frame = StackFrame{
            .function_name = "alloc",
            .address = @as(u64, @intCast(ret_addr)),
        };

        const frames = [_]StackFrame{frame};
        const values = [_]i64{@as(i64, @intCast(len))};

        self.builder.addStackSampleWithSpanContext(
            &frames,
            &values,
            null,
            self.active_span_context,
        ) catch {};
    }

    fn alloc(ctx: *anyopaque, len: usize, alignment: std.mem.Alignment, ret_addr: usize) ?[*]u8 {
        const self: *Self = @ptrCast(@alignCast(ctx));
        const ptr = self.backing_allocator.rawAlloc(len, alignment, ret_addr);
        if (ptr) |_| {
            self.recordAllocation(len, ret_addr);
        }
        return ptr;
    }

    fn resize(ctx: *anyopaque, memory: []u8, alignment: std.mem.Alignment, new_len: usize, ret_addr: usize) bool {
        const self: *Self = @ptrCast(@alignCast(ctx));
        return self.backing_allocator.rawResize(memory, alignment, new_len, ret_addr);
    }

    fn remap(ctx: *anyopaque, memory: []u8, alignment: std.mem.Alignment, new_len: usize, ret_addr: usize) ?[*]u8 {
        const self: *Self = @ptrCast(@alignCast(ctx));
        return self.backing_allocator.rawRemap(memory, alignment, new_len, ret_addr);
    }

    fn free(ctx: *anyopaque, memory: []u8, alignment: std.mem.Alignment, ret_addr: usize) void {
        const self: *Self = @ptrCast(@alignCast(ctx));
        self.backing_allocator.rawFree(memory, alignment, ret_addr);
    }
};

test "ProfilingAllocator basic allocations and profile generation" {
    const testing_allocator = std.testing.allocator;

    var prof_alloc = try ProfilingAllocator.init(testing_allocator, .{});
    defer prof_alloc.deinit();

    const mem_allocator = prof_alloc.allocator();

    // Perform tracked allocations
    const buf1 = try mem_allocator.alloc(u8, 128);
    defer mem_allocator.free(buf1);

    const buf2 = try mem_allocator.alloc(u8, 256);
    defer mem_allocator.free(buf2);

    try std.testing.expectEqual(@as(usize, 2), prof_alloc.total_allocation_count);
    try std.testing.expectEqual(@as(usize, 384), prof_alloc.total_allocated_bytes);

    const req = try prof_alloc.collect(null, null);
    try std.testing.expectEqual(@as(usize, 1), req.resource_profiles.items.len);
    const prof = req.resource_profiles.items[0].scope_profiles.items[0].profiles.items[0];
    try std.testing.expectEqual(@as(usize, 2), prof.samples.items.len);
}

test "ProfilingAllocator trace correlation and flush" {
    const testing_allocator = std.testing.allocator;

    var prof_alloc = try ProfilingAllocator.init(testing_allocator, .{
        .min_sample_bytes = 64,
    });
    defer prof_alloc.deinit();

    const mem_allocator = prof_alloc.allocator();

    // Set trace context
    const tid = trace.TraceID.init([16]u8{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 });
    const sid = trace.SpanID.init([8]u8{ 8, 7, 6, 5, 4, 3, 2, 1 });
    var ts = trace.TraceState.init(testing_allocator);
    defer ts.deinit();
    const sc = trace.SpanContext.init(tid, sid, trace.TraceFlags.sampled(), ts, false);

    prof_alloc.setActiveSpanContext(sc);

    // Allocation below threshold (should be skipped by sampler)
    const small = try mem_allocator.alloc(u8, 16);
    defer mem_allocator.free(small);

    // Allocation above threshold (should be recorded and correlated)
    const large = try mem_allocator.alloc(u8, 512);
    defer mem_allocator.free(large);

    const InMemoryProfileExporter = @import("exporters/generic.zig").InMemoryProfileExporter;
    const SimpleProfileProcessor = @import("profile_processor.zig").SimpleProfileProcessor;

    var in_memory = InMemoryProfileExporter.init(testing_allocator);
    defer in_memory.deinit();

    var processor = SimpleProfileProcessor.init(in_memory.asProfileExporter());
    try prof_alloc.flush(processor.asProfileProcessor(), null, null);

    try std.testing.expectEqual(@as(usize, 1), in_memory.export_count);
    try std.testing.expectEqual(@as(usize, 1), in_memory.sample_count);
}
