const std = @import("std");
const Square = @import("square.zig").Square;
const Bitboard = @import("bitboard.zig").Bitboard;

pub const HashKeyType = enum {
    Rank,
    File,
    Diagonal,
    AntiDiagonal,
};

const MaskType = enum {
    Diagonal,
    Antidiagonal,
};

var diagonal_mask: [64]Bitboard = undefined;
var antidiagonal_mask: [64]Bitboard = undefined;
var rank_attack_table: [64][64]Bitboard = undefined;
var file_attack_table: [64][64]Bitboard = undefined;
var diagonal_attack_table: [64][64]Bitboard = undefined;
var anti_diagonal_attack_table: [64][64]Bitboard = undefined;
var rank_offset_table: [64]Square = undefined;

const diagonal_magic: Bitboard = .{ .val = 0x80402010080400 };
const file_magic: Bitboard = .{ .val = 0x2020202020200 };
const first_file_mask: Bitboard = .{ .val = 0x101010101010101 };

fn generateRankOffsetTable() void {
    var idx: usize = 0;
    while (idx < 64) : (idx += 1) {
        if (Square.from_idx(@divFloor(idx, 8) * 8 + 1)) |square| {
            rank_offset_table[idx] = square;
        }
    }
}

fn generateDiagonalMasks(mask_type: MaskType) void {
    var idx: usize = 0;
    while (idx < 64) : (idx += 1) {
        const file: i32 = @intCast(@mod(idx, 8));
        const rank: i32 = @intCast(@divFloor(idx, 8));
        var bitboard = Bitboard.empty();
        var i: i32 = -7;
        while (i <= 7) : (i += 1) {
            const r = rank + i;
            const f = switch (mask_type) {
                .Diagonal => file + i,
                .Antidiagonal => file - i,
            };
            if (r >= 0 and r < 8 and f >= 0 and f < 8) {
                if (Square.from_idx(@intCast(r * 8 + f))) |square| {
                    bitboard = bitboard._or(square.bb());
                }
            }
        }
        switch (mask_type) {
            .Diagonal => diagonal_mask[idx] = bitboard,
            .Antidiagonal => antidiagonal_mask[idx] = bitboard,
        }
    }
}

fn hashkeyRank(square: Square, occupancy: Bitboard) Square {
    const shift_val = @intFromEnum(rank_offset_table[@intFromEnum(square)]);
    return Square.from_idx(@truncate((occupancy.val >> shift_val) & 0x3F)) orelse Square.a1;
}

fn hashkeyFile(square: Square, occupancy: Bitboard) Square {
    const val = (((occupancy.val >> @mod(@intFromEnum(square), 8)) & first_file_mask.val) *% diagonal_magic.val) >> 58;
    return Square.from_idx(@truncate(val)) orelse Square.a1;
}

fn hashkeyDiagonal(square: Square, occupancy: Bitboard) Square {
    const val = ((occupancy._and(diagonal_mask[@intFromEnum(square)]).val) *% file_magic.val) >> 58;
    return Square.from_idx(@truncate(val)) orelse Square.a1;
}

fn hashkeyAntiDiagonal(square: Square, occupancy: Bitboard) Square {
    const val = ((occupancy._and(antidiagonal_mask[@intFromEnum(square)]).val) *% file_magic.val) >> 58;
    return Square.from_idx(@truncate(val)) orelse Square.a1;
}

const Direction = struct {
    first: i8,
    second: i8,
};

fn occForSquare(hash_key: Square, square: Square, dirs: Direction, hash_key_type: HashKeyType) Bitboard {
    var result = Bitboard.empty();
    for ([_]i8{ dirs.first, dirs.second }) |dir| {
        var cur: i8 = @intCast(@intFromEnum(square));
        while (true) {
            cur += dir;
            if (cur >= 64 or cur < 0 or @abs(@mod(cur, 8) - @mod(cur - dir, 8)) >= 2) {
                break;
            }
            if (Square.from_idx(@intCast(cur))) |cur_square| {
                const bit = cur_square.bb();
                result = result._or(bit);

                const hash_key_result = switch (hash_key_type) {
                    .Rank => hashkeyRank(cur_square, bit),
                    .File => hashkeyFile(cur_square, bit),
                    .Diagonal => hashkeyDiagonal(cur_square, bit),
                    .AntiDiagonal => hashkeyAntiDiagonal(cur_square, bit),
                };

                if (@intFromEnum(hash_key_result) & @intFromEnum(hash_key) != 0) {
                    break;
                }
            }
        }
    }
    return result;
}

fn generateAttackTable(dirs: Direction, hash_key_type: HashKeyType, table: *[64][64]Bitboard) void {
    var square_idx: usize = 0;
    while (square_idx < 64) : (square_idx += 1) {
        if (Square.from_idx(square_idx)) |square| {
            var hash_key_idx: usize = 0;
            while (hash_key_idx < 64) : (hash_key_idx += 1) {
                if (Square.from_idx(hash_key_idx)) |hash_key| {
                    table[square_idx][hash_key_idx] = occForSquare(hash_key, square, dirs, hash_key_type);
                }
            }
        }
    }
}

pub fn init() void {
    generateRankOffsetTable();
    generateDiagonalMasks(.Diagonal);
    generateDiagonalMasks(.Antidiagonal);
    generateAttackTable(Direction{ .first = -1, .second = 1 }, .Rank, &rank_attack_table);
    generateAttackTable(Direction{ .first = -8, .second = 8 }, .File, &file_attack_table);
    generateAttackTable(Direction{ .first = -9, .second = 9 }, .Diagonal, &diagonal_attack_table);
    generateAttackTable(Direction{ .first = -7, .second = 7 }, .AntiDiagonal, &anti_diagonal_attack_table);
}

pub fn bishopDiagonal(square: Square, occupancy: Bitboard) Bitboard {
    return diagonal_attack_table[@intFromEnum(square)][@intFromEnum(hashkeyDiagonal(square, occupancy))];
}

pub fn bishopAntidiagonal(square: Square, occupancy: Bitboard) Bitboard {
    return anti_diagonal_attack_table[@intFromEnum(square)][@intFromEnum(hashkeyAntiDiagonal(square, occupancy))];
}

pub fn rookHorizontal(square: Square, occupancy: Bitboard) Bitboard {
    return rank_attack_table[@intFromEnum(square)][@intFromEnum(hashkeyRank(square, occupancy))];
}

pub fn rookVertical(square: Square, occupancy: Bitboard) Bitboard {
    return file_attack_table[@intFromEnum(square)][@intFromEnum(hashkeyFile(square, occupancy))];
}

pub fn bishop(square: Square, occupancy: Bitboard) Bitboard {
    return bishopDiagonal(square, occupancy)._or(bishopAntidiagonal(square, occupancy));
}

pub fn rook(square: Square, occupancy: Bitboard) Bitboard {
    return rookHorizontal(square, occupancy)._or(rookVertical(square, occupancy));
}

pub fn queen(square: Square, occupancy: Bitboard) Bitboard {
    return rook(square, occupancy)._or(bishop(square, occupancy));
}
