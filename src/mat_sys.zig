const std = @import("std");
const testing = std.testing;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

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
    };
}

test "initCapacity" {
    const alloc = std.testing.allocator;
    var mat_sys = try MatSys(i32).initCapacity(alloc, 10);
    defer mat_sys.deinit();
    try mat_sys.data.append(42);
    try testing.expectEqual(@as(i32, 42), mat_sys.data.pop());
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
}
