-- Put this at the top of any test
local ppath = package.path..';..\\?.lua'
package.path = ppath;

require "000"
require "Pixel"

local p1 = ffi.new("pixel_BGRA_b")
local arr1 = Array1D(640, "pixel_BGRA_b")

local arr2 = Array2D(640, 480, "pixel_BGRA_b")

local arr3 = Array3D(640, 480, 3, "pixel_BGRA_b")
