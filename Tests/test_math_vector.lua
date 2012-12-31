package.path = ";../?.lua"

local vec = require "math_vector"

local vec3 = vec.vec3;

local v1 = vec3(1,2,3)

-- print using __tostring
print(v1);

-- use __index
print(v1[0]);
print(v1[1]);
print(v1[2]);

-- use __newindex
v1[1] = 5;
print(v1);

v1[1] = 7;
print(v1);

print("ADD");
print(vec3(1,1,1)+vec3(2,3,4));
