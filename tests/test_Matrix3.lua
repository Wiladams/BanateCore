-- Put this at the top of any test
local ppath = package.path..';..\\?.lua;'
package.path = ppath;

require "Mat3"

m1 = mat3({1,2,3},{4,5,6},{7,8,9})

print("DEFAULT Matrix3")
print(Mat3.tostring(m1))

print("IDENTITY")
print(Mat3.tostring(mat3_identity))

print("TRANSPOSE")
local t1 = Mat3.Transpose(m1)
print(Mat3.tostring(t1))

print("MULTIPLY")
local id1 = Mat3.Clone(mat3_identity)
local m2 = Mat3.Mul(id1, m1)
print(Mat3.tostring(m2))

print("INVERSE")
local inv1 = Mat3.Mul(m1, t1)
print(Mat3.tostring(m1))
print(Mat3.tostring(t1))
print(Mat3.tostring(inv1))

print("TRANSLATION")
local tsp1 = Mat3.CreateTranslation(10,20)
print(Mat3.tostring(tsp1))

print("SCALE")
local scale1 = Mat3.CreateScale(10,15)
print(Mat3.tostring(scale1))

print("SET ROWS")
local xaxis = vec3(1,0,0)
local yaxis = vec3(0,1,0)
local zaxis = vec3(0,0,1)
local m2 = mat3()
Mat3.SetRows(m2, xaxis, yaxis, Vec3.Neg(zaxis))
print(Mat3.tostring(m2))

print()
print("ROTATE X")
local rotx = Mat3.CreateRotateX(math.pi)
print(Mat3.tostring(rotx))

print()
print("ROTATE Y")
local roty = Mat3.CreateRotateY(math.pi)
print(Mat3.tostring(roty))

print()
print("ROTATE Z")
local rotz = Mat3.CreateRotateZ(math.pi)
print(Mat3.tostring(rotz))

print("ZERO")
print("MAT 3 Is ZERO: ", Mat3.IsZero(mat3()))


