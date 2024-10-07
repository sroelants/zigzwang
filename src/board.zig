const main = @import("main.zig");
const piece = @import("piece.zig");
const square = @import("square.zig");
const castling = @import("castling.zig");
const Bitboard = @import("bitboard.zig").Bitboard;

pub const Board = struct {
    stm: piece.Color,
    occupied: [2]Bitboard,
    bbs: [6]Bitboard,
    halfmoves: u8,
    fullmoves: u8,
    crights: castling.CastlingRights,
    ep: ?square.Square,

    pub fn empty() Board {
        return .{
            .stm = piece.Color.white,
            .occupied = .{ Bitboard.empty(), Bitboard.empty() },
            .bbs = .{
                Bitboard.empty(),
                Bitboard.empty(),
                Bitboard.empty(),
                Bitboard.empty(),
                Bitboard.empty(),
                Bitboard.empty(),
            },
            .halfmoves = 0,
            .fullmoves = 0,
            .crights = castling.CastlingRights.new(),
            .ep = null,
        };
    }
};
