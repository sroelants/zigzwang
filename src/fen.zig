const std = @import("std");
const Color = @import("piece.zig").Color;
const Piece = @import("piece.zig").Piece;
const Square = @import("square.zig").Square;
const CastlingRights = @import("castling.zig").CastlingRights;
const Board = @import("board.zig").Board;
const Bitboard = @import("bitboard.zig").Bitboard;

/// Parse a fen string into a Board struct
///
/// Returns an error on invalid FEN strings
pub fn parseFen(fen: []const u8) !Board {
    var board = Board.empty();
    var parts = std.mem.splitScalar(u8, fen, ' ');

    // Parse board
    const board_str = parts.next().?;

    // Iterate the fen string backwards, because idx 0 is bottom-left for us.
    var rows = std.mem.splitBackwardsScalar(u8, board_str, '/');

    // Start at the bottom-left, at index 0.
    var sq_idx: usize = 0;

    // Parse rows
    while (rows.next()) |row| {
        for (row) |ch| {
            if (Piece.parse(ch)) |piece| {
                std.debug.print("Square idx is now: {}\n", .{sq_idx});
                const sq: Square = Square.from_idx(sq_idx).?;
                const bb = sq.bb();
                const ptype = piece.piece_type();
                const color = piece.color();

                board.bbs[ptype.idx()].val |= bb.val;
                board.occupied[color.idx()].val |= bb.val;
                sq_idx += 1;
            } else |_| {}

            const str: [1]u8 = .{ch};

            if (std.fmt.parseUnsigned(u6, &str, 10)) |gap| {
                sq_idx += gap;
            } else |_| {}
        }
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
