const std = @import("std");
const clock = @import("clock");

const log = std.log.scoped(.instrument);

const spec = @import("spec.zig");
const Attribute = @import("../../attributes.zig").Attribute;
const Attributes = @import("../../attributes.zig").Attributes;
const DataPoint = @import("measurement.zig").DataPoint;
const HistogramDataPoint = @import("measurement.zig").HistogramDataPoint;
const aggregation = @import("../../sdk/metrics/aggregation.zig");
const ExponentialHistogramDataPoint = aggregation.ExponentialHistogramDataPoint;

const MeasurementsData = @import("measurement.zig").MeasurementsData;

const AsyncInstrument = @import("async_instrument.zig");

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

    pub fn getInstrumentsData(self: Self, allocator: std.mem.Allocator) !MeasurementsData {
        switch (self.data) {
            inline else => |i| {
                return i.measurementsData(allocator);
            },
        }
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

/// A Counter is a value used to record cumulative events (monotonic or bidirectional for UpDownCounter).
/// Aggregates measurements in place by attribute set to avoid unbounded memory growth.
/// See https://opentelemetry.io/docs/specs/otel/metrics/api/#counter
pub fn Counter(comptime T: type) type {
    // Widened accumulator for smaller integer variants prevents overflow before collection.
    const Accumulator = switch (T) {
        u16, u32, i16, i32 => i64,
        else => T,
    };
    return struct {
        const Self = @This();

        pub const Mode = enum {
            sum,
            last_value,
            drop,
            explicit_histogram,
            exponential_histogram,
        };

        allocator: std.mem.Allocator,
        io: std.Io,
        lock: std.Io.Mutex,

        mode: Mode = .sum,
        cardinality_limit: usize = 2000,

        /// Aggregated measurement values keyed by distinct attribute sets.
        /// Aggregates in place at record time so memory remains bounded by attribute cardinality.
        points: std.ArrayHashMapUnmanaged(
            Attributes,
            Accumulator,
            Attributes.ArrayHashContext,
            true,
        ),

        // Explicit histogram configuration & state (when mapped via a View)
        buckets: []const f64 = spec.default_histogram_explicit_bucket_boundaries,
        record_min_max: bool = true,
        record_sum: bool = true,
        explicit_points: std.ArrayHashMapUnmanaged(
            Attributes,
            HistogramDataPoint,
            Attributes.ArrayHashContext,
            true,
        ) = .empty,

        // Exponential histogram configuration & state (when mapped via a View)
        max_scale: i32 = 20,
        max_size: u32 = 1024,
        exponential_points: std.ArrayHashMapUnmanaged(
            Attributes,
            aggregation.ExponentialHistogramState,
            Attributes.ArrayHashContext,
            true,
        ) = .empty,

        fn init(allocator: std.mem.Allocator, io: std.Io) Self {
            return Self{
                .points = .empty,
                .allocator = allocator,
                .io = io,
                .lock = std.Io.Mutex.init,
            };
        }

        fn deinit(self: *Self) void {
            for (self.points.keys()) |key| {
                if (key.attributes) |attrs| {
                    self.allocator.free(attrs);
                }
            }
            self.points.deinit(self.allocator);

            for (self.explicit_points.keys(), self.explicit_points.values()) |key, val| {
                if (key.attributes) |attrs| {
                    self.allocator.free(attrs);
                }
                self.allocator.free(val.bucket_counts);
            }
            self.explicit_points.deinit(self.allocator);

            for (self.exponential_points.keys(), self.exponential_points.values()) |key, *val| {
                if (key.attributes) |attrs| {
                    self.allocator.free(attrs);
                }
                val.deinit(self.allocator);
            }
            self.exponential_points.deinit(self.allocator);
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
            self.lock.lockUncancelable(self.io);
            defer self.lock.unlock(self.io);

            switch (self.mode) {
                .drop => return,
                .sum, .last_value => {
                    const key = Attributes.with(attributes);
                    if (self.points.getPtr(key)) |val_ptr| {
                        if (self.mode == .sum) {
                            val_ptr.* += @as(Accumulator, delta);
                        } else {
                            val_ptr.* = @as(Accumulator, delta);
                        }
                        return;
                    }

                    // OpenTelemetry 1.48.0: Aggregate excess measurements into overflow series (otel.metric.overflow=true)
                    const overflow_attr = Attribute{ .key = "otel.metric.overflow", .value = .{ .bool = true } };
                    var overflow_slice = [_]Attribute{overflow_attr};
                    const overflow_key = Attributes.with(&overflow_slice);

                    if (self.points.count() >= self.cardinality_limit or
                        (self.points.count() >= self.cardinality_limit - 1 and self.points.get(overflow_key) == null))
                    {
                        if (self.points.getPtr(overflow_key)) |overflow_ptr| {
                            if (self.mode == .sum) {
                                overflow_ptr.* += @as(Accumulator, delta);
                            } else {
                                overflow_ptr.* = @as(Accumulator, delta);
                            }
                            return;
                        }
                        log.warn("cardinality limit {d} reached; aggregating excess measurements into overflow series", .{self.cardinality_limit});
                        const owned_attrs = try self.allocator.dupe(Attribute, &overflow_slice);
                        errdefer self.allocator.free(owned_attrs);
                        try self.points.put(self.allocator, Attributes.with(owned_attrs), @as(Accumulator, delta));
                        return;
                    }

                    const owned_attrs = if (attributes) |attrs|
                        try self.allocator.dupe(Attribute, attrs)
                    else
                        null;
                    errdefer if (owned_attrs) |a| self.allocator.free(a);

                    try self.points.put(self.allocator, Attributes.with(owned_attrs), @as(Accumulator, delta));
                },
                .explicit_histogram => {
                    const f64_val: f64 = switch (T) {
                        u16, u32, u64, i16, i32, i64 => @as(f64, @floatFromInt(delta)),
                        f32, f64 => @as(f64, delta),
                        else => unreachable,
                    };

                    const key = Attributes.with(attributes);
                    if (self.explicit_points.getPtr(key)) |dp| {
                        if (self.record_sum) {
                            dp.sum = (dp.sum orelse 0) + f64_val;
                        }
                        dp.count += 1;
                        if (self.record_min_max) {
                            dp.min = if (dp.min) |curr| @min(curr, f64_val) else f64_val;
                            dp.max = if (dp.max) |curr| @max(curr, f64_val) else f64_val;
                        }
                        var bucket_index = self.buckets.len;
                        for (self.buckets, 0..) |boundary, i| {
                            if (f64_val <= boundary) {
                                bucket_index = i;
                                break;
                            }
                        }
                        dp.bucket_counts[bucket_index] += 1;
                        return;
                    }

                    const overflow_attr = Attribute{ .key = "otel.metric.overflow", .value = .{ .bool = true } };
                    var overflow_slice = [_]Attribute{overflow_attr};
                    const overflow_key = Attributes.with(&overflow_slice);

                    const target_key = if (self.explicit_points.count() >= self.cardinality_limit or
                        (self.explicit_points.count() >= self.cardinality_limit - 1 and self.explicit_points.get(overflow_key) == null))
                        overflow_key
                    else
                        key;

                    if (self.explicit_points.getPtr(target_key)) |dp| {
                        if (self.record_sum) {
                            dp.sum = (dp.sum orelse 0) + f64_val;
                        }
                        dp.count += 1;
                        if (self.record_min_max) {
                            dp.min = if (dp.min) |curr| @min(curr, f64_val) else f64_val;
                            dp.max = if (dp.max) |curr| @max(curr, f64_val) else f64_val;
                        }
                        var bucket_index = self.buckets.len;
                        for (self.buckets, 0..) |boundary, i| {
                            if (f64_val <= boundary) {
                                bucket_index = i;
                                break;
                            }
                        }
                        dp.bucket_counts[bucket_index] += 1;
                        return;
                    }

                    const bucket_counts = try self.allocator.alloc(u64, self.buckets.len + 1);
                    errdefer self.allocator.free(bucket_counts);
                    @memset(bucket_counts, 0);

                    var bucket_index = self.buckets.len;
                    for (self.buckets, 0..) |boundary, i| {
                        if (f64_val <= boundary) {
                            bucket_index = i;
                            break;
                        }
                    }
                    bucket_counts[bucket_index] = 1;

                    const dp = HistogramDataPoint{
                        .explicit_bounds = self.buckets,
                        .bucket_counts = bucket_counts,
                        .sum = if (self.record_sum) f64_val else null,
                        .count = 1,
                        .min = if (self.record_min_max) f64_val else null,
                        .max = if (self.record_min_max) f64_val else null,
                    };

                    const attrs_to_dupe = if (target_key.attributes) |attrs| attrs else attributes;
                    const owned_attrs = if (attrs_to_dupe) |attrs|
                        try self.allocator.dupe(Attribute, attrs)
                    else
                        null;
                    errdefer if (owned_attrs) |a| self.allocator.free(a);

                    try self.explicit_points.put(self.allocator, Attributes.with(owned_attrs), dp);
                },
                .exponential_histogram => {
                    const f64_val: f64 = switch (T) {
                        u16, u32, u64, i16, i32, i64 => @as(f64, @floatFromInt(delta)),
                        f32, f64 => @as(f64, delta),
                        else => unreachable,
                    };

                    const key = Attributes.with(attributes);
                    if (self.exponential_points.getPtr(key)) |state_ptr| {
                        try state_ptr.addValue(self.allocator, f64_val, self.max_size, self.record_min_max, self.record_sum);
                        return;
                    }

                    const overflow_attr = Attribute{ .key = "otel.metric.overflow", .value = .{ .bool = true } };
                    var overflow_slice = [_]Attribute{overflow_attr};
                    const overflow_key = Attributes.with(&overflow_slice);

                    const target_key = if (self.exponential_points.count() >= self.cardinality_limit or
                        (self.exponential_points.count() >= self.cardinality_limit - 1 and self.exponential_points.get(overflow_key) == null))
                        overflow_key
                    else
                        key;

                    if (self.exponential_points.getPtr(target_key)) |state_ptr| {
                        try state_ptr.addValue(self.allocator, f64_val, self.max_size, self.record_min_max, self.record_sum);
                        return;
                    }

                    var state = aggregation.ExponentialHistogramState.init(self.allocator, self.max_scale);
                    errdefer state.deinit(self.allocator);
                    try state.addValue(self.allocator, f64_val, self.max_size, self.record_min_max, self.record_sum);

                    const attrs_to_dupe = if (target_key.attributes) |attrs| attrs else attributes;
                    const owned_attrs = if (attrs_to_dupe) |attrs|
                        try self.allocator.dupe(Attribute, attrs)
                    else
                        null;
                    errdefer if (owned_attrs) |a| self.allocator.free(a);

                    try self.exponential_points.put(self.allocator, Attributes.with(owned_attrs), state);
                },
            }
        }

        fn measurementsData(self: *Self, allocator: std.mem.Allocator) !MeasurementsData {
            self.lock.lockUncancelable(self.io);
            defer self.lock.unlock(self.io);

            switch (self.mode) {
                .sum, .last_value => {
                    defer {
                        for (self.points.keys()) |key| {
                            if (key.attributes) |attrs| {
                                self.allocator.free(attrs);
                            }
                        }
                        self.points.clearRetainingCapacity();
                    }

                    switch (T) {
                        u16, u32, u64, i16, i32, i64 => {
                            const count = self.points.count();
                            var data = try allocator.alloc(DataPoint(i64), count);
                            var success_count: usize = 0;
                            errdefer {
                                for (data[0..success_count]) |*dp| {
                                    if (dp.attributes) |attrs| allocator.free(attrs);
                                }
                                allocator.free(data);
                            }

                            for (self.points.keys(), self.points.values(), 0..) |key, val, idx| {
                                data[idx] = .{
                                    .value = @intCast(val),
                                    .attributes = try key.dupe(allocator),
                                };
                                success_count += 1;
                            }
                            return .{ .int = data };
                        },
                        else => unreachable,
                    }
                },
                .drop => {
                    return .{ .int = &.{} };
                },
                .explicit_histogram => {
                    defer {
                        for (self.explicit_points.keys(), self.explicit_points.values()) |key, val| {
                            if (key.attributes) |attrs| {
                                self.allocator.free(attrs);
                            }
                            self.allocator.free(val.bucket_counts);
                        }
                        self.explicit_points.clearRetainingCapacity();
                    }

                    const count = self.explicit_points.count();
                    var data = try allocator.alloc(DataPoint(HistogramDataPoint), count);
                    var success_count: usize = 0;
                    errdefer {
                        for (data[0..success_count]) |*dp| {
                            dp.deinit(allocator);
                        }
                        allocator.free(data);
                    }

                    for (self.explicit_points.keys(), self.explicit_points.values(), 0..) |key, val, idx| {
                        data[idx] = .{
                            .value = .{
                                .explicit_bounds = val.explicit_bounds,
                                .bucket_counts = try allocator.dupe(u64, val.bucket_counts),
                                .sum = val.sum,
                                .count = val.count,
                                .min = val.min,
                                .max = val.max,
                            },
                            .attributes = try key.dupe(allocator),
                        };
                        success_count += 1;
                    }

                    return .{ .histogram = data };
                },
                .exponential_histogram => {
                    defer {
                        for (self.exponential_points.keys(), self.exponential_points.values()) |key, *val| {
                            if (key.attributes) |attrs| {
                                self.allocator.free(attrs);
                            }
                            val.deinit(self.allocator);
                        }
                        self.exponential_points.clearRetainingCapacity();
                    }

                    const count = self.exponential_points.count();
                    var data = try allocator.alloc(DataPoint(ExponentialHistogramDataPoint), count);
                    var success_count: usize = 0;
                    errdefer {
                        for (data[0..success_count]) |*dp| {
                            dp.deinit(allocator);
                        }
                        allocator.free(data);
                    }

                    for (self.exponential_points.keys(), self.exponential_points.values(), 0..) |key, *val, idx| {
                        data[idx] = .{
                            .value = try val.toDataPoint(allocator),
                            .attributes = try key.dupe(allocator),
                        };
                        success_count += 1;
                    }

                    return .{ .exponential_histogram = data };
                },
            }
        }
    };
}

/// A Histogram is used to sample observations and count them in pre-defined buckets.
/// Aggregates measurements in place by attribute set to avoid unbounded memory growth.
/// See https://opentelemetry.io/docs/specs/otel/metrics/api/#histogram
pub fn Histogram(comptime T: type) type {
    return struct {
        const Self = @This();

        pub const Mode = enum {
            explicit,
            exponential,
        };

        allocator: std.mem.Allocator,
        io: std.Io,
        lock: std.Io.Mutex,

        mode: Mode = .explicit,
        cardinality_limit: usize = 2000,

        // Explicit bucket configuration
        buckets: []const f64 = spec.default_histogram_explicit_bucket_boundaries,
        record_min_max: bool = true,
        record_sum: bool = true,

        /// Aggregated explicit bucket measurement values keyed by distinct attribute sets.
        explicit_points: std.ArrayHashMapUnmanaged(
            Attributes,
            HistogramDataPoint,
            Attributes.ArrayHashContext,
            true,
        ),

        // Exponential bucket configuration
        max_scale: i32 = 20,
        max_size: u32 = 1024,

        /// Aggregated exponential bucket measurement values keyed by distinct attribute sets.
        exponential_points: std.ArrayHashMapUnmanaged(
            Attributes,
            aggregation.ExponentialHistogramState,
            Attributes.ArrayHashContext,
            true,
        ),

        fn init(allocator: std.mem.Allocator, io: std.Io) Self {
            return Self{
                .allocator = allocator,
                .io = io,
                .lock = std.Io.Mutex.init,
                .explicit_points = .empty,
                .exponential_points = .empty,
            };
        }

        fn deinit(self: *Self) void {
            for (self.explicit_points.keys(), self.explicit_points.values()) |key, val| {
                if (key.attributes) |attrs| {
                    self.allocator.free(attrs);
                }
                self.allocator.free(val.bucket_counts);
            }
            self.explicit_points.deinit(self.allocator);

            for (self.exponential_points.keys(), self.exponential_points.values()) |key, *val| {
                if (key.attributes) |attrs| {
                    self.allocator.free(attrs);
                }
                val.deinit(self.allocator);
            }
            self.exponential_points.deinit(self.allocator);
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
            self.lock.lockUncancelable(self.io);
            defer self.lock.unlock(self.io);

            const f64_val: f64 = switch (T) {
                u16, u32, u64, i16, i32, i64 => @as(f64, @floatFromInt(value)),
                f32, f64 => @as(f64, value),
                else => unreachable,
            };

            const key = Attributes.with(attributes);

            switch (self.mode) {
                .explicit => {
                    if (self.explicit_points.getPtr(key)) |dp| {
                        if (self.record_sum) {
                            dp.sum = (dp.sum orelse 0) + f64_val;
                        }
                        dp.count += 1;
                        if (self.record_min_max) {
                            dp.min = if (dp.min) |curr| @min(curr, f64_val) else f64_val;
                            dp.max = if (dp.max) |curr| @max(curr, f64_val) else f64_val;
                        }
                        var bucket_index = self.buckets.len;
                        for (self.buckets, 0..) |boundary, i| {
                            if (f64_val <= boundary) {
                                bucket_index = i;
                                break;
                            }
                        }
                        dp.bucket_counts[bucket_index] += 1;
                        return;
                    }

                    if (self.explicit_points.count() >= self.cardinality_limit) {
                        log.warn("cardinality limit {d} reached; dropping new attribute set", .{self.cardinality_limit});
                        return;
                    }

                    const bucket_counts = try self.allocator.alloc(u64, self.buckets.len + 1);
                    errdefer self.allocator.free(bucket_counts);
                    @memset(bucket_counts, 0);

                    var bucket_index = self.buckets.len;
                    for (self.buckets, 0..) |boundary, i| {
                        if (f64_val <= boundary) {
                            bucket_index = i;
                            break;
                        }
                    }
                    bucket_counts[bucket_index] = 1;

                    const dp = HistogramDataPoint{
                        .explicit_bounds = self.buckets,
                        .bucket_counts = bucket_counts,
                        .sum = if (self.record_sum) f64_val else null,
                        .count = 1,
                        .min = if (self.record_min_max) f64_val else null,
                        .max = if (self.record_min_max) f64_val else null,
                    };

                    const owned_attrs = if (attributes) |attrs|
                        try self.allocator.dupe(Attribute, attrs)
                    else
                        null;
                    errdefer if (owned_attrs) |a| self.allocator.free(a);

                    try self.explicit_points.put(self.allocator, Attributes.with(owned_attrs), dp);
                },
                .exponential => {
                    if (self.exponential_points.getPtr(key)) |state_ptr| {
                        try state_ptr.addValue(self.allocator, f64_val, self.max_size, self.record_min_max, self.record_sum);
                        return;
                    }

                    if (self.exponential_points.count() >= self.cardinality_limit) {
                        log.warn("cardinality limit {d} reached; dropping new attribute set", .{self.cardinality_limit});
                        return;
                    }

                    var state = aggregation.ExponentialHistogramState.init(self.allocator, self.max_scale);
                    errdefer state.deinit(self.allocator);
                    try state.addValue(self.allocator, f64_val, self.max_size, self.record_min_max, self.record_sum);

                    const owned_attrs = if (attributes) |attrs|
                        try self.allocator.dupe(Attribute, attrs)
                    else
                        null;
                    errdefer if (owned_attrs) |a| self.allocator.free(a);

                    try self.exponential_points.put(self.allocator, Attributes.with(owned_attrs), state);
                },
            }
        }

        fn measurementsData(self: *Self, allocator: std.mem.Allocator) !MeasurementsData {
            self.lock.lockUncancelable(self.io);
            defer self.lock.unlock(self.io);

            switch (self.mode) {
                .explicit => {
                    const count = self.explicit_points.count();
                    var data = try allocator.alloc(DataPoint(HistogramDataPoint), count);
                    var success_count: usize = 0;
                    errdefer {
                        for (data[0..success_count]) |*dp| {
                            dp.deinit(allocator);
                        }
                        allocator.free(data);
                    }

                    for (self.explicit_points.keys(), self.explicit_points.values(), 0..) |key, val, idx| {
                        data[idx] = .{
                            .value = .{
                                .explicit_bounds = val.explicit_bounds,
                                .bucket_counts = try allocator.dupe(u64, val.bucket_counts),
                                .sum = val.sum,
                                .count = val.count,
                                .min = val.min,
                                .max = val.max,
                            },
                            .attributes = try key.dupe(allocator),
                        };
                        success_count += 1;
                    }

                    for (self.explicit_points.keys(), self.explicit_points.values()) |key, val| {
                        if (key.attributes) |attrs| {
                            self.allocator.free(attrs);
                        }
                        self.allocator.free(val.bucket_counts);
                    }
                    self.explicit_points.clearRetainingCapacity();

                    return .{ .histogram = data };
                },
                .exponential => {
                    const count = self.exponential_points.count();
                    var data = try allocator.alloc(DataPoint(ExponentialHistogramDataPoint), count);
                    var success_count: usize = 0;
                    errdefer {
                        for (data[0..success_count]) |*dp| {
                            dp.deinit(allocator);
                        }
                        allocator.free(data);
                    }

                    for (self.exponential_points.keys(), self.exponential_points.values(), 0..) |key, *val, idx| {
                        data[idx] = .{
                            .value = try val.toDataPoint(allocator),
                            .attributes = try key.dupe(allocator),
                        };
                        success_count += 1;
                    }

                    for (self.exponential_points.keys(), self.exponential_points.values()) |key, *val| {
                        if (key.attributes) |attrs| {
                            self.allocator.free(attrs);
                        }
                        val.deinit(self.allocator);
                    }
                    self.exponential_points.clearRetainingCapacity();

                    return .{ .exponential_histogram = data };
                },
            }
        }
    };
}

pub fn Gauge(comptime T: type) type {
    return struct {
        const Self = @This();

        allocator: std.mem.Allocator,
        io: std.Io,
        lock: std.Io.Mutex,

        data_points: std.ArrayListUnmanaged(DataPoint(T)),

        fn init(allocator: std.mem.Allocator, io: std.Io) Self {
            return Self{
                .allocator = allocator,
                .io = io,
                .data_points = .empty,
                .lock = std.Io.Mutex.init,
            };
        }

        fn deinit(self: *Self) void {
            for (self.data_points.items) |*m| {
                m.deinit(self.allocator);
            }
            self.data_points.deinit(self.allocator);
        }

        /// Record the given value to the gauge, using the provided attributes.
        pub fn record(self: *Self, value: T, attributes: anytype) !void {
            self.lock.lockUncancelable(self.io);
            defer self.lock.unlock(self.io);

            const dp = try DataPoint(T).new(self.allocator, value, attributes);
            try self.data_points.append(self.allocator, dp);
        }

        /// Record a value with a pre-built attribute slice.
        /// This is primarily used for C interop where attributes are passed as a slice.
        pub fn recordWithSlice(self: *Self, value: T, attributes: ?[]Attribute) !void {
            self.lock.lockUncancelable(self.io);
            defer self.lock.unlock(self.io);

            const dp = DataPoint(T){
                .value = value,
                .attributes = if (attributes) |attrs|
                    try self.allocator.dupe(Attribute, attrs)
                else
                    null,
            };
            try self.data_points.append(self.allocator, dp);
        }

        fn measurementsData(self: *Self, allocator: std.mem.Allocator) !MeasurementsData {
            self.lock.lockUncancelable(self.io);
            defer self.lock.unlock(self.io);

            defer {
                for (self.data_points.items) |*dp| {
                    dp.deinit(self.allocator);
                }
                self.data_points.clearRetainingCapacity();
            }

            switch (T) {
                i16, i32, i64 => {
                    var data = try allocator.alloc(DataPoint(i64), self.data_points.items.len);
                    for (self.data_points.items, 0..) |m, idx| {
                        data[idx] = .{
                            .value = @intCast(m.value),
                            .attributes = try Attributes.with(m.attributes).dupe(allocator),
                        };
                    }
                    return .{ .int = data };
                },
                f32, f64 => {
                    var data = try allocator.alloc(DataPoint(f64), self.data_points.items.len);
                    for (self.data_points.items, 0..) |m, idx| {
                        data[idx] = .{
                            .value = @floatCast(m.value),
                            .attributes = try Attributes.with(m.attributes).dupe(allocator),
                        };
                    }
                    return .{ .double = data };
                },
                else => unreachable,
            }
        }
    };
}

const MeterProvider = @import("meter.zig").MeterProvider;

test "counter with unsupported type does not leak" {
    const io = std.testing.io;
    const mp = try MeterProvider.init(std.testing.allocator, io);
    defer mp.shutdown();
    const meter = try mp.getMeter(.{ .name = "my-meter" });
    const err = meter.createCounter(u1, .{ .name = "a-counter" });
    try std.testing.expectError(spec.FormatError.UnsupportedValueType, err);
}

test "meter can create counter instrument and record increase without attributes" {
    const io = std.testing.io;
    const mp = try MeterProvider.init(std.testing.allocator, io);
    defer mp.shutdown();
    const meter = try mp.getMeter(.{ .name = "my-meter" });
    var counter = try meter.createCounter(u32, .{ .name = "a-counter" });

    try counter.add(10, .{});
    std.debug.assert(counter.points.count() == 1);
    try std.testing.expectEqual(10, counter.points.values()[0]);
}

test "meter can create counter instrument and record increase with attributes" {
    const io = std.testing.io;
    const mp = try MeterProvider.init(std.testing.allocator, io);
    defer mp.shutdown();
    const meter = try mp.getMeter(.{ .name = "my-meter" });
    var counter = try meter.createCounter(u32, .{
        .name = "a-counter",
        .description = "a funny counter",
        .unit = "KiB",
    });

    try counter.add(100, .{});
    try counter.add(1000, .{});

    // Identical attributes aggregate in place at record time
    std.debug.assert(counter.points.count() == 1);
    std.debug.assert(counter.points.values()[0] == 1100);

    const val1: []const u8 = "some-value";
    const val2: []const u8 = "another-value";

    try counter.add(2, .{ "some-key", val1, "another-key", val2 });
    // Distinct attributes create a new series
    std.debug.assert(counter.points.count() == 2);
    std.debug.assert(counter.points.values()[1] == 2);
}

test "histogram records value without explicit buckets" {
    const io = std.testing.io;
    const mp = try MeterProvider.init(std.testing.allocator, io);
    defer mp.shutdown();
    const meter = try mp.getMeter(.{ .name = "my-meter" });
    var histogram = try meter.createHistogram(u32, .{ .name = "anything" });

    try histogram.record(1, .{});
    try histogram.record(5, .{});
    try histogram.record(15, .{});

    // Aggregates in place at record time: single attribute set yields 1 HistogramDataPoint
    const measurements = try histogram.measurementsData(std.testing.allocator);
    defer {
        for (measurements.histogram) |*dp| {
            dp.deinit(std.testing.allocator);
        }
        std.testing.allocator.free(measurements.histogram);
    }

    try std.testing.expectEqual(1, measurements.histogram.len);
    const dp = measurements.histogram[0].value;
    try std.testing.expectEqual(3, dp.count);
    try std.testing.expectEqual(21, dp.sum.?);
    try std.testing.expectEqual(1, dp.min.?);
    try std.testing.expectEqual(15, dp.max.?);
}

test "histogram records value with explicit buckets" {
    const io = std.testing.io;
    const mp = try MeterProvider.init(std.testing.allocator, io);
    defer mp.shutdown();
    const meter = try mp.getMeter(.{ .name = "my-meter" });
    var histogram = try meter.createHistogram(u32, .{ .name = "a-histogram" });
    histogram.buckets = &[_]f64{ 2.0, 10.0 };

    try histogram.record(1, .{});
    try histogram.record(5, .{});
    try histogram.record(15, .{});

    try std.testing.expectEqual(1, histogram.explicit_points.count());

    const measurements = try histogram.measurementsData(std.testing.allocator);
    defer {
        for (measurements.histogram) |*dp| {
            dp.deinit(std.testing.allocator);
        }
        std.testing.allocator.free(measurements.histogram);
    }

    try std.testing.expectEqual(1, measurements.histogram.len);
    const dp = measurements.histogram[0].value;
    try std.testing.expectEqual(3, dp.count);
    try std.testing.expectEqual(21, dp.sum.?);
    try std.testing.expectEqual(1, dp.min.?);
    try std.testing.expectEqual(15, dp.max.?);
    // Buckets: <= 2.0 (1), <= 10.0 (1), > 10.0 (1)
    try std.testing.expectEqual(3, dp.bucket_counts.len);
    try std.testing.expectEqual(1, dp.bucket_counts[0]);
    try std.testing.expectEqual(1, dp.bucket_counts[1]);
    try std.testing.expectEqual(1, dp.bucket_counts[2]);
}

test "histogram keeps track of bucket counts by attribute" {
    const io = std.testing.io;
    const mp = try MeterProvider.init(std.testing.allocator, io);
    defer mp.shutdown();
    const meter = try mp.getMeter(.{ .name = "my-meter" });
    var histogram = try meter.createHistogram(u32, .{ .name = "a-histogram" });

    const val: []const u8 = "some-value";
    try histogram.record(1, .{ "some-key", val });
    try histogram.record(1000, .{ "other-key", val });

    try std.testing.expectEqual(2, histogram.explicit_points.count());

    const measurements = try histogram.measurementsData(std.testing.allocator);
    defer {
        for (measurements.histogram) |*dp| {
            dp.deinit(std.testing.allocator);
        }
        std.testing.allocator.free(measurements.histogram);
    }

    try std.testing.expectEqual(2, measurements.histogram.len);
}

test "histogram keeps track of count, sum and min/max by attribute" {
    const io = std.testing.io;
    const mp = try MeterProvider.init(std.testing.allocator, io);
    defer mp.shutdown();
    const meter = try mp.getMeter(.{ .name = "my-meter" });
    var histogram = try meter.createHistogram(u32, .{ .name = "a-histogram" });

    const val: []const u8 = "some-val";
    try histogram.record(1, .{});
    try histogram.record(5, .{ "key", val });
    try histogram.record(15, .{ "key", val });

    std.debug.assert(histogram.explicit_points.count() == 2);

    const measurements = try histogram.measurementsData(std.testing.allocator);
    defer {
        for (measurements.histogram) |*dp| {
            dp.deinit(std.testing.allocator);
        }
        std.testing.allocator.free(measurements.histogram);
    }

    // 2 attribute sets: empty attributes and {"key": "some-val"}
    try std.testing.expectEqual(2, measurements.histogram.len);

    var found_empty = false;
    var found_key = false;

    for (measurements.histogram) |dp| {
        if (dp.attributes == null) {
            found_empty = true;
            try std.testing.expectEqual(1, dp.value.count);
            try std.testing.expectEqual(1, dp.value.sum.?);
            try std.testing.expectEqual(1, dp.value.min.?);
            try std.testing.expectEqual(1, dp.value.max.?);
        } else {
            found_key = true;
            try std.testing.expectEqual(2, dp.value.count);
            try std.testing.expectEqual(20, dp.value.sum.?);
            try std.testing.expectEqual(5, dp.value.min.?);
            try std.testing.expectEqual(15, dp.value.max.?);
        }
    }

    try std.testing.expect(found_empty);
    try std.testing.expect(found_key);
}

test "histogram aggregates measurements in place without growing memory" {
    const io = std.testing.io;
    const mp = try MeterProvider.init(std.testing.allocator, io);
    defer mp.shutdown();
    const meter = try mp.getMeter(.{ .name = "my-meter" });
    var histogram = try meter.createHistogram(f64, .{ .name = "latency" });

    const val: []const u8 = "127.0.0.1";
    for (0..10_000) |i| {
        try histogram.record(@floatFromInt(i % 100), .{ "server.address", val });
    }

    // Must be exactly 1 series in memory despite 10,000 recordings
    try std.testing.expectEqual(1, histogram.explicit_points.count());

    const measurements = try histogram.measurementsData(std.testing.allocator);
    defer {
        for (measurements.histogram) |*dp| {
            dp.deinit(std.testing.allocator);
        }
        std.testing.allocator.free(measurements.histogram);
    }

    try std.testing.expectEqual(1, measurements.histogram.len);
    try std.testing.expectEqual(10_000, measurements.histogram[0].value.count);
}

test "histogram enforces cardinality limit" {
    const io = std.testing.io;
    const mp = try MeterProvider.init(std.testing.allocator, io);
    defer mp.shutdown();
    const meter = try mp.getMeter(.{ .name = "my-meter" });
    var histogram = try meter.createHistogram(u32, .{ .name = "cardinality-test" });
    histogram.cardinality_limit = 2;

    try histogram.record(1, .{ "attr", @as([]const u8, "a") });
    try histogram.record(2, .{ "attr", @as([]const u8, "b") });
    try histogram.record(3, .{ "attr", @as([]const u8, "c") }); // dropped

    try std.testing.expectEqual(2, histogram.explicit_points.count());
}

test "histogram exponential bucket mode aggregates in place" {
    const io = std.testing.io;
    const mp = try MeterProvider.init(std.testing.allocator, io);
    defer mp.shutdown();
    const meter = try mp.getMeter(.{ .name = "my-meter" });
    var histogram = try meter.createHistogram(f64, .{ .name = "exp-test" });
    histogram.mode = .exponential;
    histogram.max_scale = 10;
    histogram.max_size = 4;

    try histogram.record(1.0, .{});
    try histogram.record(2.0, .{});
    try histogram.record(4.0, .{});

    try std.testing.expectEqual(1, histogram.exponential_points.count());

    const measurements = try histogram.measurementsData(std.testing.allocator);
    defer {
        for (measurements.exponential_histogram) |*dp| {
            dp.deinit(std.testing.allocator);
        }
        std.testing.allocator.free(measurements.exponential_histogram);
    }

    try std.testing.expectEqual(1, measurements.exponential_histogram.len);
    const dp = measurements.exponential_histogram[0].value;
    try std.testing.expectEqual(3, dp.count);
    try std.testing.expectEqual(7.0, dp.sum.?);
}

test "gauge instrument records value without attributes" {
    const io = std.testing.io;
    const mp = try MeterProvider.init(std.testing.allocator, io);
    defer mp.shutdown();
    const meter = try mp.getMeter(.{ .name = "my-meter" });
    var gauge = try meter.createGauge(i16, .{ .name = "a-gauge" });

    try gauge.record(42, .{});
    try gauge.record(-42, .{});
    std.debug.assert(gauge.data_points.items.len == 2);
    std.debug.assert(gauge.data_points.pop().?.value == -42);
}

test "upDownCounter instrument records and stores value" {
    const io = std.testing.io;
    const mp = try MeterProvider.init(std.testing.allocator, io);
    defer mp.shutdown();
    const meter = try mp.getMeter(.{ .name = "my-meter" });
    var counter = try meter.createUpDownCounter(i32, .{ .name = "up-down-counter" });

    try counter.add(10, .{});
    try counter.add(-5, .{});
    try counter.add(-4, .{});
    // Aggregates in place for the same attribute set
    std.debug.assert(counter.points.count() == 1);
    try std.testing.expectEqual(1, counter.points.values()[0]);

    try counter.add(1, .{ "some-key", @as(i64, 42) });

    std.debug.assert(counter.points.count() == 2);
    try std.testing.expectEqual(1, counter.points.values()[1]);
}

test "instrument in meter and instrument in data are the same" {
    const io = std.testing.io;
    const mp = try MeterProvider.init(std.testing.allocator, io);
    defer mp.shutdown();

    const name = "test-instrument";

    const meter = try mp.getMeter(.{ .name = "test-meter" });

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

        const counter_value = instrument.data.Counter_u64.points.get(Attributes.with(null)) orelse unreachable;
        try std.testing.expectEqual(100, counter_value);
    } else {
        std.debug.panic("Counter {s} not found in meter {s} after creation", .{ name, meter.scope.name });
    }
}

test "instrument fetches measurements from inner" {
    const io = std.testing.io;
    const mp = try MeterProvider.init(std.testing.allocator, io);
    defer mp.shutdown();

    const name = "test-instrument";

    const meter = try mp.getMeter(.{ .name = "test-meter" });

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
        const measurements = try instrument.getInstrumentsData(std.testing.allocator);
        defer switch (measurements) {
            inline else => |list| std.testing.allocator.free(list),
        };

        std.debug.assert(measurements.int.len == 1);
        try std.testing.expectEqual(@as(i64, 100), measurements.int[0].value);
    } else {
        std.debug.panic("Counter {s} not found in meter {s} after creation", .{ name, meter.scope.name });
    }
}

test "counter thread-safety between datapoints collection and recording" {
    const io = std.testing.io;
    const mp = try MeterProvider.init(std.testing.allocator, io);
    defer mp.shutdown();

    const name = "test-instrument";

    const meter = try mp.getMeter(.{ .name = "test-meter" });

    var c = try meter.createCounter(u64, .{ .name = name });

    // We use attributes to perform memory allocation,
    // slowing down the add() call, retaining the lock
    // for longer
    const val: []const u8 = "test-val";
    try c.add(1, .{ "cde", val });

    const adding_job = try std.Thread.spawn(.{}, testCounterAddingOne, .{c});
    const fetch_compare = try std.Thread.spawn(.{}, testCounterCollect, .{c});
    adding_job.join();
    fetch_compare.join();
}

fn testCounterAddingOne(counter: *Counter(u64)) !void {
    const val: []const u8 = "test-val";
    try counter.add(2, .{ "abc", val });
}

fn testCounterCollect(counter: *Counter(u64)) !void {
    // FIXME flaky test can result in failure, so we added a sleep but we should find a more robust solution.
    for (0..1000) |_| {
        counter.lock.lockUncancelable(counter.io);
        counter.lock.unlock(counter.io);
        clock.sleep(25);
    }

    const fetched = try counter.measurementsData(std.testing.allocator);
    defer {
        for (fetched.int) |*m| {
            m.deinit(std.testing.allocator);
        }
        std.testing.allocator.free(fetched.int);
    }
    // Assert that we have 2 data points: the first added by the test thread,
    // the second added by `testAddingOne` called in a separate thread.
    try std.testing.expectEqual(2, fetched.int.len);
    try std.testing.expectEqual(1, fetched.int[0].value);
    try std.testing.expectEqual(2, fetched.int[1].value);
}

test "histogram thread-safety" {
    const io = std.testing.io;
    const mp = try MeterProvider.init(std.testing.allocator, io);
    defer mp.shutdown();

    const name = "test-instrument";

    const meter = try mp.getMeter(.{ .name = "test-meter" });

    var h = try meter.createHistogram(u64, .{ .name = name });

    const val: []const u8 = "same-val";
    try h.record(20, .{ "same-key", val });

    const adding_job = try std.Thread.spawn(.{}, testHistogramRecordOne, .{h});
    const fetch_compare = try std.Thread.spawn(.{}, testHistogramCollect, .{h});
    adding_job.join();
    fetch_compare.join();
}

fn testHistogramRecordOne(histogram: *Histogram(u64)) !void {
    const val: []const u8 = "same-val";
    try histogram.record(1, .{ "same-key", val });
}

fn testHistogramCollect(histogram: *Histogram(u64)) !void {
    // FIXME flaky test can result in failure, so we added a sleep but we should find a more robust solution.
    for (0..1000) |_| {
        histogram.lock.lockUncancelable(histogram.io);
        histogram.lock.unlock(histogram.io);
        clock.sleep(25);
    }

    const fetched = try histogram.measurementsData(std.testing.allocator);
    defer {
        for (fetched.histogram) |*m| {
            m.deinit(std.testing.allocator);
        }
        std.testing.allocator.free(fetched.histogram);
    }
    // Both recordings have the same attribute set, aggregating into 1 HistogramDataPoint
    try std.testing.expectEqual(1, fetched.histogram.len);
    try std.testing.expectEqual(2, fetched.histogram[0].value.count);
    try std.testing.expectEqual(21, fetched.histogram[0].value.sum.?);
}

test "instrument cleans up internal state when datapoints are fetched" {
    const io = std.testing.io;
    const mp = try MeterProvider.init(std.testing.allocator, io);
    defer mp.shutdown();

    const name = "test-instrument";

    const meter = try mp.getMeter(.{ .name = "test-meter" });

    var c = try meter.createCounter(u64, .{ .name = name });

    const val: []const u8 = "test-val";
    try c.add(1, .{ "cde", val });

    const fetched = try c.measurementsData(std.testing.allocator);
    defer {
        for (fetched.int) |*m| {
            m.deinit(std.testing.allocator);
        }
        std.testing.allocator.free(fetched.int);
    }
    // Assert that the map was cleared after fetching
    try std.testing.expectEqual(0, c.points.count());
}

test "counter aggregates measurements in place without growing memory" {
    const io = std.testing.io;
    const mp = try MeterProvider.init(std.testing.allocator, io);
    defer mp.shutdown();

    const meter = try mp.getMeter(.{ .name = "bench-meter" });
    var counter = try meter.createCounter(u64, .{ .name = "bench-counter" });

    // Repeated measurements with the same attribute set must aggregate in place
    // without creating new entries or leaking memory.
    const route: []const u8 = "/api/v1/resource";
    for (0..10_000) |_| {
        try counter.add(1, .{ "http.route", route, "http.status_code", @as(i64, 200) });
    }

    try std.testing.expectEqual(1, counter.points.count());
    try std.testing.expectEqual(10_000, counter.points.values()[0]);

    const fetched = try counter.measurementsData(std.testing.allocator);
    defer {
        for (fetched.int) |*m| {
            m.deinit(std.testing.allocator);
        }
        std.testing.allocator.free(fetched.int);
    }

    try std.testing.expectEqual(1, fetched.int.len);
    try std.testing.expectEqual(10_000, fetched.int[0].value);
    try std.testing.expectEqual(0, counter.points.count());
}

test "counter enforces cardinality limit" {
    const io = std.testing.io;
    const mp = try MeterProvider.init(std.testing.allocator, io);
    defer mp.shutdown();

    const meter = try mp.getMeter(.{ .name = "cardinality-meter" });
    var counter = try meter.createCounter(u64, .{ .name = "cardinality-counter" });
    counter.cardinality_limit = 3;

    try counter.add(1, .{ "id", @as(i64, 1) });
    try counter.add(2, .{ "id", @as(i64, 2) });
    try counter.add(3, .{ "id", @as(i64, 3) });
    try std.testing.expectEqual(3, counter.points.count());

    // 4th distinct attribute set is aggregated into the overflow series (otel.metric.overflow=true)
    try counter.add(4, .{ "id", @as(i64, 4) });
    try std.testing.expectEqual(3, counter.points.count());

    // Existing attribute sets can still be updated
    try counter.add(10, .{ "id", @as(i64, 1) });
    try std.testing.expectEqual(11, counter.points.values()[0]);

    const fetched = try counter.measurementsData(std.testing.allocator);
    defer {
        for (fetched.int) |*m| {
            m.deinit(std.testing.allocator);
        }
        std.testing.allocator.free(fetched.int);
    }
    try std.testing.expectEqual(3, fetched.int.len);
    // Total sum: 11 + 2 + (3 + 4) = 20
    var total: i64 = 0;
    for (fetched.int) |dp| total += dp.value;
    try std.testing.expectEqual(20, total);
}

test "counter widened accumulator prevents overflow on smaller integer types" {
    const io = std.testing.io;
    const mp = try MeterProvider.init(std.testing.allocator, io);
    defer mp.shutdown();
    const meter = try mp.getMeter(.{ .name = "test-meter" });

    var counter = try meter.createCounter(u16, .{ .name = "small-counter" });
    try counter.add(40_000, .{});
    try counter.add(40_000, .{});

    const measurements = try counter.measurementsData(std.testing.allocator);
    defer {
        for (measurements.int) |*dp| {
            dp.deinit(std.testing.allocator);
        }
        std.testing.allocator.free(measurements.int);
    }

    try std.testing.expectEqual(1, measurements.int.len);
    try std.testing.expectEqual(80_000, measurements.int[0].value);
}

test "counter with LastValue view records last value instead of sum" {
    const io = std.testing.io;
    const mp = try MeterProvider.init(std.testing.allocator, io);
    defer mp.shutdown();

    try mp.addView(.{
        .instrument_selector = .{ .name = "last-val-counter" },
        .aggregation = .LastValue,
        .temporality = .Cumulative,
    });

    const meter = try mp.getMeter(.{ .name = "test-meter" });
    var counter = try meter.createCounter(u64, .{ .name = "last-val-counter" });

    try counter.add(10, .{});
    try counter.add(25, .{});

    const measurements = try counter.measurementsData(std.testing.allocator);
    defer {
        for (measurements.int) |*dp| {
            dp.deinit(std.testing.allocator);
        }
        std.testing.allocator.free(measurements.int);
    }

    try std.testing.expectEqual(1, measurements.int.len);
    try std.testing.expectEqual(25, measurements.int[0].value);
}

const MetricObserveError = AsyncInstrument.MetricObserveError;

test "async instrument registered in meter" {
    const io = std.testing.io;
    const mp = try MeterProvider.init(std.testing.allocator, io);
    defer mp.shutdown();

    const background = struct {
        fn observe(_: AsyncInstrument.ObservedContext, _: std.mem.Allocator) MetricObserveError!MeasurementsData {
            // This is a dummy callback that does nothing.
            // In a real-world scenario, it would collect data asynchronously.
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

    // SDK users aren't expected to call measurementsData on the async instrument,
    // rather simply use the meter to register the instrument
    const data = try async_counter.measurementsData(std.testing.allocator);
    try std.testing.expectEqual(0, data.int.len);
}
