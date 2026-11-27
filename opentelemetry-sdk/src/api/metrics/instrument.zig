const std = @import("std");

const log = std.log.scoped(.instrument);

const spec = @import("spec.zig");
const Attribute = @import("../../attributes.zig").Attribute;
const Attributes = @import("../../attributes.zig").Attributes;
const DataPoint = @import("measurement.zig").DataPoint;
const HistogramDataPoint = @import("measurement.zig").HistogramDataPoint;
const aggregation = @import("../../sdk/metrics/aggregation.zig");
const ExponentialHistogramDataPoint = aggregation.ExponentialHistogramDataPoint;

const MeasurementsData = @import("measurement.zig").MeasurementsData;

const exemplar = @import("../../sdk/metrics/exemplar.zig");
const pipeline = @import("../../sdk/metrics/pipeline.zig");
const StorageSink = pipeline.StorageSink;
const Pipeline = pipeline.Pipeline;

const AsyncInstrument = @import("async_instrument.zig");
const trace_api = @import("../trace.zig");
const context_api = @import("../context.zig");
const MeterProvider = @import("meter.zig").MeterProvider;

pub const Kind = enum {
    // Synchronous instruments
    Counter,
    UpDownCounter,
    Histogram,
    Gauge,
    // Observable instruments (ascynchronous)
    ObservableCounter,
    ObservableUpDownCounter,
    ObservableGauge,

    pub fn toString(self: Kind) []const u8 {
        return switch (self) {
            .Counter => "Counter",
            .UpDownCounter => "UpDownCounter",
            .Histogram => "Histogram",
            .Gauge => "Gauge",
            .ObservableCounter => "ObservableCounter",
            .ObservableUpDownCounter => "ObservableUpDownCounter",
            .ObservableGauge => "ObservableGauge",
        };
    }

    /// Instruments that only record non-negative increments.
    /// See https://opentelemetry.io/docs/specs/otel/metrics/sdk/#sum-aggregation
    pub fn isMonotonic(self: Kind) bool {
        return switch (self) {
            .Counter, .ObservableCounter, .Histogram => true,
            .UpDownCounter, .ObservableUpDownCounter, .Gauge, .ObservableGauge => false,
        };
    }
};

const instrumentData = union(enum) {
    // Synchronous instruments.
    Counter_u16: *Counter(u16),
    Counter_u32: *Counter(u32),
    Counter_u64: *Counter(u64),
    UpDownCounter_i16: *Counter(i16),
    UpDownCounter_i32: *Counter(i32),
    UpDownCounter_i64: *Counter(i64),
    Histogram_u16: *Histogram(u16),
    Histogram_u32: *Histogram(u32),
    Histogram_u64: *Histogram(u64),
    Histogram_i16: *Histogram(i16),
    Histogram_i32: *Histogram(i32),
    Histogram_i64: *Histogram(i64),
    Histogram_f32: *Histogram(f32),
    Histogram_f64: *Histogram(f64),
    Gauge_i16: *Gauge(i16),
    Gauge_i32: *Gauge(i32),
    Gauge_i64: *Gauge(i64),
    Gauge_f32: *Gauge(f32),
    Gauge_f64: *Gauge(f64),
    // Async instruments.
    ObservableCounter: *AsyncInstrument.ObservableInstrument(.ObservableCounter),
    ObservableUpDownCounter: *AsyncInstrument.ObservableInstrument(.ObservableUpDownCounter),
    ObservableGauge: *AsyncInstrument.ObservableInstrument(.ObservableGauge),
};

/// Instrument is a container of all supported instrument types.
/// When the Meter wants to create a new instrument, it calls the new() function.
pub const Instrument = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    kind: Kind,
    opts: InstrumentOptions,
    data: instrumentData,

    pub fn new(kind: Kind, opts: InstrumentOptions, allocator: std.mem.Allocator) !*Self {
        // Validate name, unit anddescription, optionally throwing an error if non conformant.
        // See https://opentelemetry.io/docs/specs/otel/metrics/api/#instrument-name-syntax
        try spec.validateInstrumentOptions(opts);
        const i = try allocator.create(Self);
        i.* = Self{
            .allocator = allocator,
            .kind = kind,
            .opts = opts,
            .data = undefined,
        };
        return i;
    }

    pub fn counter(self: *Self, io: std.Io, comptime T: type) !*Counter(T) {
        const c = try self.allocator.create(Counter(T));
        c.* = Counter(T).init(self.allocator, io);
        errdefer self.allocator.destroy(c);
        self.data = switch (T) {
            u16 => .{ .Counter_u16 = c },
            u32 => .{ .Counter_u32 = c },
            u64 => .{ .Counter_u64 = c },
            else => {
                log.err("Unsupported monotonic counter value type: {s}", .{@typeName(T)});
                return spec.FormatError.UnsupportedValueType;
            },
        };
        return c;
    }

    pub fn upDownCounter(self: *Self, io: std.Io, comptime T: type) !*Counter(T) {
        const c = try self.allocator.create(Counter(T));
        c.* = Counter(T).init(self.allocator, io);
        errdefer self.allocator.destroy(c);
        self.data = switch (T) {
            i16 => .{ .UpDownCounter_i16 = c },
            i32 => .{ .UpDownCounter_i32 = c },
            i64 => .{ .UpDownCounter_i64 = c },
            else => {
                log.err("Unsupported Up Down counter value type: {s}", .{@typeName(T)});
                return spec.FormatError.UnsupportedValueType;
            },
        };
        return c;
    }

    pub fn histogram(self: *Self, io: std.Io, comptime T: type) !*Histogram(T) {
        const h = try self.allocator.create(Histogram(T));
        h.* = Histogram(T).init(self.allocator, io);
        errdefer self.allocator.destroy(h);
        self.data = switch (T) {
            u16 => .{ .Histogram_u16 = h },
            u32 => .{ .Histogram_u32 = h },
            u64 => .{ .Histogram_u64 = h },
            i16 => .{ .Histogram_i16 = h },
            i32 => .{ .Histogram_i32 = h },
            i64 => .{ .Histogram_i64 = h },
            f32 => .{ .Histogram_f32 = h },
            f64 => .{ .Histogram_f64 = h },
            else => {
                log.err("Unsupported histogram value type: {s}", .{@typeName(T)});
                return spec.FormatError.UnsupportedValueType;
            },
        };
        return h;
    }

    pub fn gauge(self: *Self, io: std.Io, comptime T: type) !*Gauge(T) {
        const g = try self.allocator.create(Gauge(T));
        g.* = Gauge(T).init(self.allocator, io);
        errdefer self.allocator.destroy(g);
        self.data = switch (T) {
            i16 => .{ .Gauge_i16 = g },
            i32 => .{ .Gauge_i32 = g },
            i64 => .{ .Gauge_i64 = g },
            f32 => .{ .Gauge_f32 = g },
            f64 => .{ .Gauge_f64 = g },
            else => {
                log.err("Unsupported gauge value type: {s}", .{@typeName(T)});
                return spec.FormatError.UnsupportedValueType;
            },
        };
        return g;
    }

    pub fn asyncCounter(
        self: *Self,
        io: std.Io,
        context: AsyncInstrument.ObservedContext,
        callbacks: ?[]AsyncInstrument.ObserveMeasures,
    ) !*AsyncInstrument.ObservableInstrument(.ObservableCounter) {
        const i = try self.allocator.create(AsyncInstrument.ObservableInstrument(.ObservableCounter));
        i.* = AsyncInstrument.ObservableInstrument(.ObservableCounter).init(self.allocator, io, context);

        if (callbacks) |cb| {
            for (cb) |c| {
                try i.registerCallback(c);
            }
        }
        self.data = .{ .ObservableCounter = i };
        return i;
    }

    pub fn asyncUpDownCounter(
        self: *Self,
        io: std.Io,
        context: AsyncInstrument.ObservedContext,
        callbacks: ?[]AsyncInstrument.ObserveMeasures,
    ) !*AsyncInstrument.ObservableInstrument(.ObservableUpDownCounter) {
        const i = try self.allocator.create(AsyncInstrument.ObservableInstrument(.ObservableUpDownCounter));
        i.* = AsyncInstrument.ObservableInstrument(.ObservableUpDownCounter).init(self.allocator, io, context);

        if (callbacks) |cb| {
            for (cb) |c| {
                try i.registerCallback(c);
            }
        }
        self.data = .{ .ObservableUpDownCounter = i };
        return i;
    }

    pub fn asyncGauge(
        self: *Self,
        io: std.Io,
        context: AsyncInstrument.ObservedContext,
        callbacks: ?[]AsyncInstrument.ObserveMeasures,
    ) !*AsyncInstrument.ObservableInstrument(.ObservableGauge) {
        const i = try self.allocator.create(AsyncInstrument.ObservableInstrument(.ObservableGauge));
        i.* = AsyncInstrument.ObservableInstrument(.ObservableGauge).init(self.allocator, io, context);

        if (callbacks) |cb| {
            for (cb) |c| {
                try i.registerCallback(c);
            }
        }
        self.data = .{ .ObservableGauge = i };
        return i;
    }

    pub fn deinit(self: *Self) void {
        switch (self.data) {
            inline else => |i| {
                i.deinit();
                self.allocator.destroy(i);
            },
        }
        self.allocator.destroy(self);
    }

    pub fn isFloat(self: *const Self) bool {
        return switch (self.data) {
            .Histogram_f32, .Histogram_f64, .Gauge_f32, .Gauge_f64 => true,
            else => false,
        };
    }

    pub fn syncLock(self: *Self) ?*std.Io.Mutex {
        return switch (self.data) {
            .ObservableCounter, .ObservableUpDownCounter, .ObservableGauge => null,
            inline else => |i| &i.lock,
        };
    }

    pub fn addStorageSink(self: *Self, sink: *StorageSink) !void {
        switch (self.data) {
            .ObservableCounter, .ObservableUpDownCounter, .ObservableGauge => {},
            inline else => |i| {
                i.lock.lockUncancelable(i.io);
                defer i.lock.unlock(i.io);
                try i.storages.append(i.allocator, sink);
            },
        }
    }

    pub fn removeStorageSink(self: *Self, sink: *StorageSink) void {
        switch (self.data) {
            .ObservableCounter, .ObservableUpDownCounter, .ObservableGauge => {},
            inline else => |i| {
                i.lock.lockUncancelable(i.io);
                defer i.lock.unlock(i.io);
                for (i.storages.items, 0..) |s, idx| {
                    if (s == sink) {
                        _ = i.storages.swapRemove(idx);
                        break;
                    }
                }
            },
        }
    }

    pub fn removeStorageSinksForPipeline(self: *Self, p: *Pipeline) void {
        switch (self.data) {
            .ObservableCounter, .ObservableUpDownCounter, .ObservableGauge => {},
            inline else => |i| {
                i.lock.lockUncancelable(i.io);
                defer i.lock.unlock(i.io);
                var idx: usize = 0;
                while (idx < i.storages.items.len) {
                    if (i.storages.items[idx].pipeline == p) {
                        _ = i.storages.swapRemove(idx);
                    } else {
                        idx += 1;
                    }
                }
            },
        }
    }

    pub fn asyncCreatedNs(self: *const Self) ?u64 {
        return switch (self.data) {
            inline .ObservableCounter, .ObservableUpDownCounter, .ObservableGauge => |i| i.created_ns,
            else => null,
        };
    }

    pub fn ensureStorageCapacity(self: *Self, additional: usize) !void {
        if (additional == 0) return;
        switch (self.data) {
            .ObservableCounter, .ObservableUpDownCounter, .ObservableGauge => {},
            inline else => |i| {
                i.lock.lockUncancelable(i.io);
                defer i.lock.unlock(i.io);
                try i.storages.ensureUnusedCapacity(i.allocator, additional);
            },
        }
    }

    pub fn addStorageSinkAssumeCapacity(self: *Self, sink: *StorageSink) void {
        switch (self.data) {
            .ObservableCounter, .ObservableUpDownCounter, .ObservableGauge => {},
            inline else => |i| {
                i.lock.lockUncancelable(i.io);
                defer i.lock.unlock(i.io);
                i.storages.appendAssumeCapacity(sink);
            },
        }
    }

    pub fn replaceStorageSink(self: *Self, old_sink: *StorageSink, new_sink: *StorageSink) void {
        switch (self.data) {
            .ObservableCounter, .ObservableUpDownCounter, .ObservableGauge => {},
            inline else => |i| {
                i.lock.lockUncancelable(i.io);
                defer i.lock.unlock(i.io);
                for (i.storages.items) |*s| {
                    if (s.* == old_sink) {
                        s.* = new_sink;
                        return;
                    }
                }
                i.storages.appendAssumeCapacity(new_sink);
            },
        }
    }

    pub fn getInstrumentsData(self: Self, allocator: std.mem.Allocator) !MeasurementsData {
        return switch (self.data) {
            inline .ObservableCounter, .ObservableUpDownCounter, .ObservableGauge => |i| i.measurementsData(allocator),
            else => error.SynchronousCollectionRequiresMetricReader,
        };
    }
};

/// InstrumentOptions is used to configure the instrument.
/// Base instrument options are name, description and unit.
/// Kind is inferred from the concrete type of the instrument.
pub const InstrumentOptions = struct {
    name: []const u8,
    description: ?[]const u8 = null,
    unit: ?[]const u8 = null,
    // Advisory parameters are in development, we don't support them yet, so we set to null.
    advisory: ?[]Attribute = null,
};

fn recordToStorages(
    comptime T: type,
    allocator: std.mem.Allocator,
    io: std.Io,
    lock: *std.Io.Mutex,
    exemplar_filter: exemplar.ExemplarFilter,
    storages: *const std.ArrayListUnmanaged(*StorageSink),
    value: T,
    attributes: ?[]const Attribute,
) !void {
    lock.lockUncancelable(io);
    defer lock.unlock(io);

    if (storages.items.len == 0) return;

    var base_candidate = try exemplar.Exemplar.capture(T, allocator, io, value, attributes, exemplar_filter);
    defer if (base_candidate) |*s| s.deinit(allocator);

    for (storages.items, 0..) |sink, idx| {
        const is_last = (idx + 1 == storages.items.len);
        var candidate: ?exemplar.Exemplar = if (base_candidate) |sample| blk: {
            if (is_last) {
                base_candidate = null;
                break :blk sample;
            } else {
                break :blk try sample.deepCopy(allocator);
            }
        } else null;
        defer if (candidate) |*s| s.deinit(allocator);

        try sink.record(T, allocator, value, attributes, &candidate);
    }
}

/// A Counter is a monotonically increasing value used to record cumulative events.
/// See https://opentelemetry.io/docs/specs/otel/metrics/api/#counter
pub fn Counter(comptime T: type) type {
    return struct {
        const Self = @This();
        allocator: std.mem.Allocator,
        io: std.Io,
        lock: std.Io.Mutex,
        exemplar_filter: exemplar.ExemplarFilter = .trace_based,
        storages: std.ArrayListUnmanaged(*StorageSink),

        fn init(allocator: std.mem.Allocator, io: std.Io) Self {
            return Self{
                .storages = .empty,
                .allocator = allocator,
                .io = io,
                .lock = std.Io.Mutex.init,
            };
        }

        fn deinit(self: *Self) void {
            self.storages.deinit(self.allocator);
        }

        /// Add the given delta to the counter, using the provided attributes.
        pub fn add(self: *Self, delta: T, attributes: anytype) !void {
            const ArgsType = @TypeOf(attributes);
            const args_type_info = @typeInfo(ArgsType);
            if (args_type_info != .@"struct") {
                @compileError("expected a tuple argument, found " ++ @typeName(ArgsType));
            }
            const count = args_type_info.@"struct".field_names.len / 2;
            var stack_buf: [count]Attribute = undefined;
            const attrs = Attributes.fromBuffer(&stack_buf, attributes);
            return self.addWithSlice(delta, attrs);
        }

        /// Add the given delta to the counter with a pre-built attribute slice.
        /// This is primarily used for C interop where attributes are passed as a slice.
        pub fn addWithSlice(self: *Self, delta: T, attributes: ?[]Attribute) !void {
            return recordToStorages(
                T,
                self.allocator,
                self.io,
                &self.lock,
                self.exemplar_filter,
                &self.storages,
                delta,
                attributes,
            );
        }
    };
}

/// A Histogram is used to sample observations and count them in pre-defined buckets.
/// Aggregates measurements in place by attribute set to avoid unbounded memory growth.
/// See https://opentelemetry.io/docs/specs/otel/metrics/api/#histogram
pub fn Histogram(comptime T: type) type {
    comptime {
        switch (@typeInfo(T)) {
            .int, .float => {},
            else => @compileError("Histogram only supports integer and floating-point types, found " ++ @typeName(T)),
        }
    }

    return struct {
        const Self = @This();

        allocator: std.mem.Allocator,
        io: std.Io,
        lock: std.Io.Mutex,
        exemplar_filter: exemplar.ExemplarFilter = .trace_based,
        storages: std.ArrayListUnmanaged(*StorageSink),

        fn init(allocator: std.mem.Allocator, io: std.Io) Self {
            return Self{
                .allocator = allocator,
                .io = io,
                .lock = std.Io.Mutex.init,
                .storages = .empty,
            };
        }

        fn deinit(self: *Self) void {
            self.storages.deinit(self.allocator);
        }

        /// Add the given value to the histogram, using the provided attributes.
        pub fn record(self: *Self, value: T, attributes: anytype) !void {
            const ArgsType = @TypeOf(attributes);
            const args_type_info = @typeInfo(ArgsType);
            if (args_type_info != .@"struct") {
                @compileError("expected a tuple argument, found " ++ @typeName(ArgsType));
            }
            const count = args_type_info.@"struct".field_names.len / 2;
            var stack_buf: [count]Attribute = undefined;
            const attrs = Attributes.fromBuffer(&stack_buf, attributes);
            return self.recordWithSlice(value, attrs);
        }

        /// Record a value with a pre-built attribute slice.
        /// This is primarily used for C interop where attributes are passed as a slice.
        pub fn recordWithSlice(self: *Self, value: T, attributes: ?[]Attribute) !void {
            return recordToStorages(
                T,
                self.allocator,
                self.io,
                &self.lock,
                self.exemplar_filter,
                &self.storages,
                value,
                attributes,
            );
        }
    };
}

pub fn Gauge(comptime T: type) type {
    comptime {
        switch (@typeInfo(T)) {
            .int, .float => {},
            else => @compileError("Gauge only supports integer and floating-point types, found " ++ @typeName(T)),
        }
    }

    return struct {
        const Self = @This();

        allocator: std.mem.Allocator,
        io: std.Io,
        lock: std.Io.Mutex,
        exemplar_filter: exemplar.ExemplarFilter = .trace_based,
        storages: std.ArrayListUnmanaged(*StorageSink),

        fn init(allocator: std.mem.Allocator, io: std.Io) Self {
            return Self{
                .storages = .empty,
                .allocator = allocator,
                .io = io,
                .lock = std.Io.Mutex.init,
            };
        }

        fn deinit(self: *Self) void {
            self.storages.deinit(self.allocator);
        }

        /// Record the given value to the gauge, using the provided attributes.
        pub fn record(self: *Self, value: T, attributes: anytype) !void {
            const ArgsType = @TypeOf(attributes);
            const args_type_info = @typeInfo(ArgsType);
            if (args_type_info != .@"struct") {
                @compileError("expected a tuple argument, found " ++ @typeName(ArgsType));
            }
            const count = args_type_info.@"struct".field_names.len / 2;
            var stack_buf: [count]Attribute = undefined;
            const attrs = Attributes.fromBuffer(&stack_buf, attributes);
            return self.recordWithSlice(value, attrs);
        }

        /// Record a value with a pre-built attribute slice.
        /// This is primarily used for C interop where attributes are passed as a slice.
        pub fn recordWithSlice(self: *Self, value: T, attributes: ?[]Attribute) !void {
            return recordToStorages(
                T,
                self.allocator,
                self.io,
                &self.lock,
                self.exemplar_filter,
                &self.storages,
                value,
                attributes,
            );
        }
    };
}

test "counter with unsupported type does not leak" {
    const io = std.testing.io;
    const mp = try MeterProvider.init(std.testing.allocator, io);
    defer mp.deinit();
    const meter = try mp.getMeter(.{ .name = "my-meter" });
    const err = meter.createCounter(u1, .{ .name = "a-counter" });
    try std.testing.expectError(spec.FormatError.UnsupportedValueType, err);
}

const MetricReader = @import("../../sdk/metrics/reader.zig").MetricReader;
const MetricExporter = @import("../../sdk/metrics/exporter.zig").MetricExporter;
const Measurements = @import("measurement.zig").Measurements;
const storage = @import("../../sdk/metrics/storage.zig");
const view_sdk = @import("../../sdk/metrics/view.zig");

const TestHarness = struct {
    allocator: std.mem.Allocator,
    mp: *MeterProvider,
    reader: *MetricReader,
    in_mem: *@import("../../sdk/metrics/exporters/in_memory.zig").InMemoryExporter,

    fn init(allocator: std.mem.Allocator, io: std.Io) !TestHarness {
        const mp = try MeterProvider.init(allocator, io);
        errdefer mp.deinit();
        const me = try MetricExporter.InMemory(allocator, io, null, null);
        errdefer me.in_memory.deinit();
        const reader = try MetricReader.init(allocator, io, me.exporter);
        errdefer reader.deinit();
        try mp.addReader(reader);
        return .{
            .allocator = allocator,
            .mp = mp,
            .reader = reader,
            .in_mem = me.in_memory,
        };
    }

    fn deinit(self: *TestHarness) void {
        self.reader.deinit();
        self.in_mem.deinit();
        self.mp.deinit();
    }

    fn collect(self: *TestHarness) ![]Measurements {
        try self.reader.collect();
        return try self.in_mem.fetch(self.allocator);
    }

    fn freeCollected(self: *TestHarness, data: []Measurements) void {
        for (data) |*m| m.deinit(self.allocator);
        self.allocator.free(data);
    }
};

test "meter can create counter instrument and record increase without attributes" {
    const io = std.testing.io;
    var h = try TestHarness.init(std.testing.allocator, io);
    defer h.deinit();
    const meter = try h.mp.getMeter(.{ .name = "my-meter" });
    var counter = try meter.createCounter(u32, .{ .name = "a-counter" });

    try counter.add(10, .{});
    try std.testing.expectEqual(@as(usize, 1), counter.storages.items[0].storage.count());
}

test "meter can create counter instrument and record increase with attributes" {
    const io = std.testing.io;
    var h = try TestHarness.init(std.testing.allocator, io);
    defer h.deinit();
    const meter = try h.mp.getMeter(.{ .name = "my-meter" });
    var counter = try meter.createCounter(u32, .{
        .name = "a-counter",
        .description = "a funny counter",
        .unit = "KiB",
    });

    try counter.add(100, .{});
    try counter.add(1000, .{});

    try std.testing.expectEqual(@as(usize, 1), counter.storages.items[0].storage.count());

    const val1: []const u8 = "some-value";
    const val2: []const u8 = "another-value";

    try counter.add(2, .{ "some-key", val1, "another-key", val2 });
    try std.testing.expectEqual(@as(usize, 2), counter.storages.items[0].storage.count());

    const data = try h.collect();
    defer h.freeCollected(data);
    try std.testing.expectEqual(@as(usize, 1), data.len);
    try std.testing.expectEqual(@as(usize, 2), data[0].data.int.len);
    try std.testing.expectEqual(@as(i64, 1100), data[0].data.int[0].value);
    try std.testing.expectEqual(@as(i64, 2), data[0].data.int[1].value);
}

test "histogram records value without explicit buckets" {
    const io = std.testing.io;
    var h = try TestHarness.init(std.testing.allocator, io);
    defer h.deinit();
    const meter = try h.mp.getMeter(.{ .name = "my-meter" });
    var histogram = try meter.createHistogram(u32, .{ .name = "anything" });

    try histogram.record(1, .{});
    try histogram.record(5, .{});
    try histogram.record(15, .{});

    const data = try h.collect();
    defer h.freeCollected(data);

    try std.testing.expectEqual(@as(usize, 1), data.len);
    try std.testing.expectEqual(@as(usize, 1), data[0].data.histogram.len);
    const dp = data[0].data.histogram[0].value;
    try std.testing.expectEqual(@as(u64, 3), dp.count);
    try std.testing.expectEqual(@as(f64, 21), dp.sum.?);
    try std.testing.expectEqual(@as(f64, 1), dp.min.?);
    try std.testing.expectEqual(@as(f64, 15), dp.max.?);
}

test "histogram records value with explicit buckets" {
    const io = std.testing.io;
    var h = try TestHarness.init(std.testing.allocator, io);
    defer h.deinit();
    try h.mp.addView(.{
        .instrument_selector = .{ .name = "a-histogram" },
        .aggregation = .{ .ExplicitBucketHistogram = .{ .buckets = &[_]f64{ 2.0, 10.0 } } },
        .temporality = .Cumulative,
    });
    const meter = try h.mp.getMeter(.{ .name = "my-meter" });
    var histogram = try meter.createHistogram(u32, .{ .name = "a-histogram" });

    try histogram.record(1, .{});
    try histogram.record(5, .{});
    try histogram.record(15, .{});

    const data = try h.collect();
    defer h.freeCollected(data);

    try std.testing.expectEqual(@as(usize, 1), data.len);
    try std.testing.expectEqual(@as(usize, 1), data[0].data.histogram.len);
    const dp = data[0].data.histogram[0].value;
    try std.testing.expectEqual(@as(u64, 3), dp.count);
    try std.testing.expectEqual(@as(f64, 21), dp.sum.?);
    try std.testing.expectEqual(@as(f64, 1), dp.min.?);
    try std.testing.expectEqual(@as(f64, 15), dp.max.?);
    // Buckets: <= 2.0 (1), <= 10.0 (1), > 10.0 (1)
    try std.testing.expectEqual(@as(usize, 3), dp.bucket_counts.len);
    try std.testing.expectEqual(@as(u64, 1), dp.bucket_counts[0]);
    try std.testing.expectEqual(@as(u64, 1), dp.bucket_counts[1]);
    try std.testing.expectEqual(@as(u64, 1), dp.bucket_counts[2]);
}

test "histogram keeps track of bucket counts by attribute" {
    const io = std.testing.io;
    var h = try TestHarness.init(std.testing.allocator, io);
    defer h.deinit();
    const meter = try h.mp.getMeter(.{ .name = "my-meter" });
    var histogram = try meter.createHistogram(u32, .{ .name = "a-histogram" });

    const val: []const u8 = "some-value";
    try histogram.record(1, .{ "some-key", val });
    try histogram.record(1000, .{ "other-key", val });

    const data = try h.collect();
    defer h.freeCollected(data);

    try std.testing.expectEqual(@as(usize, 1), data.len);
    try std.testing.expectEqual(@as(usize, 2), data[0].data.histogram.len);
}

test "histogram keeps track of count, sum and min/max by attribute" {
    const io = std.testing.io;
    var h = try TestHarness.init(std.testing.allocator, io);
    defer h.deinit();
    const meter = try h.mp.getMeter(.{ .name = "my-meter" });
    var histogram = try meter.createHistogram(u32, .{ .name = "a-histogram" });

    const val: []const u8 = "some-val";
    try histogram.record(1, .{});
    try histogram.record(5, .{ "key", val });
    try histogram.record(15, .{ "key", val });

    const data = try h.collect();
    defer h.freeCollected(data);

    try std.testing.expectEqual(@as(usize, 1), data.len);
    try std.testing.expectEqual(@as(usize, 2), data[0].data.histogram.len);

    var found_empty = false;
    var found_key = false;

    for (data[0].data.histogram) |dp| {
        if (dp.attributes == null) {
            found_empty = true;
            try std.testing.expectEqual(@as(u64, 1), dp.value.count);
            try std.testing.expectEqual(@as(f64, 1), dp.value.sum.?);
            try std.testing.expectEqual(@as(f64, 1), dp.value.min.?);
            try std.testing.expectEqual(@as(f64, 1), dp.value.max.?);
        } else {
            found_key = true;
            try std.testing.expectEqual(@as(u64, 2), dp.value.count);
            try std.testing.expectEqual(@as(f64, 20), dp.value.sum.?);
            try std.testing.expectEqual(@as(f64, 5), dp.value.min.?);
            try std.testing.expectEqual(@as(f64, 15), dp.value.max.?);
        }
    }

    try std.testing.expect(found_empty);
    try std.testing.expect(found_key);
}

test "histogram aggregates measurements in place without growing memory" {
    const io = std.testing.io;
    var h = try TestHarness.init(std.testing.allocator, io);
    defer h.deinit();
    const meter = try h.mp.getMeter(.{ .name = "my-meter" });
    var histogram = try meter.createHistogram(f64, .{ .name = "latency" });

    const val: []const u8 = "127.0.0.1";
    for (0..10_000) |i| {
        try histogram.record(@floatFromInt(i % 100), .{ "server.address", val });
    }

    try std.testing.expectEqual(@as(usize, 1), histogram.storages.items[0].storage.count());

    const data = try h.collect();
    defer h.freeCollected(data);

    try std.testing.expectEqual(@as(usize, 1), data.len);
    try std.testing.expectEqual(@as(usize, 1), data[0].data.histogram.len);
    try std.testing.expectEqual(@as(u64, 10_000), data[0].data.histogram[0].value.count);
}

test "histogram enforces cardinality limit" {
    const io = std.testing.io;
    var h = try TestHarness.init(std.testing.allocator, io);
    defer h.deinit();
    const meter = try h.mp.getMeter(.{ .name = "my-meter" });
    var histogram = try meter.createHistogram(u32, .{ .name = "cardinality-test" });
    histogram.storages.items[0].storage.setCardinalityLimit(2);

    try histogram.record(1, .{ "attr", @as([]const u8, "a") });
    try histogram.record(2, .{ "attr", @as([]const u8, "b") });
    try histogram.record(3, .{ "attr", @as([]const u8, "c") }); // overflow

    try std.testing.expectEqual(@as(usize, 2), histogram.storages.items[0].storage.count());
}

test "histogram exponential bucket mode aggregates in place" {
    const io = std.testing.io;
    var h = try TestHarness.init(std.testing.allocator, io);
    defer h.deinit();
    try h.mp.addView(.{
        .instrument_selector = .{ .name = "exp-test" },
        .aggregation = .{ .ExponentialBucketHistogram = try view_sdk.ExponentialBucketHistogramConfig.init(.{
            .max_scale = 10,
            .max_size = 4,
        }) },
        .temporality = .Cumulative,
    });
    const meter = try h.mp.getMeter(.{ .name = "my-meter" });
    var histogram = try meter.createHistogram(f64, .{ .name = "exp-test" });

    try histogram.record(1.0, .{});
    try histogram.record(2.0, .{});
    try histogram.record(4.0, .{});

    try std.testing.expectEqual(@as(usize, 1), histogram.storages.items[0].storage.count());

    const data = try h.collect();
    defer h.freeCollected(data);

    try std.testing.expectEqual(@as(usize, 1), data.len);
    try std.testing.expectEqual(@as(usize, 1), data[0].data.exponential_histogram.len);
    const dp = data[0].data.exponential_histogram[0].value;
    try std.testing.expectEqual(@as(u64, 3), dp.count);
    try std.testing.expectEqual(@as(f64, 7.0), dp.sum.?);
}

test "gauge instrument records value without attributes" {
    const io = std.testing.io;
    var h = try TestHarness.init(std.testing.allocator, io);
    defer h.deinit();
    const meter = try h.mp.getMeter(.{ .name = "my-meter" });
    var gauge = try meter.createGauge(i16, .{ .name = "a-gauge" });

    try gauge.record(42, .{});
    try gauge.record(-42, .{});

    try std.testing.expectEqual(@as(usize, 1), gauge.storages.items[0].storage.count());

    const data = try h.collect();
    defer h.freeCollected(data);
    try std.testing.expectEqual(@as(i64, -42), data[0].data.int[0].value);
}

test "gauge keeps separate last value per attribute set" {
    const io = std.testing.io;
    var h = try TestHarness.init(std.testing.allocator, io);
    defer h.deinit();
    const meter = try h.mp.getMeter(.{ .name = "my-meter" });
    var gauge = try meter.createGauge(f64, .{ .name = "temperature" });

    try gauge.record(20.5, .{ "room", @as([]const u8, "kitchen") });
    try gauge.record(22.0, .{ "room", @as([]const u8, "living_room") });
    try gauge.record(21.0, .{ "room", @as([]const u8, "kitchen") });

    const data = try h.collect();
    defer h.freeCollected(data);

    try std.testing.expectEqual(@as(usize, 1), data.len);
    try std.testing.expectEqual(@as(usize, 2), data[0].data.double.len);
    for (data[0].data.double) |dp| {
        const room = dp.attributes.?[0].value.string;
        if (std.mem.eql(u8, room, "kitchen")) {
            try std.testing.expectEqual(21.0, dp.value);
        } else if (std.mem.eql(u8, room, "living_room")) {
            try std.testing.expectEqual(22.0, dp.value);
        } else {
            return error.UnexpectedAttribute;
        }
    }
}

test "gauge cardinality limit creates overflow series and records excess measurements" {
    const io = std.testing.io;
    var h = try TestHarness.init(std.testing.allocator, io);
    defer h.deinit();
    const meter = try h.mp.getMeter(.{ .name = "my-meter" });
    var gauge = try meter.createGauge(i64, .{ .name = "gauge-cardinality" });
    gauge.storages.items[0].storage.setCardinalityLimit(3);

    try gauge.record(10, .{ "k", @as([]const u8, "v1") });
    try gauge.record(20, .{ "k", @as([]const u8, "v2") });
    try gauge.record(30, .{ "k", @as([]const u8, "v3") });
    try gauge.record(40, .{ "k", @as([]const u8, "v4") });

    const data = try h.collect();
    defer h.freeCollected(data);

    try std.testing.expectEqual(@as(usize, 3), data[0].data.int.len);

    var found_overflow = false;
    for (data[0].data.int) |dp| {
        if (dp.attributes) |attrs| {
            if (attrs.len == 1 and std.mem.eql(u8, attrs[0].key, "otel.metric.overflow")) {
                found_overflow = true;
                try std.testing.expectEqual(@as(i64, 40), dp.value);
            }
        }
    }
    try std.testing.expect(found_overflow);
}

test "gauge record existing series performs zero heap allocations" {
    const io = std.testing.io;
    var last_val_storage = storage.LastValueStorage(f64).init(std.testing.allocator, io, 100);
    defer last_val_storage.deinit();

    const attrs = [_]Attribute{.{ .key = "host", .value = .{ .string = "server-1" } }};
    var candidate: ?exemplar.Exemplar = null;
    try last_val_storage.record(1.0, &attrs, &candidate);

    var failing_allocator = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = 0 });
    const prev_allocator = last_val_storage.allocator;
    last_val_storage.allocator = failing_allocator.allocator();
    defer last_val_storage.allocator = prev_allocator;

    try last_val_storage.record(2.5, &attrs, &candidate);
    try last_val_storage.record(3.5, &attrs, &candidate);

    try std.testing.expectEqual(@as(usize, 1), last_val_storage.count());
    try std.testing.expectEqual(3.5, last_val_storage.aggregated_points.values()[0].value);
}

fn testGaugeAllocationFailures(allocator: std.mem.Allocator) !void {
    const io = std.testing.io;
    var s = storage.LastValueStorage(f64).init(allocator, io, 2);
    defer s.deinit();

    var candidate: ?exemplar.Exemplar = null;
    const a200 = [_]Attribute{.{ .key = "status", .value = .{ .string = "200" } }};
    const a404 = [_]Attribute{.{ .key = "status", .value = .{ .string = "404" } }};
    const a500 = [_]Attribute{.{ .key = "status", .value = .{ .string = "500" } }};

    try s.record(10.0, &a200, &candidate);
    try s.record(5.0, &a200, &candidate);
    try s.record(20.0, &a404, &candidate);
    try s.record(30.0, &a500, &candidate);

    var end_time: u64 = 0;
    const points = try s.snapshot(allocator, &end_time);
    defer {
        for (points) |*p| p.deinit(allocator);
        allocator.free(points);
    }
}

test "gauge in-place aggregation handles allocation failures without leaks or double-frees" {
    try std.testing.checkAllAllocationFailures(std.testing.allocator, testGaugeAllocationFailures, .{});
}

test "upDownCounter instrument records and stores value" {
    const io = std.testing.io;
    var h = try TestHarness.init(std.testing.allocator, io);
    defer h.deinit();
    const meter = try h.mp.getMeter(.{ .name = "my-meter" });
    var counter = try meter.createUpDownCounter(i32, .{ .name = "up-down-counter" });

    try counter.add(10, .{});
    try counter.add(-5, .{});
    try counter.add(-4, .{});
    try counter.add(1, .{ "some-key", @as(i64, 42) });

    const data = try h.collect();
    defer h.freeCollected(data);
    try std.testing.expectEqual(@as(usize, 2), data[0].data.int.len);
    try std.testing.expectEqual(@as(i64, 1), data[0].data.int[0].value);
    try std.testing.expectEqual(@as(i64, 1), data[0].data.int[1].value);
}

test "instrument in meter and instrument in data are the same" {
    const io = std.testing.io;
    var h = try TestHarness.init(std.testing.allocator, io);
    defer h.deinit();

    const name = "test-instrument";
    const meter = try h.mp.getMeter(.{ .name = "test-meter" });
    var c = try meter.createCounter(u64, .{ .name = name });
    try c.add(100, .{});

    const id = try spec.instrumentIdentifier(
        std.testing.allocator,
        name,
        Kind.Counter.toString(),
        "",
        "",
    );
    defer std.testing.allocator.free(id);

    if (meter.instruments.get(id)) |instrument| {
        std.debug.assert(instrument.kind == Kind.Counter);
        try std.testing.expectEqual(c, instrument.data.Counter_u64);
    } else {
        std.debug.panic("Counter {s} not found in meter {s} after creation", .{ name, meter.scope.name });
    }
}

test "counter thread-safety between datapoints collection and recording" {
    const io = std.testing.io;
    var h = try TestHarness.init(std.testing.allocator, io);
    defer h.deinit();

    const meter = try h.mp.getMeter(.{ .name = "test-meter" });
    var c = try meter.createCounter(u64, .{ .name = "test-instrument" });

    const val: []const u8 = "test-val";
    try c.add(1, .{ "cde", val });

    const adding_job = try std.Thread.spawn(.{}, testCounterAddingOne, .{c});
    const fetch_compare = try std.Thread.spawn(.{}, testCounterCollect, .{&h});
    adding_job.join();
    fetch_compare.join();
}

fn testCounterAddingOne(counter: *Counter(u64)) !void {
    const val: []const u8 = "test-val";
    try counter.add(2, .{ "abc", val });
}

fn testCounterCollect(h: *TestHarness) !void {
    for (0..1000) |_| {
        std.Io.sleep(std.testing.io, .fromNanoseconds(25), .awake) catch {};
    }

    const fetched = try h.collect();
    defer h.freeCollected(fetched);
    try std.testing.expectEqual(@as(usize, 1), fetched.len);
    try std.testing.expectEqual(@as(usize, 2), fetched[0].data.int.len);
}

test "histogram thread-safety" {
    const io = std.testing.io;
    var h = try TestHarness.init(std.testing.allocator, io);
    defer h.deinit();

    const meter = try h.mp.getMeter(.{ .name = "test-meter" });
    var hist = try meter.createHistogram(u64, .{ .name = "test-instrument" });

    const val: []const u8 = "same-val";
    try hist.record(20, .{ "same-key", val });

    const adding_job = try std.Thread.spawn(.{}, testHistogramRecordOne, .{hist});
    const fetch_compare = try std.Thread.spawn(.{}, testHistogramCollect, .{&h});
    adding_job.join();
    fetch_compare.join();
}

fn testHistogramRecordOne(histogram: *Histogram(u64)) !void {
    const val: []const u8 = "same-val";
    try histogram.record(1, .{ "same-key", val });
}

fn testHistogramCollect(h: *TestHarness) !void {
    for (0..1000) |_| {
        std.Io.sleep(std.testing.io, .fromNanoseconds(25), .awake) catch {};
    }

    const fetched = try h.collect();
    defer h.freeCollected(fetched);
    try std.testing.expectEqual(@as(usize, 1), fetched.len);
    try std.testing.expectEqual(@as(usize, 1), fetched[0].data.histogram.len);
    try std.testing.expectEqual(@as(u64, 2), fetched[0].data.histogram[0].value.count);
    try std.testing.expectEqual(@as(f64, 21), fetched[0].data.histogram[0].value.sum.?);
}

test "instrument cleans up internal state when datapoints are fetched" {
    const io = std.testing.io;
    var h = try TestHarness.init(std.testing.allocator, io);
    defer h.deinit();

    const meter = try h.mp.getMeter(.{ .name = "test-meter" });
    var c = try meter.createCounter(u64, .{ .name = "test-instrument" });

    const val: []const u8 = "test-val";
    try c.add(1, .{ "cde", val });

    const fetched = try h.collect();
    defer h.freeCollected(fetched);
    try std.testing.expectEqual(@as(usize, 0), c.storages.items[0].storage.count());
}

const MetricObserveError = AsyncInstrument.MetricObserveError;

test "async instrument registered in meter" {
    const io = std.testing.io;
    const mp = try MeterProvider.init(std.testing.allocator, io);
    defer mp.deinit();

    const background = struct {
        fn observe(_: AsyncInstrument.ObservedContext, _: std.mem.Allocator) MetricObserveError!MeasurementsData {
            return MeasurementsData{
                .int = &.{},
            };
        }
    };

    const name = "test-async-counter";
    const meter = try mp.getMeter(.{ .name = "test-meter" });

    var callbacks = [_]AsyncInstrument.ObserveMeasures{
        background.observe,
    };

    var async_counter = try meter.createObservableCounter(
        .{ .name = name },
        .{},
        &callbacks,
    );

    const data = try async_counter.measurementsData(std.testing.allocator);
    try std.testing.expectEqual(0, data.int.len);
}

test "exemplar recording snapshots caller attributes before draining" {
    const allocator = std.testing.allocator;
    const io = std.testing.io;
    var h = try TestHarness.init(allocator, io);
    defer h.deinit();

    const meter = try h.mp.getMeter(.{ .name = "exemplar-meter" });
    const counter = try meter.createCounter(u64, .{ .name = "exemplar-counter" });
    counter.exemplar_filter = .always_on;

    var value = [_]u8{ 'f', 'i', 'r', 's', 't' };
    var attrs = [_]Attribute{.{ .key = "request", .value = .{ .string = &value } }};
    const before: u64 = @intCast(std.Io.Clock.real.now(io).nanoseconds);
    try counter.addWithSlice(7, &attrs);
    const after: u64 = @intCast(std.Io.Clock.real.now(io).nanoseconds);
    @memcpy(&value, "later");

    // Disable exemplar_sampler filtering by checking the captured candidate directly before collect,
    // or collect with a view that drops the attribute so it stays in filtered_attributes.
    // Here we check the collected point attribute is "first" (not "later").
    const data = try h.collect();
    defer h.freeCollected(data);
    try std.testing.expectEqualStrings("first", data[0].data.int[0].attributes.?[0].value.string);
    const sample = data[0].data.int[0].exemplars[0];
    try std.testing.expect(sample.time_ns >= before and sample.time_ns <= after);
    try std.testing.expectEqual(@as(i64, 7), sample.value.int);
}

test "exemplar recording keeps sampled span IDs after context ends" {
    const allocator = std.testing.allocator;
    const io = std.testing.io;
    var h = try TestHarness.init(allocator, io);
    defer h.deinit();

    const meter = try h.mp.getMeter(.{ .name = "exemplar-meter" });
    const histogram = try meter.createHistogram(f64, .{ .name = "exemplar-histogram" });
    {
        defer context_api.cleanup();
        const sc = trace_api.SpanContext.init(trace_api.TraceID.init(@splat(1)), trace_api.SpanID.init(@splat(2)), .sampled(), trace_api.TraceState.init(allocator), false);
        const ctx = try trace_api.insertSpanContext(allocator, sc);
        defer trace_api.freeSerializedSpanContext(allocator, ctx);
        _ = try context_api.attachContext(ctx);
        try histogram.record(2.5, .{});
    }
    const data = try h.collect();
    defer h.freeCollected(data);
    const sample = data[0].data.histogram[0].exemplars[0];
    try std.testing.expectEqualSlices(u8, &@as([16]u8, @splat(1)), &sample.trace_id.?);
    try std.testing.expectEqualSlices(u8, &@as([8]u8, @splat(2)), &sample.span_id.?);
    try std.testing.expectEqual(@as(f64, 2.5), sample.value.double);
}

test "counter aggregates measurements in place in constant memory" {
    const io = std.testing.io;

    // Large enough for one series, far too small for 10,000 raw measurements.
    var buffer: [16 * 1024]u8 = undefined;
    var fixed = std.heap.FixedBufferAllocator.init(&buffer);
    var sum_storage = storage.SumStorage(i64).init(fixed.allocator(), io, spec.default_cardinality_limit);
    defer sum_storage.deinit();

    const route: []const u8 = "/api/v1/users";
    const attrs = [_]Attribute{
        .{ .key = "http.route", .value = .{ .string = route } },
        .{ .key = "http.status_code", .value = .{ .int = 200 } },
    };
    var candidate: ?exemplar.Exemplar = null;
    for (0..10_000) |_| {
        try sum_storage.record(1, &attrs, &candidate);
    }

    try std.testing.expectEqual(@as(usize, 1), sum_storage.count());
    try std.testing.expectEqual(@as(i64, 10_000), sum_storage.aggregated_points.values()[0].value);
}

test "counter enforces cardinality limit with overflow series" {
    const io = std.testing.io;
    var h = try TestHarness.init(std.testing.allocator, io);
    defer h.deinit();

    const meter = try h.mp.getMeter(.{ .name = "test-meter" });
    var counter = try meter.createCounter(u64, .{ .name = "high.cardinality" });
    counter.storages.items[0].storage.setCardinalityLimit(3);

    try counter.add(1, .{ "id", @as(i64, 1) });
    try counter.add(2, .{ "id", @as(i64, 2) });
    try std.testing.expectEqual(@as(usize, 2), counter.storages.items[0].storage.count());

    try counter.add(3, .{ "id", @as(i64, 3) });
    try std.testing.expectEqual(@as(usize, 3), counter.storages.items[0].storage.count());
    try counter.add(4, .{ "id", @as(i64, 4) });
    try std.testing.expectEqual(@as(usize, 3), counter.storages.items[0].storage.count());

    try counter.add(10, .{ "id", @as(i64, 1) });

    const fetched = try h.collect();
    defer h.freeCollected(fetched);

    try std.testing.expectEqual(@as(usize, 3), fetched[0].data.int.len);
    var found_overflow = false;
    for (fetched[0].data.int) |point| {
        if (point.attributes) |attrs| {
            for (attrs) |attr| {
                if (std.mem.eql(u8, attr.key, "otel.metric.overflow")) {
                    found_overflow = true;
                    try std.testing.expect(attr.value.bool);
                    try std.testing.expectEqual(@as(i64, 7), point.value);
                }
            }
        }
    }
    try std.testing.expect(found_overflow);
}

test "counter running total stored as i64 does not overflow small types" {
    const io = std.testing.io;
    var h = try TestHarness.init(std.testing.allocator, io);
    defer h.deinit();

    const meter = try h.mp.getMeter(.{ .name = "test-meter" });
    var counter = try meter.createCounter(u16, .{ .name = "small-counter" });

    try counter.add(50_000, .{ "key", @as([]const u8, "val") });
    try counter.add(50_000, .{ "key", @as([]const u8, "val") });

    const data = try h.collect();
    defer h.freeCollected(data);
    try std.testing.expectEqual(@as(i64, 100_000), data[0].data.int[0].value);
}

fn testCounterAllocationFailures(allocator: std.mem.Allocator) !void {
    const io = std.testing.io;
    var s = storage.SumStorage(i64).init(allocator, io, 2);
    defer s.deinit();

    var candidate: ?exemplar.Exemplar = null;
    const a200 = [_]Attribute{.{ .key = "status", .value = .{ .string = "200" } }};
    const a404 = [_]Attribute{.{ .key = "status", .value = .{ .string = "404" } }};
    const a500 = [_]Attribute{.{ .key = "status", .value = .{ .string = "500" } }};
    const a502 = [_]Attribute{.{ .key = "status", .value = .{ .string = "502" } }};

    try s.record(10, &a200, &candidate);
    try s.record(5, &a200, &candidate);
    try s.record(20, &a404, &candidate);
    try s.record(30, &a500, &candidate);
    try s.record(40, &a502, &candidate);

    var end_time: u64 = 0;
    const points = try s.snapshot(allocator, &end_time);
    defer {
        for (points) |*p| p.deinit(allocator);
        allocator.free(points);
    }
}

test "counter in-place aggregation handles allocation failures without leaks or double-frees" {
    try std.testing.checkAllAllocationFailures(std.testing.allocator, testCounterAllocationFailures, .{});
}

test "histogram cardinality limit creates overflow series and aggregates excess measurements" {
    const io = std.testing.io;
    var h = try TestHarness.init(std.testing.allocator, io);
    defer h.deinit();

    const meter = try h.mp.getMeter(.{ .name = "test-meter" });
    var hist = try meter.createHistogram(f64, .{ .name = "hist-cardinality" });
    hist.storages.items[0].storage.setCardinalityLimit(3);

    try hist.record(10.0, .{ "status", @as([]const u8, "200") });
    try hist.record(20.0, .{ "status", @as([]const u8, "200") });
    try hist.record(30.0, .{ "status", @as([]const u8, "404") });
    try hist.record(40.0, .{ "status", @as([]const u8, "500") });
    try hist.record(50.0, .{ "status", @as([]const u8, "502") });

    try std.testing.expectEqual(@as(usize, 3), hist.storages.items[0].storage.count());

    const data = try h.collect();
    defer h.freeCollected(data);

    try std.testing.expectEqual(@as(usize, 3), data[0].data.histogram.len);
    var found_overflow = false;
    for (data[0].data.histogram) |point| {
        if (point.attributes) |attrs| {
            for (attrs) |attr| {
                if (std.mem.eql(u8, attr.key, "otel.metric.overflow")) {
                    found_overflow = true;
                    try std.testing.expect(attr.value.bool);
                    try std.testing.expectEqual(@as(u64, 2), point.value.count);
                    try std.testing.expectEqual(@as(f64, 90.0), point.value.sum.?);
                }
            }
        }
    }
    try std.testing.expect(found_overflow);
}

test "histogram explicit buckets retain candidates per bucket" {
    const io = std.testing.io;
    var h = try TestHarness.init(std.testing.allocator, io);
    defer h.deinit();

    const meter = try h.mp.getMeter(.{ .name = "test-meter" });
    var hist = try meter.createHistogram(f64, .{ .name = "hist-exemplars" });
    hist.exemplar_filter = .always_on;

    try hist.record(-5.0, .{ "status", @as([]const u8, "200") });
    try hist.record(7.0, .{ "status", @as([]const u8, "200") });

    const data = try h.collect();
    defer h.freeCollected(data);

    try std.testing.expectEqual(@as(usize, 1), data[0].data.histogram.len);
    try std.testing.expectEqual(@as(usize, 2), data[0].data.histogram[0].exemplars.len);
}

test "exponential histogram retains exemplar candidate" {
    const io = std.testing.io;
    var h = try TestHarness.init(std.testing.allocator, io);
    defer h.deinit();
    try h.mp.addView(.{
        .instrument_selector = .{ .name = "exp-exemplar" },
        .aggregation = .{ .ExponentialBucketHistogram = try view_sdk.ExponentialBucketHistogramConfig.init(.{}) },
        .temporality = .Cumulative,
    });

    const meter = try h.mp.getMeter(.{ .name = "test-meter" });
    var hist = try meter.createHistogram(f64, .{ .name = "exp-exemplar" });
    hist.exemplar_filter = .always_on;

    try hist.record(12.5, .{ "route", @as([]const u8, "/api") });

    const data = try h.collect();
    defer h.freeCollected(data);

    try std.testing.expectEqual(@as(usize, 1), data[0].data.exponential_histogram.len);
    try std.testing.expectEqual(@as(usize, 1), data[0].data.exponential_histogram[0].exemplars.len);
    try std.testing.expectEqual(@as(f64, 12.5), data[0].data.exponential_histogram[0].exemplars[0].value.double);
}

fn testHistogramAllocationFailures(allocator: std.mem.Allocator) !void {
    const io = std.testing.io;
    var s = storage.ExplicitBucketHistogramStorage.init(
        allocator,
        io,
        2,
        spec.default_histogram_explicit_bucket_boundaries,
        true,
        true,
    );
    defer s.deinit();

    var candidate: ?exemplar.Exemplar = null;
    const a200 = [_]Attribute{.{ .key = "status", .value = .{ .string = "200" } }};
    const a404 = [_]Attribute{.{ .key = "status", .value = .{ .string = "404" } }};
    const a500 = [_]Attribute{.{ .key = "status", .value = .{ .string = "500" } }};

    try s.record(10.0, &a200, &candidate);
    try s.record(5.0, &a200, &candidate);
    try s.record(20.0, &a404, &candidate);
    try s.record(30.0, &a500, &candidate);

    var end_time: u64 = 0;
    const points = try s.snapshot(allocator, &end_time);
    defer {
        for (points) |*p| p.deinit(allocator);
        allocator.free(points);
    }
}

test "histogram in-place aggregation handles allocation failures without leaks or double-frees" {
    try std.testing.checkAllAllocationFailures(std.testing.allocator, testHistogramAllocationFailures, .{});
}

fn testHistogramBucketExemplarAllocationFailures(allocator: std.mem.Allocator) !void {
    var s = storage.ExplicitBucketHistogramStorage.init(
        allocator,
        std.testing.io,
        spec.default_cardinality_limit,
        spec.default_histogram_explicit_bucket_boundaries,
        true,
        true,
    );
    defer s.deinit();

    const a200 = [_]Attribute{.{ .key = "status", .value = .{ .string = "200" } }};
    var c1 = try exemplar.Exemplar.capture(f64, allocator, std.testing.io, -5.0, &a200, .always_on);
    defer if (c1) |*c| c.deinit(allocator);
    try s.record(-5.0, &a200, &c1);

    var c2 = try exemplar.Exemplar.capture(f64, allocator, std.testing.io, 7.0, &a200, .always_on);
    defer if (c2) |*c| c.deinit(allocator);
    try s.record(7.0, &a200, &c2);

    var end_time: u64 = 0;
    const points = try s.snapshot(allocator, &end_time);
    defer {
        for (points) |*p| p.deinit(allocator);
        allocator.free(points);
    }
}

test "histogram bucket exemplar collection handles allocation failures without leaks or double-frees" {
    try std.testing.checkAllAllocationFailures(std.testing.allocator, testHistogramBucketExemplarAllocationFailures, .{});
}
