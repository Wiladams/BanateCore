-- PixelBufferRenderer.lua
local ffi = require"ffi"
local bit = require"bit"

local bnot = bit.bnot
local band = bit.band
local bor = bit.bor
local lshift = bit.lshift
local rshift = bit.rshift


local class = require "class"



class.Array2DAccessor()

Array2DAccessor.Defaults = {
	Data = nil,
	Width = 0,
	Height = 0,
	TypeName = "unsigned char",
	BytesPerElement = 1,
	Alignment = 1,
}


function Array2DAccessor:_init(params)
	params = params or ArrayAccessor.Defaults

	self.TypeName = params.TypeName or Array2DAccessor.Defaults.TypeName
	--self.DefaultElement = ffi.new(self.TypeName)


	self.Width = params.Width or Array2DAccessor.Defaults.Width
	self.Height = params.Height or Array2DAccessor.Defaults.Height
	self.Extent = {self.Width, self.Height}

	self.Data = params.Data
	self.Alignment = params.Alignment or Array2DAccessor.Defaults.Alignment

	self.BytesPerElement = params.BytesPerElement or Array2DAccessor.Defaults.BytesPerElement
	self.BitsPerElement = params.BitsPerElement or self.BytesPerElement*8
end

function Array2DAccessor:GetOffset(x,y)
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
function Array2DAccessor:GetElement(x, y)
	local data = ffi.cast(self.TypeName, self.Data)
	local offset = self:GetOffset(x,y)
	local value = data[offset]

	return value
end

-- Do a SRC_COPY of the specified value into the buffer
-- Do not worry about any alpha or anti aliasing
function Array2DAccessor:SetElement(x, y, value)
	local data = ffi.cast(self.TypeName, self.Data)
	local offset = self:GetOffset(x,y)

	data[offset] = value
end
