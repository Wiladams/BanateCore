-- ArrayRenderer.lua
require "000"


require "Triangle"
require "EFLA"
require "TransferArray2D"
require "glsl_math"
require "glsl_types"


class.ArrayRenderer()


function ArrayRenderer:_init(accessor)
	self.Accessor = accessor
	self.Width = accessor.Width
	self.Height = accessor.Height

	self.ScratchRow = NAlloc(self.Width, self.Accessor.TypeName)
end

function ArrayRenderer:GetOffset(x,y)
	if x<0 or x >= self.Width then
		return nil
	end

	if y<0 or y >= self.Height then
		return nil
	end

	local offset = (y*self.Width) + x

	return offset
end

-- Retrieve a pixel from the array
function ArrayRenderer:GetPixel(x, y)
	local value = self.Accessor:GetElement(x,y)
	return value
end

-- Do a SRC_COPY of the specified value into the buffer
-- Do not worry about any alpha or anti aliasing
function ArrayRenderer:SetPixel(x, y, value)
	self.Accessor:SetElement(x,y,value)
end


function ArrayRenderer:LineH(x, y, len, value)
	local row = y
	local x2 = x + len-1
	if x < 0 then x = 0 end

	if x2 > self.Width-1 then x2 = self.Width-1 end

	for i=x,x2 do
		self.Accessor:SetElement(i, row, value)
	end
end

function ArrayRenderer:SpanH(x, y, len, values)
	local elemSize = self.Accessor.BytesPerElement
	local rowSize = elemSize * len
	local dstoffset = self.Accessor:GetOffset(x, y)*elemSize

	NCopyBytes(self.Accessor.Data, values, dstoffset, 0, rowSize)
end

function ArrayRenderer:LineV(x,y,len,value)
	if x < 0 or x >= self.Width then return end

	local y1 = y
	local y2 = y + len-1
	if y1 < 0 then y1 = 0 end
	if y2 > self.Height-1 then y2 = self.Height-1 end

	for row = y1,y2 do
		self.Accessor:SetElement(x, row, value)
	end
end

function ArrayRenderer:Line(x1, y1, x2, y2, value)
	local liner = EFLA_Iterator(x1, y1, x2, y2)
	for x,y in liner do
		x = math.floor(x)
		y = math.floor(y)

		self.Accessor:SetElement(x,y,value)
	end
end

function maxwidth(x1,x2,x3)
	local minx = math.min(math.min(x1, x2), x3)
	local maxx = math.max(math.max(x1, x2), x3)
--print("Min/Max: ", minx, maxx)
	local maxwidth = maxx-minx+1

	return maxwidth
end

--[[


function ArrayRenderer:FillTriangle(x1, y1, x2, y2, x3, y3, value)
	local minX, minY, maxY,maxY = getTriangleBBox(x1, y1, x2, y2, x3, y3)

	for y = minY, maxY do
		for x = minX, maxX do
			if insideTriangle(tri, x,y) then
				self.Accessor:SetElement(x,y,value)
			end
		end
	end
end
--]]


function ArrayRenderer:FillTriangle(x1, y1, x2, y2, x3, y3, value)
	local triscan = ScanTriangle (vec2(x1,y1), vec2(x2,y2), vec2(x3,y3))

	local elemSize = self.Accessor.BytesPerElement
	local maxWidth = maxwidth(x1, x2, x3)
	local rowSize = maxWidth * elemSize
	--local rowstore = NAlloc(maxWidth, self.Accessor.TypeName, value)
	local remaining = 0

		-- Fill the scrath row with the intended value
	for i=1,maxWidth do
		self.ScratchRow[i-1] = value
	end

	for lx, ly, len, rx, ry, lu, ru in triscan do
		local lx1 = math.floor(lx+0.5)
		local rx1 = math.floor(rx+0.5)
		local newlen = rx1-lx1+1
--print(lx1, rx1, ly, newlen)
		local x = lx1
		local y = ly
		local len = newlen
		if len > 0 then
			--self:LineH(x, y, len, value)
			self:SpanH(x, y, len, self.ScratchRow)
		end
		--local remaining = math.min((self.Width - x), len)
	end
end



function ArrayRenderer:FillQuad(x1,y1, x2,y2, x3,y3, x4,y4, value)
	self:FillTriangle(x1,y1, x2,y2, x3,y3, value)
	self:FillTriangle(x1,y1, x3,y3, x4,y4, value)
end

function ArrayRenderer:FillRectangle(x,y,width,height, value)
	-- Create a row
	--local elemSize = self.Accessor.BytesPerElement
	--local rowSize = width * elemSize
	--local rowstore = NAlloc(width, self.Accessor.TypeName, value)

	-- Fill the scrath row with the intended value
	for i=1,width do
		self.ScratchRow[i-1] = value
	end

	for row =y,y+height-1 do
		self:SpanH(x, row, width, self.ScratchRow)
	end
end

function ArrayRenderer:BitBlt(src,  dstX, dstY, srcBounds, driver, elementOp)
	TransferArray2D(self.Accessor, src,  dstX, dstY, srcBounds, driver, elementOp)
end
