-- glsl.lua

local ffi = require"ffi"
local C = ffi.C

ffi.cdef[[
// GLSL Data Types
typedef struct _vec2 {
	float d1, d2;
} vec2;

typedef struct _vec3 {
	float d1, d2, d3;
} vec3;

typedef struct _vec4 {
	float d1, d2, d3, d4;
} vec4;

// Integer types
typedef struct _ivec2 {
	int d1, d2;
} ivec2;

typedef struct _ivec3 {
	int d1, d2, d3;
} ivec3;

typedef struct _ivec4 {
	int d1, d2, d3, d4;
} ivec4;

// Unsigned int
typedef struct _uvec2 {
	unsigned int d1, d2;
} uvec2;

typedef struct _uvec3 {
	unsigned int d1, d2, d3;
} uvec3;

typedef struct _uvec4 {
	unsigned int d1, d2, d3, d4;
} uvec4;


// bool
typedef struct _bvec2 {
	bool d1, d2;
} bvec2;

typedef struct _bvec3 {
	bool d1, d2, d3;
} bvec3;

typedef struct _bvec4 {
	bool d1, d2, d3, d4;
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
		if key == 0 then
			obj.d1 = value
		end

		if key == 1 then
			obj.d2 = value
		end

		if key == 2 then
			obj.d3 = value
		end

		if key == 3 then
			obj.d4 = value
		end

		return obj
	end

	if itype == "string" then
		if key == 'r' or key == 'x' or key == 's' then
			obj.d1 = value
		elseif key == 'g' or key == 'y' or key == 't' then
			obj.d2 = value
		elseif key == "b" or key == "z" or key == "p" then
			obj.d3 = value
		elseif key == "a" or key == "w" or key == "q" then
			obj.d4 = value
		end
	end

	return obj
end

-- glsl_get_swizzler - Ideally this is set as the __index metamethod
-- on a structure/table.  It is called whenever a value is to be returned.

function glsl_get_swizzler(value, index)
print("glsl_get_swizzler: ", value, index)
	local itype = type(index)

	if itype == "number" then
		if index == 0 then
			return value.d1
		end

		if index == 1 then
			return value.d2
		end

		if index == 2 then
			return value.d3
		end

		if index == 3 then
			return value.d4
		end

		return nil
	end

	if itype == "string" then
		-- If it's one of the common names, then return
		-- the appropriate field
		if index == 'r' or index == 'x' or index == 's' then
			return value.d1
		elseif index == 'g' or index == 'y' or index == 't' then
			return value.d2
		elseif index == "b" or index == "z" or index == "q" then
			return value.d3
		elseif index == "a" or index == "w" or index == "s" then
			return value.d4
		else
			--return a function
		end
	end

	return nil
end

vec2 = nil
vec2_mt = {
	__tostring = function(self)
		return string.format("vec2(%3.3f, %3.3f)", self.d1, self.d2);
	end,

	__index = glsl_get_swizzler,

	__newindex = glsl_set_swizzler,

	__len = function(self) return 2 end,

	-- relational
	__eq = function(a, b)
		return a.d1 == b.d1 and a.d2 == b.d2
	end,

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
	__tostring = function(self)
		return string.format("vec3(%3.3f, %3.3f, %3.3f)", self.d1, self.d2, self.d3);
	end,

	__index = glsl_get_swizzler,

	__newindex = glsl_set_swizzler,

	__len = function(self) return 3 end,

	-- relational
	__eq = function(a, b)
		return a.d1 == b.d1 and a.d2 == b.d2  and a.d3 == b.d3
	end,

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
	__tostring = function(self)
		return string.format("vec4(%3.3f, %3.3f, %3.3f, %3.3f)", self.d1, self.d2, self.d3, self.d4);
	end,

	__index = glsl_get_swizzler,

	__newindex = glsl_set_swizzler,

	__len = function(self) return 4 end,

	-- relational
	__eq = function(a, b)
		return a.d1 == b.d1 and a.d2 == b.d2  and a.d3 == b.d3 and a.d4 == b.d4
	end,

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



