const std = @import("std");
const fen = @import("fen.zig");
const testing = std.testing;
const Board = @import("./board.zig").Board;
const Square = @import("./square.zig").Square;
const CastlingRights = @import("./castling.zig").CastlingRights;
const Piece = @import("./piece.zig").Piece;

pub fn main() !void {
    const board = try fen.parseFen("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1");

    std.debug.print("{}", .{board});
}

test "parse piece" {
    try testing.expectEqual(Piece.parse('K'), Piece.wk);
}

test "parse illegal piece" {
    try testing.expectError(error.IllegalPieceString, Piece.parse('L'));
}

test "parse startpos fen" {
    const board = try fen.parseFen("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1");

    try std.testing.expectEqual(board.stm, .white);
    try std.testing.expectEqual(board.crights, CastlingRights{ .rights = .{ true, true, true, true } });
    try std.testing.expectEqual(board.ep, null);
    try std.testing.expectEqual(board.halfmoves, 0);
    try std.testing.expectEqual(board.fullmoves, 1);
}

test "parse arbitrary fen" {
    const board = try fen.parseFen("r2q1rk1/pP1p2pp/Q4n2/bbp1p3/Np6/1B3NBn/pPPP1PPP/R3K2R b KQ e3 0 1 ");

    try std.testing.expectEqual(board.stm, .black);
    try std.testing.expectEqual(board.crights, CastlingRights{ .rights = .{ true, true, false, false } });
    try std.testing.expectEqual(board.ep, Square.e3);
    try std.testing.expectEqual(board.halfmoves, 0);
    try std.testing.expectEqual(board.fullmoves, 1);
}
