-- PixelBufferRenderer.lua
local ffi = require"ffi"
local bit = require"bit"

local bnot = bit.bnot
local band = bit.band
local bor = bit.bor
local lshift = bit.lshift
local rshift = bit.rshift


local class = require "class"



class.PixelBufferRenderer()

PixelBufferRenderer.Defaults = {
	Pixels = nil,
	Width = 0,
	Height = 0,
}


function PixelBufferRenderer:_init(params)
	params = params or PixelBufferRenderer.Defaults

	self.Width = params.Width
	self.Height = params.Height
	self.Extent = {self.Width, self.Height}

	self.Pixels = params.Pixels
	self.BitsPerPixel = params.BitsPerPixel or self.Pixels[0].BitsPerPixel
end

function PixelBufferRenderer:GetOffset(x,y)
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
function PixelBufferRenderer:GetPixel(x, y)
	local offset = self:GetOffset(x,y)
	if not offset then return nil end

	return self.Pixels[offset]
end

-- Do a SRC_COPY of the specified value into the buffer
-- Do not worry about any alpha or anti aliasing
function PixelBufferRenderer:CopyPixel(x, y, value)
	local offset = self:GetOffset(x,y)
	if not offset then return nil end

	self.Pixels[offset] = value
end

-- Blend with the one in the buffer.  The 'cover' is used
-- for anti-aliasing, not for opacity
function PixelBufferRenderer:BlendPixel(x, y, value, cover)
	local offset = self:GetOffset(x,y)
	if not offset then return nil end

	self.Pixels[offset] = value
end

function PixelBufferRenderer:CopyHLine(x, y, len, value)
	local row = y
	local x2 = x + len-1
	if x < 0 then x = 0 end

	if x2 > self.Width-1 then x2 = self.Width-1 end

	local offset1 = self:GetOffset(x, row)
	local offset2 = self:GetOffset(x2, row)

	for i=offset1,offset2 do
		self.Pixels[i] = value
	end
end

function PixelBufferRenderer:CopyVLine(x,y,len,value)

	-- quick reject if x is out of range
	if x < 0 or x >= self.Width then return end
	local y1 = y
	local y2 = y + len-1
	if y1 < 0 then y1 = 0 end
	if y2 > self.Height-1 then y2 = self.Height-1 end

	local offset = self:GetOffset(x,y1)

	for row = y1,y2 do
		self.Pixels[offset] = value
		offset = offset + self.Width
	end
end


function PixelBufferRenderer:BlendHLine(x, y, len, value, cover)
	local row = y
	local x2 = x + len-1
	if x < 0 then x = 0 end

	if x2 > self.Width-1 then x2 = self.Width-1 end

	local offset1 = self:GetOffset(x, row)
	local offset2 = self:GetOffset(x2, row)

	for i=offset1,offset2 do
		self.Pixels[i] = value
	end
end


function PixelBufferRenderer:BlendVLine(x,y,len,value, cover)

	-- quick reject if x is out of range
	if x < 0 or x >= self.Width then return end
	local y1 = y
	local y2 = y + len-1
	if y1 < 0 then y1 = 0 end
	if y2 > self.Height-1 then y2 = self.Height-1 end

	local offset = self:GetOffset(x,y1)

	for row = y1,y2 do
		self.Pixels[offset] = value
		offset = offset + self.Width
	end
end



function PixelBufferRenderer:BlendSolidHSpan(x, y, len, value, covers)
	local row = y
	local x2 = x + len-1
	if x < 0 then x = 0 end

	if x2 > self.Width-1 then x2 = self.Width-1 end

	local offset1 = self:GetOffset(x, row)
	local offset2 = self:GetOffset(x2, row)

	for i=offset1,offset2 do
		self.Pixels[i] = value
	end
end


function PixelBufferRenderer:BlendSolidVSpan(x,y,len,value, covers)

	-- quick reject if x is out of range
	if x < 0 or x >= self.Width then return end
	local y1 = y
	local y2 = y + len-1
	if y1 < 0 then y1 = 0 end
	if y2 > self.Height-1 then y2 = self.Height-1 end

	local offset = self:GetOffset(x,y1)

	for row = y1,y2 do
		self.Pixels[offset] = value
		offset = offset + self.Width
	end
end



function PixelBufferRenderer:BlendColorHSpan(x, y, len, values, covers)
	local row = y
	local x2 = x + len-1
	if x < 0 then x = 0 end

	if x2 > self.Width-1 then x2 = self.Width-1 end

	local offset1 = self:GetOffset(x, row)
	local offset2 = self:GetOffset(x2, row)

	local srcoffset=0
	for i=offset1,offset2 do
		self.Pixels[i] = values[srcoffset]
		srcoffset = srcoffset+1
	end
end


function PixelBufferRenderer:BlendColorVSpan(x,y,len,values, covers)

	-- quick reject if x is out of range
	if x < 0 or x >= self.Width then return end
	local y1 = y
	local y2 = y + len-1
	if y1 < 0 then y1 = 0 end
	if y2 > self.Height-1 then y2 = self.Height-1 end

	local offset = self:GetOffset(x,y1)

	for row = y1,y2 do
		self.Pixels[offset] = values[1]
		offset = offset + self.Width
	end
end
