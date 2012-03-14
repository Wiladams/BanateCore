-- pixelbuffer.lua
--require "NativeTypes"
require "Pixel"

local class = require "class"
local ffi = require"ffi"

PixmapOrientation = {
    -- The least row of the image is at the low byte of memory.  Rows progress
    -- higher as memory increases.
    TopToBottom = 0,

    -- The highest row of the image is stored at the low byte of memory.  Rows of
    -- the image decrease as memory increases.
    BottomToTop = 1,
}

class.PixelBuffer()

PixelBuffer.Defaults = {
	Origin = {0,0},
	Extent = {1,1},
	PixelType = PixelRGB,
	Orientation = PixmapOrientation.TopToBottom,
	ArraySize = 1,
	PixelCount = 1,
}

function PixelBuffer:_init(params)
	params = params or PixelBuffer.Defaults

	local origin = params.Origin or PixelBuffer.Defaults.Origin
	local extent = params.Extent or PixelBuffer.Defaults.Extent

	self.Origin = {origin[1], origin[2]}
	self.Extent = {extent[1], extent[2]}

	self.Width = self.Extent[1]
	self.Height = self.Extent[2]
	self.Orientation = params.Orientation or PixelBuffer.Defaults.Orientation
	self.ArraySize = self.Width * self.Height
	self.PixelCount = self.ArraySize
	self.PixelType = params.PixelType or PixelBuffer.Defaults.PixelType
	self.DefaultPixel = self.PixelType()
	self.BitsPerPixel = self.DefaultPixel.BitsPerPixel

	local pixeldata = FixedArray2D(self.Width, self.Height, self.DefaultPixel.TypeName)

	self.Pixels = pixeldata
end

function PixelBuffer:__tostring()
	local str = string.format("Width: %d\nHeight: %d\nPixel Type: %s",
		self.Extent[1],
		self.Extent[2],
		tostring(self.DefaultPixel))

	return str
end

-- Find the offset for a pixel, using
-- boundary checking as well
function PixelBuffer:GetOffset(x,y)
	if x<0 or x >= self.Extent[1] then
		return nil
	end

	if y<0 or y >= self.Extent[2] then
		return nil
	end

	local offset = 0;

	if (self.Orientation == PixmapOrientation.TopToBottom) then
		offset = x + (self.Extent[1] * y);
	else
		offset = x + (self.Extent[1] * (self.Extent[2] - 1 - y));
	end

	--local offset = (y*self.Width) + x
	return offset
end

function PixelBuffer:SetPixel(x, y, value)
	self.Pixels:Set(x, y, value)
end

-- Retrieve a pixel from the array
function PixelBuffer:GetPixel(x, y)
	return self.Pixels:Get(x, y)
end

