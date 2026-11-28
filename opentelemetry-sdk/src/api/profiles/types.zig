const std = @import("std");

/// 16-byte identifier uniquely identifying a profile.
pub const ProfileID = struct {
    value: [16]u8,

    const Self = @This();

    pub fn init(value: [16]u8) Self {
        return .{ .value = value };
    }

    pub fn zero() Self {
        return .{ .value = @splat(0) };
    }

    pub fn isValid(self: Self) bool {
        for (self.value) |b| {
            if (b != 0) return true;
        }
        return false;
    }

    pub fn random(rand: std.Random) Self {
        var bytes: [16]u8 = undefined;
        rand.bytes(&bytes);
        return init(bytes);
    }

    pub fn toHex(self: Self, buf: *[32]u8) []const u8 {
        _ = std.fmt.bufPrint(buf, "{x:0>32}", .{std.mem.readInt(u128, &self.value, .big)}) catch unreachable;
        return buf;
    }

    pub fn fromHex(hex_string: []const u8) !Self {
        if (hex_string.len != 32) return error.InvalidHexLength;
        var value: [16]u8 = undefined;
        for (0..16) |i| {
            value[i] = try std.fmt.parseInt(u8, hex_string[i * 2 .. i * 2 + 2], 16);
        }
        return init(value);
    }
};

/// ValueType describes the type and unit of a value in a profile (e.g. alloc_space / bytes).
pub const ValueType = struct {
    type_name: []const u8,
    unit: []const u8,
};

/// Represents a stack frame with source location and address information.
pub const StackFrame = struct {
    function_name: []const u8,
    filename: []const u8 = "",
    line: i64 = 0,
    column: i64 = 0,
    address: u64 = 0,
};

test "ProfileID validity, hex formatting and parsing" {
    const zero = ProfileID.zero();
    try std.testing.expect(!zero.isValid());

    const sample_bytes = [16]u8{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 };
    const pid = ProfileID.init(sample_bytes);
    try std.testing.expect(pid.isValid());

    var hex_buf: [32]u8 = undefined;
    const hex = pid.toHex(&hex_buf);
    try std.testing.expectEqualStrings("0102030405060708090a0b0c0d0e0f10", hex);

    const parsed = try ProfileID.fromHex(hex);
    try std.testing.expectEqual(pid.value, parsed.value);

    try std.testing.expectError(error.InvalidHexLength, ProfileID.fromHex("short"));
}
