pub const Castle = enum {
    wq,
    wk,
    bq,
    bk,

    /// Parse a color string (e.g., 'Q', 'k') into a Castle value.
    /// Returns an error if an invalid character was passed in.
    pub fn parse(ch: u8) !Castle {
        return switch (ch) {
            'Q' => Castle.wq,
            'K' => Castle.wk,
            'q' => Castle.bq,
            'k' => Castle.bk,
            else => error.IllegalCastleString,
        };
    }
};

pub const CastlingRights = struct {
    rights: [4]bool,

    pub fn new() CastlingRights {
        return .{ .rights = .{ false, false, false, false } };
    }

    /// Parse a castling string into a CastlingRights value.
    pub fn parse(s: []const u8) !CastlingRights {
        var rights = CastlingRights.new();

        if (s[0] == '-') {
            return rights;
        }

        for (s) |ch| {
            const ctype = try Castle.parse(ch);
            rights.rights[@intFromEnum(ctype)] = true;
        }

        return rights;
    }
};
