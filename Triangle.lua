

function FindTopmostPolyVertex(poly, nelems)
	local ymin = math.huge
	local vmin = 0;

	for i=1, nelems do
	--print(poly[i])
		if poly[i][1] < ymin then
			ymin = poly[i][1]
			vmin = i
		end
	end

	return vmin
end

function RotateVertices(poly, nelems, starting)
--print("RotateVertices: ", nelems, starting)
	local res={}
	local offset = starting
	for cnt=1,nelems do
		table.insert(res, poly[offset])
		offset = offset + 1
		if offset > nelems then
			offset = 1
		end
	end

	return res
end


function swap(a, b)
	return b, a
end

function getTriangleBBox(x0,y0, x1,y1, x2,y2)
	local minX = math.min(x0, math.min(x1, x2))
	local minY = math.min(y0, math.min(y1, y2))

	local maxX = math.max(x0, math.max(x1, x2))
	local maxY = math.max(y0, math.max(y1, y2))

	return minX, minY, maxX, maxY
end

function sortTriangle(v1, v2, v3)
	local verts = {v1, v2, v3}
	local topmost = FindTopmostPolyVertex(verts, 3)
	local sorted = RotateVertices(verts, 3, topmost)

	-- Top line flat

	-- Bottom line flat

	return sorted
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

function ScanTriangle ( v1, v2, v3)
	local a, b, y, last;

	local sorted = sortTriangle(v1, v2, v3)

	local x1, y1 = sorted[1][0], sorted[1][1]
	local x2, y2 = sorted[2][0], sorted[2][1]
	local x3, y3 = sorted[3][0], sorted[3][1]

	local ldda = nil
	local rdda = nil
	local longdda = nil

	-- Setup left and right edge dda iterators
	if x2 <= x1 then
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

