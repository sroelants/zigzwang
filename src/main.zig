const std = @import("std");
const fen = @import("fen.zig");
const testing = std.testing;
const Board = @import("./board.zig").Board;
const Square = @import("./square.zig").Square;
const CastlingRights = @import("./castling.zig").CastlingRights;
const Piece = @import("./piece.zig").Piece;
const Kindergarten = @import("./kindergarten.zig");
const Bitboard = @import("./bitboard.zig").Bitboard;

pub fn main() !void {
    Kindergarten.init();

    const board = try fen.parseFen("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1");

    std.debug.print("{}", .{board});
}

test "kindergarten queen move generation" {
    Kindergarten.init();

    const testCases = [_]struct {
        square: Square,
        occupancy: Bitboard,
        expected: Bitboard,
    }{
        .{ .square = Square.from_idx(27) orelse unreachable, .occupancy = Bitboard.fromInt(4547872720945168), .expected = Bitboard.fromInt(44101632010312) },
        .{ .square = Square.from_idx(26) orelse unreachable, .occupancy = Bitboard.fromInt(4547872720945168), .expected = Bitboard.fromInt(4620711970483343648) },
        .{ .square = Square.from_idx(28) orelse unreachable, .occupancy = Bitboard.fromInt(4547872720945168), .expected = Bitboard.fromInt(113245540908029074) },
        .{ .square = Square.from_idx(36) orelse unreachable, .occupancy = Bitboard.fromInt(4547872720945168), .expected = Bitboard.fromInt(4565637075832848) },
        .{ .square = Square.from_idx(44) orelse unreachable, .occupancy = Bitboard.fromInt(4547872720945168), .expected = Bitboard.fromInt(4915723215677034768) },
        .{ .square = Square.from_idx(3) orelse unreachable, .occupancy = Bitboard.fromInt(4547872720945168), .expected = Bitboard.fromInt(9381436070935) },
        .{ .square = Square.from_idx(49) orelse unreachable, .occupancy = Bitboard.fromInt(4547872720945168), .expected = Bitboard.fromInt(512573672425275520) },
        .{ .square = Square.from_idx(63) orelse unreachable, .occupancy = Bitboard.fromInt(4547872720945168), .expected = Bitboard.fromInt(9205534112117457024) },
        .{ .square = Square.from_idx(7) orelse unreachable, .occupancy = Bitboard.fromInt(4547872720945168), .expected = Bitboard.fromInt(9332167099941961840) },
        .{ .square = Square.from_idx(13) orelse unreachable, .occupancy = Bitboard.fromInt(4547872720945168), .expected = Bitboard.fromInt(20005838704) },
    };

    for (testCases) |testCase| {
        const result = Kindergarten.queen(testCase.square, testCase.occupancy);
        try testing.expect(result.equals(testCase.expected));
    }
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
