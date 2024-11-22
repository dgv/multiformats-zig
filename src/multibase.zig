const std = @import("std");

pub const DecodeError = error{
    InvalidChar,
    InvalidBaseString,
};

pub const Base = enum {
    Identity,
    Base2,
    Base8,
    Base10,
    Base16Lower,
    Base16Upper,
    Base32Lower,
    Base32Upper,
    Base32PadLower,
    Base32PadUpper,
    Base32HexLower,
    Base32HexUpper,
    Base32HexPadLower,
    Base32HexPadUpper,
    Base32Z,
    Base36Lower,
    Base36Upper,
    Base58Flickr,
    Base58Btc,
    Base64,
    Base64Pad,
    Base64Url,
    Base64UrlPad,
    Base256Emoji,

    pub fn code(self: Base) []const u8 {
        return switch (self) {
            .Identity => "\x00",
            .Base2 => "0",
            .Base8 => "7",
            .Base10 => "9",
            .Base16Lower => "f",
            .Base16Upper => "F",
            .Base32Lower => "b",
            .Base32Upper => "B",
            .Base32PadLower => "c",
            .Base32PadUpper => "C",
            .Base32HexLower => "v",
            .Base32HexUpper => "V",
            .Base32HexPadLower => "t",
            .Base32HexPadUpper => "T",
            .Base32Z => "h",
            .Base36Lower => "k",
            .Base36Upper => "K",
            .Base58Flickr => "Z",
            .Base58Btc => "z",
            .Base64 => "m",
            .Base64Pad => "M",
            .Base64Url => "u",
            .Base64UrlPad => "U",
            .Base256Emoji => "🚀",
        };
    }

    pub fn encode(self: Base, dest: []u8, source: []const u8) []const u8 {
        const code_str = self.code();
        @memcpy(dest[0..code_str.len], code_str);

        const encoded = switch (self) {
            .Identity => identity.encode(dest[code_str.len..], source),
            .Base2 => base2.encode(dest[code_str.len..], source),
            .Base8 => base8.encode(dest[code_str.len..], source),
            .Base10 => base10.encode(dest[code_str.len..], source),
            .Base16Lower => base16.encodeLower(dest[code_str.len..], source),
            .Base16Upper => base16.encodeUpper(dest[code_str.len..], source),
            .Base32Lower => base32.encode(dest[code_str.len..], source, base32.ALPHABET_LOWER, false),
            .Base32Upper => base32.encode(dest[code_str.len..], source, base32.ALPHABET_UPPER, false),
            .Base32HexLower => base32.encode(dest[code_str.len..], source, base32.ALPHABET_HEX_LOWER, false),
            .Base32HexUpper => base32.encode(dest[code_str.len..], source, base32.ALPHABET_HEX_UPPER, false),
            .Base32PadLower => base32.encode(dest[code_str.len..], source, base32.ALPHABET_LOWER, true),
            .Base32PadUpper => base32.encode(dest[code_str.len..], source, base32.ALPHABET_UPPER, true),
            .Base32HexPadLower => base32.encode(dest[code_str.len..], source, base32.ALPHABET_HEX_LOWER, true),
            .Base32HexPadUpper => base32.encode(dest[code_str.len..], source, base32.ALPHABET_HEX_UPPER, true),
            .Base32Z => base32.encode(dest[code_str.len..], source, base32.ALPHABET_Z, false),
            .Base36Lower => base36.encodeLower(dest[code_str.len..], source),
            .Base36Upper => base36.encodeUpper(dest[code_str.len..], source),
            .Base58Flickr => base58.encodeFlickr(dest[code_str.len..], source),
            .Base58Btc => base58.encodeBtc(dest[code_str.len..], source),
            .Base64 => std.base64.standard_no_pad.Encoder.encode(dest[code_str.len..], source),
            .Base64Pad => std.base64.standard.Encoder.encode(dest[code_str.len..], source),
            .Base64Url => std.base64.url_safe_no_pad.Encoder.encode(dest[code_str.len..], source),
            .Base64UrlPad => std.base64.url_safe.Encoder.encode(dest[code_str.len..], source),
            .Base256Emoji => base256emoji.encode(dest[code_str.len..], source),
        };

        return dest[0 .. code_str.len + encoded.len];
    }

    pub fn decode(self: Base, dest: []u8, source: []const u8) ![]const u8 {
        return switch (self) {
            .Identity => identity.decode(dest, source),
            .Base2 => base2.decode(dest, source),
            .Base8 => base8.decode(dest, source),
            .Base10 => base10.decode(dest, source),
            .Base16Lower => base16.decode(dest, source),
            .Base16Upper => base16.decode(dest, source),
            .Base32Lower => base32.decode(dest, source, &base32.DECODE_TABLE_LOWER),
            .Base32Upper => base32.decode(dest, source, &base32.DECODE_TABLE_UPPER),
            .Base32HexLower => base32.decode(dest, source, &base32.DECODE_TABLE_HEX_LOWER),
            .Base32HexUpper => base32.decode(dest, source, &base32.DECODE_TABLE_HEX_UPPER),
            .Base32PadLower => base32.decode(dest, source, &base32.DECODE_TABLE_LOWER),
            .Base32PadUpper => base32.decode(dest, source, &base32.DECODE_TABLE_UPPER),
            .Base32HexPadLower => base32.decode(dest, source, &base32.DECODE_TABLE_HEX_LOWER),
            .Base32HexPadUpper => base32.decode(dest, source, &base32.DECODE_TABLE_HEX_UPPER),
            .Base32Z => base32.decode(dest, source, &base32.DECODE_TABLE_Z),
            .Base36Lower => base36.decode(dest, source, base36.ALPHABET_LOWER),
            .Base36Upper => base36.decode(dest, source, base36.ALPHABET_UPPER),
            .Base58Flickr => base58.decodeFlickr(dest, source),
            .Base58Btc => base58.decodeBtc(dest, source),
            .Base64 => blk: {
                try std.base64.standard_no_pad.Decoder.decode(dest, source);
                break :blk dest[0..try std.base64.standard_no_pad.Decoder.calcSizeForSlice(source)];
            },
            .Base64Pad => blk: {
                try std.base64.standard.Decoder.decode(dest, source);
                break :blk dest[0..try std.base64.standard.Decoder.calcSizeForSlice(source)];
            },
            .Base64Url => blk: {
                try std.base64.url_safe_no_pad.Decoder.decode(dest, source);
                break :blk dest[0..try std.base64.url_safe_no_pad.Decoder.calcSizeForSlice(source)];
            },
            .Base64UrlPad => blk: {
                try std.base64.url_safe.Decoder.decode(dest, source);
                break :blk dest[0..try std.base64.url_safe.Decoder.calcSizeForSlice(source)];
            },
            .Base256Emoji => base256emoji.decode(dest, source),
        };
    }

    const identity = struct {
        pub fn encode(dest: []u8, source: []const u8) []const u8 {
            @memcpy(dest[0..source.len], source);
            return dest[0..source.len];
        }

        pub fn decode(dest: []u8, source: []const u8) ![]const u8 {
            @memcpy(dest[0..source.len], source);
            return dest[0..source.len];
        }
    };

    const base2 = struct {
        const Vec = @Vector(16, u8);
        const ascii_zero: Vec = @splat('0');
        const ascii_one: Vec = @splat('1');

        pub fn encode(dest: []u8, source: []const u8) []const u8 {
            var dest_index: usize = 0;
            var i: usize = 0;

            // Process 2 bytes at once using unrolled loops
            while (i + 2 <= source.len) : (i += 2) {
                const value = @as(u16, source[i]) << 8 | source[i + 1];

                // Unrolled loop for first byte
                inline for (0..8) |j| {
                    dest[dest_index + j] = '0' + @as(u8, @truncate((value >> (15 - j)) & 1));
                }
                // Unrolled loop for second byte
                inline for (0..8) |j| {
                    dest[dest_index + j + 8] = '0' + @as(u8, @truncate((value >> (7 - j)) & 1));
                }
                dest_index += 16;
            }

            // Handle remaining byte if any
            if (i < source.len) {
                const byte = source[i];
                inline for (0..8) |j| {
                    dest[dest_index + j] = '0' + @as(u8, @truncate((byte >> (7 - j)) & 1));
                }
                dest_index += 8;
            }

            return dest[0..dest_index];
        }

        pub fn decode(dest: []u8, source: []const u8) ![]const u8 {
            var dest_index: usize = 0;
            var i: usize = 0;

            // Validate input using SIMD
            while (i + 16 <= source.len) : (i += 16) {
                const chunk = @as(Vec, source[i..][0..16].*);
                const is_valid = @reduce(.And, chunk >= ascii_zero) and
                    @reduce(.And, chunk <= ascii_one);
                if (!is_valid) return error.InvalidChar;
            }

            // Process 16 bits (2 bytes) at once
            i = 0;
            while (i + 16 <= source.len) : (i += 16) {
                var value: u16 = 0;
                inline for (0..16) |j| {
                    value = (value << 1) | (source[i + j] - '0');
                }
                dest[dest_index] = @truncate(value >> 8);
                dest[dest_index + 1] = @truncate(value);
                dest_index += 2;
            }

            // Handle remaining bits
            var current_byte: u8 = 0;
            var bits: u4 = 0;
            while (i < source.len) : (i += 1) {
                const c = source[i];
                if (c < '0' or c > '1') return error.InvalidChar;

                current_byte = (current_byte << 1) | (c - '0');
                bits += 1;
                if (bits == 8) {
                    dest[dest_index] = current_byte;
                    dest_index += 1;
                    bits = 0;
                    current_byte = 0;
                }
            }

            if (bits > 0) {
                dest[dest_index] = current_byte << @as(u3, @intCast(8 - bits));
                dest_index += 1;
            }

            return dest[0..dest_index];
        }
    };

    const base8 = struct {
        const Vec = @Vector(16, u8);
        const ascii_zero: Vec = @splat('0');
        const ascii_seven: Vec = @splat('7');

        pub fn encode(dest: []u8, source: []const u8) []const u8 {
            var dest_index: usize = 0;
            var i: usize = 0;

            // Process 3 bytes at once (8 octal digits)
            while (i + 3 <= source.len) : (i += 3) {
                const value = (@as(u32, source[i]) << 16) |
                    (@as(u32, source[i + 1]) << 8) |
                    source[i + 2];

                inline for (0..8) |j| {
                    const shift = 21 - (j * 3);
                    const index = (value >> shift) & 0x7;
                    dest[dest_index + j] = '0' + @as(u8, @truncate(index));
                }
                dest_index += 8;
            }

            // Handle remaining bytes
            var bits: u16 = 0;
            var bit_count: u4 = 0;

            while (i < source.len) : (i += 1) {
                bits = (bits << 8) | source[i];
                bit_count += 8;

                while (bit_count >= 3) {
                    bit_count -= 3;
                    const index = (bits >> bit_count) & 0x7;
                    dest[dest_index] = '0' + @as(u8, @truncate(index));
                    dest_index += 1;
                }
            }

            if (bit_count > 0) {
                const index = (bits << (3 - bit_count)) & 0x7;
                dest[dest_index] = '0' + @as(u8, @truncate(index));
                dest_index += 1;
            }

            return dest[0..dest_index];
        }

        pub fn decode(dest: []u8, source: []const u8) DecodeError![]const u8 {
            var dest_index: usize = 0;
            var i: usize = 0;

            // Validate input using SIMD
            while (i + 16 <= source.len) : (i += 16) {
                const chunk = @as(Vec, source[i..][0..16].*);
                const is_valid = @reduce(.And, chunk >= ascii_zero) and
                    @reduce(.And, chunk <= ascii_seven);
                if (!is_valid) return DecodeError.InvalidChar;
            }

            // Process 8 octal digits (3 bytes) at once
            i = 0;
            while (i + 8 <= source.len) : (i += 8) {
                var value: u32 = 0;
                inline for (0..8) |j| {
                    value = (value << 3) | (source[i + j] - '0');
                }
                dest[dest_index] = @truncate(value >> 16);
                dest[dest_index + 1] = @truncate(value >> 8);
                dest[dest_index + 2] = @truncate(value);
                dest_index += 3;
            }

            // Handle remaining digits
            var bits: u16 = 0;
            var bit_count: u4 = 0;

            while (i < source.len) : (i += 1) {
                const c = source[i];
                if (c < '0' or c > '7') return DecodeError.InvalidChar;

                bits = (bits << 3) | (c - '0');
                bit_count += 3;

                if (bit_count >= 8) {
                    bit_count -= 8;
                    dest[dest_index] = @truncate(bits >> bit_count);
                    dest_index += 1;
                }
            }

            return dest[0..dest_index];
        }
    };

    const base10 = struct {
        pub fn encode(dest: []u8, source: []const u8) []const u8 {
            if (source.len == 0) {
                dest[0] = '0';
                return dest[0..1];
            }

            var dest_index: usize = 0;
            var num: [1024]u8 align(16) = undefined;
            var num_len: usize = 0;

            // Count leading zeros using SIMD
            const Vec = @Vector(16, u8);
            const zeros: Vec = @splat(0);
            var leading_zeros: usize = 0;

            while (leading_zeros + 16 <= source.len) {
                const chunk = @as(Vec, source[leading_zeros..][0..16].*);
                const is_zero = chunk == zeros;
                const zero_count = @popCount(@as(u16, @bitCast(is_zero)));
                if (zero_count != 16) break;
                leading_zeros += 16;
            }

            while (leading_zeros < source.len and source[leading_zeros] == 0) {
                leading_zeros += 1;
            }

            @memset(dest[0..leading_zeros], '0');
            dest_index += leading_zeros;

            // Convert bytes to decimal
            for (source) |byte| {
                var carry: u16 = byte;
                var j: usize = 0;
                while (j < num_len or carry > 0) : (j += 1) {
                    if (j < num_len) {
                        carry += @as(u16, num[j]) << 8;
                    }
                    num[j] = @truncate(carry % 10);
                    carry /= 10;
                }
                num_len = j;
            }

            // Convert to ASCII and reverse
            var i: usize = num_len;
            while (i > 0) : (i -= 1) {
                dest[dest_index] = '0' + num[i - 1];
                dest_index += 1;
            }

            return dest[0..dest_index];
        }

        pub fn decode(dest: []u8, source: []const u8) DecodeError![]const u8 {
            if (source.len == 0) return dest[0..0];

            var dest_index: usize = 0;
            var num: [1024]u8 align(16) = undefined;
            var num_len: usize = 0;

            // Count leading zeros using SIMD
            const Vec = @Vector(16, u8);
            const ascii_zero: Vec = @splat('0');
            const ascii_nine: Vec = @splat('9');
            var leading_zeros: usize = 0;

            // Validate digits using SIMD
            var i: usize = 0;
            while (i + 16 <= source.len) : (i += 16) {
                const chunk = @as(Vec, source[i..][0..16].*);
                const valid_digits = @reduce(.And, chunk >= ascii_zero) and @reduce(.And, chunk <= ascii_nine);
                if (!valid_digits) {
                    return DecodeError.InvalidChar;
                }
            }

            // Count leading zeros
            while (leading_zeros < source.len and source[leading_zeros] == '0') {
                leading_zeros += 1;
            }

            @memset(dest[0..leading_zeros], 0);
            dest_index += leading_zeros;

            // Convert decimal to bytes
            for (source) |c| {
                if (c < '0' or c > '9') return DecodeError.InvalidChar;

                var carry: u16 = c - '0';
                var j: usize = 0;
                while (j < num_len or carry > 0) : (j += 1) {
                    if (j < num_len) {
                        carry += @as(u16, num[j]) * 10;
                    }
                    num[j] = @truncate(carry);
                    carry >>= 8;
                }
                num_len = j;
            }

            // Copy and reverse
            i = num_len;
            while (i > 0) : (i -= 1) {
                dest[dest_index] = num[i - 1];
                dest_index += 1;
            }

            return dest[0..dest_index];
        }
    };

    const base16 = struct {
        const ALPHABET_LOWER = "0123456789abcdef";
        const ALPHABET_UPPER = "0123456789ABCDEF";
        const Vec = @Vector(16, u8);

        // Lookup tables for faster decoding
        const DECODE_TABLE = blk: {
            var table: [256]u8 = undefined;
            for (&table) |*v| v.* = 0xFF;
            for (0..16) |i| {
                table[ALPHABET_LOWER[i]] = @truncate(i);
                table[ALPHABET_UPPER[i]] = @truncate(i);
            }
            break :blk table;
        };

        pub fn encodeLower(dest: []u8, source: []const u8) []const u8 {
            var dest_index: usize = 0;
            var i: usize = 0;

            // Process 8 bytes (16 hex chars) at once
            while (i + 8 <= source.len) : (i += 8) {
                inline for (0..8) |j| {
                    const byte = source[i + j];
                    dest[dest_index + j * 2] = ALPHABET_LOWER[byte >> 4];
                    dest[dest_index + j * 2 + 1] = ALPHABET_LOWER[byte & 0x0F];
                }
                dest_index += 16;
            }

            // Handle remaining bytes
            while (i < source.len) : (i += 1) {
                const byte = source[i];
                dest[dest_index] = ALPHABET_LOWER[byte >> 4];
                dest[dest_index + 1] = ALPHABET_LOWER[byte & 0x0F];
                dest_index += 2;
            }

            return dest[0..dest_index];
        }

        pub fn encodeUpper(dest: []u8, source: []const u8) []const u8 {
            var dest_index: usize = 0;
            var i: usize = 0;

            // Process 8 bytes (16 hex chars) at once
            while (i + 8 <= source.len) : (i += 8) {
                inline for (0..8) |j| {
                    const byte = source[i + j];
                    dest[dest_index + j * 2] = ALPHABET_UPPER[byte >> 4];
                    dest[dest_index + j * 2 + 1] = ALPHABET_UPPER[byte & 0x0F];
                }
                dest_index += 16;
            }

            // Handle remaining bytes
            while (i < source.len) : (i += 1) {
                const byte = source[i];
                dest[dest_index] = ALPHABET_UPPER[byte >> 4];
                dest[dest_index + 1] = ALPHABET_UPPER[byte & 0x0F];
                dest_index += 2;
            }

            return dest[0..dest_index];
        }

        pub fn decode(dest: []u8, source: []const u8) DecodeError![]const u8 {
            if (source.len % 2 != 0) return DecodeError.InvalidChar;

            var dest_index: usize = 0;
            var i: usize = 0;

            // Process 16 hex chars (8 bytes) at once
            while (i + 16 <= source.len) : (i += 16) {
                inline for (0..8) |j| {
                    const high = DECODE_TABLE[source[i + j * 2]];
                    const low = DECODE_TABLE[source[i + j * 2 + 1]];
                    if (high == 0xFF or low == 0xFF) return DecodeError.InvalidChar;
                    dest[dest_index + j] = (high << 4) | low;
                }
                dest_index += 8;
            }

            // Handle remaining chars
            while (i < source.len) : (i += 2) {
                const high = DECODE_TABLE[source[i]];
                const low = DECODE_TABLE[source[i + 1]];
                if (high == 0xFF or low == 0xFF) return DecodeError.InvalidChar;
                dest[dest_index] = (high << 4) | low;
                dest_index += 1;
            }

            return dest[0..dest_index];
        }
    };

    const base32 = struct {
        const ALPHABET_LOWER = "abcdefghijklmnopqrstuvwxyz234567";
        const ALPHABET_UPPER = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";
        const ALPHABET_HEX_LOWER = "0123456789abcdefghijklmnopqrstuv";
        const ALPHABET_HEX_UPPER = "0123456789ABCDEFGHIJKLMNOPQRSTUV";
        const ALPHABET_Z = "ybndrfg8ejkmcpqxot1uwisza345h769";
        const PADDING = '=';

        // Pre-computed decode tables for each alphabet
        const DECODE_TABLE_LOWER = createDecodeTable(ALPHABET_LOWER);
        const DECODE_TABLE_UPPER = createDecodeTable(ALPHABET_UPPER);
        const DECODE_TABLE_HEX_LOWER = createDecodeTable(ALPHABET_HEX_LOWER);
        const DECODE_TABLE_HEX_UPPER = createDecodeTable(ALPHABET_HEX_UPPER);
        const DECODE_TABLE_Z = createDecodeTable(ALPHABET_Z);

        const DecodeTable = [256]u8;

        fn createDecodeTable(comptime alphabet: []const u8) DecodeTable {
            var table: DecodeTable = [_]u8{0xFF} ** 256;
            for (alphabet, 0..) |c, i| {
                table[c] = @truncate(i);
                // Also add lowercase variant for uppercase alphabets
                if (c >= 'A' and c <= 'Z') {
                    table[c + 32] = @truncate(i); // +32 converts to lowercase
                }
            }
            return table;
        }

        pub fn encode(dest: []u8, source: []const u8, alphabet: []const u8, pad: bool) []const u8 {
            var dest_index: usize = 0;
            var bits: u16 = 0;
            var bit_count: u4 = 0;

            // SIMD optimization for 8-byte chunks
            const Vec = @Vector(8, u8);
            const chunk_size = 8;
            const full_chunks = source.len / chunk_size;

            var i: usize = 0;
            while (i < full_chunks) : (i += 1) {
                const vec = @as(Vec, source[i * chunk_size ..][0..chunk_size].*);
                // Process 8 bytes at once using SIMD
                inline for (0..8) |j| {
                    const byte = vec[j];
                    bits = (bits << 8) | byte;
                    bit_count += 8;
                    while (bit_count >= 5) {
                        bit_count -= 5;
                        const index = (bits >> bit_count) & 0x1F;
                        dest[dest_index] = alphabet[index];
                        dest_index += 1;
                    }
                }
            }

            // Handle remaining bytes
            for (source[full_chunks * chunk_size ..]) |byte| {
                bits = (bits << 8) | byte;
                bit_count += 8;
                while (bit_count >= 5) {
                    bit_count -= 5;
                    const index = (bits >> bit_count) & 0x1F;
                    dest[dest_index] = alphabet[index];
                    dest_index += 1;
                }
            }

            if (bit_count > 0) {
                const index = (bits << (5 - bit_count)) & 0x1F;
                dest[dest_index] = alphabet[index];
                dest_index += 1;
            }

            if (pad) {
                const padding = (8 - dest_index % 8) % 8;
                @memset(dest[dest_index..][0..padding], PADDING);
                dest_index += padding;
            }

            return dest[0..dest_index];
        }

        pub fn decode(dest: []u8, source: []const u8, decode_table: *const [256]u8) DecodeError![]const u8 {
            var dest_index: usize = 0;
            var bits: u16 = 0;
            var bit_count: u4 = 0;

            for (source) |c| {
                if (c == PADDING) continue;

                const value = decode_table[c];
                if (value == 0xFF) return DecodeError.InvalidChar;

                bits = (bits << 5) | value;
                bit_count += 5;

                if (bit_count >= 8) {
                    bit_count -= 8;
                    dest[dest_index] = @truncate(bits >> bit_count);
                    dest_index += 1;
                }
            }

            return dest[0..dest_index];
        }
    };

    const base36 = struct {
        const ALPHABET_LOWER = "0123456789abcdefghijklmnopqrstuvwxyz";
        const ALPHABET_UPPER = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";

        pub fn encodeLower(dest: []u8, source: []const u8) []const u8 {
            if (source.len == 0) {
                dest[0] = '0';
                return dest[0..1];
            }

            var dest_index: usize = 0;
            var num: [1024]u8 = undefined;
            var num_len: usize = 0;

            // Handle leading zeros
            var leading_zeros: usize = 0;
            while (leading_zeros < source.len and source[leading_zeros] == 0) {
                leading_zeros += 1;
            }

            while (leading_zeros > 0) : (leading_zeros -= 1) {
                dest[dest_index] = '0';
                dest_index += 1;
            }

            // Convert bytes to base36
            for (source) |byte| {
                var carry: u16 = byte;
                var j: usize = 0;
                while (j < num_len or carry > 0) : (j += 1) {
                    if (j < num_len) {
                        carry += @as(u16, num[j]) << 8;
                    }
                    num[j] = @truncate(carry % 36);
                    carry /= 36;
                }
                num_len = j;
            }

            var i: usize = num_len;
            while (i > 0) : (i -= 1) {
                dest[dest_index] = ALPHABET_LOWER[num[i - 1]];
                dest_index += 1;
            }

            return dest[0..dest_index];
        }

        pub fn encodeUpper(dest: []u8, source: []const u8) []const u8 {
            if (source.len == 0) {
                dest[0] = '0';
                return dest[0..1];
            }

            var dest_index: usize = 0;
            var num: [1024]u8 = undefined;
            var num_len: usize = 0;

            // Handle leading zeros
            var leading_zeros: usize = 0;
            while (leading_zeros < source.len and source[leading_zeros] == 0) {
                leading_zeros += 1;
            }

            while (leading_zeros > 0) : (leading_zeros -= 1) {
                dest[dest_index] = '0';
                dest_index += 1;
            }

            // Convert bytes to base36
            for (source) |byte| {
                var carry: u16 = byte;
                var j: usize = 0;
                while (j < num_len or carry > 0) : (j += 1) {
                    if (j < num_len) {
                        carry += @as(u16, num[j]) << 8;
                    }
                    num[j] = @truncate(carry % 36);
                    carry /= 36;
                }
                num_len = j;
            }

            var i: usize = num_len;
            while (i > 0) : (i -= 1) {
                dest[dest_index] = ALPHABET_UPPER[num[i - 1]];
                dest_index += 1;
            }

            return dest[0..dest_index];
        }

        pub fn decode(dest: []u8, source: []const u8, alphabet: []const u8) DecodeError![]const u8 {
            if (source.len == 0) {
                return dest[0..0];
            }

            var dest_index: usize = 0;
            var num: [1024]u8 = undefined;
            var num_len: usize = 0;

            // Handle leading zeros
            var leading_zeros: usize = 0;
            while (leading_zeros < source.len and source[leading_zeros] == '0') {
                leading_zeros += 1;
            }

            while (leading_zeros > 0) : (leading_zeros -= 1) {
                dest[dest_index] = 0;
                dest_index += 1;
            }

            // Convert base36 to bytes
            for (source) |c| {
                const value = indexOf(alphabet, c) orelse return DecodeError.InvalidChar;
                var carry: u16 = value;
                var j: usize = 0;
                while (j < num_len or carry > 0) : (j += 1) {
                    if (j < num_len) {
                        carry += @as(u16, num[j]) * 36;
                    }
                    num[j] = @truncate(carry);
                    carry >>= 8;
                }
                num_len = j;
            }

            var i: usize = num_len;
            while (i > 0) : (i -= 1) {
                dest[dest_index] = num[i - 1];
                dest_index += 1;
            }

            return dest[0..dest_index];
        }

        fn indexOf(alphabet: []const u8, c: u8) ?u8 {
            for (alphabet, 0..) |char, i| {
                if (char == c) return @truncate(i);
            }
            return null;
        }
    };

    const base58 = struct {
        const ALPHABET_FLICKR = "123456789abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ";
        const ALPHABET_BTC = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz";

        pub fn encodeBtc(dest: []u8, source: []const u8) []const u8 {
            if (source.len == 0) {
                dest[0] = ALPHABET_BTC[0];
                return dest[0..1];
            }

            var dest_index: usize = 0;
            var num: [1024]u8 = undefined;
            var num_len: usize = 0;

            // Handle leading zeros
            var leading_zeros: usize = 0;
            while (leading_zeros < source.len and source[leading_zeros] == 0) {
                leading_zeros += 1;
            }

            while (leading_zeros > 0) : (leading_zeros -= 1) {
                dest[dest_index] = ALPHABET_BTC[0];
                dest_index += 1;
            }

            // Convert bytes to base58
            for (source) |byte| {
                var carry: u16 = byte;
                var j: usize = 0;
                while (j < num_len or carry > 0) : (j += 1) {
                    if (j < num_len) {
                        carry += @as(u16, num[j]) << 8;
                    }
                    num[j] = @truncate(carry % 58);
                    carry /= 58;
                }
                num_len = j;
            }

            var i: usize = num_len;
            while (i > 0) : (i -= 1) {
                dest[dest_index] = ALPHABET_BTC[num[i - 1]];
                dest_index += 1;
            }

            return dest[0..dest_index];
        }

        pub fn encodeFlickr(dest: []u8, source: []const u8) []const u8 {
            if (source.len == 0) {
                dest[0] = ALPHABET_FLICKR[0];
                return dest[0..1];
            }

            var dest_index: usize = 0;
            var num: [1024]u8 = undefined;
            var num_len: usize = 0;

            // Handle leading zeros
            var leading_zeros: usize = 0;
            while (leading_zeros < source.len and source[leading_zeros] == 0) {
                leading_zeros += 1;
            }

            while (leading_zeros > 0) : (leading_zeros -= 1) {
                dest[dest_index] = ALPHABET_FLICKR[0];
                dest_index += 1;
            }

            // Convert bytes to base58
            for (source) |byte| {
                var carry: u16 = byte;
                var j: usize = 0;
                while (j < num_len or carry > 0) : (j += 1) {
                    if (j < num_len) {
                        carry += @as(u16, num[j]) << 8;
                    }
                    num[j] = @truncate(carry % 58);
                    carry /= 58;
                }
                num_len = j;
            }

            var i: usize = num_len;
            while (i > 0) : (i -= 1) {
                dest[dest_index] = ALPHABET_FLICKR[num[i - 1]];
                dest_index += 1;
            }

            return dest[0..dest_index];
        }

        pub fn decodeBtc(dest: []u8, source: []const u8) DecodeError![]const u8 {
            if (source.len == 0) {
                return dest[0..0];
            }

            var dest_index: usize = 0;
            var num: [1024]u8 = undefined;
            var num_len: usize = 0;

            // Handle leading zeros
            var leading_zeros: usize = 0;
            while (leading_zeros < source.len and source[leading_zeros] == ALPHABET_BTC[0]) {
                leading_zeros += 1;
            }

            while (leading_zeros > 0) : (leading_zeros -= 1) {
                dest[dest_index] = 0;
                dest_index += 1;
            }

            // Convert base58 to bytes
            for (source) |c| {
                const value = indexOf(ALPHABET_BTC, c) orelse return DecodeError.InvalidChar;
                var carry: u16 = value;
                var j: usize = 0;
                while (j < num_len or carry > 0) : (j += 1) {
                    if (j < num_len) {
                        carry += @as(u16, num[j]) * 58;
                    }
                    num[j] = @truncate(carry);
                    carry >>= 8;
                }
                num_len = j;
            }

            var i: usize = num_len;
            while (i > 0) : (i -= 1) {
                dest[dest_index] = num[i - 1];
                dest_index += 1;
            }

            return dest[0..dest_index];
        }

        pub fn decodeFlickr(dest: []u8, source: []const u8) DecodeError![]const u8 {
            if (source.len == 0) {
                return dest[0..0];
            }

            var dest_index: usize = 0;
            var num: [1024]u8 = undefined;
            var num_len: usize = 0;

            // Handle leading zeros
            var leading_zeros: usize = 0;
            while (leading_zeros < source.len and source[leading_zeros] == ALPHABET_FLICKR[0]) {
                leading_zeros += 1;
            }

            while (leading_zeros > 0) : (leading_zeros -= 1) {
                dest[dest_index] = 0;
                dest_index += 1;
            }

            // Convert base58 to bytes
            for (source) |c| {
                const value = indexOf(ALPHABET_FLICKR, c) orelse return DecodeError.InvalidChar;
                var carry: u16 = value;
                var j: usize = 0;
                while (j < num_len or carry > 0) : (j += 1) {
                    if (j < num_len) {
                        carry += @as(u16, num[j]) * 58;
                    }
                    num[j] = @truncate(carry);
                    carry >>= 8;
                }
                num_len = j;
            }

            var i: usize = num_len;
            while (i > 0) : (i -= 1) {
                dest[dest_index] = num[i - 1];
                dest_index += 1;
            }

            return dest[0..dest_index];
        }

        fn indexOf(alphabet: []const u8, c: u8) ?u8 {
            for (alphabet, 0..) |char, i| {
                if (char == c) return @truncate(i);
            }
            return null;
        }
    };

    const base256emoji = struct {
        const ALPHABET = "🚀🪐☄🛰🌌🌑🌒🌓🌔🌕🌖🌗🌘🌍🌏🌎🐉☀💻🖥💾💿😂❤😍🤣😊🙏💕😭😘👍😅👏😁🔥🥰💔💖💙😢🤔😆🙄💪😉☺👌🤗💜😔😎😇🌹🤦🎉💞✌✨🤷😱😌🌸🙌😋💗💚😏💛🙂💓🤩😄😀🖤😃💯🙈👇🎶😒🤭❣😜💋👀😪😑💥🙋😞😩😡🤪👊🥳😥🤤👉💃😳✋😚😝😴🌟😬🙃🍀🌷😻😓⭐✅🥺🌈😈🤘💦✔😣🏃💐☹🎊💘😠☝😕🌺🎂🌻😐🖕💝🙊😹🗣💫💀👑🎵🤞😛🔴😤🌼😫⚽🤙☕🏆🤫👈😮🙆🍻🍃🐶💁😲🌿🧡🎁⚡🌞🎈❌✊👋😰🤨😶🤝🚶💰🍓💢🤟🙁🚨💨🤬✈🎀🍺🤓😙💟🌱😖👶🥴▶➡❓💎💸⬇😨🌚🦋😷🕺⚠🙅😟😵👎🤲🤠🤧📌🔵💅🧐🐾🍒😗🤑🌊🤯🐷☎💧😯💆👆🎤🙇🍑❄🌴💣🐸💌📍🥀🤢👅💡💩👐📸👻🤐🤮🎼🥵🚩🍎🍊👼💍📣🥂";

        const EMOJI_POSITIONS = init: {
            var table: [256]usize = undefined;
            var pos: usize = 0;
            var i: usize = 0;
            while (i < ALPHABET.len) {
                table[pos] = i;
                pos += 1;
                const len = (std.unicode.utf8ByteSequenceLength(ALPHABET[i]) catch unreachable);
                i += @as(usize, len);
            }
            break :init table;
        };

        const REVERSE_LOOKUP = blk: {
            @setEvalBranchQuota(10000);
            var table: [0x10FFFF]u8 = [_]u8{0xFF} ** 0x10FFFF;
            var pos: usize = 0; // Changed from u8 to usize
            var i: usize = 0;
            while (i < ALPHABET.len) {
                const len = (std.unicode.utf8ByteSequenceLength(ALPHABET[i]) catch unreachable);
                const codepoint = std.unicode.utf8Decode(ALPHABET[i..][0..@as(usize, len)]) catch unreachable;
                table[codepoint] = @truncate(pos); // Truncate pos to u8 when assigning
                pos += 1;
                i += @as(usize, len);
            }
            break :blk table;
        };

        pub fn encode(dest: []u8, source: []const u8) []const u8 {
            var dest_index: usize = 0;
            for (source) |byte| {
                const emoji_start = EMOJI_POSITIONS[byte];
                const emoji_len = @as(usize, std.unicode.utf8ByteSequenceLength(ALPHABET[emoji_start]) catch unreachable);
                @memcpy(dest[dest_index..][0..emoji_len], ALPHABET[emoji_start..][0..emoji_len]);
                dest_index += emoji_len;
            }
            return dest[0..dest_index];
        }

        pub fn decode(dest: []u8, source: []const u8) ![]const u8 {
            var dest_index: usize = 0;
            var i: usize = 0;
            while (i < source.len) {
                const len = @as(usize, std.unicode.utf8ByteSequenceLength(source[i]) catch return error.InvalidBaseString);
                const codepoint = std.unicode.utf8Decode(source[i..][0..len]) catch return error.InvalidBaseString;
                const byte = REVERSE_LOOKUP[codepoint];
                if (byte == 0xFF) return error.InvalidBaseString;
                dest[dest_index] = byte;
                dest_index += 1;
                i += len;
            }
            return dest[0..dest_index];
        }
    };
};

test "Base.encode/decode base2" {
    const testing = std.testing;
    {
        var dest: [256]u8 = undefined;
        const source = "\x00\x00yes mani !";
        const encoded = Base.Base2.encode(dest[0..], source);
        try testing.expectEqualStrings("0000000000000000001111001011001010111001100100000011011010110000101101110011010010010000000100001", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "0000000000000000001111001011001010111001100100000011011010110000101101110011010010010000000100001";
        const decoded = try Base.Base2.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("\x00\x00yes mani !", decoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "\x00yes mani !";
        const encoded = Base.Base2.encode(dest[0..], source);
        try testing.expectEqualStrings("00000000001111001011001010111001100100000011011010110000101101110011010010010000000100001", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "00000000001111001011001010111001100100000011011010110000101101110011010010010000000100001";
        const decoded = try Base.Base2.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("\x00yes mani !", decoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "yes mani !";
        const encoded = Base.Base2.encode(dest[0..], source);
        try testing.expectEqualStrings("001111001011001010111001100100000011011010110000101101110011010010010000000100001", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "001111001011001010111001100100000011011010110000101101110011010010010000000100001";
        const decoded = try Base.Base2.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("yes mani !", decoded);
    }
}

test "Base.encode/decode identity" {
    const testing = std.testing;

    {
        var dest: [256]u8 = undefined;
        const source = "yes mani !";
        const encoded = Base.Identity.encode(dest[0..], source);
        try testing.expectEqualStrings("\x00yes mani !", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "\x00yes mani !";
        const decoded = try Base.Identity.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("yes mani !", decoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "\x00yes mani !";
        const encoded = Base.Identity.encode(dest[0..], source);
        try testing.expectEqualStrings("\x00\x00yes mani !", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "\x00\x00yes mani !";
        const decoded = try Base.Identity.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("\x00yes mani !", decoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "\x00\x00yes mani !";
        const encoded = Base.Identity.encode(dest[0..], source);
        try testing.expectEqualStrings("\x00\x00\x00yes mani !", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "\x00\x00\x00yes mani !";
        const decoded = try Base.Identity.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("\x00\x00yes mani !", decoded);
    }
}

test "Base.encode/decode base8" {
    const testing = std.testing;
    {
        var dest: [256]u8 = undefined;
        const source = "yes mani !";
        const encoded = Base.Base8.encode(dest[0..], source);
        try testing.expectEqualStrings("7362625631006654133464440102", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "7362625631006654133464440102";
        const decoded = try Base.Base8.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("yes mani !", decoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "\x00yes mani !";
        const encoded = Base.Base8.encode(dest[0..], source);
        try testing.expectEqualStrings("7000745453462015530267151100204", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "7000745453462015530267151100204";
        const decoded = try Base.Base8.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("\x00yes mani !", decoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "\x00\x00yes mani !";
        const encoded = Base.Base8.encode(dest[0..], source);
        try testing.expectEqualStrings("700000171312714403326055632220041", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "700000171312714403326055632220041";
        const decoded = try Base.Base8.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("\x00\x00yes mani !", decoded);
    }
}

test "Base.encode/decode base10" {
    const testing = std.testing;

    {
        var dest: [256]u8 = undefined;
        const source = "yes mani !";
        const encoded = Base.Base10.encode(dest[0..], source);
        try testing.expectEqualStrings("9573277761329450583662625", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "9573277761329450583662625";
        const decoded = try Base.Base10.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("yes mani !", decoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "\x00yes mani !";
        const encoded = Base.Base10.encode(dest[0..], source);
        try testing.expectEqualStrings("90573277761329450583662625", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "90573277761329450583662625";
        const decoded = try Base.Base10.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("\x00yes mani !", decoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "\x00\x00yes mani !";
        const encoded = Base.Base10.encode(dest[0..], source);
        try testing.expectEqualStrings("900573277761329450583662625", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "900573277761329450583662625";
        const decoded = try Base.Base10.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("\x00\x00yes mani !", decoded);
    }
}

test "Base.encode/decode base16" {
    const testing = std.testing;

    // Test Base16Lower
    {
        var dest: [256]u8 = undefined;
        const source = "yes mani !";
        const encoded = Base.Base16Lower.encode(dest[0..], source);
        try testing.expectEqualStrings("f796573206d616e692021", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "f796573206d616e692021";
        const decoded = try Base.Base16Lower.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("yes mani !", decoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "\x00yes mani !";
        const encoded = Base.Base16Lower.encode(dest[0..], source);
        try testing.expectEqualStrings("f00796573206d616e692021", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "f00796573206d616e692021";
        const decoded = try Base.Base16Lower.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("\x00yes mani !", decoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "\x00\x00yes mani !";
        const encoded = Base.Base16Lower.encode(dest[0..], source);
        try testing.expectEqualStrings("f0000796573206d616e692021", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "f0000796573206d616e692021";
        const decoded = try Base.Base16Lower.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("\x00\x00yes mani !", decoded);
    }

    // Test Base16Upper
    {
        var dest: [256]u8 = undefined;
        const source = "yes mani !";
        const encoded = Base.Base16Upper.encode(dest[0..], source);
        try testing.expectEqualStrings("F796573206D616E692021", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "F796573206D616E692021";
        const decoded = try Base.Base16Upper.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("yes mani !", decoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "\x00yes mani !";
        const encoded = Base.Base16Upper.encode(dest[0..], source);
        try testing.expectEqualStrings("F00796573206D616E692021", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "F00796573206D616E692021";
        const decoded = try Base.Base16Upper.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("\x00yes mani !", decoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "\x00\x00yes mani !";
        const encoded = Base.Base16Upper.encode(dest[0..], source);
        try testing.expectEqualStrings("F0000796573206D616E692021", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "F0000796573206D616E692021";
        const decoded = try Base.Base16Upper.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("\x00\x00yes mani !", decoded);
    }
}

test "Base.encode/decode base32" {
    const testing = std.testing;

    // Test Base32Lower
    {
        var dest: [256]u8 = undefined;
        const source = "yes mani !";
        const encoded = Base.Base32Lower.encode(dest[0..], source);
        try testing.expectEqualStrings("bpfsxgidnmfxgsibb", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "bpfsxgidnmfxgsibb";
        const decoded = try Base.Base32Lower.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("yes mani !", decoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "\x00yes mani !";
        const encoded = Base.Base32Lower.encode(dest[0..], source);
        try testing.expectEqualStrings("bab4wk4zanvqw42jaee", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "bab4wk4zanvqw42jaee";
        const decoded = try Base.Base32Lower.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("\x00yes mani !", decoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "\x00\x00yes mani !";
        const encoded = Base.Base32Lower.encode(dest[0..], source);
        try testing.expectEqualStrings("baaahszltebwwc3tjeaqq", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "baaahszltebwwc3tjeaqq";
        const decoded = try Base.Base32Lower.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("\x00\x00yes mani !", decoded);
    }

    // Test Base32Upper
    {
        var dest: [256]u8 = undefined;
        const source = "yes mani !";
        const encoded = Base.Base32Upper.encode(dest[0..], source);
        try testing.expectEqualStrings("BPFSXGIDNMFXGSIBB", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "BPFSXGIDNMFXGSIBB";
        const decoded = try Base.Base32Upper.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("yes mani !", decoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "\x00yes mani !";
        const encoded = Base.Base32Upper.encode(dest[0..], source);
        try testing.expectEqualStrings("BAB4WK4ZANVQW42JAEE", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "BAB4WK4ZANVQW42JAEE";
        const decoded = try Base.Base32Upper.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("\x00yes mani !", decoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "\x00\x00yes mani !";
        const encoded = Base.Base32Upper.encode(dest[0..], source);
        try testing.expectEqualStrings("BAAAHSZLTEBWWC3TJEAQQ", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "BAAAHSZLTEBWWC3TJEAQQ";
        const decoded = try Base.Base32Upper.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("\x00\x00yes mani !", decoded);
    }

    // Test Base32HexLower
    {
        var dest: [256]u8 = undefined;
        const source = "yes mani !";
        const encoded = Base.Base32HexLower.encode(dest[0..], source);
        try testing.expectEqualStrings("vf5in683dc5n6i811", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "vf5in683dc5n6i811";
        const decoded = try Base.Base32HexLower.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("yes mani !", decoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "\x00yes mani !";
        const encoded = Base.Base32HexLower.encode(dest[0..], source);
        try testing.expectEqualStrings("v01smasp0dlgmsq9044", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "v01smasp0dlgmsq9044";
        const decoded = try Base.Base32HexLower.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("\x00yes mani !", decoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "\x00\x00yes mani !";
        const encoded = Base.Base32HexLower.encode(dest[0..], source);
        try testing.expectEqualStrings("v0007ipbj41mm2rj940gg", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "v0007ipbj41mm2rj940gg";
        const decoded = try Base.Base32HexLower.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("\x00\x00yes mani !", decoded);
    }

    // Test Base32HexUpper
    {
        var dest: [256]u8 = undefined;
        const source = "yes mani !";
        const encoded = Base.Base32HexUpper.encode(dest[0..], source);
        try testing.expectEqualStrings("VF5IN683DC5N6I811", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "VF5IN683DC5N6I811";
        const decoded = try Base.Base32HexUpper.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("yes mani !", decoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "\x00yes mani !";
        const encoded = Base.Base32HexUpper.encode(dest[0..], source);
        try testing.expectEqualStrings("V01SMASP0DLGMSQ9044", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "V01SMASP0DLGMSQ9044";
        const decoded = try Base.Base32HexUpper.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("\x00yes mani !", decoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "\x00\x00yes mani !";
        const encoded = Base.Base32HexUpper.encode(dest[0..], source);
        try testing.expectEqualStrings("V0007IPBJ41MM2RJ940GG", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "V0007IPBJ41MM2RJ940GG";
        const decoded = try Base.Base32HexUpper.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("\x00\x00yes mani !", decoded);
    }

    // Test Base32PadLower
    {
        var dest: [256]u8 = undefined;
        const source = "yes mani !";
        const encoded = Base.Base32PadLower.encode(dest[0..], source);
        try testing.expectEqualStrings("cpfsxgidnmfxgsibb", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "cpfsxgidnmfxgsibb";
        const decoded = try Base.Base32PadLower.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("yes mani !", decoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "\x00yes mani !";
        const encoded = Base.Base32PadLower.encode(dest[0..], source);
        try testing.expectEqualStrings("cab4wk4zanvqw42jaee======", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "cab4wk4zanvqw42jaee======";
        const decoded = try Base.Base32PadLower.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("\x00yes mani !", decoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "\x00\x00yes mani !";
        const encoded = Base.Base32PadLower.encode(dest[0..], source);
        try testing.expectEqualStrings("caaahszltebwwc3tjeaqq====", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "caaahszltebwwc3tjeaqq====";
        const decoded = try Base.Base32PadLower.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("\x00\x00yes mani !", decoded);
    }

    // Test Base32PadUpper
    {
        var dest: [256]u8 = undefined;
        const source = "yes mani !";
        const encoded = Base.Base32PadUpper.encode(dest[0..], source);
        try testing.expectEqualStrings("CPFSXGIDNMFXGSIBB", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "CPFSXGIDNMFXGSIBB";
        const decoded = try Base.Base32PadUpper.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("yes mani !", decoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "\x00yes mani !";
        const encoded = Base.Base32PadUpper.encode(dest[0..], source);
        try testing.expectEqualStrings("CAB4WK4ZANVQW42JAEE======", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "CAB4WK4ZANVQW42JAEE======";
        const decoded = try Base.Base32PadUpper.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("\x00yes mani !", decoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "\x00\x00yes mani !";
        const encoded = Base.Base32PadUpper.encode(dest[0..], source);
        try testing.expectEqualStrings("CAAAHSZLTEBWWC3TJEAQQ====", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "CAAAHSZLTEBWWC3TJEAQQ====";
        const decoded = try Base.Base32PadUpper.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("\x00\x00yes mani !", decoded);
    }

    // Test Base32HexPadLower
    {
        var dest: [256]u8 = undefined;
        const source = "yes mani !";
        const encoded = Base.Base32HexPadLower.encode(dest[0..], source);
        try testing.expectEqualStrings("tf5in683dc5n6i811", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "tf5in683dc5n6i811";
        const decoded = try Base.Base32HexPadLower.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("yes mani !", decoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "\x00yes mani !";
        const encoded = Base.Base32HexPadLower.encode(dest[0..], source);
        try testing.expectEqualStrings("t01smasp0dlgmsq9044======", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "t01smasp0dlgmsq9044======";
        const decoded = try Base.Base32HexPadLower.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("\x00yes mani !", decoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "\x00\x00yes mani !";
        const encoded = Base.Base32HexPadLower.encode(dest[0..], source);
        try testing.expectEqualStrings("t0007ipbj41mm2rj940gg====", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "t0007ipbj41mm2rj940gg====";
        const decoded = try Base.Base32HexPadLower.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("\x00\x00yes mani !", decoded);
    }

    // Test Base32HexPadUpper
    {
        var dest: [256]u8 = undefined;
        const source = "yes mani !";
        const encoded = Base.Base32HexPadUpper.encode(dest[0..], source);
        try testing.expectEqualStrings("TF5IN683DC5N6I811", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "TF5IN683DC5N6I811";
        const decoded = try Base.Base32HexPadUpper.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("yes mani !", decoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "\x00yes mani !";
        const encoded = Base.Base32HexPadUpper.encode(dest[0..], source);
        try testing.expectEqualStrings("T01SMASP0DLGMSQ9044======", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "T01SMASP0DLGMSQ9044======";
        const decoded = try Base.Base32HexPadUpper.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("\x00yes mani !", decoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "\x00\x00yes mani !";
        const encoded = Base.Base32HexPadUpper.encode(dest[0..], source);
        try testing.expectEqualStrings("T0007IPBJ41MM2RJ940GG====", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "T0007IPBJ41MM2RJ940GG====";
        const decoded = try Base.Base32HexPadUpper.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("\x00\x00yes mani !", decoded);
    }

    // Test Base32Z
    {
        var dest: [256]u8 = undefined;
        const source = "yes mani !";
        const encoded = Base.Base32Z.encode(dest[0..], source);
        try testing.expectEqualStrings("hxf1zgedpcfzg1ebb", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "hxf1zgedpcfzg1ebb";
        const decoded = try Base.Base32Z.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("yes mani !", decoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "\x00yes mani !";
        const encoded = Base.Base32Z.encode(dest[0..], source);
        try testing.expectEqualStrings("hybhskh3ypiosh4jyrr", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "hybhskh3ypiosh4jyrr";
        const decoded = try Base.Base32Z.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("\x00yes mani !", decoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "\x00\x00yes mani !";
        const encoded = Base.Base32Z.encode(dest[0..], source);
        try testing.expectEqualStrings("hyyy813murbssn5ujryoo", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "hyyy813murbssn5ujryoo";
        const decoded = try Base.Base32Z.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("\x00\x00yes mani !", decoded);
    }
}

test "Base.encode/decode base36" {
    const testing = std.testing;

    // Test Base36Lower
    {
        var dest: [256]u8 = undefined;
        const source = "yes mani !";
        const encoded = Base.Base36Lower.encode(dest[0..], source);
        try testing.expectEqualStrings("k2lcpzo5yikidynfl", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "k2lcpzo5yikidynfl";
        const decoded = try Base.Base36Lower.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("yes mani !", decoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "\x00yes mani !";
        const encoded = Base.Base36Lower.encode(dest[0..], source);
        try testing.expectEqualStrings("k02lcpzo5yikidynfl", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "k02lcpzo5yikidynfl";
        const decoded = try Base.Base36Lower.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("\x00yes mani !", decoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "\x00\x00yes mani !";
        const encoded = Base.Base36Lower.encode(dest[0..], source);
        try testing.expectEqualStrings("k002lcpzo5yikidynfl", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "k002lcpzo5yikidynfl";
        const decoded = try Base.Base36Lower.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("\x00\x00yes mani !", decoded);
    }

    // Test Base36Upper
    {
        var dest: [256]u8 = undefined;
        const source = "yes mani !";
        const encoded = Base.Base36Upper.encode(dest[0..], source);
        try testing.expectEqualStrings("K2LCPZO5YIKIDYNFL", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "K2LCPZO5YIKIDYNFL";
        const decoded = try Base.Base36Upper.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("yes mani !", decoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "\x00yes mani !";
        const encoded = Base.Base36Upper.encode(dest[0..], source);
        try testing.expectEqualStrings("K02LCPZO5YIKIDYNFL", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "K02LCPZO5YIKIDYNFL";
        const decoded = try Base.Base36Upper.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("\x00yes mani !", decoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "\x00\x00yes mani !";
        const encoded = Base.Base36Upper.encode(dest[0..], source);
        try testing.expectEqualStrings("K002LCPZO5YIKIDYNFL", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "K002LCPZO5YIKIDYNFL";
        const decoded = try Base.Base36Upper.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("\x00\x00yes mani !", decoded);
    }
}

test "Base.encode/decode base58" {
    const testing = std.testing;

    // Test Base58Btc
    {
        var dest: [256]u8 = undefined;
        const source = "yes mani !";
        const encoded = Base.Base58Btc.encode(dest[0..], source);
        try testing.expectEqualStrings("z7paNL19xttacUY", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "z7paNL19xttacUY";
        const decoded = try Base.Base58Btc.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("yes mani !", decoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "\x00yes mani !";
        const encoded = Base.Base58Btc.encode(dest[0..], source);
        try testing.expectEqualStrings("z17paNL19xttacUY", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "z17paNL19xttacUY";
        const decoded = try Base.Base58Btc.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("\x00yes mani !", decoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "\x00\x00yes mani !";
        const encoded = Base.Base58Btc.encode(dest[0..], source);
        try testing.expectEqualStrings("z117paNL19xttacUY", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "z117paNL19xttacUY";
        const decoded = try Base.Base58Btc.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("\x00\x00yes mani !", decoded);
    }

    // Test Base58Flickr
    {
        var dest: [256]u8 = undefined;
        const source = "yes mani !";
        const encoded = Base.Base58Flickr.encode(dest[0..], source);
        try testing.expectEqualStrings("Z7Pznk19XTTzBtx", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "Z7Pznk19XTTzBtx";
        const decoded = try Base.Base58Flickr.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("yes mani !", decoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "\x00yes mani !";
        const encoded = Base.Base58Flickr.encode(dest[0..], source);
        try testing.expectEqualStrings("Z17Pznk19XTTzBtx", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "Z17Pznk19XTTzBtx";
        const decoded = try Base.Base58Flickr.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("\x00yes mani !", decoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "\x00\x00yes mani !";
        const encoded = Base.Base58Flickr.encode(dest[0..], source);
        try testing.expectEqualStrings("Z117Pznk19XTTzBtx", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "Z117Pznk19XTTzBtx";
        const decoded = try Base.Base58Flickr.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("\x00\x00yes mani !", decoded);
    }
}

test "Base.encode/decode base64" {
    const testing = std.testing;

    // Test Base64 standard
    {
        var dest: [256]u8 = undefined;
        const source = "yes mani !";
        const encoded = Base.Base64.encode(dest[0..], source);
        try testing.expectEqualStrings("meWVzIG1hbmkgIQ", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "meWVzIG1hbmkgIQ";
        const decoded = try Base.Base64.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("yes mani !", decoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "\x00yes mani !";
        const encoded = Base.Base64.encode(dest[0..], source);
        try testing.expectEqualStrings("mAHllcyBtYW5pICE", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "mAHllcyBtYW5pICE";
        const decoded = try Base.Base64.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("\x00yes mani !", decoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "\x00\x00yes mani !";
        const encoded = Base.Base64.encode(dest[0..], source);
        try testing.expectEqualStrings("mAAB5ZXMgbWFuaSAh", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "mAAB5ZXMgbWFuaSAh";
        const decoded = try Base.Base64.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("\x00\x00yes mani !", decoded);
    }

    // Test Base64Pad
    {
        var dest: [256]u8 = undefined;
        const source = "yes mani !";
        const encoded = Base.Base64Pad.encode(dest[0..], source);
        try testing.expectEqualStrings("MeWVzIG1hbmkgIQ==", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "MeWVzIG1hbmkgIQ==";
        const decoded = try Base.Base64Pad.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("yes mani !", decoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "\x00yes mani !";
        const encoded = Base.Base64Pad.encode(dest[0..], source);
        try testing.expectEqualStrings("MAHllcyBtYW5pICE=", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "MAHllcyBtYW5pICE=";
        const decoded = try Base.Base64Pad.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("\x00yes mani !", decoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "\x00\x00yes mani !";
        const encoded = Base.Base64Pad.encode(dest[0..], source);
        try testing.expectEqualStrings("MAAB5ZXMgbWFuaSAh", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "MAAB5ZXMgbWFuaSAh";
        const decoded = try Base.Base64Pad.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("\x00\x00yes mani !", decoded);
    }

    // Test Base64Url
    {
        var dest: [256]u8 = undefined;
        const source = "yes mani !";
        const encoded = Base.Base64Url.encode(dest[0..], source);
        try testing.expectEqualStrings("ueWVzIG1hbmkgIQ", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "ueWVzIG1hbmkgIQ";
        const decoded = try Base.Base64Url.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("yes mani !", decoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "\x00yes mani !";
        const encoded = Base.Base64Url.encode(dest[0..], source);
        try testing.expectEqualStrings("uAHllcyBtYW5pICE", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "uAHllcyBtYW5pICE";
        const decoded = try Base.Base64Url.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("\x00yes mani !", decoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "\x00\x00yes mani !";
        const encoded = Base.Base64Url.encode(dest[0..], source);
        try testing.expectEqualStrings("uAAB5ZXMgbWFuaSAh", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "uAAB5ZXMgbWFuaSAh";
        const decoded = try Base.Base64Url.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("\x00\x00yes mani !", decoded);
    }

    // Test Base64UrlPad
    {
        var dest: [256]u8 = undefined;
        const source = "yes mani !";
        const encoded = Base.Base64UrlPad.encode(dest[0..], source);
        try testing.expectEqualStrings("UeWVzIG1hbmkgIQ==", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "UeWVzIG1hbmkgIQ==";
        const decoded = try Base.Base64UrlPad.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("yes mani !", decoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "\x00yes mani !";
        const encoded = Base.Base64UrlPad.encode(dest[0..], source);
        try testing.expectEqualStrings("UAHllcyBtYW5pICE=", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "UAHllcyBtYW5pICE=";
        const decoded = try Base.Base64UrlPad.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("\x00yes mani !", decoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "\x00\x00yes mani !";
        const encoded = Base.Base64UrlPad.encode(dest[0..], source);
        try testing.expectEqualStrings("UAAB5ZXMgbWFuaSAh", encoded);
    }

    {
        var dest: [256]u8 = undefined;
        const source = "UAAB5ZXMgbWFuaSAh";
        const decoded = try Base.Base64UrlPad.decode(dest[0..], source[1..]);
        try testing.expectEqualStrings("\x00\x00yes mani !", decoded);
    }
}

test "Base.encode/decode base256emoji" {
    const testing = std.testing;

    // Test with "yes mani !"
    {
        var dest: [1024]u8 = undefined;
        const source = "yes mani !";
        const encoded = Base.Base256Emoji.encode(dest[0..], source);
        try testing.expectEqualStrings("🚀🏃✋🌈😅🌷🤤😻🌟😅👏", encoded);
    }

    {
        var dest: [1024]u8 = undefined;
        const source = "🚀🏃✋🌈😅🌷🤤😻🌟😅👏";
        const decoded = try Base.Base256Emoji.decode(dest[0..], source[4..]);
        try testing.expectEqualStrings("yes mani !", decoded);
    }

    // Test with "\x00yes mani !"
    {
        var dest: [1024]u8 = undefined;
        const source = "\x00yes mani !";
        const encoded = Base.Base256Emoji.encode(dest[0..], source);
        try testing.expectEqualStrings("🚀🚀🏃✋🌈😅🌷🤤😻🌟😅👏", encoded);
    }

    {
        var dest: [1024]u8 = undefined;
        const source = "🚀🚀🏃✋🌈😅🌷🤤😻🌟😅👏";
        const decoded = try Base.Base256Emoji.decode(dest[0..], source[4..]);
        try testing.expectEqualStrings("\x00yes mani !", decoded);
    }

    // Test with "\x00\x00yes mani !"
    {
        var dest: [1024]u8 = undefined;
        const source = "\x00\x00yes mani !";
        const encoded = Base.Base256Emoji.encode(dest[0..], source);
        try testing.expectEqualStrings("🚀🚀🚀🏃✋🌈😅🌷🤤😻🌟😅👏", encoded);
    }

    {
        var dest: [1024]u8 = undefined;
        const source = "🚀🚀🚀🏃✋🌈😅🌷🤤😻🌟😅👏";
        const decoded = try Base.Base256Emoji.decode(dest[0..], source[4..]);
        try testing.expectEqualStrings("\x00\x00yes mani !", decoded);
    }
}
