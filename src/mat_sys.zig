const std = @import("std");
const testing = std.testing;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const Mat = @import("./mat.zig").Mat;

pub fn MatSys(comptime T: type) type {
    return MatSysAligned(T);
}

fn MatSysAligned(comptime T: type) type {
    return struct {
        const Self = @This();

        allocator: Allocator,

        data: ArrayList(T),

        pub fn initCapacity(alloc: Allocator, init_cap: usize) !Self {
            return Self{ .allocator = alloc, .data = try ArrayList(T).initCapacity(alloc, init_cap) };
        }

        pub fn init(alloc: Allocator) !Self {
            return Self{ .allocator = alloc, .data = ArrayList(T).init(alloc) };
        }

        pub fn deinit(self: *Self) void {
            self.data.deinit();
        }

        // adds a matrix to the system from a slice.
        // first creates space in the existing system with size of the slice.
        // then does a memcpy.
        // The operation is O(N).
        pub fn addFromSlice(self: *Self, slice: []const T) !void {
            const currLen = self.data.items.len;
            try self.data.insertSlice(currLen, slice);
        }

        fn validate2DArrayAndReturnDim(arr: *const ArrayList(ArrayList(T))) !struct { usize, usize } {
            const n_rows = arr.items.len;

            if (n_rows == 0) {
                return error.EmptyMatrix;
            }

            const n_cols = arr.items[0].items.len;

            if (n_cols == 0) {
                return error.EmptyCol;
            }

            for (arr.items) |row| {
                if (row.items.len != n_cols) {
                    return error.InconsistentCols;
                }
            }

            return .{ n_rows, n_cols };
        }

        pub fn addCopyFrom2DArrayList(self: *Self, arr: *const ArrayList(ArrayList(T))) !Mat(T) {
            const dim = try validate2DArrayAndReturnDim(arr);

            const start_index = self.data.items.len;

            for (arr.items) |row| {
                try self.addFromSlice(row.items[0..]);
            }

            return Mat(T).init(self, start_index, dim[0], dim[1]);
        }
    };
}

test "initCapacity" {
    const alloc = std.testing.allocator;
    var mat_sys = try MatSys(i32).initCapacity(alloc, 10);
    defer mat_sys.deinit();
    try mat_sys.data.append(42);
    try testing.expectEqual(@as(i32, 42), mat_sys.data.pop());
    std.debug.print("Testing initCapacity ... OK\n", .{});
}

test "init" {
    const alloc = std.testing.allocator;
    var mat_sys = try MatSys(i32).init(alloc);
    defer mat_sys.deinit();
    try mat_sys.data.append(42);
    try testing.expectEqual(@as(i32, 42), mat_sys.data.pop());
}

test "add from slice" {
    const alloc = std.testing.allocator;
    var mat_sys = try MatSys(i32).init(alloc);
    defer mat_sys.deinit();
    const slice = [_]i32{ 1, 2, 3 };
    try mat_sys.addFromSlice(&slice);
    try testing.expectEqual(@as(i32, 1), mat_sys.data.items[0]);
    try testing.expectEqual(@as(i32, 2), mat_sys.data.items[1]);
    try testing.expectEqual(@as(i32, 3), mat_sys.data.items[2]);
    std.debug.print("Testing add from slice ... OK\n", .{});
}

test "add from 2D array list" {
    const alloc = std.testing.allocator;
    var mat_sys = try MatSys(i32).init(alloc);
    defer mat_sys.deinit();
    var arr = ArrayList(ArrayList(i32)).init(alloc);
    defer arr.deinit();
    try arr.append(ArrayList(i32).init(alloc));
    try arr.items[0].append(1);
    try arr.items[0].append(2);
    try arr.items[0].append(3);
    try arr.append(ArrayList(i32).init(alloc));
    try arr.items[1].append(4);
    try arr.items[1].append(5);
    try arr.items[1].append(6);
    defer for (arr.items) |row| {
        row.deinit();
    };
    const mat = try mat_sys.addCopyFrom2DArrayList(&arr);
    try testing.expectEqual(mat.n_rows, 2);
    try testing.expectEqual(mat.n_cols, 3);
    try testing.expectEqual(mat.start_index, 0);
    try testing.expectEqual(@as(i32, 1), mat.sys_ptr.data.items[0]);
    try testing.expectEqual(@as(i32, 2), mat.sys_ptr.data.items[1]);
    try testing.expectEqual(@as(i32, 3), mat.sys_ptr.data.items[2]);
    try testing.expectEqual(@as(i32, 4), mat.sys_ptr.data.items[3]);
    try testing.expectEqual(@as(i32, 5), mat.sys_ptr.data.items[4]);
    try testing.expectEqual(@as(i32, 6), mat.sys_ptr.data.items[5]);
    std.debug.print("Testing add from 2D array list ... OK\n", .{});
}

test "add from 2D array list empty matrix" {
    const alloc = std.testing.allocator;
    var mat_sys = try MatSys(i32).init(alloc);
    defer mat_sys.deinit();
    var arr = ArrayList(ArrayList(i32)).init(alloc);
    defer arr.deinit();
    const mat = mat_sys.addCopyFrom2DArrayList(&arr);
    try testing.expectError(error.EmptyMatrix, mat);
    std.debug.print("Testing add from 2D array list empty matrix ... OK\n", .{});
}

test "add from 2D array list empty col" {
    const alloc = std.testing.allocator;
    var mat_sys = try MatSys(i32).init(alloc);
    defer mat_sys.deinit();
    var arr = ArrayList(ArrayList(i32)).init(alloc);
    defer arr.deinit();
    try arr.append(ArrayList(i32).init(alloc));
    const mat = mat_sys.addCopyFrom2DArrayList(&arr);
    try testing.expectError(error.EmptyCol, mat);
    std.debug.print("Testing add from 2D array list empty col ... OK\n", .{});
}

test "add from 2D array list inconsistent cols" {
    const alloc = std.testing.allocator;
    var mat_sys = try MatSys(i32).init(alloc);
    defer mat_sys.deinit();
    var arr = ArrayList(ArrayList(i32)).init(alloc);
    defer arr.deinit();
    try arr.append(ArrayList(i32).init(alloc));
    try arr.items[0].append(1);
    try arr.append(ArrayList(i32).init(alloc));
    try arr.items[1].append(1);
    try arr.items[1].append(2);
    defer for (arr.items) |row| {
        row.deinit();
    };
    const mat = mat_sys.addCopyFrom2DArrayList(&arr);
    try testing.expectError(error.InconsistentCols, mat);
}
