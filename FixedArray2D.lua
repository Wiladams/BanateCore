require "000"

class.FixedArray2D()


function FixedArray2D:_init(width, height, typename, init)
	width = width or 1
	height = height or 1
	typename = typename or "unsigned char"

	self.TypeName = typename
	self.PtrTypeName = string.format("%s*",self.TypeName)

	--  Allocate the data buffer
	local nelems = width * height
	self.Data = NAlloc(nelems, typename, init)

	-- Set other attributes
	self.Width = width
	self.Height = height
	self.Length = width*height
	self.SizeInBytes = NByteOffset(typename, self.Length)
	self.BytesPerElement = NByteOffset(typename, 1)
	self.BitsPerElement = self.BytesPerElement * 8
end


function FixedArray2D:__tostring()
	return string.format("Type: %s\nWidth: %d Height: %d\nLength: %d\nBytes: %d\nBitsPerElement: %d",
		self.TypeName, self.Width, self.Height, self.Length, self.SizeInBytes, self.BitsPerElement)
end


--
-- Copy a numberr of elements from a source array to our array.
-- Can specify both source and destination offsets.
-- The offsets are specified in number of array elements.
-- They are turned into byte offsets, then native byte copy routine
-- is used.
--
function FixedArray2D:Copy(src, dstoffset,srcoffset, srclen)
	dstoffset = dstoffset or 0
	srcoffset = srcoffset or 0
	srclen = srclen or src.Length

	local dstbyteOffset = NByteOffset(self.TypeName, dstoffset)
	local srcbyteoffset = NByteOffset(self.TypeName, srcoffset)
	local srcbytelen = NByteOffset(self.TypeName, srclen)

	local bytesCopied = NCopyBytes(self.Data, src.Data,
		dstbyteOffset,
		srcbyteoffset, srcbytelen)

	return bytesCopied
end

function FixedArray2D:GetOffset(col, row)
	col = col or 0
	row = row or 0

	if col < 0 or col >= self.Width then return nil end
	if row < 0 or row >= self.Height then return nil end

	local offset = row * self.Width + col

	return offset;
end

function FixedArray2D:Get(col, row)
	local offset = self:GetOffset(col, row)
	if not offset then return nil end

	return self.Data[offset]
end

function FixedArray2D:GetElement(col, row)
	return self:Get(col,row)
end


function FixedArray2D:Set(col, row,value)
	local offset = self:GetOffset(col, row)
	if not offset then return nil end

	self.Data[offset] = value
end

function FixedArray2D:SetElement(col, row,value)
	self:Set(col, row, value)
end

function FixedArray2D:SetElements(col, row, len, values)
	local data = ffi.cast(self.PtrTypeName, self.Data)
	local dstoffset = self:GetOffset(x,y)
	local elemSize = NSizeOf(self.TypeName)
	dstoffset = dstoffset * elemSize
	srcoffset = 0
	srclen = len*elemSize

	NCopyBytes(data, values, dstoffset, srcoffset, srclen)
end



