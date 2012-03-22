-- ArrayRenderer.lua
local ffi = require"ffi"
local bit = require"bit"

local bnot = bit.bnot
local band = bit.band
local bor = bit.bor
local lshift = bit.lshift
local rshift = bit.rshift
require "Triangle"
require "EFLA"
require "TransferArray2D"
require "glsl_math"

local class = require "class"

class.ArrayRenderer()


function ArrayRenderer:_init(accessor)
	self.Accessor = accessor
	self.Width = accessor.Width
	self.Height = accessor.Height
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
	local elemSize = NSizeOf(values[0])
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

function ArrayRenderer:FillTriangle(x1, y1, x2, y2, x3, y3, value)
	local triscan = ScanTriangle (x1,y1, x2,y2, x3,y3)

	local elemSize = NSizeOf(value.TypeName)
	local maxWidth = maxwidth(x1, x2, x3)
	local rowSize = maxWidth * elemSize
	local rowstore = NAlloc(maxWidth, value.TypeName, value)

	for x,y,len in triscan do
		x = math.floor(x+0.5)
		y = math.floor(y+0.5)
		len = math.floor(len+0.5)

		self:LineH(x, y, len, value)
		--self:SpanH(x, y, len, rowstore)
	end
end

function ArrayRenderer:FillQuad(x1,y1, x2,y2, x3,y3, x4,y4, value)
	self:FillTriangle(x1,y1, x2,y2, x3,y3, value)
	self:FillTriangle(x1,y1, x3,y3, x4,y4, value)
end

function ArrayRenderer:FillRectangle(x,y,width,height, value)
	-- Create a row
	local elemSize = NSizeOf(value.TypeName)
	local rowSize = width * elemSize
	local rowstore = NAlloc(width, value.TypeName, value)

	for row =y,y+height-1 do
		self:SpanH(x, row, width, rowstore)
	end
end

function ArrayRenderer:BitBlt(src,  dstX, dstY, srcBounds, driver, elementOp)
	TransferArray2D(self.Accessor, src,  dstX, dstY, srcBounds, driver, elementOp)
end
