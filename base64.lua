--[[
	base64.lua
	base64 encoding and decoding for LuaJIT
	William Adams <william_a_adams@msn.com>
	17 Mar 2012
	This code is hereby placed in the public domain

	The derivation of this code is from a public domain
	implementation in 'C' by Luiz Henrique de Figueiredo <lhf@tecgraf.puc-rio.br>
--]]
require "000"

base64={}
base64.base64bytes = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
base64.whitespacechars = "\n\r\t \f\b"

function base64.iswhitespace(c)
	local found = whitespacechars:find(c)
	return found ~= nil
end


function base64.char64index(c)
	local index = base64.base64bytes:find(c)

	if not index then
		return nil
	end

	return  index - 1
end



function base64.bencode(b, c1, c2, c3, n)
	local tuple = (c3+256*(c2+256*c1));
	local i;
	local s = {}

	for i=0, 3 do
		local offset = (tuple % 64)+1
		local c = base64.base64bytes:sub(offset, offset)

		s[4-i] = c;
		tuple = rshift(tuple, 6)	-- tuple/64;
	end

	for i=n+2, 4 do
		s[i]='=';
	end

	local encoded = table.concat(s)

	table.insert(b,encoded);
end


function base64.encode(s)
	local l = strlen(s)

	local b = {};
	local n = math.floor(l/3)
	for i=1,n do
		local c1 = getbyte(s, (i-1)*3+1)
		local c2 = getbyte(s, (i-1)*3+2)
		local c3 = getbyte(s, (i-1)*3+3)
		base64.bencode(b,c1,c2,c3,3);
	end

	-- Finish off the last few bytes
	local leftovers = l%3

	if leftovers == 1 then
		local c1 = getbyte(s, (n*3)+1)
		base64.bencode(b,c1,0,0,1);
	elseif leftovers == 2 then
		local c1 = getbyte(s, (n*3)+1)
		local c2 = getbyte(s, (n*3)+2)
		base64.bencode(b,c1,c2,0,2);
	end

	return table.concat(b)
end


function base64.bdecode(b, c1, c2, c3, c4, n)
	local tuple = c4+64*(c3+64*(c2+64*c1));
	local s={};

	for i=1,n-1 do
		local shifter = 8 * (3-i)
		local abyte = band(rshift(tuple, shifter), 0xff)

		s[i] = getchar(abyte)
	end

	local decoded = table.concat(s)
	table.insert(b, decoded)
end

function base64.decode(s)
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
				base64.bdecode(b,t[1],0,0,0,1);
			end
			if n == 2 then
				base64.bdecode(b,t[1],t[2],0,0,2);
			end
			if n == 3 then
				base64.bdecode(b,t[1],t[2],t[3],0,3);
			end

			-- If we've swallowed the '=', then
			-- we're at the end of the string, so return
			return table.concat(b)
		elseif base64.iswhitespace(c) then
			-- If whitespace, then do nothing
		else
			local p = base64.char64index(c);
			if (p==nil) then
				return nil;
			end

			t[n+1]= p;
			n = n+1
			if (n==4) then
				base64.bdecode(b,t[1],t[2],t[3],t[4],4);
				n=0;
			end
		end
	end

	-- if we've gotten to here, we've reached
	-- the end of the string, and there were
	-- no padding characters, so return decoded
	-- string in full
	return table.concat(b);
end
