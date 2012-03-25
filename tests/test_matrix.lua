-- Put this at the top of any test
local ppath = package.path..';..\\?.lua'
package.path = ppath;

local BC = require "BanateCore"
local vec = BC.Vec
local vec3 = vec.vec3
local mat4 = BC.Matrix


print("matrix.lua - TEST")
local m1 = mat4.new()
print(mat4.tostring(m1))

print("IDENTITY")
print(mat4.tostring(mat4.Identity))

print("NEW")
print(mat4.tostring(mat4.new()))

print("GENERAL")
local m2 = mat4.new(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16)
print(mat4.tostring(m2))
print("ROW")
print(mat4.vec4_tostring(mat4.GetRow(m2,0)))

print("COLUMN: 0")
print(mat4.vec4_tostring(mat4.GetColumn(m2,0)))
print("COLUMN: 3")
print(mat4.vec4_tostring(mat4.GetColumn(m2,3)))

print("TRANSFORM POINT")
local ident1 = mat4.TransformPoint(mat4.Identity, vec3(10,20,30))
print(vec.tostring(ident1))

-- mat4_set_row(m, row, vec, roworder)
print("SET ROW")
local msetter1 = mat4.Clone(mat4.Identity)
mat4.SetRow(msetter1, 2, floatv(4, 5,5,5,5))
--local rows1 = mat4.GetRow(msetter1)
print(mat4.vec4_tostring(mat4.GetRow(msetter1,2)))
mat4.SetColumn(msetter1, 2, floatv(5, 10,10,10,10))
print(mat4.tostring(msetter1))


print("TRANSLATION")
local trans1 = mat4.CreateTranslation(10, 40, 50)
print(mat4.tostring(trans1))
local t1 = mat4.TransformPoint(trans1, vec3(5, 2, 6))
print(vec.tostring(t1))

print("SCALE")
local scale1 = mat4.CreateScale(15, 20, 0.5)
local s1 = mat4.TransformPoint(scale1, vec3(1, 2, 30))
print(vec.tostring(s1))
local diag = mat4.GetDiagonal(scale1)
print(mat4.vec4_tostring(diag))

print("ROTATE")
local rotate1 = mat4.CreateRotation(math.pi/2, 0,0,1)
local r1 = mat4.TransformPoint(rotate1, vec3(10,0,0))
print(vec.tostring(r1))

print("MULTIPLY")
local mul1 = mat4.Multiply(trans1, scale1)
print(mat4.tostring(mul1))


print("INVERSE")
local inv1 = mat4.Inverse(mul1)
print(mat4.tostring(inv1))


