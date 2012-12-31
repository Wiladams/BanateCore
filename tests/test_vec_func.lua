-- Put this at the top of any test
local ppath = package.path..';..\\?.lua'
package.path = ppath;

require "01_vec_func"


local vec = Vec3

local v1 = vec3(1,2,3)
local v2 = vec3(4,5,6)


print("ADD")
assert(Vec3.Eq(vec.Add(v1, v2), vec3(5,7,9)), "Error with Vec3.Add")

print("ADD SELF")
local v31 = vec3(2,4,6)
assert(Vec3.Eq(vec.AddSelf(v31, v31), vec3(4,8,12)), "Error with Vec3.AddSelf")

print("SUB")
assert(Vec3.Eq(vec.Sub(v2, v1), vec3(3,3,3)), "Error with Vec3.Sub")

print("SCALE")
assert(Vec3.Eq(vec.Scale(v2, v1), vec3(4,10,18)), "Error with Vec3.Scale")

print("SCALES")
assert(Vec3.Eq(vec.Scales(v1, 3), vec3(3,6,9)), "Error with Vec3.Scales")


print("CROSS")
local xaxis = vec3(1,0,0)
local yaxis = vec3(0,1,0)
local zaxis = vec.Cross(xaxis, yaxis)
assert(Vec3.Eq(zaxis, vec3(0,0,1)), "Error with Vec3.Cross")

print("DISTANCE")
local dist = vec.Distance(vec3(5,0,0), vec3(5, 5, 0))
assert(dist == 5, "Error with Vec3.Distance")

print("NORMAL")
local norm = vec.FindNormal(vec3(0,1,0), vec3(0,0,0), vec3(1,0,0))
assert(Vec3.Eq(norm, vec3(0,0,1)), "Error with Vec3.FindNormal")

print("NEGATE")
assert(Vec3.Eq(Vec3.Neg(v1), vec3(-1,-2,-3)), "Error with Vec3.Neg")

print("NORMALIZED")
local vDir = vec3(2.3, 1.2, 3.0);
vDir = Vec3.Normalize(vDir)
