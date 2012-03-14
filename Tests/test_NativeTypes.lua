-- Put this at the top of any test
local ppath = package.path..';..\\?.lua'
package.path = ppath;


require "NativeTypes"
require "NativeMemory"

local ffi = require "ffi"

print("NativeTypes.lua - TEST");

local arr1typename = "short"

function printArray(ba, size)
	for i=0,size-1 do
		print(ba[i])
	end
end

function test_byte()
	-- create a byte array
	local byte = ffi.typeof("Byte")
	local ba = byte(30);
	print("Byte: ", tonumber(ba))
end

function test_offset()
	print("Size: ", ffi.sizeof("short"))
	local offset = NByteOffset("short", 1)
	print("Offset: ", offset)
end

function create_array1(typename, nelems)
	typename = typename or "unsigned char"
	nelems = nelems or 30

	-- Create an array of typed values
	local arr1type = ffi.typeof(typename)
	local arr1 = NAlloc(nelems, typename)

	for i=0,nelems-1 do
		arr1[i] = i+1
	end

	return arr1
end

function test_array1()
	local typename = "unsigned char"
	local arr1 = create_array1(typename, 30)

	local arrsize = NSizeOf(arr1)
	local elemtype = ffi.typeof(typename)
	local elemsize = NSizeOf(elemtype)
	local arrelems = arrsize/elemsize

	print("Array Size: ", arrsize)
	print("Element Size: ", elemsize)
	print("Num Elements: ", arrelems)

--print("  AFTER ASSIGNMENT  ")
--printArray(arr1, nelems);
end


function test_copy()
	local typename = "short"
	local nelems= 20
	local arr1 = create_array1(typename, nelems)


	local arr2 = NAlloc(5, typename)
	arr2[0] = 1
	arr2[1] = 2
	arr2[2] = 3
	arr2[3] = 4
	arr2[4] = 5

	local dstOffset = NByteOffset(typename, 5)
	local srcoffset = NByteOffset(typename, 1)
	local srclen = NByteOffset(typename, 3)

	NCopyBytes(arr1, arr2, dstOffset, srcoffset, srclen)

	print("AFTER COPY")
	printArray(arr1, nelems)
end

test_copy()



