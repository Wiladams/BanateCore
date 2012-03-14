local ffi = require "ffi"

ffi.cdef[[
	typedef struct {
		int X;
		int Y;
		int Width;
		int Height;
	} RectI;
]]

RectI = nil
RectI_mt = {
	__tostring = function(self)
		return string.format("RectI(%d, %d, %d, %d)",
			self.X, self.Y, self.Width, self.Height)
	end,

	__eq = function(lhs, rhs)
		return lhs.X == rhs.X and
		lhs.Y == rhs.Y and
		lhs.Width == rhs.Width and
		lhs.Height == rhs.Height
	end,

	__index = {
		TypeName = "RectI",
		Size = ffi.sizeof("RectI"),

		ToBytes = function(self)
			return ffi.string(self,ffi.sizeof("RectI"))
		end,

		Clone = function(self)
			local newRect = RectI(self.X, self.Y, self.Width, self.Height)
			return newRect
		end,

		IsEmpty = function(self)
			return self.Width == 0 and self.Height == 0
		end,

		Contains = function(self, x, y)
			if x < self.X or y < self.Y then
				return false
			end

			if x > (self.X + self.Width-1) or y > (self.Y + self.Height-1) then
				return false
			end

			return true
		end,

		Intersection = function(lhs, rhs)
			local x1 = math.max(lhs.X, rhs.X);
			local x2 = math.min(lhs.X+lhs.Width, rhs.X+rhs.Width);
			local y1 = math.max(lhs.Y, rhs.Y);
			local y2 = math.min(lhs.Y+lhs.Height, rhs.Y+rhs.Height);

			if (x2 >= x1 and y2 >= y1) then
				return RectI(x1, y1, x2-x1, y2-y1);
			end

			return RectI()
		end,
	}
}
RectI = ffi.metatype("RectI", RectI_mt)


function CalculateTargetFrame(dstX, dstY, dstWidth, dstHeight,
	srcWidth,  srcHeight, srcBounds)
	local srcFrame = RectI(0,0,srcWidth, srcHeight)
	local srcRect = srcFrame:Intersection(srcBounds)

	-- Figure out frame of destination
	dstX = dstX or 0
	dstY = dstY or 0
	local dstWidth = dstWidth - dstX
	local dstHeight = dstHeight - dstY
	local dstFrame = RectI(dstX, dstY, dstWidth, dstHeight)

	-- Get the intersection of the dstFrame and the srcRect
	-- To figure out where bits will actually be placed
	local targetBounds = RectI(dstX, dstY, srcRect.Width, srcRect.Height)
	local targetFrame = dstFrame:Intersection(targetBounds)

	return targetFrame, dstFrame, srcRect
end
