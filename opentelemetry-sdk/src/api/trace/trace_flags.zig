const std = @import("std");

/// TraceFlags contain details about the trace.
/// Unlike TraceState values, TraceFlags are present in all traces.
pub const TraceFlags = struct {
    value: u8,

    const Self = @This();

    /// Sampled flag (bit 0)
    pub const SAMPLED_FLAG: u8 = 0x01;

    /// Random trace ID flag (bit 1) - from W3C Trace Context Level 2
    pub const RANDOM_FLAG: u8 = 0x02;

    pub fn init(value: u8) Self {
        return Self{ .value = value };
    }

    pub fn default() Self {
        return Self{ .value = 0 };
    }

    /// Flags for a span the SDK records and exports.
    /// Distinct from `default()`, which is the zero value used for invalid
    /// and non-recording span contexts.
    pub fn sampled() Self {
        return Self{ .value = SAMPLED_FLAG };
    }

    /// Check if the sampled flag is set
    pub fn isSampled(self: Self) bool {
        return (self.value & SAMPLED_FLAG) != 0;
    }

    /// Check if the random flag is set
    pub fn isRandom(self: Self) bool {
        return (self.value & RANDOM_FLAG) != 0;
    }

    /// Set the sampled flag
    pub fn setSampled(self: Self) Self {
        return Self{ .value = self.value | SAMPLED_FLAG };
    }

    /// Set the random flag
    pub fn setRandom(self: Self) Self {
        return Self{ .value = self.value | RANDOM_FLAG };
    }

    /// Clear the sampled flag
    pub fn clearSampled(self: Self) Self {
        return Self{ .value = self.value & ~SAMPLED_FLAG };
    }

    /// Clear the random flag
    pub fn clearRandom(self: Self) Self {
        return Self{ .value = self.value & ~RANDOM_FLAG };
    }
};

test "TraceFlags operations" {
    var flags = TraceFlags.default();
    try std.testing.expect(!flags.isSampled());
    try std.testing.expect(!flags.isRandom());

    flags = flags.setSampled();
    try std.testing.expect(flags.isSampled());
    try std.testing.expect(!flags.isRandom());

    flags = flags.setRandom();
    try std.testing.expect(flags.isSampled());
    try std.testing.expect(flags.isRandom());

    flags = flags.clearSampled();
    try std.testing.expect(!flags.isSampled());
    try std.testing.expect(flags.isRandom());

    flags = flags.clearRandom();
    try std.testing.expect(!flags.isSampled());
    try std.testing.expect(!flags.isRandom());
}

test "TraceFlags sampled constructor" {
    try std.testing.expect(TraceFlags.sampled().isSampled());
    try std.testing.expect(!TraceFlags.sampled().isRandom());
    try std.testing.expectEqual(
        TraceFlags.default().setSampled().value,
        TraceFlags.sampled().value,
    );
}
