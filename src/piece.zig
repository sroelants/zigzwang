pub const Color = enum(u1) {
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

    pub fn idx(self: Color) usize {
        return @intFromEnum(self);
    }
};

pub const Piece = enum(u4) {
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

    pub fn idx(self: Piece) usize {
        return @intFromEnum(self);
    }

    pub fn piece_type(piece: Piece) PieceType {
        const ptype_idx = @as(u3, @intCast(@intFromEnum(piece) >> 1));
        return @enumFromInt(ptype_idx);
    }

    pub fn color(piece: Piece) Color {
        const color_idx = @as(u1, @intCast(@intFromEnum(piece) & 1));
        return @enumFromInt(color_idx);
    }
};

pub const PieceType = enum(u3) {
    // zig fmt: off
    pawn, knight, bishop, rook, queen, king,
    // zig fmt: on
    //
    pub fn idx(self: PieceType) usize {
        return @intFromEnum(self);
    }
};
