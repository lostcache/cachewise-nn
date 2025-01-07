const std = @import("std");
pub const MatSys = @import("./mat_sys.zig").MatSys;
pub const Mat = @import("./mat.zig").Mat;

test {
    std.testing.refAllDecls(@This());
}
