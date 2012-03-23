-- Put this at the top of any test
local ppath = package.path..';..\\?.lua'
package.path = ppath;

-- test_glsl_math0.lua
local ffi = require "ffi"

require "glsl_math0"

print("test_glsl_math0.lua - TEST")


local v1 = vec3(0, 0, 0)
local v2 = vec3(1, 0, 1)
local v3 = vec3(1, 1, 1)

print("ANY")
print(any(v1))
print(any(v2))
print(any(v3))

print("ALL")
print(all(v1))
print(all(v2))
print(all(v3))


print("MUL")
local v4 = vec3(2,4,6)
print(mul(v1, v4))
print(mul(v2, v4))
print(mul(v3, v4))

print("BYTE")
local b1 = bytev(320*240)
print("Size: ", ffi.sizeof(b1))
