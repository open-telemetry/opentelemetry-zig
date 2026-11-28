//! OpenTelemetry Profiles API.

pub const types = @import("profiles/types.zig");
pub const ProfileID = types.ProfileID;
pub const ValueType = types.ValueType;
pub const StackFrame = types.StackFrame;

test {
    _ = @import("profiles/types.zig");
}
