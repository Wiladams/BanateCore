-- Put this at the top of any test
local ppath = package.path..';..\\?.lua'
package.path = ppath;

-- test_glsl_math0.lua
local ffi = require "ffi"

local glm = require "glsl_math"
local vec = require ("math_vector");
local vec3 = vec.vec3;

print("test_glsl_math.lua - TEST")


local v1 = vec3(0, 0, 0)
local v2 = vec3(1, 0, 1)
local v3 = vec3(1, 1, 1)
local xaxis = vec3(1, 0, 0);
local yaxis = vec3(0, 1, 0);
local zaxis = vec3(0, 0, 1);

print("ANY")
assert(any(v1) == false)
assert(any(v2) == true)
assert(any(v3) == true)

print("ALL")
assert(all(v1) == false)
assert(all(v2) == false)
assert(all(v3) == true)


print("MUL")
local v4 = vec3(2,4,6)
print(mul(v1, v4))
print(mul(v2, v4))
print(mul(v3, v4))

print("SIGN")
print(sign(vec3(1, 0, -1)));

print("ANGLE")
print(angle(xaxis, vec3(1,1,1)));