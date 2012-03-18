-- Description
-- Due to the lack of bitwise operations in 5.1, this version uses numbers to
-- represents the 32bit words that we combine with binary operations. The basic
-- operations of byte based "xor", "or", "and" are all cached in a combination
-- table (several 64k large tables are built on startup, which
-- consumes some memory and time). The caching can be switched off through
-- setting the local cfg_caching variable to false.
-- For all binary operations, the 32 bit numbers are split into 8 bit values
-- that are are then combined and then merged again.

local floor,modf = math.floor,math.modf
local char,format,rep = string.char,string.format,string.rep

local bit = require "bit"
local band = bit.band
local bor = bit.bor
local bxor = bit.bxor

-- set this to false if you don't want to build several 64k sized tables when
-- loading this file (takes a while but grants a boost of factor 13)
local cfg_caching = true


-- caching function for functions that accept 2 arguments, both of values between
-- 0 and 255. The function to be cached is passed, all values are calculated
-- during loading and a function is returned that returns the cached values (only)
local function cache2arg (fn)
	if not cfg_caching then return fn end
	local lut = {}
	for i=0,0xffff do
		local a,b = floor(i/0x100),i%0x100
		lut[i] = fn(a,b)
	end
	return function (a,b)
		return lut[a*0x100+b]
	end
end


-- splits an 8-bit number into 8 bits, returning all 8 bits as booleans
local function byte_to_bits (b)
	local b = function (n)
		local b = floor(b/n)
		return b%2==1
	end
	return b(1),b(2),b(4),b(8),b(16),b(32),b(64),b(128)
end

-- builds an 8bit number from 8 booleans
local function bits_to_byte (a,b,c,d,e,f,g,h)
	local function n(b,x)
		return b and x or 0
	end

	return n(a,1)+n(b,2)+n(c,4)+n(d,8)+n(e,16)+n(f,32)+n(g,64)+n(h,128)
end





--[[
-- bitwise "and" function for 2 8bit number
local band = cache2arg (function(a,b)
	local A,B,C,D,E,F,G,H = byte_to_bits(b)
	local a,b,c,d,e,f,g,h = byte_to_bits(a)
	return bits_to_byte(
		A and a, B and b, C and c, D and d,
		E and e, F and f, G and g, H and h)
end)

-- bitwise "or" function for 2 8bit numbers
local bor = cache2arg(function(a,b)
	local A,B,C,D,E,F,G,H = byte_to_bits(b)
	local a,b,c,d,e,f,g,h = byte_to_bits(a)
	return bits_to_byte(
		A or a, B or b, C or c, D or d,
		E or e, F or f, G or g, H or h)
end)

-- bitwise "xor" function for 2 8bit numbers
local bxor = cache2arg(function(a,b)
	local A,B,C,D,E,F,G,H = byte_to_bits(b)
	local a,b,c,d,e,f,g,h = byte_to_bits(a)
	return bits_to_byte(
		A ~= a, B ~= b, C ~= c, D ~= d,
		E ~= e, F ~= f, G ~= g, H ~= h)
end)

-- bitwise complement for one 8bit number
local function bnot (x)
	return 255-(x % 256)
end
--]]



-- merge 4 bytes to an 32 bit word
local function bytes_to_w32 (a,b,c,d)
	return a*0x1000000+b*0x10000+c*0x100+d
end

-- split a 32 bit word into four 8 bit numbers
local function w32_to_bytes (i)
	return floor(i/0x1000000)%0x100,floor(i/0x10000)%0x100,floor(i/0x100)%0x100,i%0x100
end

-- shift the bits of a 32 bit word. Don't use negative values for "bits"
local function w32_rot (bits,a)
	local b2 = 2^(32-bits)
	local a,b = modf(a/b2)

	return a+b*b2*(2^(bits))
end



-- debug function for visualizing bits in a string
local function bits_to_string (a,b,c,d,e,f,g,h)
	local function x(b)
		return b and "1" or "0"
	end

	return ("%s%s%s%s %s%s%s%s"):format(x(a),x(b),x(c),x(d),x(e),x(f),x(g),x(h))
end


-- debug function for converting a 8-bit number as bit string
local function byte_to_bit_string (b)
	return bits_to_string(byte_to_bits(b))
end

-- debug function for converting a 32 bit number as bit string
local function w32_to_bit_string(a)
	if type(a) == "string" then
		return a
	end

	local aa,ab,ac,ad = w32_to_bytes(a)
	local s = byte_to_bit_string

	return ("%s %s %s %s"):format(s(aa):reverse(),s(ab):reverse(),s(ac):reverse(),s(ad):reverse()):reverse()
end

-- creates a function to combine to 32bit numbers using an 8bit combination function
local function w32_comb(fn)
	return function (a,b)
		local aa,ab,ac,ad = w32_to_bytes(a)
		local ba,bb,bc,bd = w32_to_bytes(b)
		return bytes_to_w32(fn(aa,ba),fn(ab,bb),fn(ac,bc),fn(ad,bd))
	end
end

-- create functions for and, xor and or, all for 2 32bit numbers
local w32_and = w32_comb(band)
local w32_xor = w32_comb(bxor)
local w32_or = w32_comb(bor)

-- xor function that may receive a variable number of arguments
local function w32_xor_n (a,...)
	local aa,ab,ac,ad = w32_to_bytes(a)
	for i=1,select('#',...) do
		local ba,bb,bc,bd = w32_to_bytes(select(i,...))
		aa,ab,ac,ad = bxor(aa,ba),bxor(ab,bb),bxor(ac,bc),bxor(ad,bd)
	end
	return bytes_to_w32(aa,ab,ac,ad)
end


-- combining 3 32bit numbers through binary "or" operation
local function w32_or3 (a,b,c)
	local aa,ab,ac,ad = w32_to_bytes(a)
	local ba,bb,bc,bd = w32_to_bytes(b)
	local ca,cb,cc,cd = w32_to_bytes(c)
	return bytes_to_w32(
		bor(aa,bor(ba,ca)), bor(ab,bor(bb,cb)), bor(ac,bor(bc,cc)), bor(ad,bor(bd,cd))
	)
end


-- binary complement for 32bit numbers
local function w32_not (a)
	return 4294967295-(a % 4294967296)
end

-- adding 2 32bit numbers, cutting off the remainder on 33th bit
local function w32_add (a,b) return (a+b) % 4294967296 end

-- adding n 32bit numbers, cutting off the remainder (again)
local function w32_add_n (a,...)
	for i=1,select('#',...) do
		a = (a+select(i,...)) % 4294967296
	end
	return a
end
-- converting the number to a hexadecimal string
local function w32_to_hexstring (w)
	return format("%08x",w)
end

local function hex_to_binary(hex)
	s = function(hexval)
		return string.char(tonumber(hexval, 16))
	end

	return hex:gsub('..', s)
end

--[[-- simple benchmark
local tstart = os.time()
while tstart == os.time() do end
tstart = os.time()
local n = 0
while os.time()-tstart<=10 do sha1(string.rep("a", 200)) n = n + 1 end
print("times: ",n)
if true then return end
--]]

return {
bytes_to_w32 = bytes_to_w32,
hex_to_binary = hex_to_binary,
w32_to_bit_string = w32_to_bit_string,
w32_to_bytes = w32_to_bytes,
w32_to_hexstring = w32_to_hexstring,

w32_add = w32_add,
w32_add_n = w32_add_n,

w32_and = w32_and,
w32_not = w32_not,
w32_or = w32_or,
w32_or3 = w32_or3,
w32_rot = w32_rot,
w32_xor = w32_xor,
w32_xor_n = w32_xor_n,
}
