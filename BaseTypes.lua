local ffi = require"ffi"
local bit = require "bit"
local rshift = bit.rshift

--[[
	The following are common base types that are found
	within typical programming languages.  They represent
	the common numeric types.

	These base types are particularly useful when
	interop to C libraries is required.  Using these types
	will reduce the amount of conversions that occur when
	marshalling to/from the C functions.
--]]


bool = ffi.typeof("unsigned char")
byte = ffi.typeof("unsigned char")
sbyte = ffi.typeof("char")
char = ffi.typeof("int")
short = ffi.typeof("short")
ushort = ffi.typeof("unsigned short")
int = ffi.typeof("int")
uint = ffi.typeof("unsigned int")
long = ffi.typeof("__int64")
ulong = ffi.typeof("unsigned __int64")

float = ffi.typeof("float")
double = ffi.typeof("double")

--[[
	These definitions allow for easy array construction.
	A typical usage would be:

		shorts(32, 16)

	This will allocate an array of 32 shorts, initialied to the value '16'
	If the initial value is not specified, a value of '0' is used.
--]]

boolv = ffi.typeof("unsigned char[?]")
bytev = ffi.typeof("unsigned char[?]")
sbytev = ffi.typeof("char[?]")
charv = ffi.typeof("int[?]")
shortv = ffi.typeof("short[?]")
ushortv = ffi.typeof("unsigned short[?]")
intv = ffi.typeof("int[?]")
uintv = ffi.typeof("unsigned int[?]")
longv = ffi.typeof("__int64[?]")
ulongv = ffi.typeof("unsigned __int64[?]")

floatv = ffi.typeof("float[?]")
doublev = ffi.typeof("double[?]")

function floatVectorSize(vec)
	return rshift(ffi.sizeof(vec),3)
end
