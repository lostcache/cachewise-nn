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
    };
}

test "initCapacity" {
    const alloc = std.testing.allocator;
    var mat = try MatSys(i32).initCapacity(alloc, 10);
    defer mat.deinit();
    try mat.data.append(42);
    try testing.expectEqual(@as(i32, 42), mat.data.pop());
}

test "init" {
    const alloc = std.testing.allocator;
    var mat = try MatSys(i32).init(alloc);
    defer mat.deinit();
    try mat.data.append(42);
    try testing.expectEqual(@as(i32, 42), mat.data.pop());
}
