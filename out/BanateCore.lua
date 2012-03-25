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

-- PixelBufferRenderer.lua

class.Array2DAccessor()

Array2DAccessor.Defaults = {
	Data = nil,
	Width = 0,
	Height = 0,
	TypeName = "unsigned char",
	BytesPerElement = 1,
	Alignment = 1,
}


function Array2DAccessor:_init(params)
	params = params or ArrayAccessor.Defaults

	self.TypeName = params.TypeName or Array2DAccessor.Defaults.TypeName
	self.PtrTypeName = string.format("%s*",self.TypeName)

	self.Width = params.Width or Array2DAccessor.Defaults.Width
	self.Height = params.Height or Array2DAccessor.Defaults.Height
	self.Extent = {self.Width, self.Height}

	self.Data = params.Data
	self.Alignment = params.Alignment or Array2DAccessor.Defaults.Alignment

	self.BytesPerElement = params.BytesPerElement or Array2DAccessor.Defaults.BytesPerElement
	self.BitsPerElement = params.BitsPerElement or self.BytesPerElement*8
end

function Array2DAccessor:GetOffset(x,y)
	if x<0 or x >= self.Width then
		return nil
	end

	if y<0 or y >= self.Height then
		return nil
	end

	local offset = (y*self.Width) + x

	return offset
end

-- Retrieve a pixel from the array
function Array2DAccessor:GetElement(x, y)
	local data = ffi.cast(self.TypeName, self.Data)
	local offset = self:GetOffset(x,y)
	local value = data[offset]

	return value
end

-- Do a SRC_COPY of the specified value into the buffer
-- Do not worry about any alpha or anti aliasing
function Array2DAccessor:SetElement(x, y, value)
	local data = ffi.cast(self.TypeName, self.Data)
	local offset = self:GetOffset(x,y)

	data[offset] = value
end


function Array2DAccessor:SetElements(col, row, len, values)
	local data = ffi.cast(self.TypeName, self.Data)
	local offset = self:GetOffset(x,y)

end

-- ArrayRenderer.lua

class.ArrayRenderer()


function ArrayRenderer:_init(accessor)
	self.Accessor = accessor
	self.Width = accessor.Width
	self.Height = accessor.Height

	self.ScratchRow = NAlloc(self.Width, self.Accessor.TypeName)
end

function ArrayRenderer:GetOffset(x,y)
	if x<0 or x >= self.Width then
		return nil
	end

	if y<0 or y >= self.Height then
		return nil
	end

	local offset = (y*self.Width) + x

	return offset
end

-- Retrieve a pixel from the array
function ArrayRenderer:GetPixel(x, y)
	local value = self.Accessor:GetElement(x,y)
	return value
end

-- Do a SRC_COPY of the specified value into the buffer
-- Do not worry about any alpha or anti aliasing
function ArrayRenderer:SetPixel(x, y, value)
	self.Accessor:SetElement(x,y,value)
end


function ArrayRenderer:LineH(x, y, len, value)
	local row = y
	local x2 = x + len-1
	if x < 0 then x = 0 end

	if x2 > self.Width-1 then x2 = self.Width-1 end

	for i=x,x2 do
		self.Accessor:SetElement(i, row, value)
	end
end

function ArrayRenderer:SpanH(x, y, len, values)
	local elemSize = self.Accessor.BytesPerElement
	local rowSize = elemSize * len
	local dstoffset = self.Accessor:GetOffset(x, y)*elemSize

	NCopyBytes(self.Accessor.Data, values, dstoffset, 0, rowSize)
end

function ArrayRenderer:LineV(x,y,len,value)
	if x < 0 or x >= self.Width then return end

	local y1 = y
	local y2 = y + len-1
	if y1 < 0 then y1 = 0 end
	if y2 > self.Height-1 then y2 = self.Height-1 end

	for row = y1,y2 do
		self.Accessor:SetElement(x, row, value)
	end
end

function ArrayRenderer:Line(x1, y1, x2, y2, value)
	local liner = EFLA_Iterator(x1, y1, x2, y2)
	for x,y in liner do
		x = math.floor(x)
		y = math.floor(y)

		self.Accessor:SetElement(x,y,value)
	end
end

function maxwidth(x1,x2,x3)
	local minx = math.min(math.min(x1, x2), x3)
	local maxx = math.max(math.max(x1, x2), x3)
--print("Min/Max: ", minx, maxx)
	local maxwidth = maxx-minx+1

	return maxwidth
end

--[[


function ArrayRenderer:FillTriangle(x1, y1, x2, y2, x3, y3, value)
	local minX, minY, maxY,maxY = getTriangleBBox(x1, y1, x2, y2, x3, y3)

	for y = minY, maxY do
		for x = minX, maxX do
			if insideTriangle(tri, x,y) then
				self.Accessor:SetElement(x,y,value)
			end
		end
	end
end
--]]


function ArrayRenderer:FillTriangle(x1, y1, x2, y2, x3, y3, value)
	local triscan = ScanTriangle (vec2(x1,y1), vec2(x2,y2), vec2(x3,y3))

	local elemSize = self.Accessor.BytesPerElement
	local maxWidth = maxwidth(x1, x2, x3)
	local rowSize = maxWidth * elemSize
	--local rowstore = NAlloc(maxWidth, self.Accessor.TypeName, value)
	local remaining = 0

		-- Fill the scrath row with the intended value
	for i=1,maxWidth do
		self.ScratchRow[i-1] = value
	end

	for lx, ly, len, rx, ry, lu, ru in triscan do
		local lx1 = math.floor(lx+0.5)
		local rx1 = math.floor(rx+0.5)
		local newlen = rx1-lx1+1
--print(lx1, rx1, ly, newlen)
		local x = lx1
		local y = ly
		local len = newlen
		if len > 0 then
			--self:LineH(x, y, len, value)
			self:SpanH(x, y, len, self.ScratchRow)
		end
		--local remaining = math.min((self.Width - x), len)
	end
end



function ArrayRenderer:FillQuad(x1,y1, x2,y2, x3,y3, x4,y4, value)
	self:FillTriangle(x1,y1, x2,y2, x3,y3, value)
	self:FillTriangle(x1,y1, x3,y3, x4,y4, value)
end

function ArrayRenderer:FillRectangle(x,y,width,height, value)
	-- Create a row
	--local elemSize = self.Accessor.BytesPerElement
	--local rowSize = width * elemSize
	--local rowstore = NAlloc(width, self.Accessor.TypeName, value)

	-- Fill the scrath row with the intended value
	for i=1,width do
		self.ScratchRow[i-1] = value
	end

	for row =y,y+height-1 do
		self:SpanH(x, row, width, self.ScratchRow)
	end
end

function ArrayRenderer:BitBlt(src,  dstX, dstY, srcBounds, driver, elementOp)
	TransferArray2D(self.Accessor, src,  dstX, dstY, srcBounds, driver, elementOp)
end
--[[
	base64.lua
	base64 encoding and decoding for LuaJIT
	William Adams <william_a_adams@msn.com>
	17 Mar 2012
	This code is hereby placed in the public domain

	The derivation of this code is from a public domain
	implementation in 'C' by Luiz Henrique de Figueiredo <lhf@tecgraf.puc-rio.br>
--]]

base64={}
base64.base64bytes = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
base64.whitespacechars = "\n\r\t \f\b"

function base64.iswhitespace(c)
	local found = whitespacechars:find(c)
	return found ~= nil
end


function base64.char64index(c)
	local index = base64.base64bytes:find(c)

	if not index then
		return nil
	end

	return  index - 1
end



function base64.bencode(b, c1, c2, c3, n)
	local tuple = (c3+256*(c2+256*c1));
	local i;
	local s = {}

	for i=0, 3 do
		local offset = (tuple % 64)+1
		local c = base64.base64bytes:sub(offset, offset)

		s[4-i] = c;
		tuple = rshift(tuple, 6)	-- tuple/64;
	end

	for i=n+2, 4 do
		s[i]='=';
	end

	local encoded = table.concat(s)

	table.insert(b,encoded);
end


function base64.encode(s)
	local l = strlen(s)

	local b = {};
	local n = math.floor(l/3)
	for i=1,n do
		local c1 = getbyte(s, (i-1)*3+1)
		local c2 = getbyte(s, (i-1)*3+2)
		local c3 = getbyte(s, (i-1)*3+3)
		base64.bencode(b,c1,c2,c3,3);
	end

	-- Finish off the last few bytes
	local leftovers = l%3

	if leftovers == 1 then
		local c1 = getbyte(s, (n*3)+1)
		base64.bencode(b,c1,0,0,1);
	elseif leftovers == 2 then
		local c1 = getbyte(s, (n*3)+1)
		local c2 = getbyte(s, (n*3)+2)
		base64.bencode(b,c1,c2,0,2);
	end

	return table.concat(b)
end


function base64.bdecode(b, c1, c2, c3, c4, n)
	local tuple = c4+64*(c3+64*(c2+64*c1));
	local s={};

	for i=1,n-1 do
		local shifter = 8 * (3-i)
		local abyte = band(rshift(tuple, shifter), 0xff)

		s[i] = getchar(abyte)
	end

	local decoded = table.concat(s)
	table.insert(b, decoded)
end

function base64.decode(s)
	local l = strlen(s);
	local b = {};
	local n=0;
	t = {}	-- char[4];
	local offset = 1

	local continue = true
	while (offset <= l) do
		local c = s:sub(offset,offset)	-- *s++;
		offset = offset + 1

		if c == 0 then
			return table.concat(b);
		elseif c == '=' then
			if n ==  1 then
				base64.bdecode(b,t[1],0,0,0,1);
			end
			if n == 2 then
				base64.bdecode(b,t[1],t[2],0,0,2);
			end
			if n == 3 then
				base64.bdecode(b,t[1],t[2],t[3],0,3);
			end

			-- If we've swallowed the '=', then
			-- we're at the end of the string, so return
			return table.concat(b)
		elseif base64.iswhitespace(c) then
			-- If whitespace, then do nothing
		else
			local p = base64.char64index(c);
			if (p==nil) then
				return nil;
			end

			t[n+1]= p;
			n = n+1
			if (n==4) then
				base64.bdecode(b,t[1],t[2],t[3],t[4],4);
				n=0;
			end
		end
	end

	-- if we've gotten to here, we've reached
	-- the end of the string, and there were
	-- no padding characters, so return decoded
	-- string in full
	return table.concat(b);
end
-- ByteArray.lua


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

--[[
    "Extremely Fast Line Algorithm"

	Original Author: Po-Han Lin (original version: http://www.edepot.com/algorithm.html)

	Port To Lua Iterator: William Adams (http://williamaadams.wordpress.com)
	x1 X component of the start point
	y1 Y component of the start point
	x2 X component of the end point
	y2 Y component of the end point
--]]

--[[
	Comment: By doing this as an interator, there is more flexibility in
	where it can be used.

	Typical usage:

	local aline = EFLA_Iterator(0,0,10,10)
	for x,y in aline do
		color  = somenewvalue
		setPixel(x,y,color)
	end

--]]

function EFLA_Iterator(x1, y1, x2, y2, skiplast)
	skiplast = skiplast or false
	local yLonger = false;
	local incrementVal = 0;
	local endVal = 0;

	local shortLen = (y2-y1);
	local longLen = (x2-x1);

	if (math.abs(shortLen) > math.abs(longLen)) then
		local swap = shortLen;
		shortLen = longLen;
		longLen = swap;
		yLonger = true;
	end

	endVal = longLen;

	if (longLen<0) then
		incrementVal = -1;
		longLen = -longLen;
	else
		incrementVal = 1;
	end

	local decInc = 0;

	if longLen == 0 then
		decInc = shortLen;
	else
		decInc = (shortLen/longLen);
	end

	local j = 0 - decInc;
	local i = 0 - incrementVal

--print("EFLA")
--print(shortLen, longLen, decInc, incrementVal, endVal)
--print("YLonger: ", yLonger)

	if yLonger then
		return function()
			i = i + incrementVal
			if not skiplast then
				if math.abs(i) > math.abs(endVal) then return nil end
			else
				if math.abs(i) > math.abs(endVal-1) then return nil end
			end

			j = j + decInc
			local x = x1 + j
			local y = y1 + i
			local u
			if (skiplast) then u = i/(endVal-1) else u = i/endVal end

			return x,y, u
		end
	else
		return function()
			i = i + incrementVal
			if not skiplast then
				if math.abs(i) > math.abs(endVal) then return nil end
			else
				if math.abs(i) > math.abs(endVal-1) then return nil end
			end

			j = j + decInc
			local x = x1 + i
			local y = y1 + j
			local u
			if (skiplast) then u = i/(endVal-1) else u = i/endVal end

			return x,y, u
		end
	end
end


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



--=====================================
-- This is public Domain Code
-- Contributed by: William A Adams
-- September 2011
--
-- Implement a language skin that
-- gives a GLSL feel to the coding
--=====================================
--require "glsl_types"

pi = math.pi;


function apply(f, v)
	if type(v) == "number" then
		return f(v)
	end


	local nelem = floatVectorSize(v)
	local res = floatv(nelem)
	for i=0,nelem-1 do
		res[i] = f(v[i])
	end

	return res
end

function apply2(f, v1, v2)
	if type(v1) == "number" then
		return f(v1, v2)
	end

	local nelem = floatVectorSize(v1)
	local res = floatv(nelem)
	if type(v2)=="number" then
		for i=0,nelem-1 do
			res[i] = f(v1[i],v2)
		end
	else
		for i=0,nelem-1 do
			res[i] = f(v1[i], v2[i])
		end
	end

	return res
end

function add(x,y)
	return apply2(function(x,y) return x + y end,x,y)
end

function sub(x,y)
	return apply2(function(x,y) return x - y end,x,y)
end

function mul(x,y)
	if type(x)=="number" then -- swap params, just in case y is a vector
		return apply2(function(x,y) return x * y end,y,x)
	else
 		return apply2(function(x,y) return x * y end,x,y)
	end
end

function div(x,y)
	return apply2(function(x,y) return x / y end,x,y)
end

-- improved equality test with tolerance
function equal(v1,v2,tol)
	assert(type(v1)==type(v2),"equal("..type(v1)..","..type(v2)..") : incompatible types")
	if not tol then tol=1E-12 end
	return apply(function(x) return x<=tol end,abs(sub(v1,v2)))
end

function notEqual(v1,v2,tol)
	assert(type(v1)==type(v2),"equal("..type(v1)..","..type(v2)..") : incompatible types")
	if not tol then tol=1E-12 end
	return apply(function(x) return x>tol end,abs(sub(v1,v2)))
end

--=====================================
--	Angle and Trigonometry Functions (5.1)
--=====================================

function radians(degs)
	return apply(math.rad, degs)
end

function degrees(rads)
	return apply(math.deg, rads)
end

function sin(rads)
	return apply(math.sin, rads)
end

function cos(rads)
	return apply(math.cos, rads)
end

function tan(rads)
	return apply(math.tan, rads)
end

function asin(rads)
	return apply(math.asin, rads)
end

function acos(rads)
	return apply(math.acos, rads)

end



function atan(rads)
	return apply(math.atan, rads)
end

function atan2(y,x)
	return apply2(math.atan2,y,x)
end

function sinh(rads)
	return apply(math.sinh, rads)
end

function cosh(rads)
	return apply(math.cosh, rads)
end


function tanh(rads)
	return apply(math.tanh, rads)
end

--[[
function asinh(rads)
	return apply(math.asinh, rads)
end

function acosh(rads)
	return apply(math.acosh, rads)
end

function atanh(rads)
	return apply(math.atanh, rads)
end
--]]

--=====================================
--	Exponential Functions (5.2)
--=====================================
function pow(x,y)
	return apply2(math.pow,x,y)
end

function exp2(x)
	return apply2(math.pow,2,x)
end

function log2(x)
	return apply(math.log,x)/math.log(2)
end

function sqrt(x)
	return apply(math.sqrt,x)
end

local function inv(x)
	return apply(function(x) return 1/x end,x)
end

function invsqrt(x)
	return inv(sqrt(x))
end

--=====================================
--	Common Functions (5.3)
--=====================================
function abs(x)
	return apply(math.abs, x)
end

function signfunc(x)
	if x > 0 then
		return 1
	elseif x < 0 then
		return -1
	end

	return 0
end

function sign(x)
	return apply(signfunc, x)
end

function floor(x)
	return apply(math.floor, x)
end

function trucfunc(x)
	local asign = sign(x)
	local res = asign * math.floor(math.abs(x))

	return res
end

function trunc(x)
	return apply(truncfunc, x)
end

function roundfunc(x)
	local asign = sign(x)
	local res = asign*math.floor((math.abs(x) + 0.5))

	return res
end

function round(x)
	return apply(roundfunc, x)
end


function ceil(x)
	return apply(math.ceil, x)
end

function fractfunc(x)
	return x - math.floor(x)
end

function fract(x)
	return apply(fractfunc, x)
end

function modfunc(x,y)
	return x - y * math.floor(x/y)
end

function mod(x,y)
	return apply2(modfunc, x, y)
end

function min2(x,y)
	return apply2(math.min, x, y)
end

function min(...)
	if arg.n == 2 then
		return min2(arg[1], arg[2])
	elseif arg.n == 3 then
		return math.min(math.min(arg[1], arg[2]), arg[3])
	end

	if type(arg[1]) == "table" then
		local lowest = math.huge
		for i=1,#arg[1] do
			lowest = math.min(lowest, arg[1][i])
		end

		return lowest
	end

	-- If we got to here, then it was invalid input
	return nil
end

function max2(x,y)
	return apply2(math.max, x, y)
end


function max(...)
	if arg.n == 2 then
		return max2(arg[1], arg[2])
	elseif arg.n == 3 then
		return math.max(math.max(arg[1], arg[2]), arg[3])
	end

	if type(arg[1]) == "table" then
		local highest = -math.huge
		for i=1,#arg[1] do
			highest = math.max(highest, arg[1][i])
		end

		return highest
	end

	-- If we got to here, then it was invalid input
	return nil
end





function clamp(x, minVal, maxVal)
	return min(max(x,minVal),maxVal)
end


function mixfunc(x, y, a)
	return x*(1.0 - a) + y * a
end

-- x*(1.0 - a) + y * a
-- same as...
-- x + s(y-x)
-- Essentially lerp
function mix(x, y, a)
	return add(x,mul(sub(y,x),a))
end


function stepfunc(edge, x)
	if (x < edge) then
		return 0;
	else
		return 1;
	end
end

function step(edge, x)
	return apply2(stepfunc, edge, x)
end

-- Hermite smoothing between two points
function hermfunc(edge0, edge1, x)
	local range = (edge1 - edge0);
	local distance = (x - edge0);
	local t = clamp((distance / range), 0.0, 1.0);
	local r = t*t*(3.0-2.0*t);

	return r;
end

function smoothstepfunc(edge0, edge1, x)
	if (x <= edge0) then
		return 0.0
	end

	if (x >= edge1) then
		return 1.0
	end

	return	herm(edge0, edge1, x);
end



function smoothstep(edge0, edge1, x)
	if type(x) == 'number' then
		local f = smoothstepfunc(edge0, edge1, x)
		return f
	end

	local res={}
	for i=1,#x do
		table.insert(res, smoothstepfunc(edge0[i], edge1[i], x))
	end

	return res
end

function isnan(x)
	if x == nil then
		return true
	end

	if x >= math.huge then
		return true
	end

	local res={}
	for i=1,#x do
		table.insert(res, x >= math.huge)
	end

	return res
end

function isinf(x)
	if type(x) == 'number' then
		local f = x >= math.huge
		return f
	end

	local res={}
	for i=1,#x do
		table.insert(res, x >= math.huge)
	end

	return res
end


--=====================================
--	Geometric Functions (5.4)
--=====================================
function dot(v1,v2)
	if type(v1) == 'number' then
		return v1*v2
	end

	if (type(v1) == 'table') then
		-- if v1 is a table
		-- it could be vector.vector
		-- or matrix.vector
		if type(v1[1] == "number") then
			local sum=0
			for i=1,#v1 do
				sum = sum + (v1[i]*v2[i])
			end
			return sum;
		else -- matrix.vector
			local res={}
			for i,x in ipairs(v1) do
				res[i] = dot(x,v2) end
			return res
		end
	end
end

function length(v)
	return math.sqrt(dot(v,v))
end

function distance(v1,v2)
	return length(sub(v1,v2))
end

function cross(v1, v2)
	if #v1 ~= 3 then
		return {0,0,0}
	end

	return {
		(v1[2]*v2[3])-(v2[2]*v1[3]),
		(v1[3]*v2[1])-(v2[3]*v1[1]),
		(v1[1]*v2[2])-(v2[1]*v1[2])
	}
end

function normalize(v1)
	return div(v1,length(v1))
end

function faceforward(n,i,nref)
	if dot(n,i)<0 then return n else return -n end
end

function reflect(i,n)
	return sub(i,mul(mul(2,dot(n,i)),n))
end

--=====================================
--	Vector Relational (5.4)
--=====================================
function isnumtrue(x)
	return x ~= nil and x ~= 0
end

function any(x)
	local nelem = floatVectorSize(x)
	for i=0,nelem-1 do
		local f = isnumtrue(x[i])
		if f then return true end
	end

	return false
end

function all(x)
	local nelem = floatVectorSize(x)
	for i=0,nelem-1 do
		local f = isnumtrue(x[i])
		if not f then return false end
	end

	return true
end

-- angle (in radians) between u and v vectors
function angle(u, v)
	if dot(u, v) < 0 then
		return math.pi - 2*asin(length(add(u,v))/2)
	else
		return 2*asin(distance(v,u)/2)
	end
end





local realv = floatv

-- Row ordering of elements
local m4r = {
	{0,1,2,3},
	{4,5,6,7},
	{8,9,10,11},
	{12,13,14,15}
}

-- Column ordering of elements
local m4c = {
	{0,4,8,12},
	{1,5,9,13},
	{2,6,10,14},
	{3,7,11,15}
}

local mc400 = 0
local mc401 = 4
local mc402 = 8
local mc403 = 12

local mc410 = 1
local mc411 = 5
local mc412 = 9
local mc413 = 13

local mc420 = 2
local mc421 = 6
local mc422 = 10
local mc423 = 14

local mc430 = 3
local mc431 = 7
local mc432 = 11
local mc433 = 15


-- Identity matrix for a 4x4 matrix
mat4_identity =  realv(16,1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1)


function mat4_new(a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p)
	a = a or 0
	b = b or 0
	c = c or 0
	d = d or 0

	e = e or 0
	f = f or 0
	g = g or 0
	h = h or 0

	i = i or 0
	j = j or 0
	k = k or 0
	l = l or 0

	m = m or 0
	n = n or 0
	o = o or 0
	p = p or 0

	return realv(16,a,b,c,d, e,f,g,h, i,j,k,l, m,n,o,p)
end


local function mat4_getoffset(row,col,roworder)
	if not roworder then
		-- column order
		return col*4 + row
	else
		-- row order
		return row*4 + col
	end
end

local function mat4_get(m, row, col, roworder)
	return m[mat4_getoffset(row,col,roworder)]
end

local function mat4_set(m, row, col, value, roworder)
	m[mat4_getoffset(row,col,roworder)] = value
	return m
end

local function mat4_clone(m)

	local res = mat4_new(
		m[0],m[1],m[2],m[3],
		m[4],m[5],m[6],m[7],
		m[8],m[9],m[10],m[11],
		m[12],m[13],m[14],m[15])

	return res
end

local function mat4_assign(a, b)
	for i=0,15 do
		a[i] = b[i]
	end
end

local function mat4_get_col(m, col, roworder)
	local res = realv(4)
	res[0] = mat4_get(m, 0,col, roworder)
	res[1] = mat4_get(m, 1,col, roworder)
	res[2] = mat4_get(m, 2,col, roworder)
	res[3] = mat4_get(m, 3,col, roworder)

	return res
end

local function mat4_set_col(m, col, vec, roworder)
	mat4_set(m, 0, col, vec[0], roworder)
	mat4_set(m, 1, col, vec[0], roworder)
	mat4_set(m, 2, col, vec[0], roworder)
	mat4_set(m, 3, col, vec[0], roworder)

	return m
end


local function mat4_get_row(m, row, roworder)
	local res = realv(4)

	res[0] = mat4_get(m, row,0,roworder)
	res[1] = mat4_get(m, row,1,roworder)
	res[2] = mat4_get(m, row,2,roworder)
	res[3] = mat4_get(m, row,3,roworder)

	return res
end

local function mat4_set_row(m, row, vec, roworder)
	mat4_set(m, row, 0, vec[0], roworder)
	mat4_set(m, row, 1, vec[0], roworder)
	mat4_set(m, row, 2, vec[0], roworder)
	mat4_set(m, row, 3, vec[0], roworder)

	return m
end

-- Matrix Multiplication
local function mat4_mul_mat4(res, a, b, roworder)
	function A(row,col)
		return mat4_get(a, row, col, roworder)
	end

	function B(row,col)
		return mat4_get(b, row, col, roworder)
	end

	function PS(row,col, value)
		mat4_set(res, row, col, value, roworder)
	end

	for i = 0,3 do
		local ai0=A(i,0);
		local ai1=A(i,1);
		local ai2=A(i,2);
		local ai3=A(i,3);

		PS(i,0, ai0 * B(0,0) + ai1 * B(1,0) + ai2 * B(2,0) + ai3 * B(3,0));
		PS(i,1, ai0 * B(0,1) + ai1 * B(1,1) + ai2 * B(2,1) + ai3 * B(3,1));
		PS(i,2, ai0 * B(0,2) + ai1 * B(1,2) + ai2 * B(2,2) + ai3 * B(3,2));
		PS(i,3, ai0 * B(0,3) + ai1 * B(1,3) + ai2 * B(2,3) + ai3 * B(3,3));
	end

	return res
end

local function mat4_mul_mat4_new(a, b, roworder)
	return mat4_mul_mat4(mat4_new(), a, b, roworder)
end

local function mat4_get_diagonal(res, m)
	res[0] = m[mc400]
	res[1] = m[mc411]
	res[2] = m[mc422]
	res[3] = m[mc433]

	return res
end

local function mat4_get_diagonal_new(m)
	return mat4_get_diagonal(realv(4), m)
end



local function mat4_sub_determinant(m, i, j)
    local x, y, ii, jj;
    local ret;
	local m3 = realv(9);

	function m3G(row,col)
		return m3[row*3+col]
	end

	function m3P(row,col, value)
		m3[row*3+col] = value
	end

    x = 0;
    for ii = 0, 3 do
		if (ii ~= i) then
			y = 0;

			for jj = 0,3 do
				if (jj ~= j) then

					m3P(x,y,m[(ii*4)+jj]);

					y = y + 1;
				end
			end

			x = x+1;
		end
	end

    ret = m3G(0,0)*(m3G(1,1)*m3G(2,2)-m3G(2,1)*m3G(1,2));
    ret = ret - m3G(0,1)*(m3G(1,0)*m3G(2,2)-m3G(2,0)*m3G(1,2));
    ret = ret + m3G(0,2)*(m3G(1,0)*m3G(2,1)-m3G(2,0)*m3G(1,1));

    return ret;
end


function mat4_inverse(mInverse, m)

    local i, j;
    local det =0
	local detij;

    -- First, calculate the sub determinant
    for i = 0,3 do
		local subdet = 0
		if band(i,0x1) > 0 then
			subdet = (-m[i] * mat4_sub_determinant(m, 0, i))
		else
			subdet = (m[i] * mat4_sub_determinant(m, 0,i))
		end

		det = det + subdet
	end

    det = 1 / det;

    -- calculate inverse
    for i = 0,3  do
        for j = 0,3 do
            detij = mat4_sub_determinant(m, j, i);
			local scratch
			if (band((i+j), 0x1) > 0) then
				scratch = (-detij * det)
			else
				scratch = (detij *det)
			end

            mInverse[(i*4)+j] = scratch;
		end
	end

	return mInverse
end

function mat4_inverse_new(m)
	return mat4_inverse(mat4_new(), m)
end

--[[
		TRANSFORMATION  MATRICES
--]]
-- Matrix creation
local function mat4_create_scale(res, x, y, z)
	mat4_assign(res, mat4_identity)

	mat4_set(res, 0,0, x)
	mat4_set(res, 1,1, y)
	mat4_set(res, 2,2, z)

	return res
end

local function mat4_create_scale_new(x,y,z)
	return mat4_create_scale(mat4_new(), x, y, z)
end

-- Create Translation Matrix
local function mat4_create_translation(res, x, y, z)
	mat4_assign(res, mat4_identity)

	mat4_set(res, 0, 3, x)
	mat4_set(res, 1, 3, y)
	mat4_set(res, 2, 3, z)

	return res
end

local function mat4_create_translation_new(x,y,z)
	return mat4_create_translation(mat4_new(), x, y, z)
end


-- Create Rotation Matrix
local function mat4_create_rotation(res, angle, x, y, z)
	local mag = 1/math.sqrt(x*x+y*y+z*z)
	local s = math.sin(angle)
	local c = math.cos(angle)

	mat4_assign(res, mat4_identity)

	-- Rotation matrix is normalized
	x = x * mag
	y = y * mag
	z = z * mag

	local xx = x * x
	local yy = y * y
	local zz = z * z
	local xy = x * y
	local yz = y * z
	local zx = z * x
	local xs = y * s
	local ys = y * s
	local zs = z * s

	local one_c = 1 - c;

	mat4_set(res, 0,0, (one_c*xx) + c)
	mat4_set(res, 0,1, (one_c*xy) - zs)
	mat4_set(res, 0,2, (one_c*zx) + ys)
	mat4_set(res, 0,3, 0)

	mat4_set(res, 1,0, (one_c*xy) + zs)
	mat4_set(res, 1,1, (one_c*yy) + c)
	mat4_set(res, 1,2, (one_c*yz) - xs)
	mat4_set(res, 1,3, 0)

	mat4_set(res, 2,0, (one_c*zx) -ys)
	mat4_set(res, 2,1, (one_c*yz) +xs)
	mat4_set(res, 2,2, (one_c*zz) + c)
	mat4_set(res, 2,3, 0)

	mat4_set(res, 3,0, 0)
	mat4_set(res, 3,1, 0)
	mat4_set(res, 3,2, 0)
	mat4_set(res, 3,3, 1)


	return res
end

local function mat4_create_rotation_new(angle, x, y, z)
	return mat4_create_rotation(mat4_new(), angle, x, y, z)
end


-- Transform a Point
-- Need to include the 'w'
local function mat4_transform_pt(res, m, pt)
	res[0] = m[mc400]*pt[0] + m[mc401]*pt[1] + m[mc402]*pt[2] + m[mc403]
	res[1] = m[mc410]*pt[0] + m[mc411]*pt[1] + m[mc412]*pt[2] + m[mc413]
	res[2] = m[mc420]*pt[0] + m[mc421]*pt[1] + m[mc422]*pt[2] + m[mc423]

	return res
end

local function mat4_transform_pt_new(m, pt)
	return mat4_transform_pt(realv(3), m, pt)
end

-- Transform a Vector
-- Need to ignore the 'w', as it is '0' for a vector
local function mat4_transform_vec(res, m, vec)
	res[0] = m[mc400]*vec[0] + m[mc401]*vec[1] + m[mc402]*vec[2]
	res[1] = m[mc410]*vec[0] + m[mc411]*vec[1] + m[mc412]*vec[2]
	res[2] = m[mc420]*vec[0] + m[mc421]*vec[1] + m[mc422]*vec[2]

	return res
end

local function mat4_transform_vec_new(m, vec)
	return mat4_transform_pt(realv(3), m, vec)
end



local function vec4_tostring(v)
	res={}

	table.insert(res,'{')
	for col = 0,3 do
		table.insert(res,v[col])
		if col < 3 then
			table.insert(res,',')
		end
	end
	table.insert(res,'}')

	return table.concat(res)
end

local function mat4_tostring(m, roworder)
	res={}

	table.insert(res,'{')
	for row = 0,3 do
		table.insert(res,'{')
		for col = 0,3 do
			table.insert(res,mat4_get(m, row,col))
			if col < 3 then
				table.insert(res,',')
			end
		end
		table.insert(res,'}')
		if row < 3 then
			table.insert(res, ',\n')
		end
	end
	table.insert(res, '}')

	return table.concat(res)
end

Mat4 = {
	new = mat4_new,
	Clone = mat4_clone,
	Assign = mat4_assign,

	Identity = mat4_identity,
	GetColumn = mat4_get_col,
	SetColumn = mat4_set_col,

	GetRow = mat4_get_row,
	SetRow = mat4_set_row,

	GetDiagonal = mat4_get_diagonal_new,

	Multiply = mat4_mul_mat4_new,
	Inverse = mat4_inverse_new,

	CreateRotation = mat4_create_rotation_new,
	CreateScale = mat4_create_scale_new,
	CreateTranslation = mat4_create_translation_new,

	TransformPoint = mat4_transform_pt_new,
	TransformNormal = mat4_transform_vec_new,

	vec4_tostring = vec4_tostring,
	tostring = mat4_tostring,
}
-- Pixel.lua


ffi.cdef[[

	typedef struct { uint8_t Lum; } pixel_Lum_b;
	typedef struct { uint8_t Lum, Alpha;} pixel_LumAlpha_b;

	typedef struct { uint8_t Red, Green, Blue, Alpha; } pixel_RGBA_b, *Ppixel_RGBA_b;
	typedef struct { uint8_t Red, Green, Blue; } pixel_RGB_b;

	typedef struct { uint8_t Blue, Green, Red, Alpha; } pixel_BGRA_b, *Ppixel_BGRA_b;
	typedef struct { uint8_t Blue, Green, Red; } pixel_BGR_b, *Ppixel_BGR_b;
]]


GrayConverter={}
GrayConverter_mt = {}

function GrayConverter.new(...)
	local new_inst = {}
	new_inst.redfactor = {}
	new_inst.greenfactor = {}
	new_inst.bluefactor = {}

	-- Based on old NTSC
	-- static float redcoeff = 0.299f;
	-- static float greencoeff = 0.587f;
	-- static float bluecoeff = 0.114f;

	-- New CRT and HDTV phosphors
	local redcoeff = 0.2225;
	local greencoeff = 0.7154;
	local bluecoeff = 0.0721;

	for i=1,256 do
		new_inst.redfactor[i] = math.min(56, math.floor(((i-1) * redcoeff) + 0.5));
		new_inst.greenfactor[i] = math.min(181, math.floor(((i-1) * greencoeff) + 0.5));
		new_inst.bluefactor[i] = math.min(18, math.floor(((i-1) * bluecoeff) + 0.5));
	end

	setmetatable(new_inst, GrayConverter_mt)

	return new_inst
end

function GrayConverter.Execute(self, r,g,b)
	local lum =
		self.redfactor[r+1] +
		self.greenfactor[g+1] +
		self.bluefactor[b+1];

	return lum
end

GrayConverter_mt.__call = GrayConverter.Execute;



local lumaker = GrayConverter.new()

-- LUMINANCE (GrayScale)
PixelLum = nil
PixelLum_mt = {
	__tostring = function(self) return string.format("PixelLum(%d)", self.Lum) end,
	__index = {
		TypeName = "pixel_Lum_b",
		BitsPerPixel = ffi.sizeof("pixel_Lum_b") * 8,
		Size = ffi.sizeof("pixel_Lum_b"),
		CreateBuffer = function(self, size)
			return ffi.new("pixel_Lum_b[?]", size)
		end,
		ToArray = function(self)
			return ffi.string(self,ffi.sizeof("pixel_Lum_b"))
		end,
		ToRGBA = function(self)
			local rgba = ffi.new("pixel_RGBA_b")
			rgba.Red = self.Lum
			rgba.Green = self.Lum
			rgba.Blue = self.Lum
			rgba.Alpha = 255
			return rgba
		end,
		CopyRGBA = function(self, rgba)
			local luminance = lumaker(rgba.Red, rgba.Green, rgba.Blue)
			self.Lum = luminance
			return self
		end,
	}
}
PixelLum = ffi.metatype("pixel_Lum_b", PixelLum_mt)

-- LUMINANCE w/ALPHA (GrayScale)
PixelLumAlpha = nil
PixelLumAlpha_mt = {
	__tostring = function(self)
		return string.format("PixelLumAlpha(%d,%d)", self.Lum, self.Alpha)
		end,

	__index = {
		TypeName = "pixel_LumAlpha_b",
		BitsPerPixel = ffi.sizeof("pixel_LumAlpha_b") * 8,
		Size = ffi.sizeof("pixel_LumAlpha_b"),
		CreateBuffer = function(self, size)
			return ffi.new("pixel_LumAlpha_b[?]", size)
		end,
		ToArray = function(self)
			return ffi.string(self,ffi.sizeof("pixel_LumAlpha_b"))
		end,
		ToRGBA = function(self)
			local rgba = ffi.new("pixel_RGBA_b")
			rgba.Red = self.Lum
			rgba.Green = self.Lum
			rgba.Blue = self.Lum
			rgba.Alpha = self.Alpha
			return rgba
		end,
		CopyRGBA = function(self, rgba)
			local luminance = lumaker(rgba.Red, rgba.Green, rgba.Blue)
			self.Lum = luminance
			self.Alpha = rgba.Alpha
			return self
		end,
	}
}
PixelLumAlpha = ffi.metatype("pixel_LumAlpha_b", PixelLumAlpha_mt)


-- RGB (Red, Green, Blue)
PixelRGB = nil
PixelRGB_mt = {
	__tostring = function(self)
			return string.format("PixelRGB(%d, %d, %d)",
			self.Red, self.Green, self.Blue)
		end,
	__index = {
		TypeName = "pixel_RGB_b",
		BitsPerPixel = ffi.sizeof("pixel_RGB_b") * 8,
		Size = ffi.sizeof("pixel_RGB_b"),
		CreateBuffer = function(self, size)
			return ffi.new("pixel_RGB_b[?]", size)
		end,
		Serialize = function(self)
			return string.format("PixelRGB(%d, %d, %d)",
			self.Red, self.Green, self.Blue)
		end,
		ToArray = function(self)
			return ffi.string(self,ffi.sizeof("pixel_RGB_b"))
		end,
		ToRGBA = function(self)
			local rgba = ffi.new("pixel_RGBA_b")
			rgba.Red = self.Red
			rgba.Green = self.Green
			rgba.Blue = self.Blue
			rgba.Alpha = 255
			return rgba
		end,
		CopyRGBA = function(self, rgba)
			self.Red = rgba.Red
			self.Green = rgba.Green
			self.Blue = rgba.Blue
			return self
		end,
	},
}
PixelRGB = ffi.metatype("pixel_RGB_b", PixelRGB_mt)


-- RGBA (Red, Green, Blue, with Alpha
PixelRGBA = nil
PixelRGBA_mt = {
	__tostring = function(self)
		return string.format("PixelRGBA(%d, %d, %d, %d)",
			self.Red, self.Green, self.Blue, self.Alpha)
		end,
	__index = {
		TypeName = "pixel_RGBA_b",
		BitsPerPixel = ffi.sizeof("pixel_RGBA_b") * 8,
		Size = ffi.sizeof("pixel_RGBA_b"),
		CreateBuffer = function(self, size)
			return ffi.new("pixel_RGBA_b[?]", size)
		end,
		ToArray = function(self)
			return ffi.string(self,ffi.sizeof("pixel_RGBA_b"))
		end,
		ToRGBA = function(self)
			local rgba = ffi.new("pixel_RGBA_b")
			rgba.Red = self.Red
			rgba.Green = self.Green
			rgba.Blue = self.Blue
			rgba.Alpha = self.Alpha
			return rgba
		end,
		CopyRGBA = function(self, rgba)
			self.Red = rgba.Red
			self.Green = rgba.Green
			self.Blue = rgba.Blue
			self.Alpha = rgba.Alpha
			return self
		end,
	},
}
PixelRGBA = ffi.metatype("pixel_RGBA_b", PixelRGBA_mt)



-- RGB (Red, Green, Blue)
PixelBGR = nil
PixelBGR_mt = {
	__tostring = function(self)
			return string.format("PixelBGR(%d, %d, %d)",
			self.Blue, self.Green, self.Red)
		end,
	__index = {
		TypeName = "pixel_BGR_b",
		BitsPerPixel = ffi.sizeof("pixel_BGR_b") * 8,
		Size = ffi.sizeof("pixel_BGR_b"),
		CreateBuffer = function(self, size)
			return ffi.new("pixel_BGR_b[?]", size)
		end,
		Serialize = function(self)
			return string.format("PixelBGR(%d, %d, %d)",
			self.Blue, self.Green, self.Red)
		end,
		ToArray = function(self)
			return ffi.string(self,ffi.sizeof("pixel_BGR_b"))
		end,
		ToRGBA = function(self)
			local rgba = ffi.new("pixel_RGBA_b")
			rgba.Red = self.Red
			rgba.Green = self.Green
			rgba.Blue = self.Blue
			rgba.Alpha = 255
			return rgba
		end,
		CopyRGBA = function(self, rgba)
			self.Red = rgba.Red
			self.Green = rgba.Green
			self.Blue = rgba.Blue
			return self
		end,
	},
}
PixelBGR = ffi.metatype("pixel_BGR_b", PixelBGR_mt)


-- RGB (Red, Green, Blue)
PixelBGRA = nil
PixelBGRA_mt = {
	__tostring = function(self)
			return string.format("PixelBGRA(%d, %d, %d %d)",
			self.Blue, self.Green, self.Red, self.Alpha)
		end,
	__index = {
		TypeName = "pixel_BGRA_b",
		BitsPerPixel = ffi.sizeof("pixel_BGRA_b") * 8,
		Size = ffi.sizeof("pixel_BGRA_b"),
		CreateBuffer = function(self, size)
			return ffi.new("pixel_BGRA_b[?]", size)
		end,
		Serialize = function(self)
			return string.format("PixelBGRA(%d, %d, %d, %d)",
			self.Blue, self.Green, self.Red, self.Alpha)
		end,
		ToArray = function(self)
			return ffi.string(self,ffi.sizeof("pixel_BGRA_b"))
		end,
		ToRGBA = function(self)
			local rgba = ffi.new("pixel_RGBA_b")
			rgba.Red = self.Red
			rgba.Green = self.Green
			rgba.Blue = self.Blue
			rgba.Alpha = self.Alpha
			return rgba
		end,
		CopyRGBA = function(self, rgba)
			self.Red = rgba.Red
			self.Green = rgba.Green
			self.Blue = rgba.Blue
			self.Alpha = rgba.Alpha
			return self
		end,
	},
}
PixelBGRA = ffi.metatype("pixel_BGRA_b", PixelBGRA_mt)




ffi.cdef[[
	typedef struct {
		int X;
		int Y;
		int Width;
		int Height;
	} RectI;
]]

RectI = nil
RectI_mt = {
	__tostring = function(self)
		return string.format("RectI(%d, %d, %d, %d)",
			self.X, self.Y, self.Width, self.Height)
	end,

	__eq = function(lhs, rhs)
		return lhs.X == rhs.X and
		lhs.Y == rhs.Y and
		lhs.Width == rhs.Width and
		lhs.Height == rhs.Height
	end,

	__index = {
		TypeName = "RectI",
		Size = ffi.sizeof("RectI"),

		ToBytes = function(self)
			return ffi.string(self,ffi.sizeof("RectI"))
		end,

		Clone = function(self)
			local newRect = RectI(self.X, self.Y, self.Width, self.Height)
			return newRect
		end,

		IsEmpty = function(self)
			return self.Width == 0 and self.Height == 0
		end,

		Contains = function(self, x, y)
			if x < self.X or y < self.Y then
				return false
			end

			if x > (self.X + self.Width-1) or y > (self.Y + self.Height-1) then
				return false
			end

			return true
		end,

		Intersection = function(lhs, rhs)
			local x1 = math.max(lhs.X, rhs.X);
			local x2 = math.min(lhs.X+lhs.Width, rhs.X+rhs.Width);
			local y1 = math.max(lhs.Y, rhs.Y);
			local y2 = math.min(lhs.Y+lhs.Height, rhs.Y+rhs.Height);

			if (x2 >= x1 and y2 >= y1) then
				return RectI(x1, y1, x2-x1, y2-y1);
			end

			return RectI()
		end,
	}
}
RectI = ffi.metatype("RectI", RectI_mt)


function CalculateTargetFrame(dstX, dstY, dstWidth, dstHeight,
	srcWidth,  srcHeight, srcBounds)
	local srcFrame = RectI(0,0,srcWidth, srcHeight)
	local srcRect = srcFrame:Intersection(srcBounds)

	-- Figure out frame of destination
	dstX = dstX or 0
	dstY = dstY or 0
	local dstWidth = dstWidth - dstX
	local dstHeight = dstHeight - dstY
	local dstFrame = RectI(dstX, dstY, dstWidth, dstHeight)

	-- Get the intersection of the dstFrame and the srcRect
	-- To figure out where bits will actually be placed
	local targetBounds = RectI(dstX, dstY, srcRect.Width, srcRect.Height)
	local targetFrame = dstFrame:Intersection(targetBounds)

	return targetFrame, dstFrame, srcRect
end

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


function FindTopmostPolyVertex(poly, nelems)
	local ymin = math.huge
	local vmin = 0;

	for i=1, nelems do
	--print(poly[i])
		if poly[i][1] < ymin then
			ymin = poly[i][1]
			vmin = i
		end
	end

	return vmin
end

function RotateVertices(poly, nelems, starting)
--print("RotateVertices: ", nelems, starting)
	local res={}
	local offset = starting
	for cnt=1,nelems do
		table.insert(res, poly[offset])
		offset = offset + 1
		if offset > nelems then
			offset = 1
		end
	end

	return res
end


function swap(a, b)
	return b, a
end

function getTriangleBBox(x0,y0, x1,y1, x2,y2)
	local minX = math.min(x0, math.min(x1, x2))
	local minY = math.min(y0, math.min(y1, y2))

	local maxX = math.max(x0, math.max(x1, x2))
	local maxY = math.max(y0, math.max(y1, y2))

	return minX, minY, maxX, maxY
end

function sortTriangle(v1, v2, v3)
	local verts = {v1, v2, v3}
	local topmost = FindTopmostPolyVertex(verts, 3)
	local sorted = RotateVertices(verts, 3, topmost)

	-- Top line flat

	-- Bottom line flat

	return sorted
end

function Triangle_DDA(x1, y1, x2, y2, skiplast)
	skiplast = skiplast or false
	local yLonger = false;
	local incrementVal = 1;
	local endVal = 0;

	local dY = (y2-y1);
	local dX = (x2-x1);

	endVal = dY;

	local decInc = 0;

	if dY == 0 then
		decInc = dX;
	else
		decInc = (dX/dY);
	end

	local j = 0 - decInc;
	local i = 0 - incrementVal

	return function()
		i = i + incrementVal
		if not skiplast then
			if i > endVal then return nil end
		else
			if i > (endVal-1) then return nil end
		end

		j = j + decInc
		local x = x1 + j
		local y = y1 + i
		local u
		if (skiplast) then u = i/(endVal-1) else u = i/endVal end

		return x,y, u
	end
end

function ScanTriangle ( v1, v2, v3)
	local a, b, y, last;

	local sorted = sortTriangle(v1, v2, v3)

	local x1, y1 = sorted[1][0], sorted[1][1]
	local x2, y2 = sorted[2][0], sorted[2][1]
	local x3, y3 = sorted[3][0], sorted[3][1]

	local ldda = nil
	local rdda = nil
	local longdda = nil

	-- Setup left and right edge dda iterators
	if x2 <= x1 then
		ldda = Triangle_DDA(x1,y1, x2,y2)
		rdda = Triangle_DDA(x1,y1, x3,y3)
		longdda = rdda
	else
		ldda = Triangle_DDA(x1,y1, x3,y3)
		rdda = Triangle_DDA(x1,y1, x2,y2)
		longdda = ldda
	end

	local lx, ly, lu
	local rx, ry, ru

	return function()
		-- start iterating down first edge, until we reach
		-- the y value of the second vertex
		lx,ly,lu = ldda()
		rx,ry,ru = rdda()

		if not lx then
			if ldda == longdda then
				return nil
			end

			ldda = Triangle_DDA(x2,y2,x3,y3)

			-- iterate once to skip over the first one
			-- which was already consumed by the previous edge
			lx,ly,lu = ldda()

			-- iterate once, to fill in the nil one that we're
			-- currently on
			lx,ly,lu = ldda()
		end

		if not rx then
			if rdda == longdda then
				return nil
			end

			rdda = Triangle_DDA(x2,y2,x3,y3)
			rx,ry,ru = rdda()
			rx,ry,ru = rdda()
		end

		local len = 0
		if rx and lx then
			len = rx-lx+1
		end

		return lx, ly, len, rx, ry, lu, ru
	end
end




--[[
	HELPER FUNCTIONS
--]]
vec2 = function(x,y) return floatv(2,x or 0,y or 0) end
vec3 = function(x,y,z) return floatv(3,x or 0,y or 0,z or 0) end
vec4 = function(x,y,z,w) return floatv(4,x or 0,y or 0,z or 0,w or 0) end

-- A Vector and a scalar
function vec3_apply1_new(a, op, func)
	local res = floatv(3)
	for i=0,2 do
		res[i] = func(a[i], op)
	end

	return res
end

function vec3_apply1(res, a, op, func)
	for i=0,2 do
		res[i] = func(a[i], op)
	end

	return res
end

function vec3_apply1_self(self, op, func)
	for i=0,2 do
		self[i] = func(self[i], op)
	end

	return self
end


-- Two vectors
function vec3_apply2_new(a, b, func)
	local res = floatv(3)
	for i=0,2 do
		res[i] = func(a[i], b[i])
	end

	return res
end

function vec3_apply2(res, a, b, func)
	for i=0,2 do
		res[i] = func(a[i], b[i])
	end

	return res
end

function vec3_apply2_self(self, b, func)
	for i=0,2 do
		self[i] = func(self[i], b[i])
	end

	return self
end

local function vec3_tostring(v)
	res={}

	table.insert(res,'{')
	for col = 0,2 do
		table.insert(res,v[col])
		if col < 2 then
			table.insert(res,',')
		end
	end
	table.insert(res,'}')

	return table.concat(res)
end

--[[
	Actual Math Functions
--]]

-- addition
local function vec3_add(res, a, b)
	return vec3_apply2(res, a, b, function(op1,op2) return op1 + op2 end)
end

local function vec3_add_new(a, b)
	return vec3_add(floatv(3), a, b)
end

local function vec3_add_self(a, b)
	return vec3_add(self, a, b)
end


-- Subtraction
local function vec3_sub(res, a, b)
	return vec3_apply2(res, a, b, function(op1,op2) return op1-op2 end)
end

local function vec3_sub_new(a, b)
	return vec3_sub(floatv(3), a, b)
end

local function vec3_sub_self(a, b)
	return vec3_sub(a, a, b)
end


-- Scale
local function vec3_scale(res, a, b)
	return vec3_apply2(res, a, b, function(op1,op2) return op1*op2 end)
end

local function vec3_scale_new(a, b)
	return vec3_scale(floatv(3), a, b)
end

local function vec3_scale_self(a, b)
	return vec3_scale(a, a, b)
end


-- Scale by scalar
local function vec3_scales(res, a, s)
	return vec3_apply1(res, a, s, function(op1,s) return op1*s end)
end

local function vec3_scales_new(a, s)
	return vec3_scales(floatv(3), a, s)
end

local function vec3_scales_self(a, s)
	return vec3_scales(a, a, s)
end


-- Cross product
local function vec3_cross(res, u, v)
	res[0] = u[1]*v[2] - v[1]*u[2];
	res[1] = -u[0]*v[2] + v[0]*u[2];
	res[2] = u[0]*v[1] - v[0]*u[1];

	return res
end

local function vec3_cross_new(u, v)
	return vec3_cross(floatv(3), u,v)
end


-- Dot product
local function vec3_dot(u, v)
	return u[0]*v[0] + u[1]*v[1] + u[2]*v[2]
end

local function vec3_angle_between(u,v)
	local tmp = vec3_dot(u,v)
	return math.acos(tmp)
end


-- Length
local function vec3_length_squared(u)
	return vec3_dot(u,u)
end

local function vec3_length(u)
	return math.sqrt(vec3_length_squared(u))
end


-- Normalize
local function vec3_normalize(res, u)
	local scalar = 1/vec3_length(u)
	return vec3_scales(res, u, scalar)
end

local function vec3_normalize_new(u)
	return vec3_normalize(floatv(3), u)
end

local function vec3_normalize_self(u)
	return vec3_normalize(u, u)
end

-- Distance
local function vec3_distance(u, v)
	return vec3_length(vec3_sub_new(u,v))
end



local function vec3_find_normal(res, point1, point2, point3)
	local v1 = vec3_sub_new(point1, point2)
	local v2 = vec3_sub_new(point2, point3)

	return vec3_cross(res, v1, v2)
end

local function vec3_find_normal_new(point1, point2, point3)
	return vec3_find_normal(vec3(), point1, point2, point3)
end



Vec3 = {
	vec3 = vec3,

	Add = vec3_add_new,
	Sub = vec3_sub_new,
	Mul = vec3_scale_new,
	Muls = vec3_scales_new,
	Div = vec3_div_new,
	Divs = vec3_divs_new,

	Dot = vec3_dot,
	Cross = vec3_cross_new,

	Length = vec3_length,

	Distance = vec3_distance,
	FindNormal = vec3_find_normal_new,
	Normalize = vec3_normalize_new,
	AngleBetween = vec3_angle_between,

	tostring = vec3_tostring,
}
--
-- zzz.lua
--
--[[
local Array2DAccessor = require "Array2DAccessor"
local ArrayRenderer = require "ArrayRenderer"
local base64 = require "base64"
local BaseTypes = require "BaseTypes"
local ByteArray = require "ByteArray"
local class = require "class"
local EFLA = require "EFLA"
local FixedArray2D = require "FixedArray2D"
local glsl_math = require "glsl_math"
local glsl_types = require "glsl_types"
local GrayConverter = require "GrayConverter"
local hashes = require "hashes"
local hmac = require "hmac"
local matrix = require "matrix"
local NativeMemory = require "NativeMemory"
local NativeTypes = require "NativeTypes"
local Pixel = require "Pixel"
local PixelBuffer = require "PixelBuffer"
local PixelBufferRenderer = require "PixelBufferRenderer"
local RectI = require "RectI"
local sha1 = require "sha1"
local sha2 = require "sha2"
local TransferArray2D = require "TransferArray2D"
local Triangle = require "Triangle"
local vec_func = require "vec_func"
local w32_ops = require "w32_ops"
--]]

return {
	ArrayRenderer = ArrayRenderer,
	Base64 = base64,
	class = class,
	FixedArray2D = FixedArray2D,
	Matrix = matrix,
	NativeMemory = NativeMemory,
	Pixel = Pixel,
	RectI = RectI,
	Vec = Vec3,
}
