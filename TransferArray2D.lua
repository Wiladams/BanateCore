require "RectI"

function SrcCopy(dst, src)
	return src
end


--
-- Function: ComposeRect
--
-- Description: This is a driver for the TransferArray2D function
-- It will do a transfer a pixel at a time, calling the supplied
-- pixelOp function to calculate the value of each pixel
-- This gives the opportunity to do procedural image construction
-- as the output can be completely fabricated
--
-- Inputs:
--	dst
--	src
--	targetFrame
--	dstFrame
--	srcRect
--	transferOp
--
function ComposeRect(dst, src,targetFrame, dstFrame, srcRect, transferOp)
	-- Now we have all the information to do a pixel by
	-- pixel copy
	for row = 0,targetFrame.Height-1 do
		local sy = srcRect.Y + row
		local dy = dstFrame.Y + row
		for col=0,targetFrame.Width-1 do
			local sx = srcRect.X + col
			local dx = dstFrame.X + col

			-- get source pixel
			local srcPixel = src:Get(sx, sy)

			-- get destination pixel
			local dstPixel = dst:Get(dx, dy)

			-- TransferOp is any function that can take two pixels
			-- and return a new pixel value
			-- If it returns nil, we skip that pixel
			local transferPixel = transferOp(dstPixel, srcPixel)
			if transferPixel then
				dst:Set(dx, dy, transferPixel)
			end
		end
	end
end

function CopyRect(dst, src,targetFrame, dstFrame, srcRect)
	-- Now we have all the information to do a pixel by
	-- pixel copy
	for row = 0,targetFrame.Height-1 do
		local dstoffset = dst:GetOffset(dstFrame.X, dstFrame.Y + row)
		local srcoffset = src:GetOffset(srcRect.X, srcRect.Y + row)

		dst:Copy(src, dstoffset, srcoffset, targetFrame.Width)
	end
end

function TransferArray2D(dst, src,  dstX, dstY, srcBounds, driver, elementOp)
	elementOp = elementOp or SrcCopy
	srcBounds = srcBounds or RectI(0,0,src.Width, src.Height)
	driver = driver or CopyRect

	local targetFrame, dstFrame, srcRect  = CalculateTargetFrame(
		dstX, dstY, dst.Width, dst.Height,
		src.Width, src.Height, srcBounds)

	driver(dst, src, targetFrame, dstFrame, srcRect, elementOp)
end
