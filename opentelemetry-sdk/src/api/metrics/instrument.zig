const std = @import("std");

const log = std.log.scoped(.instrument);

const spec = @import("spec.zig");
const Attribute = @import("../../attributes.zig").Attribute;
const Attributes = @import("../../attributes.zig").Attributes;
const DataPoint = @import("measurement.zig").DataPoint;
const HistogramDataPoint = @import("measurement.zig").HistogramDataPoint;

const MeasurementsData = @import("measurement.zig").MeasurementsData;

const exemplar = @import("../../sdk/metrics/exemplar.zig");

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

/// A Counter is a monotonically increasing value used to record cumulative events.
/// See https://opentelemetry.io/docs/specs/otel/metrics/api/#counter
fn copyNormalizedPoints(comptime From: type, comptime To: type, allocator: std.mem.Allocator, io: std.Io, points: []const DataPoint(From), collection_start_ns: *u64) ![]DataPoint(To) {
    const copied = try allocator.alloc(DataPoint(To), points.len);
    var initialized: usize = 0;
    errdefer {
        for (copied[0..initialized]) |*point| point.deinit(allocator);
        allocator.free(copied);
    }
    for (points, 0..) |point, i| {
        const copy = try point.deepCopy(allocator);
        copied[i] = .{
            .value = switch (@typeInfo(To)) {
                .int => @intCast(copy.value),
                .float => @floatCast(copy.value),
                else => @compileError("Unsupported metric value type"),
            },
            .attributes = copy.attributes,
            .attributes_owned = copy.attributes_owned,
            .timestamps = copy.timestamps,
            .exemplar_candidate = copy.exemplar_candidate,
            .exemplars = copy.exemplars,
        };
        initialized += 1;
    }
    // Callers hold the recording lock, so the next batch starts after this cut.
    if (copied.len > 0) {
        const collection_time: u64 = @intCast(std.Io.Clock.real.now(io).nanoseconds);
        for (copied) |*point| point.timestamps = .{ .start_time_ns = collection_start_ns.*, .time_ns = collection_time };
        collection_start_ns.* = collection_time;
    }
    return copied;
}

pub fn Counter(comptime T: type) type {
    return struct {
        const Self = @This();
        allocator: std.mem.Allocator,
        io: std.Io,
        lock: std.Io.Mutex,
        exemplar_filter: exemplar.ExemplarFilter = .trace_based,
        collection_start_ns: u64 = 0,
        pre_sum: bool = true,
        cardinality_limit: usize = 2000,
        has_overflow: bool = false,

        /// Pre-aggregated data points when every reader and view resolves to Sum.
        aggregated_points: std.ArrayHashMapUnmanaged(Attributes, DataPoint(i64), Attributes.ArrayHashContext, true),

        /// Raw data points kept as fallback when any reader or view resolves to non-Sum (e.g. LastValue, Histogram, Drop).
        data_points: std.ArrayListUnmanaged(DataPoint(T)),

        const overflow_attrs = [_]Attribute{
            .{ .key = "otel.metric.overflow", .value = .{ .bool = true } },
        };
        const overflow_key = Attributes.with(@constCast(&overflow_attrs));

        fn init(allocator: std.mem.Allocator, io: std.Io) Self {
            return Self{
                .pre_sum = true,
                .cardinality_limit = 2000,
                .has_overflow = false,
                .aggregated_points = .empty,
                .data_points = .empty,
                .allocator = allocator,
                .io = io,
                .lock = std.Io.Mutex.init,
                .collection_start_ns = @intCast(std.Io.Clock.real.now(io).nanoseconds),
            };
        }

        fn deinit(self: *Self) void {
            for (self.aggregated_points.values()) |*m| {
                m.deinit(self.allocator);
            }
            self.aggregated_points.deinit(self.allocator);

            for (self.data_points.items) |*m| {
                m.deinit(self.allocator);
            }
            self.data_points.deinit(self.allocator);
        }

        /// Fold `dp` into the pre-aggregated series.
        ///
        /// Whatever gets moved into the map is cleared from `dp`, so the caller
        /// must always call `dp.deinit` afterwards, whether this succeeded or not:
        /// it frees what was not moved (everything on error, the merged duplicate on success).
        ///
        /// `capture_exemplar` is false for points that were already recorded: their exemplar
        /// candidate was captured, or filtered out, in the context of the original measurement.
        fn recordSumPoint(self: *Self, dp: *DataPoint(T), capture_exemplar: bool) !void {
            const val: i64 = @intCast(dp.value);
            const key = Attributes.with(dp.attributes);
            if (self.aggregated_points.getPtr(key)) |existing| {
                if (capture_exemplar) try dp.captureExemplar(self.allocator, self.io, self.exemplar_filter);
                existing.value += val;
                if (dp.exemplar_candidate) |sample| {
                    if (existing.exemplar_candidate) |*prev| prev.deinit(self.allocator);
                    existing.exemplar_candidate = sample;
                    dp.exemplar_candidate = null;
                }
                return;
            }

            // Check cardinality limit
            if (self.cardinality_limit > 0 and
                (self.aggregated_points.count() >= self.cardinality_limit or
                    (!self.has_overflow and self.aggregated_points.count() >= self.cardinality_limit - 1)))
            {
                if (self.aggregated_points.getPtr(overflow_key)) |overflow_ptr| {
                    if (capture_exemplar) try dp.captureExemplar(self.allocator, self.io, self.exemplar_filter);
                    overflow_ptr.value += val;
                    if (dp.exemplar_candidate) |sample| {
                        if (overflow_ptr.exemplar_candidate) |*prev| prev.deinit(self.allocator);
                        overflow_ptr.exemplar_candidate = sample;
                        dp.exemplar_candidate = null;
                    }
                    return;
                }

                log.warn("cardinality limit {d} reached; aggregating excess measurements into overflow series", .{self.cardinality_limit});
                const overflow_slice = try self.allocator.dupe(Attribute, &overflow_attrs);
                var overflow_dp = DataPoint(i64){
                    .value = val,
                    .attributes = overflow_slice,
                    .attributes_owned = false,
                };
                var overflow_stored = false;
                defer if (!overflow_stored) overflow_dp.deinit(self.allocator);

                if (capture_exemplar) try dp.captureExemplar(self.allocator, self.io, self.exemplar_filter);
                if (dp.exemplar_candidate) |sample| {
                    overflow_dp.exemplar_candidate = sample;
                    dp.exemplar_candidate = null;
                }

                try self.aggregated_points.put(self.allocator, Attributes.with(overflow_slice), overflow_dp);
                overflow_stored = true;
                self.has_overflow = true;
                return;
            }

            if (capture_exemplar) try dp.captureExemplar(self.allocator, self.io, self.exemplar_filter);

            const dp_i64 = DataPoint(i64){
                .value = val,
                .attributes = dp.attributes,
                .attributes_owned = dp.attributes_owned,
                .exemplar_candidate = dp.exemplar_candidate,
                .exemplars = dp.exemplars,
                .timestamps = dp.timestamps,
            };
            try self.aggregated_points.put(self.allocator, Attributes.with(dp.attributes), dp_i64);

            // The map owns these now.
            dp.attributes = null;
            dp.attributes_owned = false;
            dp.exemplar_candidate = null;
            dp.exemplars = &.{};
        }

        pub fn setPreSum(self: *Self, enabled: bool) void {
            self.lock.lockUncancelable(self.io);
            defer self.lock.unlock(self.io);

            if (self.pre_sum == enabled) return;
            self.pre_sum = enabled;

            if (enabled) {
                // Switching back to Sum: drain any pending raw points into aggregated_points.
                // On allocation failure, the failed point and the ones after it stay in data_points.
                const items = self.data_points.items;
                var drained: usize = 0;
                for (items) |*raw_dp| {
                    self.recordSumPoint(raw_dp, false) catch break;
                    drained += 1;
                }
                // Drained points were moved out of or merged, so only the leftovers need freeing.
                for (items[0..drained]) |*raw_dp| raw_dp.deinit(self.allocator);
                const remaining = items.len - drained;
                std.mem.copyForwards(DataPoint(T), items[0..remaining], items[drained..]);
                self.data_points.shrinkRetainingCapacity(remaining);
            }
        }

        /// Add the given delta to the counter, using the provided attributes.
        pub fn add(self: *Self, delta: T, attributes: anytype) !void {
            self.lock.lockUncancelable(self.io);
            defer self.lock.unlock(self.io);

            if (self.pre_sum) {
                var dp = try DataPoint(T).new(self.allocator, delta, attributes);
                defer dp.deinit(self.allocator);
                try self.recordSumPoint(&dp, true);
            } else {
                var dp = try DataPoint(T).new(self.allocator, delta, attributes);
                errdefer dp.deinit(self.allocator);
                try dp.captureExemplar(self.allocator, self.io, self.exemplar_filter);
                try self.data_points.append(self.allocator, dp);
            }
        }

        /// Add the given delta to the counter with a pre-built attribute slice.
        /// This is primarily used for C interop where attributes are passed as a slice.
        pub fn addWithSlice(self: *Self, delta: T, attributes: ?[]Attribute) !void {
            self.lock.lockUncancelable(self.io);
            defer self.lock.unlock(self.io);

            var dp = DataPoint(T){
                .value = delta,
                .attributes = if (attributes) |attrs|
                    try self.allocator.dupe(Attribute, attrs)
                else
                    null,
            };
            if (self.pre_sum) {
                defer dp.deinit(self.allocator);
                try self.recordSumPoint(&dp, true);
            } else {
                errdefer dp.deinit(self.allocator);
                try dp.captureExemplar(self.allocator, self.io, self.exemplar_filter);
                try self.data_points.append(self.allocator, dp);
            }
        }

        fn measurementsData(self: *Self, allocator: std.mem.Allocator) !MeasurementsData {
            self.lock.lockUncancelable(self.io);
            defer self.lock.unlock(self.io);

            const has_aggregated = self.aggregated_points.count() > 0;
            const has_raw = self.data_points.items.len > 0;

            if (has_aggregated and !has_raw) {
                defer {
                    for (self.aggregated_points.values()) |*m| {
                        m.deinit(self.allocator);
                    }
                    self.aggregated_points.clearRetainingCapacity();
                    self.has_overflow = false;
                }
                return .{ .int = try copyNormalizedPoints(i64, i64, allocator, self.io, self.aggregated_points.values(), &self.collection_start_ns) };
            } else if (!has_aggregated and has_raw) {
                defer {
                    for (self.data_points.items) |*m| {
                        m.deinit(self.allocator);
                    }
                    self.data_points.clearRetainingCapacity();
                }
                return .{ .int = try copyNormalizedPoints(T, i64, allocator, self.io, self.data_points.items, &self.collection_start_ns) };
            } else if (has_aggregated and has_raw) {
                const agg_copied = try copyNormalizedPoints(i64, i64, allocator, self.io, self.aggregated_points.values(), &self.collection_start_ns);
                errdefer {
                    for (agg_copied) |*p| p.deinit(allocator);
                    allocator.free(agg_copied);
                }
                const raw_copied = try copyNormalizedPoints(T, i64, allocator, self.io, self.data_points.items, &self.collection_start_ns);
                errdefer {
                    for (raw_copied) |*p| p.deinit(allocator);
                    allocator.free(raw_copied);
                }
                const combined = try allocator.alloc(DataPoint(i64), agg_copied.len + raw_copied.len);
                @memcpy(combined[0..agg_copied.len], agg_copied);
                @memcpy(combined[agg_copied.len..], raw_copied);
                allocator.free(agg_copied);
                allocator.free(raw_copied);

                for (self.aggregated_points.values()) |*m| m.deinit(self.allocator);
                self.aggregated_points.clearRetainingCapacity();
                self.has_overflow = false;

                for (self.data_points.items) |*m| m.deinit(self.allocator);
                self.data_points.clearRetainingCapacity();

                return .{ .int = combined };
            } else {
                return .{ .int = try allocator.alloc(DataPoint(i64), 0) };
            }
        }
    };
}

/// A Histogram is used to sample observations and count them in pre-defined buckets.
/// See https://opentelemetry.io/docs/specs/otel/metrics/api/#histogram
pub fn Histogram(comptime T: type) type {
    return struct {
        const Self = @This();

        allocator: std.mem.Allocator,
        io: std.Io,
        lock: std.Io.Mutex,
        exemplar_filter: exemplar.ExemplarFilter = .trace_based,
        collection_start_ns: u64 = 0,

        /// Keeps track of the raw recorded values for each set of attributes.
        /// The measurements are cleared after each collection cycle.
        data_points: std.ArrayListUnmanaged(DataPoint(T)),

        fn init(allocator: std.mem.Allocator, io: std.Io) Self {
            return Self{
                .allocator = allocator,
                .io = io,
                .lock = std.Io.Mutex.init,
                .collection_start_ns = @intCast(std.Io.Clock.real.now(io).nanoseconds),
                .data_points = .empty,
            };
        }

        fn deinit(self: *Self) void {
            // Cleanup the arraylist or measures and their attributes.
            for (self.data_points.items) |*m| {
                m.deinit(self.allocator);
            }
            self.data_points.deinit(self.allocator);
        }

        /// Add the given value to the histogram, using the provided attributes.
        pub fn record(self: *Self, value: T, attributes: anytype) !void {
            self.lock.lockUncancelable(self.io);
            defer self.lock.unlock(self.io);

            var dp = try DataPoint(T).new(self.allocator, value, attributes);
            errdefer dp.deinit(self.allocator);
            try dp.captureExemplar(self.allocator, self.io, self.exemplar_filter);
            try self.data_points.append(self.allocator, dp);
        }

        /// Record a value with a pre-built attribute slice.
        /// This is primarily used for C interop where attributes are passed as a slice.
        pub fn recordWithSlice(self: *Self, value: T, attributes: ?[]Attribute) !void {
            self.lock.lockUncancelable(self.io);
            defer self.lock.unlock(self.io);

            var dp = DataPoint(T){
                .value = value,
                .attributes = if (attributes) |attrs|
                    try self.allocator.dupe(Attribute, attrs)
                else
                    null,
            };
            errdefer dp.deinit(self.allocator);
            try dp.captureExemplar(self.allocator, self.io, self.exemplar_filter);
            try self.data_points.append(self.allocator, dp);
        }

        fn measurementsData(self: *Self, allocator: std.mem.Allocator) !MeasurementsData {
            self.lock.lockUncancelable(self.io);
            defer self.lock.unlock(self.io);

            // We have to clear up the data points after we return a copy of them.
            // This resets the collected measurements, allowing to record more datapoints
            // until the next collection cycle.
            defer {
                for (self.data_points.items) |*dp| {
                    dp.deinit(self.allocator);
                }
                self.data_points.clearRetainingCapacity();
            }

            // Return raw data points without aggregation
            // Aggregation will be performed later in AggregateMetrics.fetch()
            switch (T) {
                u16, u32, u64, i16, i32, i64 => {
                    return .{ .int = try copyNormalizedPoints(T, i64, allocator, self.io, self.data_points.items, &self.collection_start_ns) };
                },
                f32, f64 => {
                    return .{ .double = try copyNormalizedPoints(T, f64, allocator, self.io, self.data_points.items, &self.collection_start_ns) };
                },
                // inner types are filtered before this point
                else => unreachable,
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
        exemplar_filter: exemplar.ExemplarFilter = .trace_based,
        collection_start_ns: u64 = 0,

        data_points: std.ArrayListUnmanaged(DataPoint(T)),

        fn init(allocator: std.mem.Allocator, io: std.Io) Self {
            return Self{
                .allocator = allocator,
                .io = io,
                .data_points = .empty,
                .lock = std.Io.Mutex.init,
                .collection_start_ns = @intCast(std.Io.Clock.real.now(io).nanoseconds),
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

            var dp = try DataPoint(T).new(self.allocator, value, attributes);
            errdefer dp.deinit(self.allocator);
            try dp.captureExemplar(self.allocator, self.io, self.exemplar_filter);
            try self.data_points.append(self.allocator, dp);
        }

        /// Record a value with a pre-built attribute slice.
        /// This is primarily used for C interop where attributes are passed as a slice.
        pub fn recordWithSlice(self: *Self, value: T, attributes: ?[]Attribute) !void {
            self.lock.lockUncancelable(self.io);
            defer self.lock.unlock(self.io);

            var dp = DataPoint(T){
                .value = value,
                .attributes = if (attributes) |attrs|
                    try self.allocator.dupe(Attribute, attrs)
                else
                    null,
            };
            errdefer dp.deinit(self.allocator);
            try dp.captureExemplar(self.allocator, self.io, self.exemplar_filter);
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
                    return .{ .int = try copyNormalizedPoints(T, i64, allocator, self.io, self.data_points.items, &self.collection_start_ns) };
                },
                f32, f64 => {
                    return .{ .double = try copyNormalizedPoints(T, f64, allocator, self.io, self.data_points.items, &self.collection_start_ns) };
                },
                else => unreachable,
            }
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

test "meter can create counter instrument and record increase without attributes" {
    const io = std.testing.io;
    const mp = try MeterProvider.init(std.testing.allocator, io);
    defer mp.deinit();
    const meter = try mp.getMeter(.{ .name = "my-meter" });
    var counter = try meter.createCounter(u32, .{ .name = "a-counter" });

    try counter.add(10, .{});
    std.debug.assert(counter.aggregated_points.count() == 1);
}

test "meter can create counter instrument and record increase with attributes" {
    const io = std.testing.io;
    const mp = try MeterProvider.init(std.testing.allocator, io);
    defer mp.deinit();
    const meter = try mp.getMeter(.{ .name = "my-meter" });
    var counter = try meter.createCounter(u32, .{
        .name = "a-counter",
        .description = "a funny counter",
        .unit = "KiB",
    });

    try counter.add(100, .{});
    try counter.add(1000, .{});

    // In record-time sum aggregation, identical attributes aggregate into 1 point
    std.debug.assert(counter.aggregated_points.count() == 1);
    std.debug.assert(counter.aggregated_points.values()[0].value == 1100);

    const val1: []const u8 = "some-value";
    const val2: []const u8 = "another-value";

    try counter.add(2, .{ "some-key", val1, "another-key", val2 });
    std.debug.assert(counter.aggregated_points.count() == 2);
    std.debug.assert(counter.aggregated_points.values()[1].value == 2);
}

test "histogram records value without explicit buckets" {
    const io = std.testing.io;
    const mp = try MeterProvider.init(std.testing.allocator, io);
    defer mp.deinit();
    const meter = try mp.getMeter(.{ .name = "my-meter" });
    var histogram = try meter.createHistogram(u32, .{ .name = "anything" });

    try histogram.record(1, .{});
    try histogram.record(5, .{});
    try histogram.record(15, .{});

    // After recording, we get raw measurements data (int/double values, not pre-aggregated histogram)
    const measurements = try histogram.measurementsData(std.testing.allocator);
    defer {
        for (measurements.int) |*dp| {
            dp.deinit(std.testing.allocator);
        }
        std.testing.allocator.free(measurements.int);
    }

    // We should have 3 raw data points corresponding to the 3 recorded values
    try std.testing.expectEqual(3, measurements.int.len);
    // Verify the raw values are stored correctly
    try std.testing.expectEqual(@as(i64, 1), measurements.int[0].value);
    try std.testing.expectEqual(@as(i64, 5), measurements.int[1].value);
    try std.testing.expectEqual(@as(i64, 15), measurements.int[2].value);
}

test "histogram records value with explicit buckets" {
    const io = std.testing.io;
    const mp = try MeterProvider.init(std.testing.allocator, io);
    defer mp.deinit();
    const meter = try mp.getMeter(.{ .name = "my-meter" });
    var histogram = try meter.createHistogram(u32, .{ .name = "a-histogram" });

    try histogram.record(1, .{});
    try histogram.record(5, .{});
    try histogram.record(15, .{});

    try std.testing.expectEqual(3, histogram.data_points.items.len);

    // After recording, we get raw measurements data (int values, not pre-aggregated histogram)
    const measurements = try histogram.measurementsData(std.testing.allocator);
    defer {
        for (measurements.int) |*dp| {
            dp.deinit(std.testing.allocator);
        }
        std.testing.allocator.free(measurements.int);
    }

    // We should have 3 raw data points corresponding to the 3 recorded values
    try std.testing.expectEqual(3, measurements.int.len);
    // Verify the raw values are stored correctly
    try std.testing.expectEqual(@as(i64, 1), measurements.int[0].value);
    try std.testing.expectEqual(@as(i64, 5), measurements.int[1].value);
    try std.testing.expectEqual(@as(i64, 15), measurements.int[2].value);
}

test "histogram keeps track of bucket counts by attribute" {
    const io = std.testing.io;
    const mp = try MeterProvider.init(std.testing.allocator, io);
    defer mp.deinit();
    const meter = try mp.getMeter(.{ .name = "my-meter" });
    var histogram = try meter.createHistogram(u32, .{ .name = "a-histogram" });

    const val: []const u8 = "some-value";
    try histogram.record(1, .{ "some-key", val });
    try histogram.record(1000, .{ "other-key", val });

    try std.testing.expectEqual(2, histogram.data_points.items.len);

    // After recording, we get raw measurements data (not aggregated histogram data)
    const measurements = try histogram.measurementsData(std.testing.allocator);
    defer {
        for (measurements.int) |*dp| {
            dp.deinit(std.testing.allocator);
        }
        std.testing.allocator.free(measurements.int);
    }

    // Now we get raw integer data points instead of histogram buckets
    try std.testing.expectEqual(2, measurements.int.len);

    // Check that the raw values are preserved
    try std.testing.expectEqual(@as(i64, 1), measurements.int[0].value);
    try std.testing.expectEqual(@as(i64, 1000), measurements.int[1].value);
}

test "histogram keeps track of count, sum and min/max by attribute" {
    const io = std.testing.io;
    const mp = try MeterProvider.init(std.testing.allocator, io);
    defer mp.deinit();
    const meter = try mp.getMeter(.{ .name = "my-meter" });
    var histogram = try meter.createHistogram(u32, .{ .name = "a-histogram" });

    const val: []const u8 = "some-val";
    try histogram.record(1, .{});
    try histogram.record(5, .{ "key", val });
    try histogram.record(15, .{ "key", val });

    std.debug.assert(histogram.data_points.items.len == 3);

    // After recording, we get raw measurements data (not aggregated histogram data)
    const measurements = try histogram.measurementsData(std.testing.allocator);
    defer {
        for (measurements.int) |*dp| {
            dp.deinit(std.testing.allocator);
        }
        std.testing.allocator.free(measurements.int);
    }

    // We get raw integer data points, grouped by attributes
    try std.testing.expectEqual(3, measurements.int.len);

    // Check that the raw values are preserved (order may vary by attribute hash)
    var found_1 = false;
    var found_5 = false;
    var found_15 = false;

    for (measurements.int) |dp| {
        switch (dp.value) {
            1 => found_1 = true,
            5 => found_5 = true,
            15 => found_15 = true,
            else => unreachable,
        }
    }

    try std.testing.expect(found_1);
    try std.testing.expect(found_5);
    try std.testing.expect(found_15);
}

test "gauge instrument records value without attributes" {
    const io = std.testing.io;
    const mp = try MeterProvider.init(std.testing.allocator, io);
    defer mp.deinit();
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
    defer mp.deinit();
    const meter = try mp.getMeter(.{ .name = "my-meter" });
    var counter = try meter.createUpDownCounter(i32, .{ .name = "up-down-counter" });

    try counter.add(10, .{});
    try counter.add(-5, .{});
    try counter.add(-4, .{});
    std.debug.assert(counter.aggregated_points.count() == 1);
    try std.testing.expectEqual(1, counter.aggregated_points.values()[0].value);

    try counter.add(1, .{ "some-key", @as(i64, 42) });

    std.debug.assert(counter.aggregated_points.count() == 2);
    try std.testing.expectEqual(1, counter.aggregated_points.values()[1].value);
}

test "instrument in meter and instrument in data are the same" {
    const io = std.testing.io;
    const mp = try MeterProvider.init(std.testing.allocator, io);
    defer mp.deinit();

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

        const counter_value = instrument.data.Counter_u64.aggregated_points.get(Attributes.with(null)) orelse unreachable;
        try std.testing.expectEqual(100, counter_value.value);
    } else {
        std.debug.panic("Counter {s} not found in meter {s} after creation", .{ name, meter.scope.name });
    }
}

test "instrument fetches measurements from inner" {
    const io = std.testing.io;
    const mp = try MeterProvider.init(std.testing.allocator, io);
    defer mp.deinit();

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
    defer mp.deinit();

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
        std.Io.sleep(std.testing.io, .fromNanoseconds(25), .awake) catch {};
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
    defer mp.deinit();

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
        std.Io.sleep(std.testing.io, .fromNanoseconds(25), .awake) catch {};
    }

    const fetched = try histogram.measurementsData(std.testing.allocator);
    defer {
        for (fetched.int) |*m| {
            m.deinit(std.testing.allocator);
        }
        std.testing.allocator.free(fetched.int);
    }
    // Assert that we have 2 raw data points (since both recordings have same attributes but are separate records)
    try std.testing.expectEqual(2, fetched.int.len);

    // Check that we have the raw values recorded
    const values = [_]i64{ fetched.int[0].value, fetched.int[1].value };
    try std.testing.expect(std.mem.containsAtLeast(i64, &values, 1, &[_]i64{1}));
    try std.testing.expect(std.mem.containsAtLeast(i64, &values, 1, &[_]i64{20}));
}

test "instrument cleans up internal state when datapoints are fetched" {
    const io = std.testing.io;
    const mp = try MeterProvider.init(std.testing.allocator, io);
    defer mp.deinit();

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
    // Assert that we have 1 data point: the first added by the test thread.
    try std.testing.expectEqual(0, c.aggregated_points.count());
    try std.testing.expectEqual(0, c.data_points.items.len);
}

const MetricObserveError = AsyncInstrument.MetricObserveError;

test "async instrument registered in meter" {
    const io = std.testing.io;
    const mp = try MeterProvider.init(std.testing.allocator, io);
    defer mp.deinit();

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

test "exemplar recording snapshots caller attributes before draining" {
    const allocator = std.testing.allocator;
    const io = std.testing.io;
    const instr = try Instrument.new(.Counter, .{ .name = "exemplar-counter" }, allocator);
    defer instr.deinit();
    const counter = try instr.counter(std.testing.io, u64);
    counter.exemplar_filter = .always_on;
    var value = [_]u8{ 'f', 'i', 'r', 's', 't' };
    var attrs = [_]Attribute{.{ .key = "request", .value = .{ .string = &value } }};
    const before: u64 = @intCast(std.Io.Clock.real.now(io).nanoseconds);
    try counter.addWithSlice(7, &attrs);
    const after: u64 = @intCast(std.Io.Clock.real.now(io).nanoseconds);
    @memcpy(&value, "later");
    var data = try instr.getInstrumentsData(allocator);
    defer data.deinit(allocator);
    const sample = data.int[0].exemplar_candidate.?;
    try std.testing.expectEqualStrings("first", sample.filtered_attributes[0].value.string);
    try std.testing.expect(sample.time_ns >= before and sample.time_ns <= after);
    try std.testing.expectEqual(@as(i64, 7), sample.value.int);
    try std.testing.expectEqual(@as(usize, 0), counter.aggregated_points.count());
    try std.testing.expectEqual(@as(usize, 0), counter.data_points.items.len);
}

test "exemplar recording keeps sampled span IDs after context ends" {
    const allocator = std.testing.allocator;
    const instr = try Instrument.new(.Histogram, .{ .name = "exemplar-histogram" }, allocator);
    defer instr.deinit();
    const histogram = try instr.histogram(std.testing.io, f64);
    {
        defer context_api.cleanup();
        const sc = trace_api.SpanContext.init(trace_api.TraceID.init(@splat(1)), trace_api.SpanID.init(@splat(2)), .sampled(), trace_api.TraceState.init(allocator), false);
        const ctx = try trace_api.insertSpanContext(allocator, sc);
        defer trace_api.freeSerializedSpanContext(allocator, ctx);
        _ = try context_api.attachContext(ctx);
        try histogram.record(2.5, .{});
    }
    var data = try instr.getInstrumentsData(allocator);
    defer data.deinit(allocator);
    const sample = data.double[0].exemplar_candidate.?;
    try std.testing.expectEqualSlices(u8, &@as([16]u8, @splat(1)), &sample.trace_id.?);
    try std.testing.expectEqualSlices(u8, &@as([8]u8, @splat(2)), &sample.span_id.?);
    try std.testing.expectEqual(@as(f64, 2.5), sample.value.double);
}

test "counter aggregates measurements in place without growing memory" {
    const io = std.testing.io;
    const mp = try MeterProvider.init(std.testing.allocator, io);
    defer mp.deinit();

    const meter = try mp.getMeter(.{ .name = "test-meter" });
    var counter = try meter.createCounter(u64, .{ .name = "http.requests" });

    // Record 10,000 measurements for the same route
    const route: []const u8 = "/api/v1/users";
    for (0..10_000) |_| {
        try counter.add(1, .{ "http.route", route, "http.status_code", @as(i64, 200) });
    }

    try std.testing.expectEqual(1, counter.aggregated_points.count());
    try std.testing.expectEqual(10_000, counter.aggregated_points.values()[0].value);

    const fetched = try counter.measurementsData(std.testing.allocator);
    defer {
        for (fetched.int) |*m| {
            m.deinit(std.testing.allocator);
        }
        std.testing.allocator.free(fetched.int);
    }

    try std.testing.expectEqual(1, fetched.int.len);
    try std.testing.expectEqual(10_000, fetched.int[0].value);
    try std.testing.expectEqual(0, counter.aggregated_points.count());
}

test "counter enforces cardinality limit with overflow series" {
    const io = std.testing.io;
    const mp = try MeterProvider.init(std.testing.allocator, io);
    defer mp.deinit();

    const meter = try mp.getMeter(.{ .name = "test-meter" });
    var counter = try meter.createCounter(u64, .{ .name = "high.cardinality" });
    counter.cardinality_limit = 3;

    try counter.add(1, .{ "id", @as(i64, 1) });
    try counter.add(2, .{ "id", @as(i64, 2) });
    try counter.add(3, .{ "id", @as(i64, 3) });
    try std.testing.expectEqual(3, counter.aggregated_points.count());

    // 4th distinct attribute set is aggregated into the overflow series (otel.metric.overflow=true)
    try counter.add(4, .{ "id", @as(i64, 4) });
    try std.testing.expectEqual(3, counter.aggregated_points.count());

    // Existing attribute sets can still be updated
    try counter.add(10, .{ "id", @as(i64, 1) });
    try std.testing.expectEqual(11, counter.aggregated_points.values()[0].value);

    const fetched = try counter.measurementsData(std.testing.allocator);
    defer {
        for (fetched.int) |*m| {
            m.deinit(std.testing.allocator);
        }
        std.testing.allocator.free(fetched.int);
    }

    try std.testing.expectEqual(3, fetched.int.len);
    // Find overflow series
    var found_overflow = false;
    for (fetched.int) |point| {
        if (point.attributes) |attrs| {
            for (attrs) |attr| {
                if (std.mem.eql(u8, attr.key, "otel.metric.overflow")) {
                    found_overflow = true;
                    try std.testing.expectEqual(@as(i64, 7), point.value);
                }
            }
        }
    }
    try std.testing.expect(found_overflow);
}

test "counter falls back to raw data points when non-Sum view is configured" {
    const allocator = std.testing.allocator;
    const io = std.testing.io;
    const mp = try MeterProvider.init(allocator, io);
    defer mp.deinit();

    // Register a view specifying ExplicitBucketHistogram for this counter
    const view_mod = @import("../../sdk/metrics/view.zig");
    try mp.addView(view_mod.View{
        .instrument_selector = .{ .name = "histogram_counter" },
        .aggregation = .{ .ExplicitBucketHistogram = .{} },
        .temporality = .Cumulative,
    });

    var meter = try mp.getMeter(.{ .name = "test-fallback" });
    const counter = try meter.createCounter(u64, .{ .name = "histogram_counter" });

    // Counter must have pre_sum disabled because view does not resolve to Sum
    try std.testing.expect(!counter.pre_sum);

    try counter.add(10, .{ "status", @as([]const u8, "200") });
    try counter.add(20, .{ "status", @as([]const u8, "200") });

    // Measurements are retained as raw items in data_points
    try std.testing.expectEqual(@as(usize, 2), counter.data_points.items.len);
    try std.testing.expectEqual(@as(usize, 0), counter.aggregated_points.count());

    var data = try counter.measurementsData(allocator);
    defer data.deinit(allocator);
    try std.testing.expectEqual(@as(usize, 2), data.int.len);
    try std.testing.expectEqual(@as(i64, 10), data.int[0].value);
    try std.testing.expectEqual(@as(i64, 20), data.int[1].value);
}

test "counter running total stored as i64 does not overflow small types" {
    const io = std.testing.io;
    var counter = Counter(u16).init(std.testing.allocator, io);
    defer counter.deinit();

    // Adding 50,000 twice to a u16 counter (u16 max is 65,535)
    try counter.add(50_000, .{ "key", @as([]const u8, "val") });
    try counter.add(50_000, .{ "key", @as([]const u8, "val") });

    try std.testing.expectEqual(1, counter.aggregated_points.count());
    try std.testing.expectEqual(@as(i64, 100_000), counter.aggregated_points.values()[0].value);

    var data = try counter.measurementsData(std.testing.allocator);
    defer data.deinit(std.testing.allocator);
    try std.testing.expectEqual(@as(i64, 100_000), data.int[0].value);
}

fn testCounterAllocationFailures(allocator: std.mem.Allocator) !void {
    const io = std.testing.io;
    var c = Counter(u32).init(allocator, io);
    defer c.deinit();
    c.cardinality_limit = 2;

    try c.add(10, .{ "status", @as([]const u8, "200") });
    try c.add(5, .{ "status", @as([]const u8, "200") });
    try c.add(20, .{ "status", @as([]const u8, "404") });
    try c.add(30, .{ "status", @as([]const u8, "500") });
    try c.add(40, .{ "status", @as([]const u8, "502") });

    var data = try c.measurementsData(allocator);
    defer data.deinit(allocator);
}

test "counter in-place aggregation handles allocation failures without leaks or double-frees" {
    try std.testing.checkAllAllocationFailures(std.testing.allocator, testCounterAllocationFailures, .{});
}

fn testSwitchBackToSumAllocationFailures(allocator: std.mem.Allocator) !void {
    const io = std.testing.io;
    var c = Counter(u32).init(allocator, io);
    defer c.deinit();
    c.cardinality_limit = 3;

    c.setPreSum(false);
    try c.add(1, .{ "status", @as([]const u8, "200") });
    try c.add(2, .{ "status", @as([]const u8, "200") });
    try c.add(3, .{ "status", @as([]const u8, "404") });
    try c.add(4, .{ "status", @as([]const u8, "500") });
    try c.add(5, .{ "status", @as([]const u8, "502") });

    // A failure while draining must leave the remaining raw points valid.
    c.setPreSum(true);

    var data = try c.measurementsData(allocator);
    defer data.deinit(allocator);

    var total: i64 = 0;
    for (data.int) |point| total += point.value;
    try std.testing.expectEqual(15, total);
}

test "switching back to Sum handles allocation failures without leaks or double-frees" {
    try std.testing.checkAllAllocationFailures(std.testing.allocator, testSwitchBackToSumAllocationFailures, .{});
}

test "switching back to Sum keeps the exemplars captured at record time" {
    const io = std.testing.io;
    var c = Counter(u64).init(std.testing.allocator, io);
    defer c.deinit();

    c.setPreSum(false);
    c.exemplar_filter = .always_on;
    try c.add(7, .{ "route", @as([]const u8, "/sampled") });
    c.exemplar_filter = .always_off;
    try c.add(3, .{ "route", @as([]const u8, "/filtered") });

    // The filter in effect while draining must not matter.
    c.exemplar_filter = .always_off;
    c.setPreSum(true);

    var data = try c.measurementsData(std.testing.allocator);
    defer data.deinit(std.testing.allocator);
    try std.testing.expectEqual(2, data.int.len);
    for (data.int) |point| {
        switch (point.value) {
            7 => try std.testing.expectEqual(@as(i64, 7), point.exemplar_candidate.?.value.int),
            3 => try std.testing.expect(point.exemplar_candidate == null),
            else => return error.UnexpectedPoint,
        }
    }
}

test "switching back to Sum does not invent exemplars for filtered measurements" {
    const io = std.testing.io;
    var c = Counter(u64).init(std.testing.allocator, io);
    defer c.deinit();

    c.setPreSum(false);
    c.exemplar_filter = .always_off;
    try c.add(3, .{ "route", @as([]const u8, "/filtered") });

    c.exemplar_filter = .always_on;
    c.setPreSum(true);

    var data = try c.measurementsData(std.testing.allocator);
    defer data.deinit(std.testing.allocator);
    try std.testing.expectEqual(1, data.int.len);
    try std.testing.expect(data.int[0].exemplar_candidate == null);
}
