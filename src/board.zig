const main = @import("main.zig");

pub const Bitboard = u64;

pub const Board = struct {
    stm: main.Color,
    occupied: [2]main.Bitboard,
    pawns: main.Bitboard,
    knights: main.Bitboard,
    bishops: main.Bitboard,
    rooks: main.Bitboard,
    queens: main.Bitboard,
    kings: main.Bitboard,
    halfmoves: u8,
    fullmoves: u8,
    crights: main.CastlingRights,
    ep: ?main.Square,

    pub fn empty() Board {
        return .{
            .stm = main.Color.white,
            .occupied = .{ 0, 0 },
            .pawns = 0,
            .knights = 0,
            .bishops = 0,
            .rooks = 0,
            .queens = 0,
            .kings = 0,
            .halfmoves = 0,
            .fullmoves = 0,
            .crights = main.CastlingRights.new(),
            .ep = null,
        };
    }
};
