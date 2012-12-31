-- Put this at the top of any test
local ppath = package.path..';..\\?.lua'
package.path = ppath;

require "000"
require "Pixel"
local ffi = require "ffi"

local p1 = ffi.new("pixel_BGRA_b")
local arr1 = Array1D(640, "pixel_BGRA_b")

local arr2 = Array2D(640, 480, "pixel_BGRA_b")

local arr3 = Array3D(640, 480, 3, "pixel_BGRA_b")


ffi.cdef[[
typedef struct {
	int x;
	int y;
} point_t;
]]

local point_t = ffi.typeof("point_t");
local point_t_mt = {
	__eq = function(lhs, rhs)
		return lhs.x == rhs.x;
	end,

	__new = function(ct, ...)
		print("NEW: point_t");
		local obj = ffi.new(point_t, ...)

		return obj
	end,

	__gc = function(self)
		print("GC: point_t");
	end,

	__index = {
		assign = function(self, rhs)
			self.x = rhs.x;
			self.y = rhs.y;
		end,
	},
}
ffi.metatype(point_t, point_t_mt);

local p1 = point_t(10,15);
local p2 = point_t();

p2:assign(p1);
p2.y = 20;

print(p1.x, p1.y);
print(p2.x, p2.y);
