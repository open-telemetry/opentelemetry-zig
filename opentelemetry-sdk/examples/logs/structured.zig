//! Shows the ways of shaping a log record: a plain string body or a structured one,
//! with attributes written by hand, taken from the semantic conventions, or derived from
//! a struct literal at compile time.

const std = @import("std");
const sdk = @import("opentelemetry-sdk");
const semconv = @import("opentelemetry-semconv");

pub fn main(init: std.process.Init) !void {
    const allocator = init.gpa;
    const io = init.io;

    var stdout_buffer: [4096]u8 = undefined;
    var stdout_writer = std.Io.File.stdout().writer(io, &stdout_buffer);

    var print_exporter = PrintExporter.init(&stdout_writer.interface);
    var simple_processor = sdk.logs.SimpleLogRecordProcessor.init(io, print_exporter.asLogRecordExporter());

    var provider = try sdk.logs.LoggerProvider.init(allocator, io, null);
    defer provider.deinit();
    try provider.addLogRecordProcessor(simple_processor.asLogRecordProcessor());

    const logger = try provider.getLogger(.{ .name = "example.structured", .version = "1.0.0" });

    // 1. A plain string body: what a log line looks like in most logging libraries.
    heading("plain body");
    logger.emit(.info, "Application started", .{});

    // 2. Attributes written by hand, one Attribute per key. Names covered by the semantic
    //    conventions come from the semconv module rather than being spelled out here.
    heading("plain body, attributes written by hand");
    const server_attrs = [_]sdk.attributes.Attribute{
        .{ .key = semconv.attribute.server_address.name, .value = .{ .string = "localhost" } },
        .{ .key = semconv.attribute.server_port.name, .value = .{ .int = 8080 } },
    };
    logger.emit(.info, "Listening for connections", .{ .attributes = &server_attrs });

    // 3. The same, from key-value pairs. A key can be a semantic convention definition,
    //    which saves reaching for `.name` (or `.base.name`, for the ones with well-known
    //    values). A definition that has well-known values also names their enum, so `.get`
    //    below is enough to mean `semconv.attribute.http_request_methodValue.get`.
    heading("plain body, attributes from semantic conventions");
    const request_attrs = sdk.attributes.fromPairs(.{
        .{ semconv.attribute.http_request_method, .get },
        .{ semconv.attribute.http_response_status_code, 200 },
        .{ semconv.attribute.url_path, "/api/users" },
    });
    logger.emit(.info, "Request handled", .{ .attributes = &request_attrs });

    // 4. Attributes this application owns, from a struct literal: nested literals become
    //    dot-delimited keys, so a whole namespace is written once.
    heading("plain body, attributes from a struct literal");
    const checkout_attrs = sdk.attributes.flatten(.{
        .checkout = .{
            .cart = .{ .items = 3, .currency = "EUR" },
            .coupon = .{ .applied = true },
        },
    });
    logger.emit(.info, "Checkout completed", .{ .attributes = &checkout_attrs });

    // 5. A structured body: the payload of the record is key-value fields instead of
    //    a message. Values can be computed at runtime.
    heading("structured body");
    const users = [_][]const u8{ "alice", "bob", "carol" };
    logger.emitStructured(.debug, .{
        .page = 1,
        .returned = users.len,
        .truncated = false,
    }, .{});

    // 6. Both at once, with an event name. Fields covered by the semantic conventions
    //    belong in the attributes, which backends index; the body carries what is
    //    specific to this event.
    //    See https://opentelemetry.io/docs/specs/semconv/general/events/
    heading("structured body with an event name and attributes");
    logger.emitStructured(.info, .{
        .cache = .{ .hit = false, .lookup_ms = 0.4 },
        .upstream_retries = 2,
    }, .{
        .event_name = "app.request.handled",
        .attributes = &request_attrs,
    });

    // 7. The attribute list can also be built inline: the temporary lives until the end
    //    of the statement, which covers the whole emit call.
    heading("attributes built inline");
    logger.emitStructured(.err, .{
        .reason = "connection reset",
        .attempts = 3,
    }, .{
        .event_name = "app.upstream.failed",
        .attributes = &sdk.attributes.fromPairs(.{
            .{ semconv.attribute.server_address, "upstream.example.com" },
            .{ semconv.attribute.server_port, 443 },
            .{ semconv.attribute.error_type, "ConnectionResetError" },
        }),
    });

    try provider.shutdown();
}

fn heading(title: []const u8) void {
    std.debug.print("\n{s}\n", .{title});
}

/// Prints every field this example cares about: the SDK's StdoutExporter serializes the
/// body as JSON, but not the attributes or the event name.
const PrintExporter = struct {
    writer: *std.Io.Writer,

    const Self = @This();

    /// The writer must remain valid for the lifetime of the exporter.
    pub fn init(writer: *std.Io.Writer) Self {
        return Self{ .writer = writer };
    }

    pub fn exportLogs(ctx: *anyopaque, log_records: []sdk.logs.ReadbleLogRecord) anyerror!void {
        const self: *Self = @ptrCast(@alignCast(ctx));

        for (log_records) |record| {
            try self.writer.print("  {s}", .{severityName(record.severity_number)});
            if (record.event_name) |event_name| {
                try self.writer.print(" event_name={s}", .{event_name});
            }
            if (record.body) |body| switch (body) {
                .string => |message| try self.writer.print(" body=\"{s}\"", .{message}),
                .structured => |fields| {
                    try self.writer.writeAll(" body={");
                    try writeAttributes(self.writer, fields);
                    try self.writer.writeAll(" }");
                },
            };
            if (record.attributes.len > 0) {
                try self.writer.writeAll(" attributes={");
                try writeAttributes(self.writer, record.attributes);
                try self.writer.writeAll(" }");
            }
            try self.writer.writeByte('\n');
        }
        try self.writer.flush();
    }

    pub fn shutdown(_: *anyopaque) anyerror!void {}

    pub fn asLogRecordExporter(self: *Self) sdk.logs.LogRecordExporter {
        return .{
            .ptr = self,
            .vtable = &.{
                .exportLogsFn = exportLogs,
                .shutdownFn = shutdown,
            },
        };
    }
};

fn writeAttributes(writer: *std.Io.Writer, attributes: []const sdk.attributes.Attribute) !void {
    for (attributes) |attribute| {
        try writer.print(" {s}=", .{attribute.key});
        switch (attribute.value) {
            .string => |value| try writer.print("\"{s}\"", .{value}),
            .bool => |value| try writer.print("{}", .{value}),
            .int => |value| try writer.print("{d}", .{value}),
            .double => |value| try writer.print("{d}", .{value}),
            .baggage => try writer.writeAll("<baggage>"),
        }
    }
}

/// Short name for a severity number, following the ranges of the log data model:
/// https://opentelemetry.io/docs/specs/otel/logs/data-model/#field-severitynumber
fn severityName(severity_number: ?u8) []const u8 {
    const number = severity_number orelse return "UNSET";
    return switch (number) {
        1...4 => "TRACE",
        5...8 => "DEBUG",
        9...12 => "INFO",
        13...16 => "WARN",
        17...20 => "ERROR",
        else => "FATAL",
    };
}
