const std = @import("std");
const testing = std.testing;
const MatSys = @import("./matsys.zig").MatSys;

pub fn Mat(comptime T: type) type {
    return struct {
        const Self = @This();

        sys_ptr: *MatSys(T),

        start_index: usize,

        n_rows: usize,

        n_cols: usize,

        pub fn init(sys_ptr: *MatSys(T), start_index: usize, n_cols: usize, n_rows: usize) Self {
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
    var matSys = try MatSys(i32).init(alloc);
    defer matSys.deinit();
    const mat = Mat(i32).init(&matSys, 0, 3, 3);
    try testing.expectEqual(mat.n_rows, 3);
    try testing.expectEqual(mat.n_cols, 3);
    try testing.expectEqual(mat.start_index, 0);
}
