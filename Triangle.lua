
function swap(a, b)
	return b, a
end

function sortTriangle(x0, y0,x1, y1, x2, y2)
	if (y0 > y1) then
		y0, y1 = swap(y0, y1);
		x0, x1 = swap(x0, x1);
	end

	if (y1 > y2) then
		y2, y1 = swap(y2, y1);
		x2, x1 = swap(x2, x1);
	end

	if (y0 > y1) then
		y0, y1 = swap(y0, y1);
		x0, x1 = swap(x0, x1);
	end

	return x0, y0, x1, y1, x2, y2
end

function Triangle_DDA(x1, y1, x2, y2, skiplast)
	skiplast = skiplast or false
	local yLonger = false;
	local incrementVal = 1;
	local endVal = 0;

	local dY = (y2-y1);
	local dX = (x2-x1);

	endVal = dY;

	local decInc = 0;

	if dY == 0 then
		decInc = dX;
	else
		decInc = (dX/dY);
	end

	local j = 0 - decInc;
	local i = 0 - incrementVal

	return function()
		i = i + incrementVal
		if not skiplast then
			if i > endVal then return nil end
		else
			if i > (endVal-1) then return nil end
		end

		j = j + decInc
		local x = x1 + j
		local y = y1 + i
		local u
		if (skiplast) then u = i/(endVal-1) else u = i/endVal end

		return x,y, u
	end
end

function ScanTriangle ( x1, y1, x2, y2, x3, y3)
	local a, b, y, last;

	x1,y1,x2,y2,x3,y3 = sortTriangle(x1, y1, x2, y2, x3, y3)

--print(x1, y1, x2, y2, x3, y3)

	local ldda = nil
	local rdda = nil
	local longdda = nil

	-- Setup left and right edge dda iterators
	if x2 < x1 then
		ldda = Triangle_DDA(x1,y1, x2,y2)
		rdda = Triangle_DDA(x1,y1, x3,y3)
		longdda = rdda
	else
		ldda = Triangle_DDA(x1,y1, x3,y3)
		rdda = Triangle_DDA(x1,y1, x2,y2)
		longdda = ldda
	end

	local lx, ly, lu
	local rx, ry, ru

	return function()
		-- start iterating down first edge, until we reach
		-- the y value of the second vertex
		lx,ly,lu = ldda()
		rx,ry,ru = rdda()

		if not lx then
			if ldda == longdda then
				return nil
			end

			ldda = Triangle_DDA(x2,y2,x3,y3)

			-- iterate once to skip over the first one
			-- which was already consumed by the previous edge
			lx,ly,lu = ldda()

			-- iterate once, to fill in the nil one that we're
			-- currently on
			lx,ly,lu = ldda()
		end

		if not rx then
			if rdda == longdda then
				return nil
			end

			rdda = Triangle_DDA(x2,y2,x3,y3)
			rx,ry,ru = rdda()
			rx,ry,ru = rdda()
		end

		local len = 0
		if rx and lx then
			len = rx-lx+1
		end

		return lx, ly, len, rx, ry, lu, ru
	end
end


--[[
print("Triangle.lua - TEST")


local x1 = 1
local y1 = 1
local x2 = 5
local y2 = 5
local x3 = 1
local y3 = 10

--x1, y1, x2, y2, x3, y3 = sortTriangle(x1, y1,x2, y2, x3, y3)
--print(x1, y1, x2, y2, x3, y3)


--local triscan = ScanTriangle (x1, y1,x2, y2, x3, y3)
local triscan = ScanTriangle (10,1, 1,5, 10,10)

for lx,ly, len, rx,ry, lu, ru in triscan do
	print(lx, ly, rx, ry)
end

--]]
