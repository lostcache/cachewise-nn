const std = @import("std");
const testing = std.testing;
const MatSys = @import("./mat_sys.zig").MatSys;

pub fn Mat(comptime T: type) type {
    return struct {
        const Self = @This();

        sys_ptr: *MatSys(T),

        start_index: usize,

        n_rows: usize,

        n_cols: usize,

        pub fn init(sys_ptr: *MatSys(T), start_index: usize, n_rows: usize, n_cols: usize) Self {
            return Self{
                .sys_ptr = sys_ptr,
                .start_index = start_index,
                .n_rows = n_rows,
                .n_cols = n_cols,
            };
        }
    };
}

test "init Mat" {
    const alloc = std.testing.allocator;
    var mat_sys = try MatSys(i32).init(alloc);
    defer mat_sys.deinit();
    const mat = Mat(i32).init(&mat_sys, 0, 3, 3);
    try testing.expectEqual(mat.n_rows, 3);
    try testing.expectEqual(mat.n_cols, 3);
    try testing.expectEqual(mat.start_index, 0);
}
