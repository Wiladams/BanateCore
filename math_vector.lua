-- math_vector.lua

local ffi = require "ffi"

-- Useful constants
local kEpsilon = 1.0e-6

--[[
http://lua-users.org/wiki/MetatableEvents

__len +
__index +
__newindex
__mode
__call
__metatable__new

__tostring +
__gc

Math Operators
__unm +
__add +
__sub +
__mul +
__div +
__pow
__concat
__eq +
__lt
__le
--]]

local vec3_mt = {
	__len = function(self)
		return 3
	end,
	
	__new = function(ct, x, y, z)
		--print("NEW - vec3_mt: ", ct, size);
		local obj = ffi.new(ct, x, y, z)

		return obj
	end,

	__tostring = function(self)
		return string.format("%3.4f, %3.4f, %3.4f", self.x, self.y, self.z);
	end,

	-- Math Operators
	__eq = function(self, rhs)
		return self.x == rhs.x and self.y == rhs.y and self.z == rhs.z
	end,

	__unm = function(self)
		return ffi.new(ffi.typeof(self), -self.x, -self.y, -self.z);
	end,

	__add = function(self, rhs)
		return ffi.new(ffi.typeof(self),
			self.x + rhs.x,
			self.y + rhs.y,
			self.z + rhs.z);
	end,

	__sub = function(self, rhs)
		return ffi.new(ffi.typeof(self),
			self.x - rhs.x,
			self.y - rhs.y,
			self.z - rhs.z);
	end,

	__mul = function(self, scalar)
		if type(scalar) == "number" then
			return ffi.new(ffi.typeof(self),
				self.x * scalar,
				self.y * scalar,
				self.z * scalar);
		elseif type(scalar) == "cdata" then
			return ffi.new(ffi.typeof(self),
				self.x * scalar.x,
				self.y * scalar.y,
				self.z * scalar.z);
		end
	end,

	__div = function(self, scalar)
		if type(scalar) == "number" then
			return ffi.new(ffi.typeof(self),
				self.x / scalar,
				self.y / scalar,
				self.z / scalar);
		elseif type(scalar) == "cdata" then
			return ffi.new(ffi.typeof(self),
				self.x / scalar.x,
				self.y / scalar.y,
				self.z / scalar.z);
		end
	end,

	__index = function(self, key)
		if key == 0 then return self.x end
		if key == 1 then return self.y end
		if key == 2 then return self.z end
		return nil
	end,
	
	__newindex = function(self, key, value)
		if key == 0 then self.x = value end
		if key == 1 then self.y = value end
		if key == 2 then self.z = value end
	end,

}


local function make_vec3_type(ct)
	local vec3_t = ffi.typeof("struct {$ x; $ y; $ z;}", ct, ct, ct);
	--local vec3_t = ffi.typeof("$[3]", ct);
	
	local mt = ffi.metatype(vec3_t, vec3_mt);
	
	return mt 
end

local float = ffi.typeof("float");

--[[
local double = ffi.typeof("double");
local bool = ffi.typeof("uint8_t");
local int16_t = ffi.typeof("int16_t");
local int32_t = ffi.typeof("int32_t");
local uint32_t = ffi.typeof("uint32_t");
--]]

return {
	MakeVec3Type = make_vec3_type,

	vec3 = make_vec3_type(float);
	ivec3 = make_vec3_type(ffi.typeof("int32_t"));
	uvec3 = make_vec3_type(ffi.typeof("uint32_t"));
	bvec3 = make_vec3_type(ffi.typeof("uint8_t"));

	PlaneNormal = function(point1, point2, point3)
		local v1 = point1 - point2
		local v2 = point2 - point3

		return v1:Cross(v2);
	end,

	Distance = function(u, v)
		return (u-v):Length();
	end,
}
