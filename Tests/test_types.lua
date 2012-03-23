local ffi=require "ffi"
local bit = require "bit"
local band = bit.band
local bor = bit.bor

ffi.cdef[[
typedef unsigned char Byte;
typedef short			Int16;
typedef int 			Int32;
typedef float 			Single;
typedef double 			Double;
]]

--[[
local Byte
local Byte_mt = {
}
ffi.metatype("unsigned char", Byte_mt)
--]]

Byte = ffi.typeof("Byte")
Int16 = ffi.typeof("Int16")
Int32 = ffi.typeof("Int32")
Single = ffi.typeof("Single")
Double = ffi.typeof("Double")

local val1 = Int16(30)
local val2 = Byte(15)
local val3 = Double(val1 + val2)

print(tonumber(val3))

local bits1 = Byte(0x01)
local bits2 = Byte(0x10)
local bitsor = bor(tonumber(bits1), tonumber(bits2))
local bitsand = band(tonumber(bits1), tonumber(bits2))
local bitsplus = bits1+bits2

print("OR: ", tonumber(bitsor))
print("AND: ", tonumber(bitsand))

print("Plus: ", bitsplus, type(bitsplus))
