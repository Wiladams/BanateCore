-- Put this at the top of any test
local ppath = package.path..';..\\?.lua;..\\out\\?.lua'
package.path = ppath;

require "matrix"

local fFov = 60
local fAspect = 16/9
local zMin = 10
local zMax = -100





local per1 = Mat4.CreatePerspective(fFov, fAspect, zMin, zMax)

--local per1 = mat4_create_perspective_new(fFov, fAspect, zMin, zMax)
print(Mat4.tostring(per1))

local persppt1 = Mat4.TransformPoint(per1, vec3(10,10,0))
print(Vec3.tostring(persppt1))

