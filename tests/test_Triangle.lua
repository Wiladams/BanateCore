-- Put this at the top of any test
local ppath = package.path..';..\\?.lua'
package.path = ppath;

-- test_Triangle.lua

require "Triangle"
require "glsl_types"

local v1 = vec2(10, 10)
local v2 = vec2(10, 0)
local v3 = vec2(0 , 0)

local poly = {v1, v2, v3}


local minv = FindTopmostPolyVertex(poly, #poly)
local rotated = RotateVertices(poly, #poly, minv)

print("Min Vertex: ", minv)

function printvertices(verts)
	for i=1,#verts  do
		print(verts[i][0], verts[i][1])
	end
end

printvertices(rotated)

--local sorted = sortTriangle(v1, v2, v3)
