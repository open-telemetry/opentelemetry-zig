const std = @import("std");

const log = std.log.scoped(.pipeline);

const Attribute = @import("../../attributes.zig").Attribute;
const Attributes = @import("../../attributes.zig").Attributes;
const InstrumentationScope = @import("../../scope.zig").InstrumentationScope;
const DataPoint = @import("../../api/metrics/measurement.zig").DataPoint;
const HistogramDataPoint = @import("../../api/metrics/measurement.zig").HistogramDataPoint;
const MeasurementsData = @import("../../api/metrics/measurement.zig").MeasurementsData;
const Measurements = @import("../../api/metrics/measurement.zig").Measurements;
const instrument = @import("../../api/metrics/instrument.zig");
const Instrument = instrument.Instrument;
const Kind = instrument.Kind;
const InstrumentOptions = instrument.InstrumentOptions;
const MeterProvider = @import("../../api/metrics/meter.zig").MeterProvider;
const AggregatedMetrics = @import("../../api/metrics/meter.zig").AggregatedMetrics;

const storage = @import("storage.zig");
const view = @import("view.zig");
const exemplar = @import("exemplar.zig");
const aggregation = @import("aggregation.zig");
const ExponentialHistogramDataPoint = aggregation.ExponentialHistogramDataPoint;
const MetricReader = @import("reader.zig").MetricReader;

pub const Storage = union(enum) {
    sum_int: storage.SumStorage(i64),
    sum_double: storage.SumStorage(f64),
    last_value_int: storage.LastValueStorage(i64),
    last_value_double: storage.LastValueStorage(f64),
    explicit_histogram: storage.ExplicitBucketHistogramStorage,
    exponential_histogram: storage.ExponentialHistogramStorage,

    pub fn deinit(self: *Storage) void {
        switch (self.*) {
            inline else => |*s| s.deinit(),
        }
    }

    pub fn clearRetainingCapacity(self: *Storage) void {
        switch (self.*) {
            inline else => |*s| s.clearRetainingCapacity(),
        }
    }

    pub fn count(self: *const Storage) usize {
        return switch (self.*) {
            inline else => |*s| s.count(),
        };
    }

    pub fn setCardinalityLimit(self: *Storage, limit: usize) void {
        switch (self.*) {
            inline else => |*s| s.cardinality_limit = limit,
        }
    }
};

fn toI64(comptime T: type, value: T) i64 {
    return switch (@typeInfo(T)) {
        .int => @intCast(value),
        .float => @intFromFloat(value),
        else => @compileError("Unsupported metric value type: " ++ @typeName(T)),
    };
}

fn toF64(comptime T: type, value: T) f64 {
    return switch (@typeInfo(T)) {
        .int => @floatFromInt(value),
        .float => @floatCast(value),
        else => @compileError("Unsupported metric value type: " ++ @typeName(T)),
    };
}

/// Per-(pipeline, instrument) storage sink that receives measurements at record time.
pub const StorageSink = struct {
    pipeline: *Pipeline,
    instrument_id: usize,
    instrument_kind: Kind,
    instrument_options: InstrumentOptions,
    scope: InstrumentationScope,
    instrument_lock: *std.Io.Mutex,
    attribute_filter: ?view.AttributeFilter,
    exemplar_reservoir: ?exemplar.ReservoirFactory,
    is_float: bool,
    collection_start_ns: u64,
    storage: Storage,

    pub fn deinit(self: *StorageSink) void {
        self.storage.deinit();
    }

    pub fn aggregationType(self: *const StorageSink) view.AggregationType {
        return switch (self.storage) {
            .sum_int, .sum_double => .Sum,
            .last_value_int, .last_value_double => .LastValue,
            .explicit_histogram => .ExplicitBucketHistogram,
            .exponential_histogram => .ExponentialBucketHistogram,
        };
    }

    /// Record a measurement into this sink, applying any view attribute filter at record time.
    /// Takes ownership of `candidate.*` if stored.
    pub fn record(
        self: *StorageSink,
        comptime T: type,
        allocator: std.mem.Allocator,
        value: T,
        attributes: ?[]const Attribute,
        candidate: *?exemplar.Exemplar,
    ) !void {
        var filtered_attrs: ?Attributes = null;
        defer if (filtered_attrs) |fa| {
            if (fa.attributes) |slice| allocator.free(slice);
        };

        const target_attrs: ?[]const Attribute = if (self.attribute_filter) |filter| blk: {
            filtered_attrs = try filter.apply(allocator, Attributes.with(if (attributes) |a| @constCast(a) else null));
            break :blk if (filtered_attrs) |fa| fa.attributes else null;
        } else attributes;

        switch (self.storage) {
            .sum_int => |*s| try s.record(toI64(T, value), target_attrs, candidate),
            .sum_double => |*s| try s.record(toF64(T, value), target_attrs, candidate),
            .last_value_int => |*s| try s.record(toI64(T, value), target_attrs, candidate),
            .last_value_double => |*s| try s.record(toF64(T, value), target_attrs, candidate),
            .explicit_histogram => |*s| try s.record(toF64(T, value), target_attrs, candidate),
            .exponential_histogram => |*s| try s.record(toF64(T, value), target_attrs, candidate),
        }
    }

    fn reservoirOptions(self: *const StorageSink) exemplar.ReservoirOptions {
        return switch (self.storage) {
            .explicit_histogram => |s| if (s.buckets.len > 0) .{ .aligned = s.buckets } else .{ .fixed_size = 1 },
            .exponential_histogram => |s| .{ .fixed_size = @min(@as(usize, 20), s.max_size) },
            else => .{ .fixed_size = 1 },
        };
    }

    fn streamIdentity(self: *const StorageSink) exemplar.StreamIdentity {
        return .{
            .instrument_id = self.instrument_id,
            .aggregation = switch (self.storage) {
                .sum_int, .sum_double => .sum,
                .last_value_int, .last_value_double => .last_value,
                .explicit_histogram => .explicit_histogram,
                .exponential_histogram => .exponential_histogram,
            },
            .max_scale = if (self.storage == .exponential_histogram) self.storage.exponential_histogram.max_scale else 0,
            .max_size = if (self.storage == .exponential_histogram) self.storage.exponential_histogram.max_size else 0,
            .record_min_max = switch (self.storage) {
                .explicit_histogram => |s| s.record_min_max,
                .exponential_histogram => |s| s.record_min_max,
                else => false,
            },
        };
    }

    /// Snapshot and reset this sink's storage under the instrument lock, returning null if empty.
    fn collectData(
        self: *StorageSink,
        allocator: std.mem.Allocator,
        io: std.Io,
        exemplar_filter: exemplar.ExemplarFilter,
        exemplar_sampler: *exemplar.Sampler,
    ) !?MeasurementsData {
        self.instrument_lock.lockUncancelable(io);
        if (self.storage.count() == 0) {
            self.instrument_lock.unlock(io);
            return null;
        }

        const raw_data: MeasurementsData = blk: {
            errdefer self.instrument_lock.unlock(io);
            break :blk switch (self.storage) {
                .sum_int => |*s| .{ .int = try s.snapshot(allocator, &self.collection_start_ns) },
                .sum_double => |*s| .{ .double = try s.snapshot(allocator, &self.collection_start_ns) },
                .last_value_int => |*s| .{ .int = try s.snapshot(allocator, &self.collection_start_ns) },
                .last_value_double => |*s| .{ .double = try s.snapshot(allocator, &self.collection_start_ns) },
                .explicit_histogram => |*s| .{ .histogram = try s.snapshot(allocator, &self.collection_start_ns) },
                .exponential_histogram => |*s| .{ .exponential_histogram = try s.snapshot(allocator, &self.collection_start_ns) },
            };
        };
        self.storage.clearRetainingCapacity();
        self.instrument_lock.unlock(io);

        var owned_raw = raw_data;
        var raw_consumed = false;
        errdefer if (!raw_consumed) owned_raw.deinit(allocator);

        if (owned_raw.isEmpty()) {
            owned_raw.deinit(allocator);
            raw_consumed = true;
            return null;
        }

        // For explicit histograms, snapshot() may emit extra count==0 points to carry
        // multiple bucket exemplars per series. Merge those into one point per attribute set.
        const output_data: MeasurementsData = if (owned_raw == .histogram and hasZeroCountPoints(owned_raw.histogram)) blk: {
            const timestamps = owned_raw.histogram[0].timestamps orelse return error.MissingCollectionTimestamp;
            const merged = try AggregatedMetrics.mergeHistogram(
                owned_raw.histogram,
                timestamps,
                self.instrument_kind.isMonotonic(),
                allocator,
            );
            break :blk .{ .histogram = merged };
        } else blk: {
            raw_consumed = true;
            break :blk owned_raw;
        };

        var owned_output = output_data;
        errdefer owned_output.deinit(allocator);

        if (exemplar_filter != .always_off) {
            switch (owned_raw) {
                inline .int, .double, .histogram, .exponential_histogram => |raw| switch (owned_output) {
                    inline else => |points| try exemplar_sampler.attach(
                        allocator,
                        io,
                        self.streamIdentity(),
                        self.reservoirOptions(),
                        self.exemplar_reservoir,
                        raw,
                        points,
                    ),
                },
            }
        }

        // Clear exemplar_candidate on output points now that reservoirs have sampled them.
        switch (owned_output) {
            inline else => |points| for (points) |*point| {
                if (point.exemplar_candidate) |*sample| sample.deinit(allocator);
                point.exemplar_candidate = null;
            },
        }

        if (!raw_consumed) {
            owned_raw.deinit(allocator);
            raw_consumed = true;
        }

        return owned_output;
    }
};

fn hasZeroCountPoints(points: []const DataPoint(HistogramDataPoint)) bool {
    for (points) |p| {
        if (p.value.count == 0) return true;
    }
    return false;
}

/// Per-MetricReader collection pipeline.
/// Created by MeterProvider.addReader and destroyed once detached and no collection is in flight.
pub const Pipeline = struct {
    allocator: std.mem.Allocator,
    io: std.Io,
    reader: *MetricReader,
    cardinality_limit: usize,
    exemplar_filter: exemplar.ExemplarFilter,
    exemplar_sampler: exemplar.Sampler,
    sinks: std.ArrayListUnmanaged(*StorageSink),
    observable_windows: std.AutoHashMapUnmanaged(usize, u64),
    created_at_ns: u64,
    ref_count: std.atomic.Value(usize),

    pub const AsyncTask = struct {
        instr: *Instrument,
        scope: InstrumentationScope,
        opts: InstrumentOptions,
        agg: view.Aggregation,
        attribute_filter: ?view.AttributeFilter,
        exemplar_reservoir: ?exemplar.ReservoirFactory,
    };

    pub const PendingRebind = union(enum) {
        noop,
        update_metadata: struct {
            sink: *StorageSink,
            options: InstrumentOptions,
            exemplar_reservoir: ?exemplar.ReservoirFactory,
        },
        drop: struct {
            pipeline: *Pipeline,
            instr: *Instrument,
            old_sink: *StorageSink,
        },
        replace: struct {
            pipeline: *Pipeline,
            instr: *Instrument,
            old_sink: ?*StorageSink,
            new_sink: *StorageSink,
        },

        pub fn deinitOnError(self: PendingRebind) void {
            switch (self) {
                .replace => |r| {
                    r.new_sink.deinit();
                    r.pipeline.allocator.destroy(r.new_sink);
                },
                else => {},
            }
        }

        pub fn commit(self: PendingRebind) void {
            switch (self) {
                .noop => {},
                .update_metadata => |u| {
                    u.sink.instrument_lock.lockUncancelable(u.sink.pipeline.io);
                    u.sink.instrument_options = u.options;
                    u.sink.exemplar_reservoir = u.exemplar_reservoir;
                    u.sink.instrument_lock.unlock(u.sink.pipeline.io);
                },
                .drop => |d| {
                    for (d.pipeline.sinks.items, 0..) |s, idx| {
                        if (s == d.old_sink) {
                            _ = d.pipeline.sinks.swapRemove(idx);
                            break;
                        }
                    }
                    d.instr.removeStorageSink(d.old_sink);
                    d.old_sink.deinit();
                    d.pipeline.allocator.destroy(d.old_sink);
                },
                .replace => |r| {
                    if (r.old_sink) |old| {
                        for (r.pipeline.sinks.items) |*s| {
                            if (s.* == old) {
                                s.* = r.new_sink;
                                break;
                            }
                        }
                        r.instr.replaceStorageSink(old, r.new_sink);
                        old.deinit();
                        r.pipeline.allocator.destroy(old);
                    } else {
                        r.instr.addStorageSinkAssumeCapacity(r.new_sink);
                        r.pipeline.sinks.appendAssumeCapacity(r.new_sink);
                    }
                },
            }
        }
    };

    pub fn init(
        allocator: std.mem.Allocator,
        io: std.Io,
        reader: *MetricReader,
        cardinality_limit: usize,
        exemplar_filter: exemplar.ExemplarFilter,
    ) !*Pipeline {
        const p = try allocator.create(Pipeline);
        p.* = .{
            .allocator = allocator,
            .io = io,
            .reader = reader,
            .cardinality_limit = cardinality_limit,
            .exemplar_filter = exemplar_filter,
            .exemplar_sampler = .{ .allocator = allocator },
            .sinks = .empty,
            .observable_windows = .empty,
            .created_at_ns = @intCast(std.Io.Clock.real.now(io).nanoseconds),
            .ref_count = std.atomic.Value(usize).init(1),
        };
        return p;
    }

    pub fn retain(self: *Pipeline) void {
        _ = self.ref_count.fetchAdd(1, .monotonic);
    }

    pub fn release(self: *Pipeline) void {
        if (self.ref_count.fetchSub(1, .acq_rel) == 1) {
            self.deinit();
        }
    }

    pub fn deinit(self: *Pipeline) void {
        for (self.sinks.items) |sink| {
            sink.deinit();
            self.allocator.destroy(sink);
        }
        self.sinks.deinit(self.allocator);
        self.observable_windows.deinit(self.allocator);
        self.exemplar_sampler.deinit(self.allocator);
        self.allocator.destroy(self);
    }

    fn buildStorage(
        self: *Pipeline,
        agg: view.Aggregation,
        is_float: bool,
        is_monotonic: bool,
    ) Storage {
        return switch (agg) {
            .Drop => unreachable,
            .Sum => if (is_float)
                .{ .sum_double = storage.SumStorage(f64).init(self.allocator, self.io, self.cardinality_limit) }
            else
                .{ .sum_int = storage.SumStorage(i64).init(self.allocator, self.io, self.cardinality_limit) },
            .LastValue => if (is_float)
                .{ .last_value_double = storage.LastValueStorage(f64).init(self.allocator, self.io, self.cardinality_limit) }
            else
                .{ .last_value_int = storage.LastValueStorage(i64).init(self.allocator, self.io, self.cardinality_limit) },
            .ExplicitBucketHistogram => |conf| .{
                .explicit_histogram = storage.ExplicitBucketHistogramStorage.init(
                    self.allocator,
                    self.io,
                    self.cardinality_limit,
                    conf.buckets,
                    conf.record_min_max,
                    is_monotonic,
                ),
            },
            .ExponentialBucketHistogram => |conf| .{
                .exponential_histogram = storage.ExponentialHistogramStorage.init(
                    self.allocator,
                    self.io,
                    self.cardinality_limit,
                    conf.max_scale,
                    conf.max_size,
                    conf.record_min_max,
                    is_monotonic,
                ),
            },
        };
    }

    fn resolveOptions(base_opts: InstrumentOptions, config: view.CombinedViewConfig) InstrumentOptions {
        var opts = base_opts;
        if (config.name) |name_override| opts.name = name_override;
        if (config.description) |desc_override| opts.description = desc_override;
        return opts;
    }

    fn createSink(
        self: *Pipeline,
        instr: *Instrument,
        scope: *const InstrumentationScope,
        lock_ptr: *std.Io.Mutex,
        config: view.CombinedViewConfig,
        agg: view.Aggregation,
    ) !*StorageSink {
        const is_float = instr.isFloat();
        const sink = try self.allocator.create(StorageSink);
        errdefer self.allocator.destroy(sink);

        sink.* = .{
            .pipeline = self,
            .instrument_id = @intFromPtr(instr),
            .instrument_kind = instr.kind,
            .instrument_options = resolveOptions(instr.opts, config),
            .scope = scope.*,
            .instrument_lock = lock_ptr,
            .attribute_filter = config.attribute_filter,
            .exemplar_reservoir = config.exemplar_reservoir,
            .is_float = is_float,
            .collection_start_ns = @intCast(std.Io.Clock.real.now(self.io).nanoseconds),
            .storage = self.buildStorage(agg, is_float, instr.kind.isMonotonic()),
        };
        return sink;
    }

    /// Resolve views for `instr` and bind a StorageSink to it (unless Drop).
    pub fn bindInstrument(
        self: *Pipeline,
        instr: *Instrument,
        scope: *const InstrumentationScope,
        views: []const view.View,
    ) !void {
        const lock_ptr = instr.syncLock() orelse return;

        var config = view.CombinedViewConfig.init(instr.kind);
        for (views) |*v| {
            if (v.matches(instr, scope)) config.applyView(v);
        }
        const agg = config.combinedAggregation(self.reader.aggregation);
        try agg.validate();

        if (agg == .Drop) return;

        const sink = try self.createSink(instr, scope, lock_ptr, config, agg);
        errdefer {
            sink.deinit();
            self.allocator.destroy(sink);
        }

        try self.sinks.append(self.allocator, sink);
        errdefer _ = self.sinks.pop();

        try instr.addStorageSink(sink);
    }

    /// Remove and destroy any StorageSink bound to `instr` in this pipeline.
    pub fn unbindInstrument(self: *Pipeline, instr: *Instrument) void {
        const instr_id = @intFromPtr(instr);
        var idx: usize = 0;
        while (idx < self.sinks.items.len) {
            const sink = self.sinks.items[idx];
            if (sink.instrument_id == instr_id) {
                _ = self.sinks.swapRemove(idx);
                instr.removeStorageSink(sink);
                sink.deinit();
                self.allocator.destroy(sink);
            } else {
                idx += 1;
            }
        }
    }

    /// Prepare a view re-evaluation for `instr` without mutating `self.sinks` or `instr`.
    /// When aggregation and attribute filtering are unchanged, returns `.update_metadata`
    /// so uncollected measurements and collection windows are preserved.
    pub fn prepareRebind(
        self: *Pipeline,
        instr: *Instrument,
        scope: *const InstrumentationScope,
        views: []const view.View,
    ) !PendingRebind {
        const lock_ptr = instr.syncLock() orelse return .noop;
        const instr_id = @intFromPtr(instr);

        var config = view.CombinedViewConfig.init(instr.kind);
        for (views) |*v| {
            if (v.matches(instr, scope)) config.applyView(v);
        }
        const agg = config.combinedAggregation(self.reader.aggregation);
        try agg.validate();

        var existing_sink: ?*StorageSink = null;
        for (self.sinks.items) |sink| {
            if (sink.instrument_id == instr_id) {
                existing_sink = sink;
                break;
            }
        }

        if (agg == .Drop) {
            if (existing_sink) |old_sink| {
                return .{ .drop = .{ .pipeline = self, .instr = instr, .old_sink = old_sink } };
            }
            return .noop;
        }

        if (existing_sink) |existing| {
            if (sinkMatchesStorageAndFilter(existing, agg, config)) {
                const resolved = resolveOptions(instr.opts, config);
                if (std.mem.eql(u8, existing.instrument_options.name, resolved.name) and
                    optionalStringEqual(existing.instrument_options.description, resolved.description) and
                    existing.exemplar_reservoir == config.exemplar_reservoir)
                {
                    return .noop;
                }
                return .{ .update_metadata = .{
                    .sink = existing,
                    .options = resolved,
                    .exemplar_reservoir = config.exemplar_reservoir,
                } };
            }
        }

        const new_sink = try self.createSink(instr, scope, lock_ptr, config, agg);
        return .{ .replace = .{
            .pipeline = self,
            .instr = instr,
            .old_sink = existing_sink,
            .new_sink = new_sink,
        } };
    }

    /// Re-evaluate views for `instr` (e.g. after MeterProvider.addView).
    /// Replaces the existing sink only if aggregation or attribute filtering changed.
    pub fn rebindInstrument(
        self: *Pipeline,
        instr: *Instrument,
        scope: *const InstrumentationScope,
        views: []const view.View,
    ) !void {
        const pending = try self.prepareRebind(instr, scope, views);
        errdefer pending.deinitOnError();
        if (pending == .replace and pending.replace.old_sink == null) {
            try instr.ensureStorageCapacity(1);
            try self.sinks.ensureUnusedCapacity(self.allocator, 1);
        }
        pending.commit();
    }

    fn optionalStringEqual(a: ?[]const u8, b: ?[]const u8) bool {
        if (a == null and b == null) return true;
        if (a == null or b == null) return false;
        return std.mem.eql(u8, a.?, b.?);
    }

    fn sinkMatchesStorageAndFilter(
        sink: *const StorageSink,
        agg: view.Aggregation,
        config: view.CombinedViewConfig,
    ) bool {
        if (!attributeFilterEqual(sink.attribute_filter, config.attribute_filter)) return false;
        return switch (agg) {
            .Drop => false,
            .Sum => sink.storage == .sum_int or sink.storage == .sum_double,
            .LastValue => sink.storage == .last_value_int or sink.storage == .last_value_double,
            .ExplicitBucketHistogram => |conf| sink.storage == .explicit_histogram and
                sink.storage.explicit_histogram.record_min_max == conf.record_min_max and
                std.mem.eql(f64, sink.storage.explicit_histogram.buckets, conf.buckets),
            .ExponentialBucketHistogram => |conf| sink.storage == .exponential_histogram and
                sink.storage.exponential_histogram.record_min_max == conf.record_min_max and
                sink.storage.exponential_histogram.max_scale == conf.max_scale and
                sink.storage.exponential_histogram.max_size == conf.max_size,
        };
    }

    fn attributeFilterEqual(a: ?view.AttributeFilter, b: ?view.AttributeFilter) bool {
        if (a == null and b == null) return true;
        if (a == null or b == null) return false;
        const fa = a.?;
        const fb = b.?;
        if (!stringSliceEqual(fa.include_keys, fb.include_keys)) return false;
        if (!stringSliceEqual(fa.exclude_keys, fb.exclude_keys)) return false;
        return true;
    }

    fn stringSliceEqual(a: ?[]const []const u8, b: ?[]const []const u8) bool {
        if (a == null and b == null) return true;
        if (a == null or b == null) return false;
        const sa = a.?;
        const sb = b.?;
        if (sa.len != sb.len) return false;
        for (sa, sb) |x, y| {
            if (!std.mem.eql(u8, x, y)) return false;
        }
        return true;
    }

    pub fn beginCollection(self: *Pipeline) void {
        if (self.exemplar_filter != .always_off) self.exemplar_sampler.beginCollection();
    }

    pub fn endCollection(self: *Pipeline) void {
        if (self.exemplar_filter != .always_off) self.exemplar_sampler.endCollection();
    }

    /// Snapshot synchronous sinks belonging to this pipeline into `results`.
    /// Must be called while provider state is stable (e.g. under `mp.mx`).
    pub fn collectSync(
        self: *Pipeline,
        collect_allocator: std.mem.Allocator,
        resource: ?[]const Attribute,
        results: *std.ArrayList(Measurements),
    ) !void {
        for (self.sinks.items) |sink| {
            const data = try sink.collectData(
                collect_allocator,
                self.io,
                self.exemplar_filter,
                &self.exemplar_sampler,
            ) orelse continue;

            var measurement = Measurements{
                .scope = sink.scope,
                .instrumentKind = sink.instrument_kind,
                .instrumentOptions = sink.instrument_options,
                .data = data,
                .aggregation = sink.aggregationType(),
                .resource = resource,
            };
            errdefer measurement.deinit(collect_allocator);

            try self.reader.temporal_aggregation.process(&measurement, self.reader.temporality);
            try results.append(collect_allocator, measurement);
        }
    }

    /// Snapshot asynchronous observable instrument tasks from `mp` while `mp.mx` is held,
    /// so user callbacks can later run with `mp.mx` released.
    pub fn snapshotAsyncTasks(
        self: *Pipeline,
        allocator: std.mem.Allocator,
        mp: *MeterProvider,
    ) ![]AsyncTask {
        var tasks = std.ArrayList(AsyncTask).empty;
        errdefer tasks.deinit(allocator);

        var meters = mp.meters.valueIterator();
        while (meters.next()) |meter| {
            meter.mx.lockUncancelable(meter.io);
            defer meter.mx.unlock(meter.io);

            var instr_iter = meter.instruments.valueIterator();
            while (instr_iter.next()) |instr_ptr| {
                const instr = instr_ptr.*;
                switch (instr.kind) {
                    .ObservableCounter, .ObservableUpDownCounter, .ObservableGauge => {},
                    else => continue,
                }

                var config = view.CombinedViewConfig.init(instr.kind);
                for (mp.views.items) |*v| {
                    if (v.matches(instr, &meter.scope)) config.applyView(v);
                }
                const aggregation_type = config.combinedAggregation(self.reader.aggregation);
                try aggregation_type.validate();
                if (aggregation_type == .Drop) continue;

                try tasks.append(allocator, .{
                    .instr = instr,
                    .scope = .{
                        .name = meter.scope.name,
                        .version = meter.scope.version,
                        .schema_url = meter.scope.schema_url,
                        .attributes = meter.scope.attributes,
                    },
                    .opts = resolveOptions(instr.opts, config),
                    .agg = aggregation_type,
                    .attribute_filter = config.attribute_filter,
                    .exemplar_reservoir = config.exemplar_reservoir,
                });
            }
        }

        return try tasks.toOwnedSlice(allocator);
    }

    /// Execute snapshotted asynchronous tasks with `mp.mx` released, tracking per-pipeline windows
    /// and isolating callback failures so healthy metrics are still exported.
    pub fn collectAsyncTasks(
        self: *Pipeline,
        collect_allocator: std.mem.Allocator,
        resource: ?[]const Attribute,
        tasks: []const AsyncTask,
        results: *std.ArrayList(Measurements),
    ) !void {
        for (tasks) |task| {
            const instr = task.instr;
            const data_points: MeasurementsData = instr.getInstrumentsData(collect_allocator) catch |err| switch (err) {
                error.CallbackExecutionFailed,
                error.UnsupportedDataPointTypeReturnedByCallback,
                error.NonUniformMeasurementsDataType,
                => {
                    log.err("error observing instrument {s}: {}", .{ instr.opts.name, err });
                    continue;
                },
                else => return err,
            };
            var consumed = false;
            errdefer if (!consumed) {
                var failed = data_points;
                failed.deinit(collect_allocator);
            };

            if (data_points.isEmpty()) {
                consumed = true;
                var empty_dp = data_points;
                empty_dp.deinit(collect_allocator);
                continue;
            }

            const instr_id = @intFromPtr(instr);
            const window_start = self.observable_windows.get(instr_id) orelse
                @max(self.created_at_ns, instr.asyncCreatedNs() orelse self.created_at_ns);
            const obs_time_ns: u64 = switch (data_points) {
                inline else => |pts| pts[0].timestamps.?.time_ns,
            };
            switch (data_points) {
                inline else => |pts| for (pts) |*pt| {
                    pt.timestamps = .{ .start_time_ns = window_start, .time_ns = obs_time_ns };
                },
            }

            if (task.attribute_filter) |filter| {
                try AggregatedMetrics.filterAttributes(collect_allocator, data_points, filter);
            }

            consumed = true;
            const exemplar_ctx: ?AggregatedMetrics.ExemplarContext = if (self.exemplar_filter != .always_off) .{
                .sampler = &self.exemplar_sampler,
                .io = self.io,
                .instrument_id = instr_id,
                .factory = task.exemplar_reservoir,
            } else null;

            const aggregated_data = try AggregatedMetrics.aggregate(
                collect_allocator,
                data_points,
                task.agg,
                instr.kind.isMonotonic(),
                exemplar_ctx,
            ) orelse continue;

            var measurement = Measurements{
                .scope = task.scope,
                .instrumentKind = instr.kind,
                .instrumentOptions = task.opts,
                .data = aggregated_data,
                .aggregation = task.agg.getType(),
                .resource = resource,
            };
            errdefer measurement.deinit(collect_allocator);

            try self.observable_windows.ensureUnusedCapacity(self.allocator, 1);
            try self.reader.temporal_aggregation.process(&measurement, self.reader.temporality);
            try results.append(collect_allocator, measurement);
            self.observable_windows.putAssumeCapacity(instr_id, obs_time_ns);
        }
    }

    /// Convenience helper for single-threaded callers/tests collecting while holding `mp.mx`.
    pub fn collect(self: *Pipeline, collect_allocator: std.mem.Allocator, mp: *MeterProvider) ![]Measurements {
        self.beginCollection();
        defer self.endCollection();

        var results = std.ArrayList(Measurements).empty;
        errdefer {
            for (results.items) |*r| r.deinit(collect_allocator);
            results.deinit(collect_allocator);
        }

        try self.collectSync(collect_allocator, mp.resource, &results);
        const async_tasks = try self.snapshotAsyncTasks(collect_allocator, mp);
        defer collect_allocator.free(async_tasks);
        try self.collectAsyncTasks(collect_allocator, mp.resource, async_tasks, &results);

        return try results.toOwnedSlice(collect_allocator);
    }
};

const MetricExporter = @import("exporter.zig").MetricExporter;

fn histogramForCounter(_: Kind) view.Aggregation {
    return .{ .ExplicitBucketHistogram = .{ .buckets = &.{ 10.0, 50.0 } } };
}

test "pipeline: two readers with different aggregations collect independently" {
    const allocator = std.testing.allocator;
    const io = std.testing.io;

    const mp = try MeterProvider.init(allocator, io, null);
    defer mp.deinit();

    const me_sum = try MetricExporter.InMemory(allocator, io, view.TemporalityDelta, null);
    defer me_sum.in_memory.deinit();
    const reader_sum = try MetricReader.init(allocator, io, me_sum.exporter);
    defer reader_sum.deinit();
    try mp.addReader(reader_sum);

    const me_hist = try MetricExporter.InMemory(allocator, io, view.TemporalityDelta, histogramForCounter);
    defer me_hist.in_memory.deinit();
    const reader_hist = try MetricReader.init(allocator, io, me_hist.exporter);
    defer reader_hist.deinit();
    try mp.addReader(reader_hist);

    const meter = try mp.getMeter(.{ .name = "multi-agg" });
    const counter = try meter.createCounter(u64, .{ .name = "requests" });

    try counter.add(5, .{ "route", @as([]const u8, "/a") });
    try counter.add(25, .{ "route", @as([]const u8, "/a") });

    try reader_sum.collect();
    const sum_data = try me_sum.in_memory.fetch(allocator);
    defer {
        for (sum_data) |*m| m.deinit(allocator);
        allocator.free(sum_data);
    }
    try std.testing.expectEqual(@as(usize, 1), sum_data.len);
    try std.testing.expectEqual(@as(i64, 30), sum_data[0].data.int[0].value);

    // Collecting on reader_sum must not drain reader_hist.
    try reader_hist.collect();
    const hist_data = try me_hist.in_memory.fetch(allocator);
    defer {
        for (hist_data) |*m| m.deinit(allocator);
        allocator.free(hist_data);
    }
    try std.testing.expectEqual(@as(usize, 1), hist_data.len);
    const dp = hist_data[0].data.histogram[0].value;
    try std.testing.expectEqual(@as(u64, 2), dp.count);
    try std.testing.expectEqual(@as(f64, 30.0), dp.sum.?);
    try std.testing.expectEqualSlices(u64, &.{ 1, 1, 0 }, dp.bucket_counts);
}

test "pipeline: two delta readers collecting at different intervals stay independent" {
    const allocator = std.testing.allocator;
    const io = std.testing.io;

    const mp = try MeterProvider.init(allocator, io, null);
    defer mp.deinit();

    const me_fast = try MetricExporter.InMemory(allocator, io, view.TemporalityDelta, null);
    defer me_fast.in_memory.deinit();
    const reader_fast = try MetricReader.init(allocator, io, me_fast.exporter);
    defer reader_fast.deinit();
    try mp.addReader(reader_fast);

    const me_slow = try MetricExporter.InMemory(allocator, io, view.TemporalityDelta, null);
    defer me_slow.in_memory.deinit();
    const reader_slow = try MetricReader.init(allocator, io, me_slow.exporter);
    defer reader_slow.deinit();
    try mp.addReader(reader_slow);

    const meter = try mp.getMeter(.{ .name = "delta-intervals" });
    const counter = try meter.createCounter(u64, .{ .name = "events" });

    try counter.add(10, .{});
    try reader_fast.collect();
    {
        const d = try me_fast.in_memory.fetch(allocator);
        defer {
            for (d) |*m| m.deinit(allocator);
            allocator.free(d);
        }
        try std.testing.expectEqual(@as(i64, 10), d[0].data.int[0].value);
    }

    try counter.add(5, .{});
    try reader_fast.collect();
    {
        const d = try me_fast.in_memory.fetch(allocator);
        defer {
            for (d) |*m| m.deinit(allocator);
            allocator.free(d);
        }
        try std.testing.expectEqual(@as(i64, 5), d[0].data.int[0].value);
    }

    // Slow reader has not collected yet, so it sees the full 10 + 5 = 15 window.
    try reader_slow.collect();
    {
        const d = try me_slow.in_memory.fetch(allocator);
        defer {
            for (d) |*m| m.deinit(allocator);
            allocator.free(d);
        }
        try std.testing.expectEqual(@as(i64, 15), d[0].data.int[0].value);
    }

    try counter.add(3, .{});
    try reader_fast.collect();
    try reader_slow.collect();
    {
        const d_fast = try me_fast.in_memory.fetch(allocator);
        defer {
            for (d_fast) |*m| m.deinit(allocator);
            allocator.free(d_fast);
        }
        const d_slow = try me_slow.in_memory.fetch(allocator);
        defer {
            for (d_slow) |*m| m.deinit(allocator);
            allocator.free(d_slow);
        }
        try std.testing.expectEqual(@as(i64, 3), d_fast[0].data.int[0].value);
        try std.testing.expectEqual(@as(i64, 3), d_slow[0].data.int[0].value);
    }
}

test "pipeline: detachReader while another thread records" {
    const allocator = std.testing.allocator;
    const io = std.testing.io;

    const mp = try MeterProvider.init(allocator, io, null);
    defer mp.deinit();

    const me1 = try MetricExporter.InMemory(allocator, io, view.TemporalityDelta, null);
    defer me1.in_memory.deinit();
    const reader1 = try MetricReader.init(allocator, io, me1.exporter);
    defer reader1.deinit();
    try mp.addReader(reader1);

    const me2 = try MetricExporter.InMemory(allocator, io, view.TemporalityDelta, null);
    defer me2.in_memory.deinit();
    const reader2 = try MetricReader.init(allocator, io, me2.exporter);
    defer reader2.deinit();
    try mp.addReader(reader2);

    const meter = try mp.getMeter(.{ .name = "concurrent-detach" });
    const counter = try meter.createCounter(u64, .{ .name = "ops" });

    var stop = std.atomic.Value(bool).init(false);
    const Worker = struct {
        fn run(c: *instrument.Counter(u64), stop_flag: *std.atomic.Value(bool)) void {
            while (!stop_flag.load(.acquire)) {
                c.add(1, .{ "worker", @as(i64, 1) }) catch {};
            }
        }
    };

    const thread = try std.Thread.spawn(.{}, Worker.run, .{ counter, &stop });
    defer {
        stop.store(true, .release);
        thread.join();
    }

    std.Io.sleep(io, .fromMilliseconds(5), .awake) catch {};
    mp.detachReader(reader2);
    std.Io.sleep(io, .fromMilliseconds(5), .awake) catch {};
    try reader1.collect();
    stop.store(true, .release);

    const d1 = try me1.in_memory.fetch(allocator);
    defer {
        for (d1) |*m| m.deinit(allocator);
        allocator.free(d1);
    }
    try std.testing.expectEqual(@as(usize, 1), d1.len);
    try std.testing.expect(d1[0].data.int[0].value > 0);
}

test "pipeline: 1M measurements with two disagreeing readers keep memory flat" {
    const allocator = std.testing.allocator;
    const io = std.testing.io;

    var tracked = std.testing.FailingAllocator.init(allocator, .{ .fail_index = std.math.maxInt(usize) });
    const tracked_alloc = tracked.allocator();

    const mp = try MeterProvider.init(tracked_alloc, io, null);
    defer mp.deinit();

    const me_sum = try MetricExporter.InMemory(tracked_alloc, io, view.TemporalityDelta, null);
    defer me_sum.in_memory.deinit();
    const reader_sum = try MetricReader.init(tracked_alloc, io, me_sum.exporter);
    defer reader_sum.deinit();
    try mp.addReader(reader_sum);

    const me_hist = try MetricExporter.InMemory(tracked_alloc, io, view.TemporalityDelta, histogramForCounter);
    defer me_hist.in_memory.deinit();
    const reader_hist = try MetricReader.init(tracked_alloc, io, me_hist.exporter);
    defer reader_hist.deinit();
    try mp.addReader(reader_hist);

    const meter = try mp.getMeter(.{ .name = "flat-memory" });
    const counter = try meter.createCounter(u64, .{ .name = "requests" });

    // Warm up the series so both pipelines allocate their storage slots once.
    try counter.add(1, .{ "route", @as([]const u8, "/api") });
    const baseline_live_bytes = tracked.allocated_bytes - tracked.freed_bytes;

    // 1,000,000 measurements across the same series must allocate 0 additional bytes.
    for (0..1_000_000) |_| {
        try counter.add(1, .{ "route", @as([]const u8, "/api") });
    }
    const after_live_bytes = tracked.allocated_bytes - tracked.freed_bytes;
    try std.testing.expectEqual(baseline_live_bytes, after_live_bytes);

    try reader_sum.collect();
    try reader_hist.collect();

    const sum_data = try me_sum.in_memory.fetch(tracked_alloc);
    defer {
        for (sum_data) |*m| m.deinit(tracked_alloc);
        tracked_alloc.free(sum_data);
    }
    const hist_data = try me_hist.in_memory.fetch(tracked_alloc);
    defer {
        for (hist_data) |*m| m.deinit(tracked_alloc);
        tracked_alloc.free(hist_data);
    }

    try std.testing.expectEqual(@as(i64, 1_000_001), sum_data[0].data.int[0].value);
    try std.testing.expectEqual(@as(u64, 1_000_001), hist_data[0].data.histogram[0].value.count);
}

fn pipelineLifecycleAllocationFailure(allocator: std.mem.Allocator) !void {
    const InMemoryExporter = @import("exporters/in_memory.zig").InMemoryExporter;
    const io = std.testing.io;

    // Set up reader/exporter with testing.allocator so OOM injection targets
    // MeterProvider, Pipeline, instruments, and collection paths directly.
    var in_mem = try InMemoryExporter.init(std.testing.allocator, io);
    defer in_mem.deinit();
    const metric_exporter = try MetricExporter.new(std.testing.allocator, io, &in_mem.exporter);
    metric_exporter.temporality = view.TemporalityDelta;
    const reader = try MetricReader.init(std.testing.allocator, io, metric_exporter);
    defer reader.deinit();

    const mp = try MeterProvider.init(allocator, io, null);
    defer mp.deinit();

    const meter = try mp.getMeter(.{ .name = "oom-test" });
    const counter = try meter.createCounter(u64, .{ .name = "before" });

    try mp.addReader(reader);
    const after = try meter.createCounter(u64, .{ .name = "after" });

    try counter.add(3, .{ "k", @as([]const u8, "v") });
    try after.add(4, .{});

    const collected = try reader.pipeline.?.collect(allocator, mp);
    defer {
        for (collected) |*m| m.deinit(allocator);
        allocator.free(collected);
    }
    try std.testing.expectEqual(@as(usize, 2), collected.len);
}

test "pipeline: lifecycle handles allocation failures without leaks or dangling sinks" {
    var fail_index: usize = 0;
    while (true) : (fail_index += 1) {
        var failing = std.testing.FailingAllocator.init(std.testing.allocator, .{ .fail_index = fail_index });
        const result = pipelineLifecycleAllocationFailure(failing.allocator());
        if (!failing.has_induced_failure) {
            try result;
            break;
        }
        result catch |err| switch (err) {
            error.OutOfMemory => {},
            else => return err,
        };
    }
}

test "pipeline: AggregatedMetrics.fetch fails explicitly on synchronous instruments" {
    const allocator = std.testing.allocator;
    const io = std.testing.io;

    const mp = try MeterProvider.init(allocator, io, null);
    defer mp.deinit();
    const meter = try mp.getMeter(.{ .name = "obsolete-fetch" });
    _ = try meter.createCounter(u64, .{ .name = "requests" });

    try std.testing.expectError(
        error.SynchronousCollectionRequiresMetricReader,
        AggregatedMetrics.fetch(allocator, meter, mp.views.items, null),
    );
}

test "pipeline: detachReader ignores reader owned by another provider" {
    const allocator = std.testing.allocator;
    const io = std.testing.io;

    const mp_a = try MeterProvider.init(allocator, io, null);
    defer mp_a.deinit();
    const mp_b = try MeterProvider.init(allocator, io, null);
    defer mp_b.deinit();

    const me = try MetricExporter.InMemory(allocator, io, view.TemporalityDelta, null);
    defer me.in_memory.deinit();
    const reader = try MetricReader.init(allocator, io, me.exporter);
    defer reader.deinit();
    try mp_a.addReader(reader);

    const meter = try mp_a.getMeter(.{ .name = "cross-provider" });
    const counter = try meter.createCounter(u64, .{ .name = "hits" });
    try counter.add(5, .{});

    // Must be a no-op because `reader` belongs to `mp_a`, not `mp_b`.
    mp_b.detachReader(reader);
    try std.testing.expectEqual(mp_a, reader.meterProvider.?);
    try std.testing.expect(reader.pipeline != null);

    try reader.collect();
    const data = try me.in_memory.fetch(allocator);
    defer {
        for (data) |*m| m.deinit(allocator);
        allocator.free(data);
    }
    try std.testing.expectEqual(@as(usize, 1), data.len);
    try std.testing.expectEqual(@as(i64, 5), data[0].data.int[0].value);
}

test "pipeline: addView metadata or reservoir update preserves uncollected measurements" {
    const allocator = std.testing.allocator;
    const io = std.testing.io;

    const CustomFactory = struct {
        fn create(a: std.mem.Allocator, i: std.Io, options: exemplar.ReservoirOptions) !exemplar.ExemplarReservoir {
            return exemplar.SimpleFixedSizeExemplarReservoir.init(a, i, options.fixed_size);
        }
    };

    const mp = try MeterProvider.init(allocator, io, null);
    defer mp.deinit();
    const me = try MetricExporter.InMemory(allocator, io, view.TemporalityDelta, null);
    defer me.in_memory.deinit();
    const reader = try MetricReader.init(allocator, io, me.exporter);
    defer reader.deinit();
    try mp.addReader(reader);

    const meter = try mp.getMeter(.{ .name = "metadata-preserve" });
    const counter = try meter.createCounter(u64, .{ .name = "requests" });
    try counter.add(7, .{});

    try mp.addView(.{
        .instrument_selector = .{ .name = "requests" },
        .name = "requests_renamed",
        .description = "renamed description",
        .exemplar_reservoir = CustomFactory.create,
        .aggregation = .Sum,
        .temporality = .Delta,
    });
    try counter.add(3, .{});

    try reader.collect();
    const data = try me.in_memory.fetch(allocator);
    defer {
        for (data) |*m| m.deinit(allocator);
        allocator.free(data);
    }
    try std.testing.expectEqual(@as(usize, 1), data.len);
    try std.testing.expectEqualStrings("requests_renamed", data[0].instrumentOptions.name);
    try std.testing.expectEqualStrings("renamed description", data[0].instrumentOptions.description.?);
    try std.testing.expectEqual(@as(i64, 10), data[0].data.int[0].value);
}

test "pipeline: addView rebinding is atomic on allocation failure" {
    const allocator = std.testing.allocator;
    const io = std.testing.io;

    var failing = std.testing.FailingAllocator.init(allocator, .{});
    const falloc = failing.allocator();

    const mp = try MeterProvider.init(falloc, io, null);
    defer mp.deinit();
    const me = try MetricExporter.InMemory(allocator, io, view.TemporalityDelta, null);
    defer me.in_memory.deinit();
    const reader = try MetricReader.init(allocator, io, me.exporter);
    defer reader.deinit();
    try mp.addReader(reader);

    const meter = try mp.getMeter(.{ .name = "atomic-view" });
    const counter = try meter.createCounter(u64, .{ .name = "c1" });
    try counter.add(11, .{});

    const new_view = view.View{
        .instrument_selector = .{ .name = "c1" },
        .aggregation = .{ .ExplicitBucketHistogram = .{ .buckets = &.{ 1.0, 10.0 } } },
        .temporality = .Delta,
    };

    // Fail at every possible allocation point inside addView.
    var fail_offset: usize = 0;
    while (true) : (fail_offset += 1) {
        failing.has_induced_failure = false;
        failing.fail_index = failing.alloc_index + fail_offset;
        const res = mp.addView(new_view);
        failing.fail_index = std.math.maxInt(usize);
        if (!failing.has_induced_failure) {
            try res;
            break;
        }
        try std.testing.expectError(error.OutOfMemory, res);
        // Provider views and existing counter storage must remain untouched.
        try std.testing.expectEqual(@as(usize, 0), mp.views.items.len);
        try std.testing.expect(counter.storages.items[0].storage == .sum_int);
    }
}

test "pipeline: observable callback failure preserves sync metrics and re-entrant callback does not deadlock" {
    const Async = @import("../../api/metrics/async_instrument.zig");
    const allocator = std.testing.allocator;
    const io = std.testing.io;

    const Callbacks = struct {
        fn failingObserve(_: Async.ObservedContext, _: std.mem.Allocator) Async.MetricObserveError!MeasurementsData {
            return Async.MetricObserveError.CallbackExecutionFailed;
        }
        fn reentrantObserve(ctx: Async.ObservedContext, alloc: std.mem.Allocator) Async.MetricObserveError!MeasurementsData {
            const provider = ctx.into(MeterProvider).?;
            _ = provider.getMeter(.{ .name = "callback-meter" }) catch return Async.MetricObserveError.CallbackExecutionFailed;
            const pts = try alloc.alloc(DataPoint(i64), 1);
            pts[0] = .{ .value = 42 };
            return .{ .int = pts };
        }
    };

    const mp = try MeterProvider.init(allocator, io, null);
    defer mp.deinit();
    const me = try MetricExporter.InMemory(allocator, io, view.TemporalityDelta, null);
    defer me.in_memory.deinit();
    const reader = try MetricReader.init(allocator, io, me.exporter);
    defer reader.deinit();
    try mp.addReader(reader);

    const meter = try mp.getMeter(.{ .name = "async-resilience" });
    const counter = try meter.createCounter(u64, .{ .name = "sync_counter" });
    try counter.add(9, .{});

    var failing_cbs = [_]Async.ObserveMeasures{Callbacks.failingObserve};
    _ = try meter.createObservableCounter(.{ .name = "failing_async" }, .{}, &failing_cbs);

    var reentrant_cbs = [_]Async.ObserveMeasures{Callbacks.reentrantObserve};
    _ = try meter.createObservableGauge(.{ .name = "reentrant_async" }, Async.ObservedContext.from(mp), &reentrant_cbs);

    try reader.collect();
    const data = try me.in_memory.fetch(allocator);
    defer {
        for (data) |*m| m.deinit(allocator);
        allocator.free(data);
    }
    try std.testing.expectEqual(@as(usize, 2), data.len);
}

test "pipeline: two readers track independent observable collection windows" {
    const Async = @import("../../api/metrics/async_instrument.zig");
    const allocator = std.testing.allocator;
    const io = std.testing.io;

    const Observer = struct {
        fn observe(ctx: Async.ObservedContext, alloc: std.mem.Allocator) Async.MetricObserveError!MeasurementsData {
            const val = ctx.into(i64).?.*;
            const pts = try alloc.alloc(DataPoint(i64), 1);
            pts[0] = .{ .value = val };
            return .{ .int = pts };
        }
    };

    const mp = try MeterProvider.init(allocator, io, null);
    defer mp.deinit();

    const me_a = try MetricExporter.InMemory(allocator, io, view.TemporalityDelta, null);
    defer me_a.in_memory.deinit();
    const reader_a = try MetricReader.init(allocator, io, me_a.exporter);
    defer reader_a.deinit();
    try mp.addReader(reader_a);

    const me_b = try MetricExporter.InMemory(allocator, io, view.TemporalityDelta, null);
    defer me_b.in_memory.deinit();
    const reader_b = try MetricReader.init(allocator, io, me_b.exporter);
    defer reader_b.deinit();
    try mp.addReader(reader_b);

    const meter = try mp.getMeter(.{ .name = "obs-windows" });
    var total: i64 = 10;
    var cbs = [_]Async.ObserveMeasures{Observer.observe};
    _ = try meter.createObservableCounter(.{ .name = "cpu" }, Async.ObservedContext.from(&total), &cbs);

    // Reader A collects twice; Reader B has not collected yet.
    try reader_a.collect();
    {
        const d = try me_a.in_memory.fetch(allocator);
        defer {
            for (d) |*m| m.deinit(allocator);
            allocator.free(d);
        }
        try std.testing.expectEqual(@as(i64, 10), d[0].data.int[0].value);
    }
    total = 25;
    try reader_a.collect();
    const a_second_time = blk: {
        const d = try me_a.in_memory.fetch(allocator);
        defer {
            for (d) |*m| m.deinit(allocator);
            allocator.free(d);
        }
        try std.testing.expectEqual(@as(i64, 15), d[0].data.int[0].value);
        break :blk d[0].data.int[0].timestamps.?.time_ns;
    };

    // Reader B's first collection must see the full 25 AND its own window start (< a_second_time),
    // not Reader A's last collection timestamp.
    try reader_b.collect();
    {
        const d = try me_b.in_memory.fetch(allocator);
        defer {
            for (d) |*m| m.deinit(allocator);
            allocator.free(d);
        }
        try std.testing.expectEqual(@as(i64, 25), d[0].data.int[0].value);
        const start_b = d[0].data.int[0].timestamps.?.start_time_ns.?;
        try std.testing.expect(start_b < a_second_time);
    }
}
