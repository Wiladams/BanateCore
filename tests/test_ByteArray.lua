-- Put this at the top of any test
local ppath = package.path..';..\\?.lua'
package.path = ppath;

require "ByteArray"

local ffi = require "ffi"

print("ByteArray.lua - TEST")

function printByteArray(ba)
	print(ba.data)
	for i=0, ba.Length-1 do
		print(ba.data[i])
	end
end

local ba = ByteArray():new(10, 127)
--print(ba)
--printByteArray(ba)

local bb = ByteArray():new(2, 255)
ba:Copy(bb,5,1)
--printByteArray(ba)


print("ByteArray:CopyBytes")
--local bytea = s_byte_t():new(7)
local bytea = ffi.new("unsigned char[1]",7)
--print(bytea.Length)
--print(bytea.data[0])

--print(bytea[0])

local bd = ByteArray():new(10)
--dstoffset, src, srclen, srcoffset
bd:CopyBytes(0, bytea, 0, 1)
bd:CopyBytes(3, bytea, 0, 1)
printByteArray(bd)

