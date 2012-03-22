-- ByteArray.lua

local ffi = require "ffi"
local C = ffi.C



ffi.cdef[[
typedef struct {
	unsigned int Length;
	unsigned char *data;
} array_b;
]]



ByteArray = nil
ByteArray_mt = {
	__index = {
		new = function(self, size, init)
			self.data = ffi.new("unsigned char[?]", size);
			self.Length = size;
			if init then
				for i=0,size-1 do
					self.data[i] = init
				end
			end
			return self;
		end,

		CopyBytes = function(self, dstoffset, src, srcoffset, srclen)
			dstoffset = dstoffset or 0
			srcoffset = srcoffset or 0
			srclen = srclen or 0

			local dstBytesAvailable = self.Length - dstoffset
			local nBytesToCopy = math.min(srclen, dstBytesAvailable)

			-- Use the right offset
			ffi.copy(self.data+dstoffset, src+srcoffset, nBytesToCopy)
		end,

		Copy = function(self, src, offset, len, srcoffset)
			offset = offset or 0
			len = len or src.Length

			local nBytesAvailable = self.Length - offset
			local nBytesToCopy = math.min(math.min(len, src.Length), nBytesAvailable)

			-- Use the right offset
			ffi.copy(self.data+offset, src.data, nBytesToCopy)
		end,

		Get = function(self, offset)
			return self.data[offset]
		end,

		Put = function(self, value, offset)
			self.data[offset] = value
		end,
	},
	__tostring = function(self)
		return string.format("Length: %d", self.Length);
	end,
}
ByteArray = ffi.metatype("array_b", ByteArray_mt)

