-- NativeTypes.lua

--[[
This file contains some basic types and functions that are useful
for interacting with LuaJIT native types.

Although the memory management types are similar to what is found
the std C library, they are not named the same because they behave
in ways that are different.

One behavioral change is that bounds checking is always used when copying.

Another is since Lua allows for default vaues, the order of parameters
is optimized for specifying the minimal set of parameters.
--]]

local ffi = require "ffi"

-- Declaration of some basic types
-- These are the same as found in
-- The .net languages
ffi.cdef[[
	typedef unsigned char	Byte;
	typedef int16_t			Int16;
	typedef int16_t			UInt16;
	typedef int32_t			Int32;
	typedef uint32_t		UInt32;
	typedef int64_t			Int64;
	typedef uint64_t		UInt64;
	typedef float			Single;
	typedef double			Double;

]]






