--[[
    "Extremely Fast Line Algorithm"

	Original Author: Po-Han Lin (original version: http://www.edepot.com/algorithm.html)

	Port To Lua Iterator: William Adams (http://williamaadams.wordpress.com)
	x1 X component of the start point
	y1 Y component of the start point
	x2 X component of the end point
	y2 Y component of the end point
--]]

--[[
	Comment: By doing this as an interator, there is more flexibility in
	where it can be used.

	Typical usage:

	local aline = EFLA_Iterator(0,0,10,10)
	for x,y in aline do
		color  = somenewvalue
		setPixel(x,y,color)
	end

--]]

function EFLA_Iterator(x1, y1, x2, y2, skiplast)
	skiplast = skiplast or false
	local yLonger = false;
	local incrementVal = 0;
	local endVal = 0;

	local shortLen = (y2-y1);
	local longLen = (x2-x1);

	if (math.abs(shortLen) > math.abs(longLen)) then
		local swap = shortLen;
		shortLen = longLen;
		longLen = swap;
		yLonger = true;
	end

	endVal = longLen;

	if (longLen<0) then
		incrementVal = -1;
		longLen = -longLen;
	else
		incrementVal = 1;
	end

	local decInc = 0;

	if longLen == 0 then
		decInc = shortLen;
	else
		decInc = (shortLen/longLen);
	end

	local j = 0 - decInc;
	local i = 0 - incrementVal

--print("EFLA")
--print(shortLen, longLen, decInc, incrementVal, endVal)
--print("YLonger: ", yLonger)

	if yLonger then
		return function()
			i = i + incrementVal
			if not skiplast then
				if math.abs(i) > math.abs(endVal) then return nil end
			else
				if math.abs(i) > math.abs(endVal-1) then return nil end
			end

			j = j + decInc
			local x = x1 + j
			local y = y1 + i
			local u
			if (skiplast) then u = i/(endVal-1) else u = i/endVal end

			return x,y, u
		end
	else
		return function()
			i = i + incrementVal
			if not skiplast then
				if math.abs(i) > math.abs(endVal) then return nil end
			else
				if math.abs(i) > math.abs(endVal-1) then return nil end
			end

			j = j + decInc
			local x = x1 + i
			local y = y1 + j
			local u
			if (skiplast) then u = i/(endVal-1) else u = i/endVal end

			return x,y, u
		end
	end
end



--[[
print("EFLA.lua - TEST")

--local line = EFLA_Iterator(5, 1, 1, 8)
--local line = EFLA_Iterator(10, 1, 1, 5)
local line = EFLA_Iterator(1, 1, 10, 5)

for x,y,len in line do
	print(x,y,len)
end
--]]
