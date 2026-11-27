const std = @import("std");

// NOTE: API-surface mutex operations use lockUncancelable so that user-facing
// methods do not introduce cancellation points. This is safe with Io.Threaded
// (the default) but means user cancellations will be ignored if the SDK is
// used with Io.Evented. Switching to lock() would require propagating
// error{Canceled} through all public APIs.

const log = std.log.scoped(.meter);

const spec = @import("spec.zig");
const builtin = @import("builtin");
const Attribute = @import("../../attributes.zig").Attribute;
const Attributes = @import("../../attributes.zig").Attributes;
const InstrumentationScope = @import("../../scope.zig").InstrumentationScope;

const DataPoint = @import("measurement.zig").DataPoint;
const Timestamps = @import("measurement.zig").Timestamps;
const metrics_temporality = @import("../../sdk/metrics/temporality.zig");
const HistogramDataPoint = @import("measurement.zig").HistogramDataPoint;
const aggregation = @import("../../sdk/metrics/aggregation.zig");
const ExponentialHistogramDataPoint = aggregation.ExponentialHistogramDataPoint;

const exemplar = @import("../../sdk/metrics/exemplar.zig");
const Pipeline = @import("../../sdk/metrics/pipeline.zig").Pipeline;

const MeasurementsData = @import("measurement.zig").MeasurementsData;
const Measurements = @import("measurement.zig").Measurements;

const Instrument = @import("instrument.zig").Instrument;
const Kind = @import("instrument.zig").Kind;
const InstrumentOptions = @import("instrument.zig").InstrumentOptions;
const Counter = @import("instrument.zig").Counter;
const Histogram = @import("instrument.zig").Histogram;
const Gauge = @import("instrument.zig").Gauge;
const MetricReader = @import("../../sdk/metrics/reader.zig").MetricReader;
const exporter = @import("../../sdk/metrics/exporter.zig");
const MetricExporter = exporter.MetricExporter;
const InMemoryExporter = @import("../../sdk/metrics/exporters/in_memory.zig").InMemoryExporter;

const AsyncInstrument = @import("async_instrument.zig");

// Import configuration module
const Configuration = @import("../../sdk/config.zig").Configuration;
const MetricsConfig = @import("../../sdk/config.zig").MetricsConfig;
const resource_attributes = @import("../../sdk/resource.zig");

/// MeterProvider is responsble for creating and managing meters.
/// See https://opentelemetry.io/docs/specs/otel/metrics/api/#meterprovider
pub const MeterProvider = struct {
    allocator: std.mem.Allocator,
    io: std.Io,
    meters: std.HashMapUnmanaged(
        InstrumentationScope,
        Meter,
        InstrumentationScope.HashContext,
        std.hash_map.default_max_load_percentage,
    ),
    readers: std.ArrayListUnmanaged(*MetricReader),
    pipelines: std.ArrayListUnmanaged(*Pipeline),
    views: std.ArrayListUnmanaged(view.View),
    sdk_disabled: bool,
    // Configuration (accessed internally from global singleton)
    config: ?*const Configuration,
    // Resource attributes for this provider
    resource: ?[]const Attribute = null,

    is_shutdown: std.atomic.Value(bool) = std.atomic.Value(bool).init(false),
    mx: std.Io.Mutex = std.Io.Mutex.init,

    const Self = @This();

    /// Create a new custom meter provider, using the specified allocator.
    pub fn init(alloc: std.mem.Allocator, io: std.Io, resource: ?[]const Attribute) !*Self {
        // Access global configuration (transparent to user)
        const cfg = Configuration.get();
        const sdk_disabled = if (cfg) |c| c.sdk_disabled else false;

        // Only build resource attributes from config if SDK is enabled
        const merged_resource = if (!sdk_disabled) blk: {
            const cfg_resource_attributes: []Attribute = if (cfg) |c| try resource_attributes.buildFromConfig(alloc, c) else &.{};
            defer if (cfg_resource_attributes.len > 0) resource_attributes.freeResource(alloc, cfg_resource_attributes);
            break :blk try resource_attributes.mergeResources(
                alloc,
                if (resource) |r| r else &.{},
                cfg_resource_attributes,
            );
        } else null;
        errdefer if (merged_resource) |r| resource_attributes.freeResource(alloc, r);

        const provider = try alloc.create(Self);
        provider.* = Self{
            .allocator = alloc,
            .io = io,
            .meters = .empty,
            .readers = .empty,
            .pipelines = .empty,
            .views = .empty,
            .sdk_disabled = sdk_disabled,
            .config = cfg,
            .resource = merged_resource,
        };

        if (sdk_disabled) {
            std.log.info("MeterProvider: SDK disabled via OTEL_SDK_DISABLED", .{});
        }

        return provider;
    }

    /// Detach a MetricReader from this provider without shutting it down.
    /// Rejects readers that are not attached to this provider.
    pub fn detachReader(self: *Self, reader: *MetricReader) void {
        self.mx.lockUncancelable(self.io);

        if (reader.meterProvider != self) {
            self.mx.unlock(self.io);
            return;
        }

        for (self.readers.items, 0..) |r, i| {
            if (r == reader) {
                _ = self.readers.swapRemove(i);
                reader.meterProvider = null;
                break;
            }
        }

        const detached_pipeline: ?*Pipeline = blk: {
            const pipeline = reader.pipeline orelse break :blk null;
            reader.pipeline = null;
            for (self.pipelines.items, 0..) |p, i| {
                if (p == pipeline) {
                    _ = self.pipelines.swapRemove(i);
                    break;
                }
            }

            var meter_iter = self.meters.valueIterator();
            while (meter_iter.next()) |meter| {
                meter.mx.lockUncancelable(meter.io);
                defer meter.mx.unlock(meter.io);

                var instr_iter = meter.instruments.valueIterator();
                while (instr_iter.next()) |instr| {
                    instr.*.removeStorageSinksForPipeline(pipeline);
                }
            }
            break :blk pipeline;
        };
        self.mx.unlock(self.io);

        if (detached_pipeline) |p| p.release();
    }

    /// Immediately export all metrics that have not yet been exported across all registered MetricReaders.
    /// See https://opentelemetry.io/docs/specs/otel/metrics/sdk/#meterprovider-forceflush
    pub fn forceFlush(self: *Self) !void {
        if (self.is_shutdown.load(.acquire)) {
            return error.MeterProviderShutdown;
        }

        self.mx.lockUncancelable(self.io);
        const readers = try self.allocator.dupe(*MetricReader, self.readers.items);
        self.mx.unlock(self.io);
        defer self.allocator.free(readers);

        var first_error: ?anyerror = null;
        for (readers) |reader| {
            reader.forceFlush() catch |err| {
                if (first_error == null) first_error = err;
            };
        }
        if (first_error) |err| return err;
    }

    /// Flush and shut down all registered MetricReaders.
    /// Idempotent: subsequent calls return immediately.
    /// Every reader is shut down even if some fail; the first error is returned.
    /// To free provider memory and meters, call deinit().
    /// See https://opentelemetry.io/docs/specs/otel/metrics/sdk/#meterprovider-shutdown
    pub fn shutdown(self: *Self) !void {
        if (self.is_shutdown.swap(true, .acq_rel)) {
            return;
        }

        var first_error: ?anyerror = null;
        self.mx.lockUncancelable(self.io);
        const readers = self.allocator.dupe(*MetricReader, self.readers.items) catch {
            while (self.readers.items.len > 0) {
                const reader = self.readers.items[self.readers.items.len - 1];
                self.mx.unlock(self.io);
                reader.shutdown() catch |err| {
                    if (first_error == null) first_error = err;
                };
                self.mx.lockUncancelable(self.io);
                if (self.readers.items.len > 0 and self.readers.items[self.readers.items.len - 1] == reader) {
                    _ = self.readers.pop();
                    reader.meterProvider = null;
                }
            }
            self.mx.unlock(self.io);
            if (first_error) |err| return err;
            return;
        };
        self.mx.unlock(self.io);
        defer self.allocator.free(readers);

        for (readers) |reader| {
            reader.shutdown() catch |err| {
                if (first_error == null) first_error = err;
            };
        }
        if (first_error) |err| return err;
    }

    /// Shutdown the provider, if it is still running, and free it along with its meters.
    /// Callers that need the readers' final export result call shutdown() first.
    pub fn deinit(self: *Self) void {
        self.shutdown() catch |err| log.err("shutdown: error while shutting down readers: {}", .{err});

        self.mx.lockUncancelable(self.io);

        self.readers.deinit(self.allocator);
        for (self.pipelines.items) |p| {
            p.release();
        }
        self.pipelines.deinit(self.allocator);

        var meters = self.meters.valueIterator();
        while (meters.next()) |m| {
            m.deinit();
        }
        self.meters.deinit(self.allocator);
        self.views.deinit(self.allocator);

        if (self.resource) |res| {
            resource_attributes.freeResource(self.allocator, res);
        }

        self.mx.unlock(self.io);
        self.allocator.destroy(self);
    }

    /// Get a new meter by specifying its name.
    /// Scope can be passed to specify a version, schemaURL, and attributes.
    /// SchemaURL and attributes are default to null.
    /// If a meter with the same name already exists, it will be returned.
    /// See https://opentelemetry.io/docs/specs/otel/metrics/api/#get-a-meter
    pub fn getMeter(self: *Self, scope: InstrumentationScope) !*Meter {
        if (self.is_shutdown.load(.acquire)) {
            return error.MeterProviderShutdown;
        }

        self.mx.lockUncancelable(self.io);
        defer self.mx.unlock(self.io);

        const i = Meter{
            .scope = scope,
            .instruments = .empty,
            .allocator = self.allocator,
            .io = self.io,
            .exemplar_filter = if (self.sdk_disabled) .always_off else if (self.config) |cfg| cfg.metrics_config.exemplar_filter else .trace_based,
            .exemplar_sampler = .{ .allocator = self.allocator },
            .provider = self,
            .cardinality_limit = if (self.config) |cfg| cfg.metrics_config.cardinality_limit else spec.default_cardinality_limit,
        };

        const meter = try self.meters.getOrPutValue(self.allocator, scope, i);

        return meter.value_ptr;
    }

    pub fn addReader(self: *Self, m: *MetricReader) !void {
        if (self.is_shutdown.load(.acquire)) {
            return error.MeterProviderShutdown;
        }

        self.mx.lockUncancelable(self.io);
        defer self.mx.unlock(self.io);

        if (m.meterProvider != null) {
            return spec.ResourceError.MetricReaderAlreadyAttached;
        }

        const cardinality_limit = if (self.config) |cfg| cfg.metrics_config.cardinality_limit else spec.default_cardinality_limit;
        const exemplar_filter: exemplar.ExemplarFilter = if (self.sdk_disabled) .always_off else if (self.config) |cfg| cfg.metrics_config.exemplar_filter else .trace_based;
        const pipeline = try Pipeline.init(self.allocator, self.io, m, cardinality_limit, exemplar_filter);
        errdefer {
            var meter_iter = self.meters.valueIterator();
            while (meter_iter.next()) |meter| {
                meter.mx.lockUncancelable(meter.io);
                defer meter.mx.unlock(meter.io);
                var instr_iter = meter.instruments.valueIterator();
                while (instr_iter.next()) |instr| {
                    instr.*.removeStorageSinksForPipeline(pipeline);
                }
            }
            pipeline.release();
        }

        var meter_iter = self.meters.valueIterator();
        while (meter_iter.next()) |meter| {
            meter.mx.lockUncancelable(meter.io);
            defer meter.mx.unlock(meter.io);

            var instr_iter = meter.instruments.valueIterator();
            while (instr_iter.next()) |instr| {
                try pipeline.bindInstrument(instr.*, &meter.scope, self.views.items);
            }
        }

        try self.pipelines.append(self.allocator, pipeline);
        errdefer _ = self.pipelines.pop();

        try self.readers.append(self.allocator, m);
        m.meterProvider = self;
        m.pipeline = pipeline;
    }

    /// Register a view with this meter provider.
    /// Atomic on allocation or validation failure: either all instruments/pipelines are updated or none are.
    pub fn addView(self: *Self, new_view: view.View) !void {
        if (self.is_shutdown.load(.acquire)) {
            return error.MeterProviderShutdown;
        }

        try new_view.aggregation.validate();

        self.mx.lockUncancelable(self.io);
        defer self.mx.unlock(self.io);

        try self.views.append(self.allocator, new_view);
        errdefer _ = self.views.pop();

        var pending = std.ArrayList(Pipeline.PendingRebind).empty;
        defer pending.deinit(self.allocator);
        errdefer {
            for (pending.items) |item| item.deinitOnError();
        }

        const extra_per_pipeline = try self.allocator.alloc(usize, self.pipelines.items.len);
        defer self.allocator.free(extra_per_pipeline);
        @memset(extra_per_pipeline, 0);

        var meter_iter = self.meters.valueIterator();
        while (meter_iter.next()) |meter| {
            meter.mx.lockUncancelable(meter.io);
            defer meter.mx.unlock(meter.io);

            var instr_iter = meter.instruments.valueIterator();
            while (instr_iter.next()) |instr_ptr| {
                const instr = instr_ptr.*;
                var extra_for_instr: usize = 0;
                for (self.pipelines.items, 0..) |pipeline, p_idx| {
                    const rebind = try pipeline.prepareRebind(instr, &meter.scope, self.views.items);
                    errdefer rebind.deinitOnError();
                    try pending.append(self.allocator, rebind);
                    if (rebind == .replace and rebind.replace.old_sink == null) {
                        extra_for_instr += 1;
                        extra_per_pipeline[p_idx] += 1;
                    }
                }
                try instr.ensureStorageCapacity(extra_for_instr);
            }
        }

        for (self.pipelines.items, 0..) |pipeline, p_idx| {
            try pipeline.sinks.ensureUnusedCapacity(pipeline.allocator, extra_per_pipeline[p_idx]);
        }

        // All allocations succeeded; commit swaps and metadata updates infallibly.
        for (pending.items) |item| {
            item.commit();
        }
    }

    /// Helper: Create a MetricReader configured with environment variable settings
    /// This convenience method uses OTEL_METRIC_* environment variables
    pub fn createReaderFromConfig(
        self: *Self,
        metric_exporter: *@import("../../sdk/metrics/exporter.zig").MetricExporter,
    ) !*MetricReader {
        const mc = self.config.?.metrics_config;
        const reader = try MetricReader.init(self.allocator, self.io, metric_exporter);

        // Apply export timeout from config
        reader.exportTimeout = mc.export_timeout_ms;

        return reader;
    }
};

/// Meter is a named instance that is used to record measurements.
/// See https://opentelemetry.io/docs/specs/otel/metrics/api/#meter
pub const Meter = struct {
    scope: InstrumentationScope,
    instruments: std.StringHashMapUnmanaged(*Instrument),
    allocator: std.mem.Allocator,
    io: std.Io,
    exemplar_filter: exemplar.ExemplarFilter = .trace_based,
    exemplar_sampler: exemplar.Sampler = .{},
    provider: ?*MeterProvider = null,
    cardinality_limit: usize = spec.default_cardinality_limit,

    mx: std.Io.Mutex = std.Io.Mutex.init,

    const Self = @This();

    fn bindSyncInstrument(self: *Self, i: *Instrument) !void {
        if (self.provider) |p| {
            p.mx.lockUncancelable(p.io);
            defer p.mx.unlock(p.io);

            errdefer {
                for (p.pipelines.items) |pipeline| {
                    pipeline.unbindInstrument(i);
                }
            }

            for (p.pipelines.items) |pipeline| {
                try pipeline.bindInstrument(i, &self.scope, p.views.items);
            }
            try self.registerInstrument(i);
        } else {
            try self.registerInstrument(i);
        }
    }

    /// Create a new Counter instrument using the specified type as the value type.
    /// This is a monotonic counter that can only be incremented.
    pub fn createCounter(self: *Self, comptime T: type, options: InstrumentOptions) !*Counter(T) {
        var i = try Instrument.new(.Counter, options, self.allocator);
        const c = i.counter(self.io, T) catch |err| {
            self.allocator.destroy(i);
            return err;
        };
        errdefer i.deinit();
        c.exemplar_filter = self.exemplar_filter;
        try self.bindSyncInstrument(i);

        return c;
    }

    /// Create a new UpDownCounter instrument using the specified type as the value type.
    /// This is a counter that can be incremented and decremented.
    pub fn createUpDownCounter(self: *Self, comptime T: type, options: InstrumentOptions) !*Counter(T) {
        var i = try Instrument.new(.UpDownCounter, options, self.allocator);
        const c = i.upDownCounter(self.io, T) catch |err| {
            self.allocator.destroy(i);
            return err;
        };
        errdefer i.deinit();
        c.exemplar_filter = self.exemplar_filter;
        try self.bindSyncInstrument(i);

        return c;
    }

    /// Create a new Histogram instrument using the specified type as the value type.
    /// A histogram is a metric that samples observations and counts them in different buckets.
    pub fn createHistogram(self: *Self, comptime T: type, options: InstrumentOptions) !*Histogram(T) {
        var i = try Instrument.new(.Histogram, options, self.allocator);
        const h = i.histogram(self.io, T) catch |err| {
            self.allocator.destroy(i);
            return err;
        };
        errdefer i.deinit();
        h.exemplar_filter = self.exemplar_filter;
        try self.bindSyncInstrument(i);

        return h;
    }

    /// Create a new Gauge instrument using the specified type as the value type.
    /// A gauge is a metric that represents a single numerical value that can arbitrarily go up and down,
    /// and represents a point-in-time value.
    pub fn createGauge(self: *Self, comptime T: type, options: InstrumentOptions) !*Gauge(T) {
        var i = try Instrument.new(.Gauge, options, self.allocator);
        const g = i.gauge(self.io, T) catch |err| {
            self.allocator.destroy(i);
            return err;
        };
        errdefer i.deinit();
        g.exemplar_filter = self.exemplar_filter;
        try self.bindSyncInstrument(i);

        return g;
    }

    /// Create an ObservableCounter instrument that can be used to observe values asynchronously.
    /// This instrument is used to report counters with absolute values.
    /// See https://opentelemetry.io/docs/specs/otel/metrics/api/#asynchronous-counter.
    pub fn createObservableCounter(
        self: *Self,
        options: InstrumentOptions,
        context: AsyncInstrument.ObservedContext,
        callbacks: ?[]AsyncInstrument.ObserveMeasures,
    ) !*AsyncInstrument.ObservableInstrument(.ObservableCounter) {
        var i = try Instrument.new(.ObservableCounter, options, self.allocator);
        const c = i.asyncCounter(self.io, context, callbacks) catch |err| {
            self.allocator.destroy(i);
            return err;
        };
        c.exemplar_filter = self.exemplar_filter;
        errdefer i.deinit();
        try self.registerInstrument(i);

        return c;
    }

    /// Create an ObservableUpDownCounter instrument that can be used to observe values asynchronously.
    /// This instrument is used to report counters with absolute values that can go up and down.
    /// See https://opentelemetry.io/docs/specs/otel/metrics/api/#asynchronous-updowncounter.
    pub fn createObservableUpDownCounter(
        self: *Self,
        options: InstrumentOptions,
        context: AsyncInstrument.ObservedContext,
        callbacks: ?[]AsyncInstrument.ObserveMeasures,
    ) !*AsyncInstrument.ObservableInstrument(.ObservableUpDownCounter) {
        var i = try Instrument.new(.ObservableUpDownCounter, options, self.allocator);
        const c = i.asyncUpDownCounter(self.io, context, callbacks) catch |err| {
            self.allocator.destroy(i);
            return err;
        };
        c.exemplar_filter = self.exemplar_filter;
        errdefer i.deinit();
        try self.registerInstrument(i);

        return c;
    }

    /// Create an ObservableGauge instrument that can be used to observe values asynchronously.
    /// See https://opentelemetry.io/docs/specs/otel/metrics/api/#asynchronous-gauge.
    pub fn createObservableGauge(
        self: *Self,
        options: InstrumentOptions,
        context: AsyncInstrument.ObservedContext,
        callbacks: ?[]AsyncInstrument.ObserveMeasures,
    ) !*AsyncInstrument.ObservableInstrument(.ObservableGauge) {
        var i = try Instrument.new(.ObservableGauge, options, self.allocator);
        const g = i.asyncGauge(self.io, context, callbacks) catch |err| {
            self.allocator.destroy(i);
            return err;
        };
        g.exemplar_filter = self.exemplar_filter;
        errdefer i.deinit();
        try self.registerInstrument(i);

        return g;
    }

    // Check that the instrument is not already registered with the same name identifier.
    // Name is case-insensitive.
    // The remaining are also forming the identifier.
    fn registerInstrument(self: *Self, instrument: *Instrument) !void {
        self.mx.lockUncancelable(self.io);
        defer self.mx.unlock(self.io);

        const id = try spec.instrumentIdentifier(
            self.allocator,
            instrument.opts.name,
            instrument.kind.toString(),
            instrument.opts.unit orelse "",
            instrument.opts.description orelse "",
        );

        if (self.instruments.contains(id)) {
            log.warn(
                "Instrument with identifying name {s} already exists in meter {s}",
                .{ id, self.scope.name },
            );
            self.allocator.free(id);
            return spec.ResourceError.InstrumentExistsWithSameNameAndIdentifyingFields;
        }
        errdefer self.allocator.free(id);
        return self.instruments.put(self.allocator, id, instrument);
    }

    fn deinit(self: *Self) void {
        self.exemplar_sampler.deinit(self.allocator);
        var instrs = self.instruments.iterator();
        while (instrs.next()) |i| {
            // Instrument.deinit() will free up the memory allocated for the instrument,
            i.value_ptr.*.deinit();
            // Also free up the memory allocated for the instrument keys.
            self.allocator.free(i.key_ptr.*);
        }
        // Cleanup Meters' Instruments values.
        self.instruments.deinit(self.allocator);
        // Cleanup the meter attributes.
        if (self.scope.attributes) |attrs| self.allocator.free(attrs);
    }
};

test "default meter provider can be fetched" {
    const io = std.testing.io;
    const mp = try MeterProvider.init(std.testing.allocator, io, null);
    defer mp.deinit();

    std.debug.assert(@intFromPtr(&mp) != 0);
}

test "custom meter provider can be created" {
    const io = std.testing.io;
    const mp = try MeterProvider.init(std.testing.allocator, io, null);
    defer mp.deinit();

    std.debug.assert(@intFromPtr(&mp) != 0);
}

test "meter provider with custom resource" {
    const user_resource = [_]Attribute{
        .{ .key = "service.name", .value = .{ .string = "my-service" } },
        .{ .key = "timecard.name", .value = .{ .string = "ocp2" } },
    };
    const mp = try MeterProvider.init(std.testing.allocator, std.testing.io, &user_resource);
    defer mp.deinit();

    // The provider owns a copy of the resource
    try std.testing.expect(mp.resource != null);
    try std.testing.expectEqual(@as(usize, 2), mp.resource.?.len);
    try std.testing.expect(mp.resource.?.ptr != &user_resource);
    try std.testing.expectEqualStrings("service.name", mp.resource.?[0].key);
    try std.testing.expectEqualStrings("my-service", mp.resource.?[0].value.string);
    try std.testing.expectEqualStrings("timecard.name", mp.resource.?[1].key);
    try std.testing.expectEqualStrings("ocp2", mp.resource.?[1].value.string);
}

test "meter provider without resource has none when there is no configuration" {
    const mp = try MeterProvider.init(std.testing.allocator, std.testing.io, null);
    defer mp.deinit();

    try std.testing.expectEqual(null, mp.resource);
}

test "meter provider resource takes precedence over the configuration" {
    var env_map = std.process.Environ.Map.init(std.testing.allocator);
    defer env_map.deinit();
    try env_map.put("OTEL_SERVICE_NAME", "env-service");
    try env_map.put("OTEL_RESOURCE_ATTRIBUTES", "env.only=from-env,shared=from-env");

    const cfg = try Configuration.init(std.testing.allocator, std.testing.io, &env_map);
    defer cfg.deinit();
    Configuration.set(cfg);

    const user_resource = [_]Attribute{
        .{ .key = "service.name", .value = .{ .string = "user-service" } },
        .{ .key = "shared", .value = .{ .string = "from-user" } },
        .{ .key = "user.only", .value = .{ .string = "from-user" } },
    };
    const mp = try MeterProvider.init(std.testing.allocator, std.testing.io, &user_resource);
    defer mp.deinit();

    const resource = mp.resource.?;
    var service_name: ?[]const u8 = null;
    var shared: ?[]const u8 = null;
    var user_only: ?[]const u8 = null;
    var env_only: ?[]const u8 = null;
    for (resource, 0..) |attr, i| {
        // Keys are unique
        for (resource[i + 1 ..]) |other| try std.testing.expect(!std.mem.eql(u8, attr.key, other.key));
        if (std.mem.eql(u8, attr.key, "service.name")) service_name = attr.value.string;
        if (std.mem.eql(u8, attr.key, "shared")) shared = attr.value.string;
        if (std.mem.eql(u8, attr.key, "user.only")) user_only = attr.value.string;
        if (std.mem.eql(u8, attr.key, "env.only")) env_only = attr.value.string;
    }
    try std.testing.expectEqualStrings("user-service", service_name.?);
    try std.testing.expectEqualStrings("from-user", shared.?);
    try std.testing.expectEqualStrings("from-user", user_only.?);
    try std.testing.expectEqualStrings("from-env", env_only.?);
}

test "meter provider has no resource when the SDK is disabled" {
    var env_map = std.process.Environ.Map.init(std.testing.allocator);
    defer env_map.deinit();
    try env_map.put("OTEL_SDK_DISABLED", "true");

    const cfg = try Configuration.init(std.testing.allocator, std.testing.io, &env_map);
    defer cfg.deinit();
    Configuration.set(cfg);

    const user_resource = [_]Attribute{.{ .key = "service.name", .value = .{ .string = "my-service" } }};
    const mp = try MeterProvider.init(std.testing.allocator, std.testing.io, &user_resource);
    defer mp.deinit();

    try std.testing.expectEqual(null, mp.resource);
}

fn initAndDeinitMeterProvider(allocator: std.mem.Allocator, io: std.Io, resource: []const Attribute) !void {
    const mp = try MeterProvider.init(allocator, io, resource);
    mp.deinit();
}

test "MeterProvider.init with a resource does not leak on allocation failure" {
    const user_resource = [_]Attribute{
        .{ .key = "service.name", .value = .{ .string = "my-service" } },
        .{ .key = "timecard.name", .value = .{ .string = "ocp2" } },
    };
    try std.testing.checkAllAllocationFailures(std.testing.allocator, initAndDeinitMeterProvider, .{ std.testing.io, @as([]const Attribute, &user_resource) });
}

test "meter provider with config from environment" {
    var env_map = std.process.Environ.Map.init(std.testing.allocator);
    defer env_map.deinit();

    const cfg = try Configuration.init(std.testing.allocator, std.testing.io, &env_map);
    defer cfg.deinit();
    Configuration.set(cfg);

    const io = std.testing.io;
    const mp = try MeterProvider.init(std.testing.allocator, io, null);
    defer mp.deinit();

    // Verify config was loaded with defaults
    try std.testing.expectEqual(@as(u64, 60000), mp.config.?.metrics_config.export_interval_ms);
    try std.testing.expectEqual(@as(u64, 30000), mp.config.?.metrics_config.export_timeout_ms);
    try std.testing.expectEqual(MetricsConfig.ExporterType.otlp, mp.config.?.metrics_config.exporter);
    try std.testing.expectEqual(MetricsConfig.ExemplarFilter.trace_based, mp.config.?.metrics_config.exemplar_filter);
}

test "meter can be created from custom provider" {
    const meter_name = "my-meter";
    const meter_version = "my-meter";
    const io = std.testing.io;
    const mp = try MeterProvider.init(std.testing.allocator, io, null);
    defer mp.deinit();

    const meter = try mp.getMeter(.{ .name = meter_name, .version = meter_version });

    std.debug.assert(std.mem.eql(u8, meter.scope.name, meter_name));
    std.debug.assert(std.mem.eql(u8, meter.scope.version.?, meter_version));
    std.debug.assert(meter.scope.schema_url == null);
    std.debug.assert(meter.scope.attributes == null);
}

test "meter can be created from default provider with schema url and attributes" {
    const meter_name = "my-meter";
    const meter_version = "my-meter";

    const io = std.testing.io;
    const mp = try MeterProvider.init(std.testing.allocator, io, null);
    defer mp.deinit();

    const val: []const u8 = "value";
    const attributes = try Attributes.from(mp.allocator, .{ "key", val });

    const meter = try mp.getMeter(.{ .name = meter_name, .version = meter_version, .schema_url = "http://foo.bar", .attributes = attributes });
    try std.testing.expectEqual(meter.scope.name, meter_name);
    try std.testing.expectEqualStrings(meter.scope.version.?, meter_version);
    try std.testing.expectEqualStrings(meter.scope.schema_url.?, "http://foo.bar");
    std.debug.assert(std.mem.eql(u8, std.mem.sliceAsBytes(meter.scope.attributes.?), std.mem.sliceAsBytes(attributes.?)));
}

test "meter register instrument twice with same name fails" {
    const io = std.testing.io;
    const mp = try MeterProvider.init(std.testing.allocator, io, null);
    defer mp.deinit();

    const meter = try mp.getMeter(.{ .name = "my-meter" });

    const counterName = "beautiful-counter";
    _ = try meter.createCounter(u16, .{ .name = counterName });
    const r = meter.createCounter(u16, .{ .name = counterName });

    try std.testing.expectError(spec.ResourceError.InstrumentExistsWithSameNameAndIdentifyingFields, r);
}

test "meter register instrument" {
    const io = std.testing.io;
    const mp = try MeterProvider.init(std.testing.allocator, io, null);
    defer mp.deinit();

    const meter = try mp.getMeter(.{ .name = "my-meter" });

    const counter = try meter.createCounter(u16, .{ .name = "my-counter" });
    _ = try meter.createHistogram(u16, .{ .name = "my-histogram" });

    try std.testing.expectEqual(2, meter.instruments.count());

    const id: []const u8 = try spec.instrumentIdentifier(
        std.testing.allocator,
        "my-counter",
        Kind.Counter.toString(),
        "",
        "",
    );
    defer std.testing.allocator.free(id);

    if (meter.instruments.get(id)) |inst| {
        try std.testing.expectEqual(counter, inst.data.Counter_u16);
    } else {
        unreachable;
    }
}

test "meter provider adds metric reader" {
    const io = std.testing.io;
    const mp = try MeterProvider.init(std.testing.allocator, io, null);
    defer mp.deinit();
    var noop = exporter.ExporterImpl{ .exportFn = exporter.noopExporter };
    const metric_exporter = try MetricExporter.new(std.testing.allocator, io, &noop);
    const mr = try MetricReader.init(std.testing.allocator, io, metric_exporter);
    defer mr.deinit();
    try mp.addReader(mr);

    std.debug.assert(mp.readers.items.len == 1);
}

test "meter provider adds multiple metric readers" {
    const io = std.testing.io;
    const mp = try MeterProvider.init(std.testing.allocator, io, null);
    defer mp.deinit();
    var noop1 = exporter.ExporterImpl{ .exportFn = exporter.noopExporter };
    const metric_exporter1 = try MetricExporter.new(std.testing.allocator, io, &noop1);
    const mr1 = try MetricReader.init(std.testing.allocator, io, metric_exporter1);
    defer mr1.deinit();
    var noop2 = exporter.ExporterImpl{ .exportFn = exporter.noopExporter };
    const metric_exporter2 = try MetricExporter.new(std.testing.allocator, io, &noop2);
    const mr2 = try MetricReader.init(std.testing.allocator, io, metric_exporter2);
    defer mr2.deinit();
    try mp.addReader(mr1);
    try mp.addReader(mr2);

    std.debug.assert(mp.readers.items.len == 2);
}

test "metric reader cannot be registered with multiple providers" {
    const io = std.testing.io;
    const mp1 = try MeterProvider.init(std.testing.allocator, io, null);
    defer mp1.deinit();

    const mp2 = try MeterProvider.init(std.testing.allocator, io, null);
    defer mp2.deinit();

    var noop = exporter.ExporterImpl{ .exportFn = exporter.noopExporter };
    const metric_exporter = try MetricExporter.new(std.testing.allocator, io, &noop);
    const mr = try MetricReader.init(std.testing.allocator, io, metric_exporter);
    defer mr.deinit();

    try mp1.addReader(mr);
    const err = mp2.addReader(mr);
    try std.testing.expectError(spec.ResourceError.MetricReaderAlreadyAttached, err);
}

test "metric reader cannot be registered twice on same meter provider" {
    const io = std.testing.io;
    const mp1 = try MeterProvider.init(std.testing.allocator, io, null);
    defer mp1.deinit();

    var noop = exporter.ExporterImpl{ .exportFn = exporter.noopExporter };
    const metric_exporter = try MetricExporter.new(std.testing.allocator, io, &noop);
    const mr = try MetricReader.init(std.testing.allocator, io, metric_exporter);
    defer mr.deinit();

    try mp1.addReader(mr);
    const err = mp1.addReader(mr);
    try std.testing.expectError(spec.ResourceError.MetricReaderAlreadyAttached, err);
}

test "meter provider shutdown shuts down registered readers and flushes metrics" {
    const allocator = std.testing.allocator;
    const io = std.testing.io;

    var inMem = try InMemoryExporter.init(allocator, io);
    defer inMem.deinit();

    var mp = try MeterProvider.init(allocator, io, null);
    defer mp.deinit();

    const metric_exporter = try MetricExporter.new(allocator, io, &inMem.exporter);
    const reader = try MetricReader.init(allocator, io, metric_exporter);
    defer reader.deinit();
    try mp.addReader(reader);

    const meter = try mp.getMeter(.{ .name = "shutdown-flush-test" });
    var counter = try meter.createCounter(u64, .{ .name = "requests" });
    try counter.add(42, .{});

    // Calling shutdown on the provider must shut down the reader and export pending metrics
    try mp.shutdown();

    // Verify metrics were collected and exported during provider shutdown
    const exported = try inMem.fetch(allocator);
    defer {
        for (exported) |*d| {
            d.deinit(allocator);
        }
        allocator.free(exported);
    }

    try std.testing.expectEqual(@as(usize, 1), exported.len);
}

test "meter provider shutdown shuts down every reader and returns the first error" {
    const allocator = std.testing.allocator;
    const io = std.testing.io;

    var mp = try MeterProvider.init(allocator, io, null);
    defer mp.deinit();

    // Registered first, so the provider must keep going after its failure.
    var failing = exporter.ExporterImpl{ .exportFn = exporter.failingExporter };
    const failing_exporter = try MetricExporter.new(allocator, io, &failing);
    const failing_reader = try MetricReader.init(allocator, io, failing_exporter);
    defer failing_reader.deinit();
    try mp.addReader(failing_reader);

    var noop = exporter.ExporterImpl{ .exportFn = exporter.noopExporter };
    const noop_exporter = try MetricExporter.new(allocator, io, &noop);
    const reader = try MetricReader.init(allocator, io, noop_exporter);
    defer reader.deinit();
    try mp.addReader(reader);

    try std.testing.expectError(error.ExportFailed, mp.shutdown());

    // The reader after the failing one was shut down too.
    try std.testing.expect(@atomicLoad(bool, &reader.hasShutDown, .acquire));
    try std.testing.expect(reader.meterProvider == null);
}

test "meter provider shutdown is idempotent" {
    const allocator = std.testing.allocator;
    const io = std.testing.io;

    var mp = try MeterProvider.init(allocator, io, null);
    defer mp.deinit();

    try mp.shutdown();
    try mp.shutdown();
}

test "meter provider forceFlush flushes all registered readers" {
    const allocator = std.testing.allocator;
    const io = std.testing.io;

    var inMem = try InMemoryExporter.init(allocator, io);
    defer inMem.deinit();

    var mp = try MeterProvider.init(allocator, io, null);
    defer mp.deinit();

    const metric_exporter = try MetricExporter.new(allocator, io, &inMem.exporter);
    const reader = try MetricReader.init(allocator, io, metric_exporter);
    defer reader.deinit();
    try mp.addReader(reader);

    const meter = try mp.getMeter(.{ .name = "forceflush-test" });
    var counter = try meter.createCounter(u64, .{ .name = "requests" });
    try counter.add(100, .{});

    // Force flush
    try mp.forceFlush();

    const exported = try inMem.fetch(allocator);
    defer {
        for (exported) |*d| {
            d.deinit(allocator);
        }
        allocator.free(exported);
    }

    try std.testing.expectEqual(@as(usize, 1), exported.len);
}

test "meter provider end to end" {
    const io = std.testing.io;
    const mp = try MeterProvider.init(std.testing.allocator, io, null);
    defer mp.deinit();

    const meter = try mp.getMeter(.{ .name = "service.company.com" });

    var counter = try meter.createCounter(u32, .{
        .name = "loc",
        .description = "lines of code written",
    });
    const meVal: []const u8 = "person@company.com";

    try counter.add(1000000, .{ "author", meVal });
    try counter.add(10, .{ "author", meVal });

    var hist = try meter.createHistogram(u16, .{ .name = "my-histogram" });
    const v: []const u8 = "success";

    try hist.record(1234, .{});
    try hist.record(4567, .{ "amazing", v });

    std.debug.assert(meter.instruments.count() == 2);
}

test "meter provider with arena allocator" {
    var buffer: [10 << 20]u8 = undefined;
    var fb = std.heap.FixedBufferAllocator.init(&buffer);
    defer fb.reset();
    var arena = std.heap.ArenaAllocator.init(fb.allocator());
    defer arena.deinit();

    const io = std.testing.io;
    const mp = try MeterProvider.init(arena.allocator(), io, null);
    defer mp.deinit();

    const meter = try mp.getMeter(.{ .name = "service.company.com" });

    var counter = try meter.createCounter(u32, .{
        .name = "loc",
        .description = "lines of code written",
    });
    const meVal: []const u8 = "test";

    try counter.add(1, .{ "author", meVal });
}

const view = @import("../../sdk/metrics/view.zig");

/// AggregatedMetrics is a collection of metrics that have been aggregated using the
/// MeterProvider's view configured by users or falling back to the
/// MetricReader's temporality and aggregation functions.
pub const AggregatedMetrics = struct {
    fn sum(comptime T: type, data_points: []DataPoint(T), collection_timestamps: Timestamps, allocator: std.mem.Allocator) ![]DataPoint(T) {
        var deduped = std.ArrayHashMapUnmanaged(
            Attributes,
            DataPoint(T),
            Attributes.ArrayHashContext,
            true,
        ).empty;
        // No need to cleanup the keys, they are reference to the same Attribute slices from data_points.
        defer deduped.deinit(allocator);
        errdefer for (deduped.values()) |*point| point.deinit(allocator);

        for (data_points) |dp| {
            const key = Attributes.with(dp.attributes);
            const gop = try deduped.getOrPut(allocator, key);
            if (!gop.found_existing) {
                gop.value_ptr.* = dp.deepCopy(allocator) catch |err| {
                    _ = deduped.swapRemove(key);
                    return err;
                };
            } else gop.value_ptr.value += dp.value;
            // Add timestamps that will be used in temporal aggregation.
            gop.value_ptr.*.timestamps = collection_timestamps;
        }
        return allocator.dupe(DataPoint(T), deduped.values());
    }

    fn lastValue(comptime T: type, data_points: []DataPoint(T), collection_timestamps: Timestamps, allocator: std.mem.Allocator) ![]DataPoint(T) {
        var deduped = std.ArrayHashMapUnmanaged(
            Attributes,
            DataPoint(T),
            Attributes.ArrayHashContext,
            true,
        ).empty;
        defer deduped.deinit(allocator);
        errdefer for (deduped.values()) |*point| point.deinit(allocator);

        for (data_points) |dp| {
            var duped = try dp.deepCopy(allocator);
            errdefer duped.deinit(allocator);
            // Add timestamps that will be used in temporal aggregation.
            duped.timestamps = collection_timestamps;

            const gop = try deduped.getOrPut(allocator, Attributes.with(dp.attributes));
            if (gop.found_existing) gop.value_ptr.deinit(allocator);
            gop.value_ptr.* = duped;
        }
        return allocator.dupe(DataPoint(T), deduped.values());
    }

    pub fn mergeHistogram(data_points: []DataPoint(HistogramDataPoint), collection_timestamps: Timestamps, record_sum: bool, allocator: std.mem.Allocator) ![]DataPoint(HistogramDataPoint) {
        var deduped = std.ArrayHashMapUnmanaged(
            Attributes,
            DataPoint(HistogramDataPoint),
            Attributes.ArrayHashContext,
            true,
        ).empty;
        defer deduped.deinit(allocator);
        errdefer for (deduped.values()) |*point| point.deinit(allocator);

        for (data_points) |dp| {
            const key = Attributes.with(dp.attributes);
            const gop = try deduped.getOrPut(allocator, key);
            if (!gop.found_existing) {
                gop.value_ptr.* = dp.deepCopy(allocator) catch |err| {
                    _ = deduped.swapRemove(key);
                    return err;
                };
                if (!record_sum) gop.value_ptr.value.sum = null;
            } else {
                const existing = &gop.value_ptr.value;
                existing.count += dp.value.count;
                if (record_sum) {
                    if (dp.value.sum) |s| {
                        existing.sum = if (existing.sum) |curr| curr + s else s;
                    }
                } else {
                    existing.sum = null;
                }
                if (dp.value.min) |m| {
                    existing.min = if (existing.min) |curr| @min(curr, m) else m;
                }
                if (dp.value.max) |m| {
                    existing.max = if (existing.max) |curr| @max(curr, m) else m;
                }
                for (existing.bucket_counts, dp.value.bucket_counts) |*b, add_b| {
                    b.* += add_b;
                }
                if (dp.exemplar_candidate) |sample| {
                    if (gop.value_ptr.exemplar_candidate) |*prev| prev.deinit(allocator);
                    gop.value_ptr.exemplar_candidate = try sample.deepCopy(allocator);
                }
            }
            gop.value_ptr.timestamps = collection_timestamps;
        }
        return allocator.dupe(DataPoint(HistogramDataPoint), deduped.values());
    }

    fn mergeExponentialHistogram(data_points: []DataPoint(ExponentialHistogramDataPoint), collection_timestamps: Timestamps, record_sum: bool, allocator: std.mem.Allocator) ![]DataPoint(ExponentialHistogramDataPoint) {
        var deduped = std.ArrayHashMapUnmanaged(
            Attributes,
            DataPoint(ExponentialHistogramDataPoint),
            Attributes.ArrayHashContext,
            true,
        ).empty;
        defer deduped.deinit(allocator);
        errdefer for (deduped.values()) |*point| point.deinit(allocator);

        for (data_points) |dp| {
            const key = Attributes.with(dp.attributes);
            const gop = try deduped.getOrPut(allocator, key);
            if (!gop.found_existing) {
                gop.value_ptr.* = dp.deepCopy(allocator) catch |err| {
                    _ = deduped.swapRemove(key);
                    return err;
                };
                if (!record_sum) gop.value_ptr.value.sum = null;
            } else {
                try metrics_temporality.mergeExponentialDataPointValues(allocator, &gop.value_ptr.value, dp.value, record_sum);
                if (dp.exemplar_candidate) |sample| {
                    if (gop.value_ptr.exemplar_candidate) |*prev| prev.deinit(allocator);
                    gop.value_ptr.exemplar_candidate = try sample.deepCopy(allocator);
                }
            }
            gop.value_ptr.timestamps = collection_timestamps;
        }
        return allocator.dupe(DataPoint(ExponentialHistogramDataPoint), deduped.values());
    }

    pub const ExemplarContext = struct {
        sampler: *exemplar.Sampler,
        io: std.Io,
        instrument_id: usize,
        factory: ?exemplar.ReservoirFactory,
    };

    pub fn aggregate(allocator: std.mem.Allocator, data_points: MeasurementsData, aggregation_type: view.Aggregation, record_sum: bool, exemplar_context: ?ExemplarContext) !?MeasurementsData {
        // If there are no data points, we can return early.
        if (data_points.isEmpty()) return null;

        // After aggreating, the original data needs to go away.
        // The returned aggregated data copy the values and attributes from the originals.
        defer {
            switch (data_points) {
                inline else => |list| {
                    for (list) |*dp| {
                        dp.deinit(allocator);
                    }
                    allocator.free(list);
                },
            }
        }

        const collection_timestamps = switch (data_points) {
            inline else => |points| points[0].timestamps orelse return error.MissingCollectionTimestamp,
        };

        // Processing pipeline is split by aggregation type
        const aggregated: ?MeasurementsData = switch (aggregation_type.getType()) {
            .Drop => null,
            .Sum => switch (data_points) {
                .int => MeasurementsData{ .int = try sum(i64, data_points.int, collection_timestamps, allocator) },
                .double => MeasurementsData{ .double = try sum(f64, data_points.double, collection_timestamps, allocator) },
                // Sum aggregation is not supported for histograms data points.
                // FIXME we should probably return an error here.
                // Specification does not seem to be clear...
                .histogram, .exponential_histogram => null,
            },
            .LastValue => switch (data_points) {
                .int => MeasurementsData{ .int = try lastValue(i64, data_points.int, collection_timestamps, allocator) },
                .double => MeasurementsData{ .double = try lastValue(f64, data_points.double, collection_timestamps, allocator) },
                // LastValue aggregation is not supported for histograms data points.
                // FIXME we should probably return an error here.
                // Specification does not seem to be clear...
                .histogram, .exponential_histogram => null,
            },
            .ExplicitBucketHistogram => switch (data_points) {
                .exponential_histogram => null,
                .int => blk: {
                    const config = aggregation_type.ExplicitBucketHistogram;
                    const buckets = config.buckets;
                    const aggregated = try aggregation.aggregateExplicitBucketHistogram(i64, allocator, data_points.int, buckets, config.record_min_max, record_sum);
                    for (aggregated) |*dp| {
                        dp.timestamps = collection_timestamps;
                    }
                    break :blk MeasurementsData{ .histogram = aggregated };
                },
                .double => blk: {
                    const config = aggregation_type.ExplicitBucketHistogram;
                    const buckets = config.buckets;
                    const aggregated = try aggregation.aggregateExplicitBucketHistogram(f64, allocator, data_points.double, buckets, config.record_min_max, record_sum);
                    for (aggregated) |*dp| {
                        dp.timestamps = collection_timestamps;
                    }
                    break :blk MeasurementsData{ .histogram = aggregated };
                },
                .histogram => MeasurementsData{ .histogram = try mergeHistogram(data_points.histogram, collection_timestamps, record_sum, allocator) },
            },
            .ExponentialBucketHistogram => switch (data_points) {
                .histogram => null,
                .int => blk: {
                    const config = aggregation_type.ExponentialBucketHistogram;
                    const aggregated = try aggregation.aggregateExponentialBucketHistogram(i64, allocator, data_points.int, config.max_scale, config.max_size, config.record_min_max, record_sum);
                    for (aggregated) |*dp| {
                        dp.timestamps = collection_timestamps;
                    }
                    break :blk MeasurementsData{ .exponential_histogram = aggregated };
                },
                .double => blk: {
                    const config = aggregation_type.ExponentialBucketHistogram;
                    const aggregated = try aggregation.aggregateExponentialBucketHistogram(f64, allocator, data_points.double, config.max_scale, config.max_size, config.record_min_max, record_sum);
                    for (aggregated) |*dp| {
                        dp.timestamps = collection_timestamps;
                    }
                    break :blk MeasurementsData{ .exponential_histogram = aggregated };
                },
                .exponential_histogram => MeasurementsData{ .exponential_histogram = try mergeExponentialHistogram(data_points.exponential_histogram, collection_timestamps, record_sum, allocator) },
            },
        };
        const result = aggregated orelse return null;
        errdefer {
            var failed = result;
            failed.deinit(allocator);
        }
        // Buffered ownership survives changes to the filters before collection.
        switch (data_points) {
            inline .int, .double, .histogram, .exponential_histogram => |raw| {
                var captured = false;
                for (raw) |point| if (point.attributes_owned or point.exemplar_candidate != null) {
                    captured = true;
                    break;
                };
                if (captured) switch (result) {
                    inline else => |points| for (points) |*point| {
                        try point.ownAttributes(allocator);
                        if (point.exemplar_candidate) |*sample| sample.deinit(allocator);
                        point.exemplar_candidate = null;
                    },
                };
            },
        }
        if (exemplar_context) |ctx| {
            const options: exemplar.ReservoirOptions = switch (aggregation_type) {
                .ExplicitBucketHistogram => |config| if (config.buckets.len > 0) .{ .aligned = config.buckets } else .{ .fixed_size = 1 },
                .ExponentialBucketHistogram => |config| .{ .fixed_size = @min(@as(usize, 20), config.max_size) },
                else => .{ .fixed_size = 1 },
            };
            const stream = exemplar.StreamIdentity{
                .instrument_id = ctx.instrument_id,
                .aggregation = switch (aggregation_type) {
                    .LastValue => .last_value,
                    .ExplicitBucketHistogram => .explicit_histogram,
                    .ExponentialBucketHistogram => .exponential_histogram,
                    else => .sum,
                },
                .max_scale = if (aggregation_type == .ExponentialBucketHistogram) aggregation_type.ExponentialBucketHistogram.max_scale else 0,
                .max_size = if (aggregation_type == .ExponentialBucketHistogram) aggregation_type.ExponentialBucketHistogram.max_size else 0,
                .record_min_max = switch (aggregation_type) {
                    .ExplicitBucketHistogram => |config| config.record_min_max,
                    .ExponentialBucketHistogram => |config| config.record_min_max,
                    else => false,
                },
            };
            switch (data_points) {
                inline .int, .double, .histogram, .exponential_histogram => |raw| switch (result) {
                    inline else => |points| try ctx.sampler.attach(allocator, ctx.io, stream, options, ctx.factory, raw, points),
                },
            }
        }
        return result;
    }

    pub fn filterAttributes(allocator: std.mem.Allocator, points: MeasurementsData, filter: view.AttributeFilter) !void {
        switch (points) {
            inline else => |list| for (list) |*point| {
                const filtered = try filter.apply(allocator, Attributes.with(point.attributes));
                const attrs = if (filtered) |attributes| attributes.attributes else null;
                errdefer if (attrs) |attributes| allocator.free(attributes);
                const owned = if (point.attributes_owned and attrs != null)
                    try exemplar.Exemplar.copyAttributes(allocator, attrs.?)
                else
                    attrs;
                if (point.attributes) |original| {
                    if (point.attributes_owned) for (original) |attr| {
                        allocator.free(attr.key);
                        if (attr.value == .string) allocator.free(attr.value.string);
                    };
                    allocator.free(original);
                }
                if (point.attributes_owned) if (attrs) |attributes| allocator.free(attributes);
                point.attributes = owned;
            },
        }
    }

    /// Fetch the aggreagted metrics from the meter.
    /// Each instrument is an entry of the slice.
    /// Caller owns the returned memory and it should be freed using the AggregatedMetrics allocator.
    /// Matching views take precedence; default_aggregation applies to instruments no view matches,
    /// falling back to the instrument kind default when null.
    pub fn fetch(allocator: std.mem.Allocator, meter: *Meter, views: []const view.View, agg_selector: ?view.AggregationSelector) ![]Measurements {
        meter.mx.lockUncancelable(meter.io);
        defer meter.mx.unlock(meter.io);

        if (meter.exemplar_filter != .always_off) meter.exemplar_sampler.beginCollection();
        defer if (meter.exemplar_filter != .always_off) meter.exemplar_sampler.endCollection();

        var results = std.ArrayList(Measurements).empty;

        errdefer {
            for (results.items) |*r| {
                r.deinit(allocator);
            }
            results.deinit(allocator);
        }

        var iter = meter.instruments.valueIterator();
        while (iter.next()) |instr| {
            var config = view.CombinedViewConfig.init(instr.*.kind);
            for (views) |*v| if (v.matches(instr.*, &meter.scope)) config.applyView(v);
            const aggregation_type = config.combinedAggregation(agg_selector orelse view.DefaultAggregation);

            try aggregation_type.validate();

            // Get the data points from the instrument and reset their state,
            const data_points: MeasurementsData = try instr.*.getInstrumentsData(allocator);
            var consumed = false;
            errdefer if (!consumed) {
                var failed = data_points;
                failed.deinit(allocator);
            };
            if (config.attribute_filter) |filter| try filterAttributes(allocator, data_points, filter);

            // Histogram sum is not collected for instruments that can record negative values.
            // See https://opentelemetry.io/docs/specs/otel/metrics/sdk/#explicit-bucket-histogram-aggregation
            consumed = true;
            const aggregated_data = try aggregate(allocator, data_points, aggregation_type, instr.*.kind.isMonotonic(), if (meter.exemplar_filter != .always_off) .{ .sampler = &meter.exemplar_sampler, .io = meter.io, .instrument_id = @intFromPtr(instr.*), .factory = config.exemplar_reservoir } else null);
            // then fill the result with the aggregated data points
            // only if there are data points.
            if (aggregated_data) |agg| {
                var measurement = Measurements{
                    .scope = .{
                        .name = meter.scope.name,
                        .version = meter.scope.version,
                        .schema_url = meter.scope.schema_url,
                        .attributes = meter.scope.attributes,
                    },
                    .instrumentKind = instr.*.kind,
                    .instrumentOptions = instr.*.opts,
                    .data = agg,
                    .aggregation = aggregation_type.getType(),
                };
                errdefer measurement.deinit(allocator);
                try results.append(allocator, measurement);
            }
        }
        return try results.toOwnedSlice(allocator);
    }
};

const MeterTestHarness = struct {
    allocator: std.mem.Allocator,
    mp: *MeterProvider,
    reader: *MetricReader,
    in_mem: *InMemoryExporter,

    fn init(allocator: std.mem.Allocator, io: std.Io, temporality_sel: ?view.TemporalitySelector, agg_sel: ?view.AggregationSelector) !MeterTestHarness {
        const mp = try MeterProvider.init(allocator, io, null);
        errdefer mp.deinit();
        const me = try MetricExporter.InMemory(allocator, io, temporality_sel, agg_sel);
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

    fn deinit(self: *MeterTestHarness) void {
        self.reader.deinit();
        self.in_mem.deinit();
        self.mp.deinit();
    }

    fn collect(self: *MeterTestHarness) ![]Measurements {
        try self.reader.collect();
        return try self.in_mem.fetch(self.allocator);
    }

    fn freeCollected(self: *MeterTestHarness, data: []Measurements) void {
        for (data) |*m| m.deinit(self.allocator);
        self.allocator.free(data);
    }
};

test "aggregated metrics deduplicated from meter without attributes" {
    const io = std.testing.io;
    var h = try MeterTestHarness.init(std.testing.allocator, io, null, null);
    defer h.deinit();
    const meter = try h.mp.getMeter(.{ .name = "test", .schema_url = "http://example.com" });
    var counter = try meter.createCounter(u64, .{ .name = "test-counter" });
    try counter.add(1, .{});
    try counter.add(3, .{});

    const data = try h.collect();
    defer h.freeCollected(data);

    try std.testing.expectEqual(@as(usize, 1), data.len);
    try std.testing.expectEqual(@as(i64, 4), data[0].data.int[0].value);
}

test "aggregated metrics deduplicated from meter with attributes" {
    const io = std.testing.io;
    var h = try MeterTestHarness.init(std.testing.allocator, io, null, null);
    defer h.deinit();

    const meterVal: []const u8 = "meter_val";
    const meter = try h.mp.getMeter(.{
        .name = "test",
        .schema_url = "http://example.com",
        .attributes = try Attributes.from(std.testing.allocator, .{ "meter_attr", meterVal }),
    });
    var counter = try meter.createCounter(u64, .{ .name = "test-counter" });
    const val: []const u8 = "test";
    try counter.add(1, .{ "key", val });
    try counter.add(3, .{ "key", val });

    const data = try h.collect();
    defer h.freeCollected(data);

    try std.testing.expectEqual(@as(usize, 1), data.len);
    try std.testing.expectEqual(@as(usize, 1), data[0].data.int.len);
    try std.testing.expectEqual(@as(i64, 4), data[0].data.int[0].value);
    try std.testing.expectEqualStrings("test", data[0].data.int[0].attributes.?[0].value.string);
}

test "aggregated metrics fetch to owned slice" {
    const io = std.testing.io;
    var h = try MeterTestHarness.init(std.testing.allocator, io, null, null);
    defer h.deinit();

    const meter = try h.mp.getMeter(.{ .name = "test", .schema_url = "http://example.com" });
    var counter = try meter.createCounter(u64, .{ .name = "test-counter" });
    try counter.add(1, .{});
    try counter.add(3, .{});

    const result = try h.collect();
    defer h.freeCollected(result);

    try std.testing.expectEqual(1, result.len);
    try std.testing.expectEqualStrings(meter.scope.name, result[0].scope.name);
    try std.testing.expectEqualStrings(meter.scope.schema_url.?, result[0].scope.schema_url.?);
    try std.testing.expectEqualStrings("test-counter", result[0].instrumentOptions.name);
    try std.testing.expectEqual(4, result[0].data.int[0].value);
}

test "fetch validates exponential histogram max_size" {
    const io = std.testing.io;
    const mp = try MeterProvider.init(std.testing.allocator, io, null);
    defer mp.deinit();

    const meter = try mp.getMeter(.{ .name = "test" });
    var histogram = try meter.createHistogram(f64, .{ .name = "test_histogram" });
    try histogram.record(1.0, .{});

    inline for (0..3) |max_size| {
        const aggregation_selector = struct {
            fn selectAggregation(_: Kind) view.Aggregation {
                return .{ .ExponentialBucketHistogram = .{
                    .max_scale = 10,
                    .max_size = max_size,
                    .record_min_max = false,
                } };
            }
        }.selectAggregation;

        const me = try MetricExporter.InMemory(std.testing.allocator, io, null, aggregation_selector);
        defer me.in_memory.deinit();
        const reader = try MetricReader.init(std.testing.allocator, io, me.exporter);
        defer reader.deinit();

        const res = mp.addReader(reader);
        if (max_size != 2) {
            try std.testing.expectError(error.InvalidMaxSize, res);
            continue;
        }
        try res;
        try histogram.record(1.0, .{});
        try histogram.record(2.0, .{});
        try reader.collect();
        const arr = try me.in_memory.fetch(std.testing.allocator);
        defer {
            for (arr) |*m| m.deinit(std.testing.allocator);
            std.testing.allocator.free(arr);
        }
        try std.testing.expectEqual(1, arr.len);
        try std.testing.expectEqual(1, arr[0].data.exponential_histogram.len);
        try std.testing.expectEqual(2, arr[0].data.exponential_histogram[0].value.count);
        try std.testing.expectEqual(3, arr[0].data.exponential_histogram[0].value.sum);
        mp.detachReader(reader);
    }
}

test "fetch records histogram sum only for instruments without negative values" {
    const io = std.testing.io;
    var h = try MeterTestHarness.init(std.testing.allocator, io, null, null);
    defer h.deinit();

    try h.mp.addView(.{
        .instrument_selector = .{ .name = "test-updown" },
        .aggregation = .{ .ExplicitBucketHistogram = .{} },
        .temporality = .Cumulative,
    });

    const meter = try h.mp.getMeter(.{ .name = "test" });
    var histogram = try meter.createHistogram(i64, .{ .name = "test-histogram" });
    try histogram.record(4, .{});
    try histogram.record(6, .{});
    var updown = try meter.createUpDownCounter(i64, .{ .name = "test-updown" });
    try updown.add(4, .{});
    try updown.add(-6, .{});

    const result = try h.collect();
    defer h.freeCollected(result);

    try std.testing.expectEqual(2, result.len);
    for (result) |m| {
        const dp = m.data.histogram[0].value;
        try std.testing.expectEqual(2, dp.count);
        switch (m.instrumentKind) {
            .Histogram => try std.testing.expectEqual(10, dp.sum),
            .UpDownCounter => try std.testing.expectEqual(null, dp.sum),
            else => return error.UnexpectedInstrument,
        }
    }
}

test "fetch frees accumulated results on validation failure" {
    const io = std.testing.io;
    const mp = try MeterProvider.init(std.testing.allocator, io, null);
    defer mp.deinit();

    const invalid_view = view.View{
        .instrument_selector = .{ .name = "test-counter" },
        .aggregation = .{ .ExponentialBucketHistogram = .{
            .max_scale = 10,
            .max_size = 1,
            .record_min_max = false,
        } },
        .temporality = .Cumulative,
    };

    try std.testing.expectError(error.InvalidMaxSize, mp.addView(invalid_view));
}

test "aggregated metrics do not duplicate data points" {
    const io = std.testing.io;
    var h = try MeterTestHarness.init(std.testing.allocator, io, view.TemporalityDelta, null);
    defer h.deinit();

    const meter = try h.mp.getMeter(.{ .name = "test", .schema_url = "http://example.com" });
    var counter = try meter.createCounter(u64, .{ .name = "test-counter" });
    try counter.add(1, .{});
    try counter.add(3, .{});

    const result = try h.collect();
    defer h.freeCollected(result);

    try std.testing.expectEqual(1, result.len);
    try std.testing.expectEqual(1, result[0].data.int.len);

    const result_second = try h.collect();
    defer h.freeCollected(result_second);

    try std.testing.expectEqual(0, result_second.len);
}

test "aggregated metrics have timestamps" {
    const io = std.testing.io;
    var h = try MeterTestHarness.init(std.testing.allocator, io, null, null);
    defer h.deinit();

    const meter = try h.mp.getMeter(.{ .name = "test", .schema_url = "http://example.com" });
    var counter = try meter.createCounter(u64, .{ .name = "test-counter" });
    try counter.add(1, .{});
    try counter.add(3, .{});

    const result = try h.collect();
    defer h.freeCollected(result);

    try std.testing.expectEqual(1, result.len);
    try std.testing.expectEqual(4, result[0].data.int[0].value);
    try std.testing.expect(result[0].data.int[0].timestamps.?.start_time_ns.? > 0);
    try std.testing.expect(result[0].data.int[0].timestamps.?.time_ns > 0);
}

test "aggregated metrics with custom views" {
    const io = std.testing.io;
    var h = try MeterTestHarness.init(std.testing.allocator, io, null, null);
    defer h.deinit();

    const meter = try h.mp.getMeter(.{ .name = "test", .schema_url = "http://example.com" });
    var counter = try meter.createCounter(u64, .{ .name = "test_counter" });
    try counter.add(1, .{});

    const result_no_views = try h.collect();
    defer h.freeCollected(result_no_views);
    try std.testing.expectEqual(1, result_no_views.len);
    try std.testing.expectEqual(1, result_no_views[0].data.int[0].value);

    // Create a view that drops this specific metric
    try h.mp.addView(view.View{
        .instrument_selector = view.InstrumentSelector{
            .name = "test_counter",
        },
        .aggregation = .Drop,
        .temporality = .Cumulative,
    });

    try counter.add(1, .{});
    const result_with_views = try h.collect();
    defer h.freeCollected(result_with_views);
    try std.testing.expectEqual(0, result_with_views.len);
}

test "meter provider validates exponential histogram view max_size" {
    const io = std.testing.io;
    const mp = try MeterProvider.init(std.testing.allocator, io, null);
    defer mp.deinit();

    const view_max_size_0 = view.View{
        .instrument_selector = .{ .kind = .Histogram },
        .aggregation = .{ .ExponentialBucketHistogram = .{
            .max_scale = 10,
            .max_size = 0,
            .record_min_max = false,
        } },
        .temporality = .Cumulative,
    };

    const registration_result_0 = mp.addView(view_max_size_0);
    try std.testing.expectEqual(error.InvalidMaxSize, registration_result_0);

    const view_max_size_1 = view.View{
        .instrument_selector = .{ .kind = .Histogram },
        .aggregation = .{ .ExponentialBucketHistogram = .{
            .max_scale = 10,
            .max_size = 1,
            .record_min_max = false,
        } },
        .temporality = .Cumulative,
    };
    const registration_result_1 = mp.addView(view_max_size_1);
    try std.testing.expectEqual(error.InvalidMaxSize, registration_result_1);

    const view_max_size_2 = view.View{
        .instrument_selector = .{ .kind = .Histogram },
        .aggregation = .{ .ExponentialBucketHistogram = .{
            .max_scale = 10,
            .max_size = 2,
            .record_min_max = false,
        } },
        .temporality = .Cumulative,
    };

    try mp.addView(view_max_size_2);
    try std.testing.expectEqual(1, mp.views.items.len);
    try std.testing.expectEqual(view.AggregationType.ExponentialBucketHistogram, mp.views.items[0].aggregation.getType());
    try std.testing.expectEqual(10, mp.views.items[0].aggregation.ExponentialBucketHistogram.max_scale);
    try std.testing.expectEqual(2, mp.views.items[0].aggregation.ExponentialBucketHistogram.max_size);
    try std.testing.expectEqual(false, mp.views.items[0].aggregation.ExponentialBucketHistogram.record_min_max);
}

test "view associated with meter provider" {
    const io = std.testing.io;
    const mp = try MeterProvider.init(std.testing.allocator, io, null);
    defer mp.deinit();

    // Create a view that matches histograms and uses explicit bucket aggregation
    const histogram_view = view.View{
        .instrument_selector = .{ .kind = .Histogram },
        .aggregation = .{ .ExplicitBucketHistogram = .{ .buckets = &.{ 0.1, 1.0, 10.0 } } },
        .temporality = .Cumulative,
    };

    try mp.addView(histogram_view);

    const meter = try mp.getMeter(.{ .name = "test" });

    // Create real instruments through the meter (proper way)
    var histogram = try meter.createHistogram(f64, .{ .name = "test-histogram" });
    var counter = try meter.createCounter(u64, .{ .name = "test-counter" });

    // Get the underlying instruments from the meter's registry
    var hist_instr: ?*Instrument = null;
    var counter_instr: ?*Instrument = null;

    // Find the instruments in the meter's registry
    var iter = meter.instruments.iterator();
    while (iter.next()) |entry| {
        const instr = entry.value_ptr.*;
        if (std.mem.eql(u8, instr.opts.name, "test-histogram")) {
            hist_instr = instr;
        } else if (std.mem.eql(u8, instr.opts.name, "test-counter")) {
            counter_instr = instr;
        }
    }

    try std.testing.expect(hist_instr != null);
    try std.testing.expect(counter_instr != null);

    // The histogram should get the custom aggregation from the view
    const hist_aggregation = view.aggregationForViews(mp.views.items, hist_instr.?, &meter.scope, view.DefaultAggregation);
    try std.testing.expectEqual(view.AggregationType.ExplicitBucketHistogram, hist_aggregation.getType());
    try std.testing.expectEqual(@as(usize, 3), hist_aggregation.ExplicitBucketHistogram.buckets.len);

    // The counter should get the default aggregation (no view matches)
    const counter_aggregation = view.aggregationForViews(mp.views.items, counter_instr.?, &meter.scope, view.DefaultAggregation);
    try std.testing.expectEqual(view.AggregationType.Sum, counter_aggregation.getType());

    // Test temporality as well
    const hist_temporality = view.temporalityForViews(mp.views.items, hist_instr.?, &meter.scope);
    try std.testing.expectEqual(view.Temporality.Cumulative, hist_temporality);

    const counter_temporality = view.temporalityForViews(mp.views.items, counter_instr.?, &meter.scope);
    try std.testing.expectEqual(view.Temporality.Cumulative, counter_temporality); // Default for counters

    // Verify the instruments work
    try histogram.record(5.0, .{});
    try counter.add(1, .{});
}

test "view is additive processing with conflicts" {
    const io = std.testing.io;
    var h = try MeterTestHarness.init(std.testing.allocator, io, null, null);
    defer h.deinit();

    // Add first view with specific aggregation
    try h.mp.addView(view.View{
        .instrument_selector = view.InstrumentSelector{
            .name = "test_histogram",
        },
        .aggregation = .{ .ExplicitBucketHistogram = .{
            .buckets = &[_]f64{ 1.0, 2.0, 5.0 },
        } },
        .temporality = .Cumulative,
        .name = "renamed_histogram",
    });

    // Add second view with conflicting aggregation (should log warning)
    try h.mp.addView(view.View{
        .instrument_selector = view.InstrumentSelector{
            .name = "test_histogram",
        },
        .aggregation = .{
            .ExplicitBucketHistogram = .{
                .buckets = &[_]f64{ 0.5, 1.0, 2.0, 5.0, 10.0 },
            },
        },
        .temporality = .Delta,
        .name = "another_name",
    });

    const meter = try h.mp.getMeter(.{ .name = "test", .schema_url = "http://example.com" });
    var histogram = try meter.createHistogram(f64, .{ .name = "test_histogram" });
    try histogram.record(1.0, .{});

    const result = try h.collect();
    defer h.freeCollected(result);

    try std.testing.expectEqual(1, result.len);
    try std.testing.expect(result[0].data.histogram.len > 0);
}

test "exemplar aggregation samples the series after View attribute filtering" {
    const allocator = std.testing.allocator;
    var h = try MeterTestHarness.init(allocator, std.testing.io, null, null);
    defer h.deinit();
    try h.mp.addView(.{
        .instrument_selector = .{ .name = "requests" },
        .aggregation = .Sum,
        .temporality = .Cumulative,
        .attribute_filter = .{ .include_keys = &.{"region"} },
    });
    const meter = try h.mp.getMeter(.{ .name = "exemplar-test" });
    const counter = try meter.createCounter(u64, .{ .name = "requests" });
    counter.exemplar_filter = .always_on;
    const region: []const u8 = "west";
    const first: []const u8 = "one";
    const second: []const u8 = "two";
    try counter.add(7, .{ "region", region, "request_id", first });
    try counter.add(9, .{ "region", region, "request_id", second });

    const collected = try h.collect();
    defer h.freeCollected(collected);

    const points = collected[0].data.int;
    try std.testing.expectEqual(@as(usize, 1), points.len);
    try std.testing.expectEqual(@as(i64, 16), points[0].value);
    try std.testing.expectEqual(@as(usize, 1), points[0].exemplars.len);
    const sample = points[0].exemplars[0];
    try std.testing.expect(sample.value.int == 7 or sample.value.int == 9);
    try std.testing.expectEqual(@as(usize, 1), sample.filtered_attributes.len);
    try std.testing.expectEqualStrings("request_id", sample.filtered_attributes[0].key);
    try std.testing.expectEqualStrings(if (sample.value.int == 7) "one" else "two", sample.filtered_attributes[0].value.string);
}

test "gauge with filtered view preserves measurement order" {
    const allocator = std.testing.allocator;
    const io = std.testing.io;
    var h = try MeterTestHarness.init(allocator, io, view.TemporalityDelta, null);
    defer h.deinit();

    // Register a view that filters attributes (drops distinguishing sub_id attribute)
    try h.mp.addView(.{
        .instrument_selector = .{ .name = "temperature" },
        .aggregation = .LastValue,
        .temporality = .Delta,
        .attribute_filter = .{ .include_keys = &.{"sensor"} },
    });

    const meter = try h.mp.getMeter(.{ .name = "test-meter" });
    var gauge = try meter.createGauge(f64, .{ .name = "temperature" });

    // Record A=10, B=20, A=30
    try gauge.record(10.0, .{ "sensor", @as([]const u8, "temp1"), "sub_id", @as([]const u8, "a") });
    try gauge.record(20.0, .{ "sensor", @as([]const u8, "temp1"), "sub_id", @as([]const u8, "b") });
    try gauge.record(30.0, .{ "sensor", @as([]const u8, "temp1"), "sub_id", @as([]const u8, "a") });

    const collected = try h.collect();
    defer h.freeCollected(collected);

    try std.testing.expectEqual(@as(usize, 1), collected.len);
    const points = collected[0].data.double;
    try std.testing.expectEqual(@as(usize, 1), points.len);
    // Must be 30.0, not 20.0!
    try std.testing.expectEqual(30.0, points[0].value);
}

test "exemplar aggregation aligns histogram samples with bucket boundaries" {
    const allocator = std.testing.allocator;
    var h = try MeterTestHarness.init(allocator, std.testing.io, null, null);
    defer h.deinit();
    try h.mp.addView(.{
        .instrument_selector = .{ .name = "latency" },
        .aggregation = .{ .ExplicitBucketHistogram = .{ .buckets = &.{ 0, 10 } } },
        .temporality = .Cumulative,
    });
    const meter = try h.mp.getMeter(.{ .name = "exemplar-test" });
    const histogram = try meter.createHistogram(f64, .{ .name = "latency" });
    histogram.exemplar_filter = .always_on;
    for ([_]f64{ -1, 0, 5, 10, 11 }) |value| try histogram.record(value, .{});

    const collected = try h.collect();
    defer h.freeCollected(collected);
    const samples = collected[0].data.histogram[0].exemplars;
    try std.testing.expectEqual(@as(usize, 3), samples.len);
    try std.testing.expectEqual(@as(f64, 0), samples[0].value.double);
    try std.testing.expectEqual(@as(f64, 10), samples[1].value.double);
    try std.testing.expectEqual(@as(f64, 11), samples[2].value.double);
}

test "exemplar aggregation bounds exponential histogram reservoirs" {
    const allocator = std.testing.allocator;
    var h = try MeterTestHarness.init(allocator, std.testing.io, null, null);
    defer h.deinit();
    try h.mp.addView(.{
        .instrument_selector = .{ .name = "sizes" },
        .aggregation = .{ .ExponentialBucketHistogram = try view.ExponentialBucketHistogramConfig.init(.{ .max_size = 2 }) },
        .temporality = .Cumulative,
    });
    const meter = try h.mp.getMeter(.{ .name = "exemplar-test" });
    const histogram = try meter.createHistogram(u64, .{ .name = "sizes" });
    histogram.exemplar_filter = .always_on;
    for ([_]u64{ 1, 2, 3, 4 }) |value| try histogram.record(value, .{});

    const collected = try h.collect();
    defer h.freeCollected(collected);
    const point = collected[0].data.exponential_histogram[0];
    try std.testing.expectEqual(@as(u64, 4), point.value.count);
    try std.testing.expect(point.exemplars.len >= 1 and point.exemplars.len <= 2);
    for (point.exemplars) |sample| try std.testing.expect(sample.value.int >= 1 and sample.value.int <= 4);
}

test "exemplar custom reservoir changes with aggregation configuration" {
    const allocator = std.testing.allocator;
    const Factory = struct {
        var calls: usize = 0;
        fn create(a: std.mem.Allocator, io: std.Io, options: exemplar.ReservoirOptions) !exemplar.ExemplarReservoir {
            calls += 1;
            return exemplar.SimpleFixedSizeExemplarReservoir.init(a, io, options.fixed_size);
        }
    };
    Factory.calls = 0;
    const aggregations = [_]view.Aggregation{
        .Sum,
        .LastValue,
        .{ .ExponentialBucketHistogram = try view.ExponentialBucketHistogramConfig.init(.{ .max_size = 2, .max_scale = 5 }) },
        .{ .ExponentialBucketHistogram = try view.ExponentialBucketHistogramConfig.init(.{ .max_size = 2, .max_scale = 6 }) },
    };
    for (aggregations, 0..) |aggregation_type, index| {
        var h = try MeterTestHarness.init(allocator, std.testing.io, null, null);
        defer h.deinit();
        try h.mp.addView(.{
            .instrument_selector = .{ .name = "requests" },
            .aggregation = aggregation_type,
            .temporality = .Cumulative,
            .exemplar_reservoir = Factory.create,
        });
        const meter = try h.mp.getMeter(.{ .name = "exemplar-streams" });
        const counter = try meter.createCounter(u64, .{ .name = "requests" });
        counter.exemplar_filter = .always_on;
        try counter.add(1, .{});
        const collected = try h.collect();
        defer h.freeCollected(collected);
        try std.testing.expectEqual(index + 1, Factory.calls);
    }
}

test "exemplar reservoirs retire inactive series between collections" {
    const allocator = std.testing.allocator;
    const Factory = struct {
        var calls: usize = 0;
        fn create(a: std.mem.Allocator, io: std.Io, options: exemplar.ReservoirOptions) !exemplar.ExemplarReservoir {
            calls += 1;
            return exemplar.AlignedHistogramBucketExemplarReservoir.init(a, io, options.aligned);
        }
    };
    Factory.calls = 0;
    var h = try MeterTestHarness.init(allocator, std.testing.io, view.TemporalityDelta, null);
    defer h.deinit();
    try h.mp.addView(.{
        .instrument_selector = .{},
        .aggregation = .{ .ExplicitBucketHistogram = .{} },
        .temporality = .Delta,
        .exemplar_reservoir = Factory.create,
    });
    const meter = try h.mp.getMeter(.{ .name = "exemplar-retirement" });
    const histogram = try meter.createHistogram(u64, .{ .name = "requests" });
    histogram.exemplar_filter = .always_on;
    for (0..8) |index| {
        for (0..2) |_| {
            try histogram.record(1, .{ "series", @as(u64, index) });
            const collected = try h.collect();
            defer h.freeCollected(collected);
            try std.testing.expectEqual(@as(usize, 1), h.reader.pipeline.?.exemplar_sampler.reservoirs.count());
        }
        try std.testing.expectEqual(index + 1, Factory.calls);
    }
    const idle = try h.collect();
    defer h.freeCollected(idle);
    try std.testing.expectEqual(@as(usize, 0), h.reader.pipeline.?.exemplar_sampler.reservoirs.count());
}

test "exemplar collection windows stay stable across delta cumulative and idle cycles" {
    const allocator = std.testing.allocator;
    for ([_]bool{ false, true }) |cumulative| for ([_]bool{ false, true }) |sample_first| {
        var h = try MeterTestHarness.init(
            allocator,
            std.testing.io,
            if (cumulative) view.TemporalityCumulative else view.TemporalityDelta,
            null,
        );
        defer h.deinit();
        const meter = try h.mp.getMeter(.{ .name = "exemplar-cycles" });
        const counter = try meter.createCounter(u64, .{ .name = "requests" });
        const created_ns = counter.storages.items[0].collection_start_ns;
        var initial_start: ?u64 = null;
        var previous_end: ?u64 = null;
        var total: i64 = 0;
        for (0..3) |cycle| {
            counter.exemplar_filter = if (cycle == 0 and !sample_first) .always_off else .always_on;
            const value: u64 = cycle + 1;
            total += @intCast(value);
            try counter.add(value, .{ "series", @as(u64, 1) });
            const data = try h.collect();
            defer h.freeCollected(data);
            try std.testing.expectEqual(@as(usize, 1), data.len);
            const point = data[0].data.int[0];
            try std.testing.expectEqual(if (cumulative) total else @as(i64, @intCast(value)), point.value);
            const timestamps = point.timestamps.?;
            if (initial_start == null) initial_start = timestamps.start_time_ns;
            if (cumulative) try std.testing.expectEqual(initial_start, timestamps.start_time_ns) else try std.testing.expectEqual(previous_end orelse created_ns, timestamps.start_time_ns.?);
            try std.testing.expectEqual(@as(usize, if (cycle == 0 and !sample_first) 0 else 1), point.exemplars.len);
            for (point.exemplars) |sample| {
                try std.testing.expect(timestamps.start_time_ns.? <= sample.time_ns);
                try std.testing.expect(sample.time_ns <= timestamps.time_ns);
            }
            previous_end = timestamps.time_ns;
            const idle = try h.collect();
            defer h.freeCollected(idle);
            try std.testing.expectEqual(@as(usize, 0), idle.len);
        }
    };
}

test "exemplar disabling an instrument after recording preserves buffered ownership" {
    const allocator = std.testing.allocator;
    const aggregations = [_]view.Aggregation{ .{ .ExplicitBucketHistogram = .{} }, .{ .ExponentialBucketHistogram = try view.ExponentialBucketHistogramConfig.init(.{}) }, .Sum, .LastValue };
    for (aggregations) |aggregation_type| {
        var h = try MeterTestHarness.init(allocator, std.testing.io, null, null);
        defer h.deinit();
        try h.mp.addView(.{ .instrument_selector = .{}, .aggregation = aggregation_type, .temporality = .Cumulative });
        const meter = try h.mp.getMeter(.{ .name = "exemplar-filter-conflict" });
        const counter = try meter.createCounter(u64, .{ .name = "requests" });
        counter.exemplar_filter = .always_on;
        var key = "route".*;
        var value = "/first".*;
        var attrs = [_]Attribute{.{ .key = &key, .value = .{ .string = &value } }};
        try counter.addWithSlice(7, &attrs);
        counter.exemplar_filter = .always_off;
        @memcpy(&key, "other");
        @memcpy(&value, "/later");
        const collected = try h.collect();
        defer h.freeCollected(collected);
        try std.testing.expectEqual(@as(usize, 1), collected.len);
        switch (collected[0].data) {
            inline else => |points| {
                try std.testing.expectEqual(@as(usize, 1), points.len);
                try std.testing.expect(points[0].attributes_owned);
                try std.testing.expectEqual(@as(usize, 1), points[0].attributes.?.len);
                try std.testing.expectEqualStrings("route", points[0].attributes.?[0].key);
                try std.testing.expectEqualStrings("/first", points[0].attributes.?[0].value.string);
                try std.testing.expectEqual(@as(usize, 1), points[0].exemplars.len);
            },
        }
    }
}
