--[[
	base64.lua
	base64 encoding and decoding for LuaJIT
	William Adams <william_a_adams@msn.com>
	17 Mar 2012
	This code is hereby placed in the public domain

	The derivation of this code is from a public domain
	implementation in 'C' by Luiz Henrique de Figueiredo <lhf@tecgraf.puc-rio.br>

	The usage of LuaJIT is superfluous as I only use a character
	array, which can easily be replaced by a simple table.
--]]
local ffi = require "ffi"
local bit = require "bit"
local rshift = bit.rshift
local lshift = bit.lshift
local band = bit.band
local bor = bit.bor
local strlen = string.len
local byte = string.byte
local char = string.char

ffi.cdef[[
	typedef char char64[64];
]]


local whitespacechars = "\n\r\t \f\b"
local function iswhitespace(c)
	local found = whitespacechars:find(c)
	return found ~= nil
end


local code = ffi.new("char64", "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/")
local base64bytes = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

local function char64index(c)
	local index = base64bytes:find(c)

	if not index then
		return nil
	end

	return  index - 1
end



local function encode(b, c1, c2, c3, n)
	local tuple = (c3+256*(c2+256*c1));
	local i;
	local s = {}

	for i=0, 3 do
		local c = string.char(code[tuple % 64])
		--local code = char64index(tuple % 64) + string.byte('A')
		--local c = string.char(code)

		s[4-i] = c;
		tuple = rshift(tuple, 6)	-- tuple/64;
	end

	for i=n+2, 4 do
		s[i]='=';
	end

	local encoded = table.concat(s)

	table.insert(b,encoded);
end


local function Lencode(s)
	local l = strlen(s)

	local b = {};
	local n = math.floor(l/3)
	for i=1,n do
		local c1 = byte(s, (i-1)*3+1)
		local c2 = byte(s, (i-1)*3+2)
		local c3 = byte(s, (i-1)*3+3)
		encode(b,c1,c2,c3,3);
	end

	-- Finish off the last few bytes
	local leftovers = l%3

	if leftovers == 1 then
		local c1 = byte(s, (n*3)+1)
		encode(b,c1,0,0,1);
	elseif leftovers == 2 then
		local c1 = byte(s, (n*3)+1)
		local c2 = byte(s, (n*3)+2)
		encode(b,c1,c2,0,2);
	end

	return table.concat(b)
end







function decode(b, c1, c2, c3, c4, n)
	local tuple = c4+64*(c3+64*(c2+64*c1));
	local s={};

	for i=1,n-1 do
		local shifter = 8 * (3-i)
		local abyte = band(rshift(tuple, shifter), 0xff)

		s[i] = string.char(abyte)
	end

	local decoded = table.concat(s)
--print("Decoded: ",decoded)
	table.insert(b, decoded)
end



-- decode(s)
function Ldecode(s)
	local l = strlen(s);
	local b = {};
	local n=0;
	t = {}	-- char[4];
	local offset = 1

	local continue = true
	while (offset <= l) do
		local c = s:sub(offset,offset)	-- *s++;
		offset = offset + 1

		if c == 0 then
			return table.concat(b);
		elseif c == '=' then
			if n ==  1 then
				decode(b,t[1],0,0,0,1);
			end
			if n == 2 then
				decode(b,t[1],t[2],0,0,2);
			end
			if n == 3 then
				decode(b,t[1],t[2],t[3],0,3);
			end

			return table.concat(b)
		elseif iswhitespace(c) then
			-- If whitespace, then do nothing
		else
			local p = char64index(c);
			if (p==nil) then
				return nil;
			end

			t[n+1]= p;
			n = n+1
			if (n==4) then
				decode(b,t[1],t[2],t[3],t[4],4);
				n=0;
			end
		end
	end

	return table.concat(b);
end


--[[
print(Ldecode("cGxl"))
print(Ldecode("YXN1"))
print(Ldecode("cmUu"))
print(Ldecode("Zg=="))		-- f
print(Ldecode("Zm8="))		-- fo
print(Ldecode("Zm9v"))		-- foo
print(Ldecode("Zm9vYg=="))	-- foob
print(Ldecode("Zm9vYmE="))	-- fooba
print(Ldecode("Zm9vYmFy"))	-- foobar

print(Ldecode("ZWFzdXJlLg=="))
--]]


return {
	decode = Ldecode,
	encode = Lencode,
	base64bytes = base64bytes,
	char64index = char64index,
	iswhitespace = iswhitespace,
}





