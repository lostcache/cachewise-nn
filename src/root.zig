const std = @import("std");
pub const MatSys = @import("./matsys.zig").MatSys;

test {
    std.testing.refAllDecls(@This());
}
