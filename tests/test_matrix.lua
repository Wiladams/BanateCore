-- Put this at the top of any test
local ppath = package.path..';..\\?.lua;..\\out\\?.lua'
package.path = ppath;

require "Mat4"


print("matrix.lua - TEST")
local m1 = mat4()
print(Mat4.tostring(m1))

print("IDENTITY")
print(Mat4.tostring(Mat4.Identity))

print("NEW")
print(Mat4.tostring(mat4()))

print("GENERAL")
local m2 = Mat4.new(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16)
print(Mat4.tostring(m2))

print("ROW")
local row0 = Mat4.GetRow(m2,0)
print(Mat4.vec4_tostring(row0))

print("COLUMN: 0")
local col0 = Mat4.GetColumn(m2,0)
print(Mat4.vec4_tostring(col0))
print("COLUMN: 3")
print(Mat4.vec4_tostring(Mat4.GetColumn(m2,3)))

print("TRANSFORM POINT By Identity")
local ident1 = Mat4.TransformPoint(Mat4.Identity, vec3(10,20,30))
print(Vec3.tostring(ident1))

-- mat4_set_row(m, row, vec, roworder)
print("SET ROW")
local msetter1 = Mat4.Clone(Mat4.Identity)
Mat4.SetRow(msetter1, 2, vec4(5,5,5,5))
--local rows1 = mat4.GetRow(msetter1)
print(Mat4.vec4_tostring(Mat4.GetRow(msetter1,2)))
Mat4.SetColumn(msetter1, 2, vec4(10,10,10,10))
print(Mat4.tostring(msetter1))


print("TRANSLATION")
local trans1 = Mat4.CreateTranslation(10, 40, 50)
print(Mat4.tostring(trans1))
local t1 = Mat4.TransformPoint(trans1, vec3(5, 2, 6))
print(Vec3.tostring(t1))

print("SCALE")
local scale1 = Mat4.CreateScale(15, 20, 0.5)
local s1 = Mat4.TransformPoint(scale1, vec3(1, 2, 30))
print(Vec3.tostring(s1))

print()
print("INVERSE")
local inv1 = Mat4.AffineInverse(scale1)
local s2 = Mat4.TransformPoint(inv1, s1)
print(Vec3.tostring(s2))

print()
print("DIAGONAL")
print()
--local diag = vec4(scale1[0][0], scale1[1][1], scale1[2][2], scale1[3][3])
local diag = Mat4.GetDiagonal(scale1)
print(Mat4.vec4_tostring(diag))


print("ROTATE")
local rotate1 = Mat4.CreateRotation(math.pi/2, 0,0,1)
local r1 = Mat4.TransformPoint(rotate1, vec3(10,0,0))
print(Vec3.tostring(r1))

print("MULTIPLY")
local mul1 = Mat4.Mul( trans1, scale1)
print(Mat4.tostring(mul1))




--[[
print("ORTHOGRAPHIC")
local ortho1 = Mat4.CreateOrthographic(-1, 1, -1, 1, -1, 1)
local opt1 = Mat4.TransformPoint(ortho1, vec3(10,0,0))
print(vec.tostring(opt1))

--]]
