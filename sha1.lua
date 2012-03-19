-- http://cube3d.de/uploads/Main/sha1.txt
-------------------------------------------------------------------------------
-- SHA-1 secure hash computation, and HMAC-SHA1 signature computation,
-- in pure Lua (tested on Lua 5.1)
-- License: MIT
--
-- Usage:
--   local hash_as_hex   = sha1(message)            -- returns a hex string
--   local hash_as_data  = sha1_binary(message)     -- returns raw bytes
--
--   local hmac_as_hex   = hmac_sha1(key, message)        -- hex string
--   local hmac_as_data  = hmac_sha1_binary(key, message) -- raw bytes
--
--
-- Pass sha1() a string, and it returns a hash as a 40-character hex string.
-- For example, the call
--
--   local hash = sha1 "http://regex.info/blog/"
--
-- puts the 40-character string
--
--   "7f103bf600de51dfe91062300c14738b32725db5"
--
-- into the variable 'hash'
--
-- Pass sha1_hmac() a key and a message, and it returns the signature as a
-- 40-byte hex string.
--
--
-- The two "_binary" versions do the same, but return the 20-byte string of raw
-- data that the 40-byte hex strings represent.
--
-------------------------------------------------------------------------------
--
-- based on Jeffrey Friedl's implementation (which I found a bit too slow)
-- > jfriedl@yahoo.com
-- > http://regex.info/blog/
-- > Version 1 [May 28, 2009]
-- The original implementation is about 10 times slower, so you might prefer
-- this one.
--
--
-- Algorithm: http://www.itl.nist.gov/fipspubs/fip180-1.htm
--
-- This code was declared to be placed in the public domain

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
local bit = require "bit"
local band = bit.band
local bor = bit.bor
local bxor = bit.bxor
local w32 = require "w32_ops"

-- local storing of global functions (minor speedup)
local floor,modf = math.floor,math.modf
local char,format,rep = string.char,string.format,string.rep


-- calculating the SHA1 for some text
function sha1(msg)
	local H0,H1,H2,H3,H4 = 0x67452301,0xEFCDAB89,0x98BADCFE,0x10325476,0xC3D2E1F0
	local msg_len_in_bits = #msg * 8

	local first_append = char(0x80) -- append a '1' bit plus seven '0' bits

	local non_zero_message_bytes = #msg +1 +8 -- the +1 is the appended bit 1, the +8 are for the final appended length
	local current_mod = non_zero_message_bytes % 64
	local second_append = current_mod>0 and rep(char(0), 64 - current_mod) or ""

	-- now to append the length as a 64-bit number.
	local B1, R1	= modf(msg_len_in_bits  / 0x01000000)
	local B2, R2	= modf( 0x01000000 * R1 / 0x00010000)
	local B3, R3	= modf( 0x00010000 * R2 / 0x00000100)
	local B4		= 0x00000100 * R3

	local L64 = char( 0) .. char( 0) .. char( 0) .. char( 0) -- high 32 bits
				.. char(B1) .. char(B2) .. char(B3) .. char(B4) --  low 32 bits

	msg = msg .. first_append .. second_append .. L64

	assert(#msg % 64 == 0)

	local chunks = #msg / 64

	local W = { }
	local start, A, B, C, D, E, f, K, TEMP
	local chunk = 0

	while chunk < chunks do
		--
		-- break chunk up into W[0] through W[15]
		--
		start,chunk = chunk * 64 + 1,chunk + 1

		for t = 0, 15 do
			W[t] = w32.bytes_to_w32(msg:byte(start, start + 3))
			start = start + 4
		end

		--
		-- build W[16] through W[79]
		--
		for t = 16, 79 do
			-- For t = 16 to 79 let Wt = S1(Wt-3 XOR Wt-8 XOR Wt-14 XOR Wt-16).
			W[t] = w32.w32_rot(1, w32.w32_xor_n(W[t-3], W[t-8], W[t-14], W[t-16]))
		end

		A,B,C,D,E = H0,H1,H2,H3,H4

		for t = 0, 79 do
			if t <= 19 then
				-- (B AND C) OR ((NOT B) AND D)
				f = w32.w32_or(w32.w32_and(B, C), w32.w32_and(w32.w32_not(B), D))
				K = 0x5A827999
			elseif t <= 39 then
				-- B XOR C XOR D
				f = w32.w32_xor_n(B, C, D)
				K = 0x6ED9EBA1
			elseif t <= 59 then
				-- (B AND C) OR (B AND D) OR (C AND D
				f = w32.w32_or3(w32.w32_and(B, C), w32.w32_and(B, D), w32.w32_and(C, D))
				K = 0x8F1BBCDC
			else
				-- B XOR C XOR D
				f = w32.w32_xor_n(B, C, D)
				K = 0xCA62C1D6
			end

			-- TEMP = S5(A) + ft(B,C,D) + E + Wt + Kt;
			A,B,C,D,E = w32.w32_add_n(w32.w32_rot(5, A), f, E, W[t], K),
				A, w32.w32_rot(30, B), C, D
		end
		-- Let H0 = H0 + A, H1 = H1 + B, H2 = H2 + C, H3 = H3 + D, H4 = H4 + E.
		H0,H1,H2,H3,H4 = w32.w32_add(H0, A),w32.w32_add(H1, B),w32.w32_add(H2, C),w32.w32_add(H3, D),w32.w32_add(H4, E)
	end
	local f = w32.w32_to_hexstring
	return f(H0) .. f(H1) .. f(H2) .. f(H3) .. f(H4)
end



function sha1_binary(msg)
	return w32.hex_to_binary(sha1(msg))
end

local xor_with_0x5c = {}
local xor_with_0x36 = {}
-- building the lookuptables ahead of time (instead of littering the source code
-- with precalculated values)
for i=0,0xff do
	xor_with_0x5c[char(i)] = char(bxor(i,0x5c))
	xor_with_0x36[char(i)] = char(bxor(i,0x36))
end

local blocksize = 64 -- 512 bits

function hmac_sha1(key, text)
	assert(type(key)  == 'string', "key passed to hmac_sha1 should be a string")
	assert(type(text) == 'string', "text passed to hmac_sha1 should be a string")

	if #key > blocksize then
		key = sha1_binary(key)
	end

	local key_xord_with_0x36 = key:gsub('.', xor_with_0x36) .. string.rep(string.char(0x36), blocksize - #key)
	local key_xord_with_0x5c = key:gsub('.', xor_with_0x5c) .. string.rep(string.char(0x5c), blocksize - #key)

	return sha1(key_xord_with_0x5c .. sha1_binary(key_xord_with_0x36 .. text))
end

function hmac_sha1_binary(key, text)
	return w32.hex_to_binary(hmac_sha1(key, text))
end




return {
	sha1 = sha1,
	sha1_binary = sha1_binary,
	hmac_sha1 = hmac_sha1,
	hmac_sha1_binary = hmac_sha1_binary,
}

