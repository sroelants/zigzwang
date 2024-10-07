const std = @import("std");
const Square = @import("square.zig").Square;

pub const Bitboard = struct {
    val: u64,

    pub fn empty() Bitboard {
        return .{ .val = 0 };
    }

    /// Format a bitboard
    pub fn format(
        self: Bitboard,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;

        for (0..64) |i| {
            if (self.val & (@as(u64, 1) << @truncate(i)) > 0) {
                try writer.writeAll("x");
            } else {
                try writer.writeAll(".");
            }

            if (i % 8 == 7) {
                try writer.writeAll("\n");
            }
        }
    }
};

pub const BitboardIterator = struct {
    remaining: u64,

    pub fn next(self: BitboardIterator) ?Square {
        if (self.remaining == 0) {
            return null;
        }

        const lsb: u8 = @ctz(self.remaining);
        self.remaining &= self.remaining - 1;
        return Square.from_idx(lsb);
    }
};