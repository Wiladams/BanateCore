-- glsl_types.lua

local ffi = require"ffi"
local C = ffi.C
local bit = require "bit"
local rshift = bit.rshift

require "BaseTypes"


vec2 = function(x,y) return floatv(2,x,y) end
vec3 = function(x,y,z) return floatv(3,x,y,z) end
vec4 = function(x,y,z,w) return floatv(4,x,y,z,w) end

--[==[
ffi.cdef[[
// GLSL Data Types
typedef struct _vec2 {
	float data[2];
} vec2;

//typedef float[3] vec3;

typedef struct _vec3 {
	float data[3];
} vec3;

typedef struct _vec4 {
	float data[4];
} vec4;

// Integer types
typedef struct _ivec2 {
	int data[2];
} ivec2;

typedef struct _ivec3 {
	int data[3];
} ivec3;

typedef struct _ivec4 {
	int data[4];
} ivec4;

// Unsigned int
typedef struct _uvec2 {
	unsigned int data[2];
} uvec2;

typedef struct _uvec3 {
	unsigned int data[3];
} uvec3;

typedef struct _uvec4 {
	unsigned int data[4];
} uvec4;


// bool
typedef struct _bvec2 {
	bool data[2];
} bvec2;

typedef struct _bvec3 {
	bool data[3];
} bvec3;

typedef struct _bvec4 {
	bool data[4];
} bvec4;

]]




-- GLSL allows the programmer to access values of a vector
-- using multiple naming conventions
--
-- x, y, z, w - typical for coordinates
-- r, g, b, a - typical for colors
-- s, t, p, q - typical for texture access
--
-- The swizzler functions allow the Lua programmer to use the
-- various vec objects in the same way.  So, although the basic
-- data structures are declared with data members: d1, d2, d3, d4
-- They can be accessed with the more common names: x, y, z, etc...
--
-- glsl_set_swizzler - Ideally this is set as the __nexindex metamethod
-- on a structure/table.  It is called whenever a value is to be set.
function glsl_set_swizzler(obj, key, value)
	local itype = type(key)

	if itype == "number" then
		obj.data[key] = value

		return obj
	end

	if itype == "string" then
		if key == 'r' or key == 'x' or key == 's' then
			obj.data[0] = value
		elseif key == 'g' or key == 'y' or key == 't' then
			obj.data[1] = value
		elseif key == "b" or key == "z" or key == "p" then
			obj.data[2] = value
		elseif key == "a" or key == "w" or key == "q" then
			obj.data[3] = value
		end
	end

	return obj
end

-- glsl_get_swizzler - Ideally this is set as the __index metamethod
-- on a structure/table.  It is called whenever a value is to be returned.

function glsl_get_swizzler(value, index)
--print("glsl_get_swizzler: ", value, index)
	local itype = type(index)

	if itype == "number" then
		return value.data[index]
	end

	if itype == "string" then
		-- If it's one of the common names, then return
		-- the appropriate field
		if index == 'r' or index == 'x' or index == 's' then
			return value.data[0]
		elseif index == 'g' or index == 'y' or index == 't' then
			return value.data[1]
		elseif index == "b" or index == "z" or index == "q" then
			return value.data[2]
		elseif index == "a" or index == "w" or index == "s" then
			return value.data[3]
		else
			--return a function
		end
	end

	return nil
end

function vec_tostring(vec)
	local nElems = #vec
	local res = {}

	table.insert(res, "{")
	for i=1,nElems do
		table.insert(res, vec[i-1])
		if i < nElems then
			table.insert(res, ',')
		end
	end
	table.insert(res, "}")

	return table.concat(res)
end

function vec_eq(a, b)
	local len = #a

	for i=1,len do
		if a[i-1] ~= b[i-1] then
			return false
		end
	end
	return true
end






vec2 = nil
vec2_mt = {

	__tostring = vec_tostring,

	__index = glsl_get_swizzler,

	__newindex = glsl_set_swizzler,

	__len = function(a) return 2 end,

	__eq = vec_eq,

	__unm = function(a)
		return vec2(-a.d1, -a.d2)
	end,

	__add = function(a, b)
		return vec2(a.d1+b.d1, a.d2+b.d2)
	end,

	__sub = function(a, b)
		return vec2(a.d1-b.d1, a.d2-b.d2)
	end,
}
vec2 = ffi.metatype("vec2", vec2_mt)

vec3 = nil
vec3_mt = {
	__call = function(t,k)
		print("Call")
	end,

	__tostring = vec_tostring,

	__index = glsl_get_swizzler,

	__newindex = glsl_set_swizzler,

	__len = function(a) return 3 end,

	__eq = vec_eq,

	__unm = function(a)
		return vec3(-a.d1, -a.d2, -a.d3)
	end,

	__add = function(a, b)
		return vec3(a.d1+b.d1, a.d2+b.d2, a.d3+b.d3)
	end,

	__sub = function(a, b)
		return vec3(a.d1-b.d1, a.d2-b.d2, a.d3-b.d3)
	end,
}
vec3 = ffi.metatype("vec3", vec3_mt)

vec4 = nil
vec4_mt = {
	__tostring = vec_tostring,

	__index = glsl_get_swizzler,

	__newindex = glsl_set_swizzler,

	__len = function(a) return 4 end,

	-- relational
	__eq = vec_eq,

	-- Arithmetic
	__unm = function(a)
		return vec4(-a.d1, -a.d2, -a.d3, -a.d4)
	end,

	__add = function(a, b)
		return vec4(a.d1+b.d1, a.d2+b.d2, a.d3+b.d3, a.d4+b.d4)
	end,

	__sub = function(a, b)
		return vec4(a.d1-b.d1, a.d2-b.d2, a.d3-b.d3, a.d4-b.d4)
	end,
}
vec4 = ffi.metatype("vec4", vec4_mt)
--]==]

