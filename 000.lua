ffi = require"ffi"
C = ffi.C

bit = require"bit"
bnot = bit.bnot
band = bit.band
bor = bit.bor
bxor = bit.bxor
rrotate = bit.ror
lrotate = bit.rol

lshift = bit.lshift
rshift = bit.rshift


strlen = string.len
getchar = string.char
getbyte = string.byte



--- Provides a reuseable and convenient framework for creating classes in Lua.
-- Two possible notations: <br> <code> B = class(A) </code> or <code> class.B(A) </code>. <br>
-- <p>The latter form creates a named class. </p>
-- See the Guide for further <a href="../../index.html#class">discussion</a>
-- @module pl.class

local error, getmetatable, io, pairs, rawget, rawset, setmetatable, tostring, type =
    _G.error, _G.getmetatable, _G.io, _G.pairs, _G.rawget, _G.rawset, _G.setmetatable, _G.tostring, _G.type
-- this trickery is necessary to prevent the inheritance of 'super' and
-- the resulting recursive call problems.
local function call_ctor (c,obj,...)
    -- nice alias for the base class ctor
    local base = rawget(c,'_base')
    if base then obj.super = rawget(base,'_init') end
    local res = c._init(obj,...)
    obj.super = nil
    return res
end

local function is_a(self,klass)
    local m = getmetatable(self)
    if not m then return false end --*can't be an object!
    while m do
        if m == klass then return true end
        m = rawget(m,'_base')
    end
    return false
end

local function class_of(klass,obj)
    if type(klass) ~= 'table' or not rawget(klass,'is_a') then return false end
    return klass.is_a(obj,klass)
end

local function _class_tostring (obj)
    local mt = obj._class
    local name = rawget(mt,'_name')
    setmetatable(obj,nil)
    local str = tostring(obj)
    setmetatable(obj,mt)
    if name then str = name ..str:gsub('table','') end
    return str
end

local function tupdate(td,ts)
    for k,v in pairs(ts) do
        td[k] = v
    end
end

local function _class(base,c_arg,c)
    c = c or {}     -- a new class instance, which is the metatable for all objects of this type
    -- the class will be the metatable for all its objects,
    -- and they will look up their methods in it.
    local mt = {}   -- a metatable for the class instance

    if type(base) == 'table' then
        -- our new class is a shallow copy of the base class!
        tupdate(c,base)
        c._base = base
        -- inherit the 'not found' handler, if present
        if rawget(c,'_handler') then mt.__index = c._handler end
    elseif base ~= nil then
        error("must derive from a table type",3)
    end

    c.__index = c
    setmetatable(c,mt)
    c._init = nil

    if base and rawget(base,'_class_init') then
        base._class_init(c,c_arg)
    end

    -- expose a ctor which can be called by <classname>(<args>)
    mt.__call = function(class_tbl,...)
        local obj = {}
        setmetatable(obj,c)

        if rawget(c,'_init') then -- explicit constructor
            local res = call_ctor(c,obj,...)
            if res then -- _if_ a ctor returns a value, it becomes the object...
                obj = res
                setmetatable(obj,c)
            end
        elseif base and rawget(base,'_init') then -- default constructor
            -- make sure that any stuff from the base class is initialized!
            call_ctor(base,obj,...)
        end

        if base and rawget(base,'_post_init') then
            base._post_init(obj)
        end

        if not rawget(c,'__tostring') then
            c.__tostring = _class_tostring
        end
        return obj
    end
    -- Call Class.catch to set a handler for methods/properties not found in the class!
    c.catch = function(handler)
        c._handler = handler
        mt.__index = handler
    end
    c.is_a = is_a
    c.class_of = class_of
    c._class = c
    -- any object can have a specified delegate which is called with unrecognized methods
    -- if _handler exists and obj[key] is nil, then pass onto handler!
    c.delegate = function(self,obj)
        mt.__index = function(tbl,key)
            local method = obj[key]
            if method then
                return function(self,...)
                    return method(obj,...)
                end
            elseif self._handler then
                return self._handler(tbl,key)
            end
        end
    end
    return c
end

--- create a new class, derived from a given base class. <br>
-- Supporting two class creation syntaxes:
-- either <code>Name = class(base)</code> or <code>class.Name(base)</code>
-- @class function
-- @name class
-- @param base optional base class
-- @param c_arg optional parameter to class ctor
-- @param c optional table to be used as class
--class
class = setmetatable({},{
    __call = function(fun,...)
        return _class(...)
    end,
    __index = function(tbl,key)
        if key == 'class' then
            io.stderr:write('require("pl.class").class is deprecated. Use require("pl.class")\n')
            return class
        end
        local env = _G
        return function(...)
            local c = _class(...)
            c._name = key
            rawset(env,key,c)
            return c
        end
    end
})






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


-- Base types matching those found in the .net frameworks
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






--[[
	Native Memory Allocation
--]]

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

