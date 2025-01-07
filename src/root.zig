const std = @import("std");
pub const MatSys = @import("./matsys.zig").MatSys;
pub const Mat = @import("./mat.zig").Mat;

test {
    std.testing.refAllDecls(@This());
}
