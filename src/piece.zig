pub const Color = enum {
    white,
    black,

    /// Parse a color string (e.g., 'w', 'b') into a Color value.
    /// Returns an error if an invalid character was passed in.
    pub fn parse(ch: u8) !Color {
        return switch (ch) {
            'w' => Color.white,
            'b' => Color.black,
            else => error.IllegalColorString,
        };
    }
};

pub const Piece = enum {
    // zig fmt: off
    wp, bp, wn, bn, wb, bb, wr, br, wq, bq, wk, bk,
    // zig fmt: on

    /// Parse a piece string (e.g., 'P', 'N', 'q') into a Piece value.
    /// Returns an error if an invalid character was passed in.
    pub fn parse(ch: u8) !Piece {
        return switch (ch) {
            'P' => Piece.wp,
            'p' => Piece.bp,
            'N' => Piece.wn,
            'n' => Piece.bn,
            'B' => Piece.wb,
            'b' => Piece.bb,
            'R' => Piece.wr,
            'r' => Piece.br,
            'Q' => Piece.wq,
            'q' => Piece.bq,
            'K' => Piece.wk,
            'k' => Piece.bk,
            else => error.IllegalPieceString,
        };
    }
};

pub const PieceType = enum {
    // zig fmt: off
    pawn, knight, bishop, rook, queen, king 
    // zig fmt: on
};
