-- Put this at the top of any test
local ppath = package.path..';..\\?.lua'
package.path = ppath;

require "vec_func"

local vec = Vec3

local v1 = vec3(1,2,3)
local v2 = vec3(4,5,6)


print("ADD")
local v3 = vec.Add(v1, v2)
print(vec.tostring(v3))

print("SUB")
local v4 = vec.Sub(v2, v1)
print(vec.tostring(v4))

print("SCALE")
local v5 = vec.Mul(v1, v2)
print(vec.tostring(v5))

print("SCALES")
local v6 = vec.Muls(v1, 3)
print(vec.tostring(v6))


print("CROSS")
local xaxis = vec3(1,0,0)
local yaxis = vec3(0,1,0)
local zaxis = vec.Cross(xaxis, yaxis)
print(vec.tostring(zaxis))

print("DISTANCE")
local dist = vec.Distance(vec3(5,0,0), vec3(5, 5, 0))
print(dist)

print("NORMAL")
local zaxis = vec.FindNormal(vec3(0,1,0), vec3(0,0,0), vec3(1,0,0))
print(vec.tostring(zaxis))
