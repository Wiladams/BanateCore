require "000"

--[[
	HELPER FUNCTIONS
--]]
vec2 = function(x,y) return floatv(2,x or 0,y or 0) end
vec3 = function(x,y,z) return floatv(3,x or 0,y or 0,z or 0) end
vec4 = function(x,y,z,w) return floatv(4,x or 0,y or 0,z or 0,w or 0) end

-- A Vector and a scalar
function vec3_apply1_new(a, op, func)
	local res = floatv(3)
	for i=0,2 do
		res[i] = func(a[i], op)
	end

	return res
end

function vec3_apply1(res, a, op, func)
	for i=0,2 do
		res[i] = func(a[i], op)
	end

	return res
end

function vec3_apply1_self(self, op, func)
	for i=0,2 do
		self[i] = func(self[i], op)
	end

	return self
end


-- Two vectors
function vec3_apply2_new(a, b, func)
	local res = floatv(3)
	for i=0,2 do
		res[i] = func(a[i], b[i])
	end

	return res
end

function vec3_apply2(res, a, b, func)
	for i=0,2 do
		res[i] = func(a[i], b[i])
	end

	return res
end

function vec3_apply2_self(self, b, func)
	for i=0,2 do
		self[i] = func(self[i], b[i])
	end

	return self
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

-- addition
local function vec3_add(res, a, b)
	return vec3_apply2(res, a, b, function(op1,op2) return op1 + op2 end)
end

local function vec3_add_new(a, b)
	return vec3_add(floatv(3), a, b)
end

local function vec3_add_self(a, b)
	return vec3_add(self, a, b)
end


-- Subtraction
local function vec3_sub(res, a, b)
	return vec3_apply2(res, a, b, function(op1,op2) return op1-op2 end)
end

local function vec3_sub_new(a, b)
	return vec3_sub(floatv(3), a, b)
end

local function vec3_sub_self(a, b)
	return vec3_sub(a, a, b)
end


-- Scale
local function vec3_scale(res, a, b)
	return vec3_apply2(res, a, b, function(op1,op2) return op1*op2 end)
end

local function vec3_scale_new(a, b)
	return vec3_scale(floatv(3), a, b)
end

local function vec3_scale_self(a, b)
	return vec3_scale(a, a, b)
end


-- Scale by scalar
local function vec3_scales(res, a, s)
	return vec3_apply1(res, a, s, function(op1,s) return op1*s end)
end

local function vec3_scales_new(a, s)
	return vec3_scales(floatv(3), a, s)
end

local function vec3_scales_self(a, s)
	return vec3_scales(a, a, s)
end


-- Cross product
local function vec3_cross(res, u, v)
	res[0] = u[1]*v[2] - v[1]*u[2];
	res[1] = -u[0]*v[2] + v[0]*u[2];
	res[2] = u[0]*v[1] - v[0]*u[1];

	return res
end

local function vec3_cross_new(u, v)
	return vec3_cross(floatv(3), u,v)
end


-- Dot product
local function vec3_dot(u, v)
	return u[0]*v[0] + u[1]*v[1] + u[2]*v[2]
end

local function vec3_angle_between(u,v)
	local tmp = vec3_dot(u,v)
	return math.acos(tmp)
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
	return vec3_scales(res, u, scalar)
end

local function vec3_normalize_new(u)
	return vec3_normalize(floatv(3), u)
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

	Add = vec3_add_new,
	Sub = vec3_sub_new,
	Mul = vec3_scale_new,
	Muls = vec3_scales_new,
	Div = vec3_div_new,
	Divs = vec3_divs_new,

	Dot = vec3_dot,
	Cross = vec3_cross_new,

	Length = vec3_length,

	Distance = vec3_distance,
	FindNormal = vec3_find_normal_new,
	Normalize = vec3_normalize_new,
	AngleBetween = vec3_angle_between,

	tostring = vec3_tostring,
}
