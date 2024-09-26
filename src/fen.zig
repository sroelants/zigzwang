const std = @import("std");
const Color = @import("piece.zig").Color;
const Piece = @import("piece.zig").Piece;
const Square = @import("square.zig").Square;
const CastlingRights = @import("castling.zig").CastlingRights;
const Board = @import("board.zig").Board;

pub fn parseFen(fen: []const u8) !Board {
    var board = Board.empty();
    var parts = std.mem.splitScalar(u8, fen, ' ');

    // Parse board
    const board_str = parts.next().?;
    var rows = std.mem.splitScalar(u8, board_str, '/');

    while (rows.next()) |row| {
        std.debug.print("{s}\n", .{row});
    }

    // Parse stm
    const color_str = parts.next().?;
    board.stm = try Color.parse(color_str[0]);

    // Parse castling rights
    const castling_str = parts.next().?;
    board.crights = try CastlingRights.parse(castling_str);

    // Parse EP
    const ep_str = parts.next().?;
    if (ep_str[0] != '-') {
        board.ep = try Square.parse(ep_str);
    }

    // Parse halfmove counter
    const halfmoves_str = parts.next().?;
    board.halfmoves = try std.fmt.parseUnsigned(u8, halfmoves_str, 10);

    // Parse fullmove counter
    const fullmoves_str = parts.next().?;
    board.fullmoves = try std.fmt.parseUnsigned(u8, fullmoves_str, 10);

    return board;
}
