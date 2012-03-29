-- Array2DRenderer.lua

if not BanateCore_000 then
require "Triangle"
require "EFLA"
require "TransferArray2D"
require "glsl_math"
end

class.Array2DRenderer()


function Array2DRenderer:_init(width, height, data, typename)
	self.Data = data
	self.Width = width
	self.Height = height
	self.TypeName = typename

	self.BytesPerElement = ffi.sizeof(typename)
	self.RowStride = ffi.sizeof(data[0])
	self.ScratchRow = Array1D(self.Width, self.TypeName)
end

function Array2DRenderer:GetByteOffset(x,y)
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
function Array2DRenderer:GetPixel(x, y)
	return self.Data[y][x]
end

-- Do a SRC_COPY of the specified value into the buffer
-- Do not worry about any alpha or anti aliasing
function Array2DRenderer:SetPixel(x, y, value)
	self.Data[y][x] = value
end


function Array2DRenderer:LineH(x, y, len, value)
	local row = y
	local x2 = x + len-1
	if x < 0 then x = 0 end

	if x2 > self.Width-1 then x2 = self.Width-1 end

	for i=x,x2 do
		self.Data[row][i] = value
	end
end

function Array2DRenderer:SpanH(x, y, len, values)
	local rowSize = self.BytesPerElement * len
	local dstoffset = self:GetByteOffset(x, y)

	NCopyBytes(self.Data, values, dstoffset, 0, rowSize)
end

function Array2DRenderer:LineV(x,y,len,value)
	if x < 0 or x >= self.Width then return end

	local y1 = y
	local y2 = y + len-1
	if y1 < 0 then y1 = 0 end
	if y2 > self.Height-1 then y2 = self.Height-1 end

	for row = y1,y2 do
		self.Data[row][x] = value
	end
end

function Array2DRenderer:Line(x1, y1, x2, y2, value)
	local liner = EFLA_Iterator(x1, y1, x2, y2)

	for x,y in liner do
		x = math.floor(x)
		y = math.floor(y)

		if x>0 and y>0 then
			self.Data[y][x] = value
		end
	end
end


function Array2DRenderer:FillTriangle(x1, y1, x2, y2, x3, y3, value)
	local triscan = ScanTriangle (vec2(x1,y1), vec2(x2,y2), vec2(x3,y3))


	for lx, ly, len, rx, ry, lu, ru in triscan do
		local lx1 = math.floor(lx+0.5)
		local rx1 = math.floor(rx+0.5)
		local newlen = rx1-lx1+1

		local x = lx1
		local y = ly
		local len = newlen
		if len > 0 then
			self:LineH(x, y, len, value)
		end
	end
end

function Array2DRenderer:FillQuad(x1,y1, x2,y2, x3,y3, x4,y4, value)
	self:FillTriangle(x1,y1, x2,y2, x3,y3, value)
	self:FillTriangle(x1,y1, x3,y3, x4,y4, value)
end

function Array2DRenderer:FillRectangle(x,y,width,height, value)
	for row =y,y+height-1 do
		self:LineH(x, row, width, value)
	end
end

function Array2DRenderer:BitBlt(src,  dstX, dstY, srcBounds, driver, elementOp)
	TransferArray2D(self.Accessor, src,  dstX, dstY, srcBounds, driver, elementOp)
end


function Array2DRenderer.Create(width, height, data, typename)
	return Array2DRenderer(width, height, data, typename)
end
