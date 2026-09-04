//! Compile-time builders for attribute lists.
//!
//! Signals take attributes as a `[]const Attribute`, which is verbose to write by hand.
//! `fromPairs` builds that list from key-value pairs, where a key can be a semantic
//! convention attribute definition, and `flatten` builds it from a struct literal, turning
//! nested literals into dot-delimited keys.
//!
//! Neither allocates: both return a fixed-size array sized at compile time.

const std = @import("std");

const Attribute = @import("../attributes.zig").Attribute;
const AttributeValue = @import("../attributes.zig").AttributeValue;

/// Converts a value into an AttributeValue.
/// Only the types that an OTel attribute can hold are accepted, anything else is
/// a compile error at the call site.
fn toAttributeValue(v: anytype) AttributeValue {
    const T = @TypeOf(v);
    return switch (@typeInfo(T)) {
        .pointer => |p| switch (p.size) {
            .slice => if (p.child == u8)
                .{ .string = v }
            else
                @compileError("unsupported slice type for attribute value: " ++ @typeName(T)),
            .one => switch (@typeInfo(p.child)) {
                .array => |a| if (a.child == u8)
                    .{ .string = v } // *const [N:0]u8 string literal
                else
                    @compileError("unsupported array type for attribute value: " ++ @typeName(T)),
                else => @compileError("unsupported pointer type for attribute value: " ++ @typeName(T)),
            },
            else => @compileError("unsupported pointer type for attribute value: " ++ @typeName(T)),
        },
        .bool => .{ .bool = v },
        .int, .comptime_int => .{ .int = @intCast(v) },
        .float, .comptime_float => .{ .double = @floatCast(v) },
        // Well-known values of a semantic convention enum attribute, which spell their
        // wire representation through toString().
        .@"enum" => if (@hasDecl(T, "toString"))
            .{ .string = v.toString() }
        else
            @compileError("enum " ++ @typeName(T) ++ " has no toString() to spell its attribute value"),
        // Reached from `flatten`, where nothing names the enum a literal belongs to.
        .enum_literal => @compileError("an enum literal does not name its enum: pass it to fromPairs keyed by a semantic convention enum attribute definition, or spell the value out"),
        else => @compileError("unsupported type for attribute value: " ++ @typeName(T)),
    };
}

fn isString(comptime T: type) bool {
    return switch (@typeInfo(T)) {
        .pointer => |p| switch (p.size) {
            .slice => p.child == u8,
            .one => switch (@typeInfo(p.child)) {
                .array => |a| a.child == u8,
                else => false,
            },
            else => false,
        },
        else => false,
    };
}

/// The key of an attribute, either spelled out or taken from a semantic convention
/// attribute definition of the opentelemetry-semconv module. Definitions are matched
/// structurally, so the SDK does not depend on that module: a plain `name` field is a
/// `types.Attribute`, a `base.name` one is a `types.EnumAttribute`.
fn keyOf(definition: anytype) []const u8 {
    const T = @TypeOf(definition);
    if (comptime isString(T)) return definition;
    if (comptime @typeInfo(T) == .@"struct") {
        if (comptime @hasField(T, "name")) return definition.name;
        if (comptime @hasField(T, "base")) return definition.base.name;
    }
    @compileError("attribute key must be a string or a semantic convention attribute definition, found " ++ @typeName(T));
}

/// The enum a semantic convention enum attribute definition draws its well-known values
/// from, or null for any other kind of key. Matched structurally like `keyOf`, on the
/// `well_known_values` field of `types.EnumAttribute`.
fn wellKnownEnum(comptime T: type) ?type {
    if (@typeInfo(T) != .@"struct" or !@hasField(T, "well_known_values")) return null;
    const E = @FieldType(T, "well_known_values");
    return if (@typeInfo(E) == .@"enum") E else null;
}

/// The value of a pair. A bare enum literal is resolved against the enum of the key's
/// definition, so that `.{ semconv.attribute.http_request_method, .get }` says as much as
/// naming the value type in full; anything else converts on its own.
fn valueOf(definition: anytype, value: anytype) AttributeValue {
    if (comptime @typeInfo(@TypeOf(value)) == .enum_literal) {
        const E = comptime wellKnownEnum(@TypeOf(definition)) orelse
            @compileError("an enum literal needs a semantic convention enum attribute definition as its key to name its enum, found " ++ @typeName(@TypeOf(definition)));
        return toAttributeValue(@as(E, value));
    }
    return toAttributeValue(value);
}

fn pairFields(comptime T: type) []const std.builtin.Type.StructField {
    const info = @typeInfo(T);
    if (info != .@"struct" or !info.@"struct".is_tuple) {
        @compileError("expected a tuple of .{ key, value } pairs, found " ++ @typeName(T));
    }
    inline for (info.@"struct".fields) |field| {
        const pair = @typeInfo(field.type);
        if (pair != .@"struct" or !pair.@"struct".is_tuple or pair.@"struct".fields.len != 2) {
            @compileError("expected a .{ key, value } pair, found " ++ @typeName(field.type));
        }
    }
    return info.@"struct".fields;
}

/// Builds an attribute list from `.{ key, value }` pairs, without allocating.
///
/// A key is either a string or an attribute definition from the opentelemetry-semconv
/// module, which keeps convention names out of the call site:
/// ```zig
/// const attrs = fromPairs(.{
///     .{ semconv.attribute.http_request_method, .get },
///     .{ semconv.attribute.http_response_status_code, 200 },
///     .{ "acme.tenant.id", tenant_id },
/// });
/// ```
/// Values must be a `[]const u8`, a `bool`, an integer, a float, or an enum spelling its
/// value through `toString()`, which is how semantic convention enum values are written.
///
/// A key that defines well-known values also names their enum, so those values can be
/// written as bare enum literals: `.get` above stands for
/// `semconv.attribute.http_request_methodValue.get`. A value outside the set is a compile
/// error, but a plain string is still accepted, for the conventions whose set is open.
///
/// Keys taken from a definition and string values are borrowed, not copied. The returned
/// array is owned by the caller and must outlive every use of the attributes it holds.
/// Taking its address inline, as in `.attributes = &fromPairs(.{ ... })`, is enough for a
/// call that consumes the attributes before it returns.
pub fn fromPairs(pairs: anytype) [pairFields(@TypeOf(pairs)).len]Attribute {
    var attrs: [pairFields(@TypeOf(pairs)).len]Attribute = undefined;
    inline for (comptime pairFields(@TypeOf(pairs)), 0..) |field, i| {
        const pair = @field(pairs, field.name);
        attrs[i] = .{ .key = keyOf(pair[0]), .value = valueOf(pair[0], pair[1]) };
    }
    return attrs;
}

/// Whether `T` is a struct with named fields, the shape `flatten` walks into.
/// Tuples with fields are not: their field names are "0", "1", ... which would make
/// meaningless attribute keys. `.{}` is both an empty struct and an empty tuple, so
/// an empty tuple counts here and yields no attributes.
fn isNamedStruct(comptime T: type) bool {
    return switch (@typeInfo(T)) {
        .@"struct" => |s| !s.is_tuple or s.fields.len == 0,
        else => false,
    };
}

fn namedFields(comptime T: type) []const std.builtin.Type.StructField {
    if (comptime !isNamedStruct(T)) {
        @compileError("expected a struct literal with named fields, found " ++ @typeName(T));
    }
    return @typeInfo(T).@"struct".fields;
}

/// Number of attributes `flatten` produces for the struct type `T`: one per leaf
/// field, counting nested structs recursively.
pub fn flatCount(comptime T: type) usize {
    comptime var count: usize = 0;
    inline for (comptime namedFields(T)) |field| {
        count += if (comptime isNamedStruct(field.type)) flatCount(field.type) else 1;
    }
    return count;
}

fn flattenInto(comptime prefix: []const u8, data: anytype, out: []Attribute, next: *usize) void {
    inline for (comptime namedFields(@TypeOf(data))) |field| {
        const key = comptime if (prefix.len == 0) field.name else prefix ++ "." ++ field.name;
        const value = @field(data, field.name);
        if (comptime isNamedStruct(@TypeOf(value))) {
            flattenInto(key, value, out, next);
        } else {
            out[next.*] = .{ .key = key, .value = toAttributeValue(value) };
            next.* += 1;
        }
    }
}

/// Builds an attribute list from a struct literal, without allocating.
///
/// Nested struct literals are flattened into dot-delimited keys at compile time:
/// ```zig
/// const attrs = flatten(.{ .checkout = .{ .cart = .{ .items = 3 }, .coupon = true } });
/// // { "checkout.cart.items" = 3, "checkout.coupon" = true }
/// ```
/// Keys are spelled at the call site, so this is for the attributes an application owns.
/// Names covered by the semantic conventions should come from the opentelemetry-semconv
/// module instead of being written out here: pass the definitions to `fromPairs`.
///
/// Field values must be a `[]const u8`, a `bool`, an integer or a float; anything else is
/// a compile error. Note that map-valued attributes, which the specification allows, are
/// not representable by `AttributeValue`, and the semantic conventions recommend flat
/// attributes anyway: see https://opentelemetry.io/docs/specs/semconv/general/naming/
///
/// Keys are compile-time strings and live for the whole program, string values are
/// borrowed from `data` and not copied. The returned array is owned by the caller and
/// must outlive every use of the attributes it holds. Taking its address inline, as in
/// `.attributes = &flatten(.{ ... })`, is enough for a call that consumes the attributes
/// before it returns.
pub fn flatten(data: anytype) [flatCount(@TypeOf(data))]Attribute {
    var attrs: [flatCount(@TypeOf(data))]Attribute = undefined;
    var next: usize = 0;
    flattenInto("", data, &attrs, &next);
    return attrs;
}

test "fromPairs takes the key from a semantic convention definition" {
    // Shape of the opentelemetry-semconv types: a plain definition carries the name
    // directly, an enum one carries it in `base`, and its values spell themselves.
    const Definition = struct { name: []const u8, stability: enum { stable } };
    const Method = enum {
        get,
        post,
        pub fn toString(self: @This()) []const u8 {
            return switch (self) {
                .get => "GET",
                .post => "POST",
            };
        }
    };
    const EnumDefinition = struct { base: Definition, well_known_values: Method };

    const http_request_method: EnumDefinition = .{
        .base = .{ .name = "http.request.method", .stability = .stable },
        .well_known_values = .get,
    };
    const http_response_status_code: Definition = .{ .name = "http.response.status_code", .stability = .stable };

    const attrs = fromPairs(.{
        .{ http_request_method, Method.get },
        .{ http_response_status_code, 200 },
        .{ "acme.tenant.id", "t-42" },
    });

    try std.testing.expectEqual(@as(usize, 3), attrs.len);
    try std.testing.expectEqualStrings("http.request.method", attrs[0].key);
    try std.testing.expectEqualStrings("GET", attrs[0].value.string);
    try std.testing.expectEqualStrings("http.response.status_code", attrs[1].key);
    try std.testing.expectEqual(@as(i64, 200), attrs[1].value.int);
    try std.testing.expectEqualStrings("acme.tenant.id", attrs[2].key);
    try std.testing.expectEqualStrings("t-42", attrs[2].value.string);

    // The result coerces to the slice type the signals take.
    const slice: []const Attribute = &attrs;
    try std.testing.expectEqual(@as(usize, 3), slice.len);
}

test "fromPairs resolves an enum literal against the enum of its key" {
    const Method = enum {
        get,
        post,
        pub fn toString(self: @This()) []const u8 {
            return switch (self) {
                .get => "GET",
                .post => "POST",
            };
        }
    };
    const Definition = struct { name: []const u8 };
    const EnumDefinition = struct { base: Definition, well_known_values: Method };

    const http_request_method: EnumDefinition = .{
        .base = .{ .name = "http.request.method" },
        .well_known_values = .get,
    };
    // An open set: the definition has well-known values, but any string is allowed.
    const error_type: EnumDefinition = .{
        .base = .{ .name = "error.type" },
        .well_known_values = .get,
    };

    // A literal is comptime-only, which makes it a comptime field of the pairs tuple;
    // runtime values in the other pairs are unaffected.
    var tenant: []const u8 = "";
    tenant = "t-42";

    const attrs = fromPairs(.{
        .{ http_request_method, .post },
        .{ error_type, "ConnectionResetError" },
        .{ "acme.tenant.id", tenant },
    });

    try std.testing.expectEqualStrings("http.request.method", attrs[0].key);
    try std.testing.expectEqualStrings("POST", attrs[0].value.string);
    try std.testing.expectEqualStrings("error.type", attrs[1].key);
    try std.testing.expectEqualStrings("ConnectionResetError", attrs[1].value.string);
    try std.testing.expectEqualStrings("t-42", attrs[2].value.string);
}

test "fromPairs accepts runtime values" {
    var status: u16 = 0;
    status = 503;
    const reason: []const u8 = "upstream timeout";
    const ratio: f32 = 0.5;

    const attrs = fromPairs(.{
        .{ "http.response.status_code", status },
        .{ "error.message", reason },
        .{ "sampling.ratio", ratio },
        .{ "retried", true },
    });

    try std.testing.expectEqual(@as(i64, 503), attrs[0].value.int);
    try std.testing.expectEqualStrings("upstream timeout", attrs[1].value.string);
    try std.testing.expectEqual(@as(f64, 0.5), attrs[2].value.double);
    try std.testing.expectEqual(true, attrs[3].value.bool);
}

test "fromPairs of no pairs is empty" {
    const attrs = fromPairs(.{});
    try std.testing.expectEqual(@as(usize, 0), attrs.len);
}

test "flatten nests struct literals into dot-delimited keys" {
    const attrs = flatten(.{
        .checkout = .{
            .cart = .{ .items = 3 },
            .coupon = .{ .applied = true },
        },
        .experiment = .{ .variant = "b" },
        .duration_ms = 12.5,
        .cached = true,
    });

    try std.testing.expectEqual(@as(usize, 5), attrs.len);
    try std.testing.expectEqualStrings("checkout.cart.items", attrs[0].key);
    try std.testing.expectEqual(@as(i64, 3), attrs[0].value.int);
    try std.testing.expectEqualStrings("checkout.coupon.applied", attrs[1].key);
    try std.testing.expectEqual(true, attrs[1].value.bool);
    try std.testing.expectEqualStrings("experiment.variant", attrs[2].key);
    try std.testing.expectEqualStrings("b", attrs[2].value.string);
    try std.testing.expectEqualStrings("duration_ms", attrs[3].key);
    try std.testing.expectEqual(@as(f64, 12.5), attrs[3].value.double);
    try std.testing.expectEqualStrings("cached", attrs[4].key);
    try std.testing.expectEqual(true, attrs[4].value.bool);

    // The result coerces to the slice type the signals take.
    const slice: []const Attribute = &attrs;
    try std.testing.expectEqual(@as(usize, 5), slice.len);
}

test "flatten accepts runtime values" {
    const items = [_]u8{ 1, 2, 3 };
    var status: u16 = 0;
    status = 503;
    const reason: []const u8 = "upstream timeout";
    const ratio: f32 = 0.5;

    const attrs = flatten(.{
        .count = items.len, // usize
        .status = status,
        .reason = reason,
        .ratio = ratio,
    });

    try std.testing.expectEqual(@as(i64, 3), attrs[0].value.int);
    try std.testing.expectEqual(@as(i64, 503), attrs[1].value.int);
    try std.testing.expectEqualStrings("upstream timeout", attrs[2].value.string);
    try std.testing.expectEqual(@as(f64, 0.5), attrs[3].value.double);
}

test "flatten of an empty struct literal is empty" {
    const attrs = flatten(.{});
    try std.testing.expectEqual(@as(usize, 0), attrs.len);
    try std.testing.expectEqual(@as(usize, 0), flatCount(@TypeOf(.{})));
}
