-- Put this at the top of any test
local ppath = package.path..';..\\?.lua'
package.path = ppath;

require "glsl_types"

local v1 = vec3()
--print(v1, "Length: ", #v1)
v1[0] = 1
v1[1] = 10
v1[2] = 20

local v2 = vec3()
v2[0] = 1
v2[1] = 10
v2[2] = 20

local vec3 = function(a,b,c)
	return floats(3, a, b, c)
end

local v3 = vec3(1, 15, 20)

print(v3[0], v3[1], v3[2])

--print(vec_tostring(v1))

--print("v1 == v2", v1 == v2)
--print("v2 == v3", v2 == v3)


local v1 = floats(3, 1,2,3)
print(v1)

local dvec1 = doubles(3,7)
print("Length Double Vec: ", ffi.sizeof(dvec1))
--ffi.metatype(dvec1, vec3_mt)
for i=0,2 do
print(dvec1[i])
end
--print(math.sin(v1[0]))

local len = ffi.sizeof(v1)
local arrtype = ffi.typeof(v1)
print("Length of cdata: ", len, arrtype)
