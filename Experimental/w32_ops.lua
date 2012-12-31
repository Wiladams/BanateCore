-- Description

--require "000"

local bit = require "bit"
local bor = bit.bor
local band = bit.band
local bxor = bit.bxor

local floor,modf = math.floor,math.modf
local char,format,rep = string.char,string.format,string.rep


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





-- merge 4 bytes to an 32 bit word
local function bytes_to_w32 (a,b,c,d)
	return a*0x1000000+b*0x10000+c*0x100+d
end

-- split a 32 bit word into four 8 bit numbers
local function w32_to_bytes (i)
	return floor(i/0x1000000)%0x100,floor(i/0x10000)%0x100,floor(i/0x100)%0x100,i%0x100
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


--print(w32_to_bit_string(523))
print(type(tonumber(0x10000000LL)))

return {
bytes_to_w32 = bytes_to_w32,
hex_to_binary = hex_to_binary,
w32_to_bit_string = w32_to_bit_string,
w32_to_bytes = w32_to_bytes,
w32_to_hexstring = w32_to_hexstring,
}
