local ffi = require "ffi"

function NAlloc(n, typename, init)
	local data = nil
	typename = typename or "unsigned char"

	if type(typename) == "string" then
		local efmt = string.format("%s [?]", typename)
		data = ffi.new(efmt, n)
	end

	if init then
		for i=0,n-1 do
			data[i] = init
		end
	end

	return data
end

function NSizeOf(thing)
	return ffi.sizeof(thing)
end

function NByteOffset(typename, numelem)
	return ffi.sizeof(typename) * numelem
end

--
-- Basic native memory byte copy
-- This routines checks the bounds of the elements
-- so it won't go over.
--
-- Input:
--	dst - Must be pointer to a ctype
--	src - Must be pointer to a ctype
--	dstoffset - Offset, starting at 0, if nil, will be set to 0
--	srcoffset - Offset in source, starting at 0, if nil, will be set to 0
--	srclen - number of bytes of source to copy, if nil, will copy all bytes
--
-- Return:
--	Nil if the copy failed
--  Number of bytes copied if succeeded
--
function NCopyBytes(dst, src, dstoffset, srcoffset, srclen)
	local dstSize = ffi.sizeof(dst)
	local srcSize = ffi.sizeof(src)

	srclen = srclen or srcSize
	dstoffset = dstoffset or 0
	srcoffset = srcoffset or 0

	local dstBytesAvailable = dstSize - dstoffset
	local srcBytesAvailable = srcSize - srcoffset
	local srcBytesToCopy = math.min(srcBytesAvailable, srclen)
	local nBytesToCopy = math.min(srcBytesToCopy, dstBytesAvailable)

	-- Use the right offset
	local bytedst = ffi.cast("unsigned char *", dst)
	local bytesrc = ffi.cast("unsigned char *", src)

	ffi.copy(bytedst+dstoffset, bytesrc+srcoffset, nBytesToCopy)

	return nBytesToCopy
end

function NSetBytes(dst, value, dstoffset, nbytes)
	local dstSize = ffi.sizeof(dst)
	local srcLen = nbytes or dstSize

	local dstBytesAvailable = dstSize - dstoffset
	nBytesToCopy = math.miin(dstBytesAvailable, srcLen)

	local bytedst = ffi.cast("unsigned char *", dst)

	ffi.fill(bytedst+dstoffset, nBytesToCopy, value)

	return nBytesToCopy
end
