-- vec_func.lua

if not BanateCore_000 then
require "000"
end

vec_func_included = true

-- Useful constants

kEpsilon = 1.0e-6


--[[
	HELPER FUNCTIONS
--]]
vec2 = ffi.typeof("double[2]")
vec3 = ffi.typeof("double[3]")
vec4 = ffi.typeof("double[4]")

function IsZero(a)
    return (math.abs(a) < kEpsilon);
end


-- A Vector and a scalar

local function vec3_assign(a, b)
	a[0] = b[0]
	a[1] = b[1]
	a[2] = b[2]

	return a
end




local function vec3_tostring(v)
	res={}

	table.insert(res,'{')
	for col = 0,2 do
		table.insert(res,v[col])
		if col < 2 then
			table.insert(res,',')
		end
	end
	table.insert(res,'}')

	return table.concat(res)
end

--[[
	Actual Math Functions
--]]
-- Equal
local function vec3_eq(a, b)
	return a[0] == b[0] and a[1] == b[1] and a[2] == b[2]
end


-- negate
local function vec3_neg(res, a)
	res[0] = -a[0]
	res[1] = -a[1]
	res[2] = -a[2]

	return res
end

local function vec3_neg_new(a)
	return vec3_neg(vec3(), a)
end

-- addition
local function vec3_add(res, a, b)
	res[0] = a[0]+b[0]
	res[1] = a[1]+b[1]
	res[2] = a[2]+b[2]
	return res
end

local function vec3_add_new(a, b)
	return vec3_add(vec3(), a, b)
end

local function vec3_add_self(a, b)
	return vec3_add(a, a, b)
end


-- Subtraction
local function vec3_sub(res, a, b)
	res[0] = a[0]-b[0]
	res[1] = a[1]-b[1]
	res[2] = a[2]-b[2]
	return res
end

local function vec3_sub_new(a, b)
	return vec3_sub(vec3(), a, b)
end

local function vec3_sub_self(a, b)
	return vec3_sub(a, a, b)
end


-- Scale
local function vec3_scale(res, a, b)
	res[0] = a[0]*b[0]
	res[1] = a[1]*b[1]
	res[2] = a[2]*b[2]
	return res
end

local function vec3_scale_new(a, b)
	return vec3_scale(vec3(), a, b)
end

local function vec3_scale_self(a, b)
	return vec3_scale(a, a, b)
end


-- Scale by scalar
local function vec3_scales(res, a, s)
	res[0] = a[0]*s
	res[1] = a[1]*s
	res[2] = a[2]*s

	return res
end

local function vec3_scales_new(a, s)
	return vec3(a[0]*s, a[1]*s, a[2]*s)
end

local function vec3_scales_self(a, s)
	a[0]=a[0]*s
	a[1]=a[1]*s
	a[2]=a[2]*s
	return a
end


-- Cross product
local function vec3_cross(res, u, v)
	res[0] = u[1]*v[2] - v[1]*u[2];
	res[1] = -u[0]*v[2] + v[0]*u[2];
	res[2] = u[0]*v[1] - v[0]*u[1];

	return res
end

local function vec3_cross_new(u, v)
	return vec3_cross(vec3(), u,v)
end


-- Dot product
local function vec3_dot(u, v)
	return u[0]*v[0] + u[1]*v[1] + u[2]*v[2]
end

local function vec3_angle_between(u,v)
	return math.acos(vec3_dot(u,v))
end


-- Length
local function vec3_length_squared(u)
	return vec3_dot(u,u)
end

local function vec3_length(u)
	return math.sqrt(vec3_length_squared(u))
end


-- Normalize
local function vec3_normalize(res, u)
	local scalar = 1/vec3_length(u)

	res[0] = u[0] * scalar
	res[1] = u[1] * scalar
	res[2] = u[2] * scalar

	return res
end

local function vec3_normalize_new(u)
	return vec3_normalize(vec3(), u)
end

local function vec3_normalize_self(u)
	return vec3_normalize(u, u)
end

-- Distance
local function vec3_distance(u, v)
	return vec3_length(vec3_sub_new(u,v))
end



local function vec3_find_normal(res, point1, point2, point3)
	local v1 = vec3_sub_new(point1, point2)
	local v2 = vec3_sub_new(point2, point3)

	return vec3_cross(res, v1, v2)
end

local function vec3_find_normal_new(point1, point2, point3)
	return vec3_find_normal(vec3(), point1, point2, point3)
end



Vec3 = {
	vec3 = vec3,
	Assign = vec3_assign,

	Add = vec3_add_new,
	AddSelf = vec3_add_self,
	Sub = vec3_sub_new,
	Scale = vec3_scale_new,
	Scales = vec3_scales_new,
	Div = vec3_div_new,
	Divs = vec3_divs_new,
	Neg = vec3_neg_new,
	Eq = vec3_eq,

	Dot = vec3_dot,
	Cross = vec3_cross_new,

	Length = vec3_length,

	Distance = vec3_distance,
	FindNormal = vec3_find_normal_new,
	Normalize = vec3_normalize_new,
	NormalizeSelf = vec3_normalize_self,

	AngleBetween = vec3_angle_between,

	tostring = vec3_tostring,
}
