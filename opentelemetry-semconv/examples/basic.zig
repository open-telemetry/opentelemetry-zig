//! Basic example showing how to access attributes and metrics
//! from the OpenTelemetry semantic conventions

const std = @import("std");
const semconv = @import("opentelemetry-semconv");

pub fn main() !void {
    // Accessing attributes from the attribute namespace
    const http_method = semconv.attribute.http_request_method;
    std.debug.assert(std.mem.eql(u8, http_method.name, "http.request.method"));
    std.debug.assert(http_method.stability == .stable);

    // Attribute with enum values
    const method_get = semconv.attribute.http_request_methodValue.get;
    std.debug.assert(std.mem.eql(u8, method_get.toString(), "GET"));

    const http_status = semconv.attribute.http_response_status_code;
    std.debug.assert(std.mem.eql(u8, http_status.name, "http.response.status_code"));
    std.debug.assert(http_status.stability == .stable);

    // Accessing metrics from the metric namespace
    const http_server_duration = semconv.metric.http_server_request_duration;
    std.debug.assert(std.mem.eql(u8, http_server_duration.name, "http.server.request.duration"));
    std.debug.assert(http_server_duration.instrument == .histogram);
    std.debug.assert(std.mem.eql(u8, http_server_duration.unit, "s"));
    std.debug.assert(http_server_duration.stability == .stable);

    // Accessing resource attributes from the resource namespace
    const service_name = semconv.resource.service_name;
    std.debug.assert(std.mem.eql(u8, service_name.name, "service.name"));
    std.debug.assert(service_name.requirement_level == .required);

    // Accessing trace attributes from the trace namespace
    const db_operation_name = semconv.trace.db_operation_name;
    std.debug.assert(std.mem.eql(u8, db_operation_name.name, "db.operation.name"));
    std.debug.assert(db_operation_name.stability == .stable);
}
