--=====================================
-- This is public Domain Code
-- Contributed by: William A Adams
-- September 2011
--
-- Implement a language skin that
-- gives a GLSL feel to the coding
--=====================================
local vec = require "math_vector"

pi = math.pi;

local floatv = function(nelem)
	return ffi.new("float[?]", nelem);
end

function apply(f, v)
	if type(v) == "number" then
		return f(v)
	end

	local nelem = #v
	local res = floatv(nelem)
	for i=0,nelem-1 do
		res[i] = f(v[i])
	end

	return res
end

function apply2(f, v1, v2)
	if type(v1) == "number" then
		return f(v1, v2)
	end

	local nelem = #v1
	local res = floatv(nelem)
	if type(v2)=="number" then
		for i=0,nelem-1 do
			res[i] = f(v1[i],v2)
		end
	else
		for i=0,nelem-1 do
			res[i] = f(v1[i], v2[i])
		end
	end

	return res
end

function add(x,y)
	return apply2(function(x,y) return x + y end,x,y)
end

function sub(x,y)
	return apply2(function(x,y) return x - y end,x,y)
end

function mul(x,y)
	if type(x)=="number" then -- swap params, just in case y is a vector
		return apply2(function(x,y) return x * y end,y,x)
	else
 		return apply2(function(x,y) return x * y end,x,y)
	end
end

function div(x,y)
	return apply2(function(x,y) return x / y end,x,y)
end

-- improved equality test with tolerance
function equal(v1,v2,tol)
	assert(type(v1)==type(v2),"equal("..type(v1)..","..type(v2)..") : incompatible types")
	tol = tol or 1E-12;

	return apply(function(x) return x<=tol end,abs(sub(v1,v2)))
end

function notEqual(v1,v2,tol)
	return not equal(v1, v2, tol);
end

--=====================================
--	Angle and Trigonometry Functions (5.1)
--=====================================

function radians(degs)
	return apply(math.rad, degs)
end

function degrees(rads)
	return apply(math.deg, rads)
end

function sin(rads)
	return apply(math.sin, rads)
end

function cos(rads)
	return apply(math.cos, rads)
end

function tan(rads)
	return apply(math.tan, rads)
end

function asin(rads)
	return apply(math.asin, rads)
end

function acos(rads)
	return apply(math.acos, rads)

end



function atan(rads)
	return apply(math.atan, rads)
end

function atan2(y,x)
	return apply2(math.atan2,y,x)
end

function sinh(rads)
	return apply(math.sinh, rads)
end

function cosh(rads)
	return apply(math.cosh, rads)
end


function tanh(rads)
	return apply(math.tanh, rads)
end

--[[
function asinh(rads)
	return apply(math.asinh, rads)
end

function acosh(rads)
	return apply(math.acosh, rads)
end

function atanh(rads)
	return apply(math.atanh, rads)
end
--]]

--=====================================
--	Exponential Functions (5.2)
--=====================================
function pow(x,y)
	return apply2(math.pow,x,y)
end

function exp2(x)
	return apply2(math.pow,2,x)
end

function log2(x)
	return apply(math.log,x)/math.log(2)
end

function sqrt(x)
	return apply(math.sqrt,x)
end

local function inv(x)
	return apply(function(x) return 1/x end,x)
end

function invsqrt(x)
	return inv(sqrt(x))
end

--=====================================
--	Common Functions (5.3)
--=====================================
function abs(x)
	return apply(math.abs, x)
end

function signfunc(x)
	if x > 0 then
		return 1
	elseif x < 0 then
		return -1
	end

	return 0
end

function sign(x)
	return apply(signfunc, x)
end

function floor(x)
	return apply(math.floor, x)
end

function trucfunc(x)
	local asign = sign(x)
	local res = asign * math.floor(math.abs(x))

	return res
end

function trunc(x)
	return apply(truncfunc, x)
end

function roundfunc(x)
	local asign = sign(x)
	local res = asign*math.floor((math.abs(x) + 0.5))

	return res
end

function round(x)
	return apply(roundfunc, x)
end


function ceil(x)
	return apply(math.ceil, x)
end

function fractfunc(x)
	return x - math.floor(x)
end

function fract(x)
	return apply(fractfunc, x)
end

function modfunc(x,y)
	return x - y * math.floor(x/y)
end

function mod(x,y)
	return apply2(modfunc, x, y)
end

function min2(x,y)
	return apply2(math.min, x, y)
end

function min(...)
	if arg.n == 2 then
		return min2(arg[1], arg[2])
	elseif arg.n == 3 then
		return math.min(math.min(arg[1], arg[2]), arg[3])
	end

	if type(arg[1]) == "table" then
		local lowest = math.huge
		for i=1,#arg[1] do
			lowest = math.min(lowest, arg[1][i])
		end

		return lowest
	end

	-- If we got to here, then it was invalid input
	return nil
end

function max2(x,y)
	return apply2(math.max, x, y)
end


function max(...)
	if arg.n == 2 then
		return max2(arg[1], arg[2])
	elseif arg.n == 3 then
		return math.max(math.max(arg[1], arg[2]), arg[3])
	end

	if type(arg[1]) == "table" then
		local highest = -math.huge
		for i=1,#arg[1] do
			highest = math.max(highest, arg[1][i])
		end

		return highest
	end

	-- If we got to here, then it was invalid input
	return nil
end





function clamp(x, minVal, maxVal)
	return min(max(x,minVal),maxVal)
end


function mixfunc(x, y, a)
	return x*(1.0 - a) + y * a
end

-- x*(1.0 - a) + y * a
-- same as...
-- x + s(y-x)
-- Essentially lerp
function mix(x, y, a)
	return add(x,mul(sub(y,x),a))
end


function stepfunc(edge, x)
	if (x < edge) then
		return 0;
	else
		return 1;
	end
end

function step(edge, x)
	return apply2(stepfunc, edge, x)
end

-- Hermite smoothing between two points
function hermfunc(edge0, edge1, x)
	local range = (edge1 - edge0);
	local distance = (x - edge0);
	local t = clamp((distance / range), 0.0, 1.0);
	local r = t*t*(3.0-2.0*t);

	return r;
end

function smoothstepfunc(edge0, edge1, x)
	if (x <= edge0) then
		return 0.0
	end

	if (x >= edge1) then
		return 1.0
	end

	return	herm(edge0, edge1, x);
end



function smoothstep(edge0, edge1, x)
	if type(x) == 'number' then
		local f = smoothstepfunc(edge0, edge1, x)
		return f
	end

	local res={}
	for i=1,#x do
		table.insert(res, smoothstepfunc(edge0[i], edge1[i], x))
	end

	return res
end

function isnan(x)
	if x == nil then
		return true
	end

	if x >= math.huge then
		return true
	end

	local res={}
	for i=1,#x do
		table.insert(res, x >= math.huge)
	end

	return res
end

function isinf(x)
	if type(x) == 'number' then
		local f = x >= math.huge
		return f
	end

	local res={}
	for i=1,#x do
		table.insert(res, x >= math.huge)
	end

	return res
end


--=====================================
--	Geometric Functions (5.4)
--=====================================
function dot(v1,v2)
	if type(v1) == 'number' then
		return v1*v2
	end

	if (type(v1) == 'table') then
		-- if v1 is a table
		-- it could be vector.vector
		-- or matrix.vector
		if type(v1[1] == "number") then
			local sum=0
			for i=1,#v1 do
				sum = sum + (v1[i]*v2[i])
			end
			return sum;
		else -- matrix.vector
			local res={}
			for i,x in ipairs(v1) do
				res[i] = dot(x,v2) end
			return res
		end
	end
end

function length(v)
	return math.sqrt(dot(v,v))
end

function distance(v1,v2)
	return length(sub(v1,v2))
end

function cross(v1, v2)
	if #v1 ~= 3 then
		return {0,0,0}
	end

	return {
		(v1[2]*v2[3])-(v2[2]*v1[3]),
		(v1[3]*v2[1])-(v2[3]*v1[1]),
		(v1[1]*v2[2])-(v2[1]*v1[2])
	}
end

function normalize(v1)
	return div(v1,length(v1))
end

function faceforward(n,i,nref)
	if dot(n,i)<0 then 
		return n 
	else 
		return -n 
	end
end

function reflect(i,n)
	return sub(i,mul(mul(2,dot(n,i)),n))
end

--=====================================
--	Vector Relational (5.4)
--=====================================
function isnumtrue(x)
	return x ~= nil and x ~= 0
end

function any(x)
	local nelem = #x
	for i=0,nelem-1 do
		local f = isnumtrue(x[i])
		if f then return true end
	end

	return false
end

function all(x)
	local nelem = #x
	for i=0,nelem-1 do
		local f = isnumtrue(x[i])
		if not f then return false end
	end

	return true
end

-- angle (in radians) between u and v vectors
function angle(u, v)
	if dot(u, v) < 0 then
		return math.pi - 2*asin(length(add(u,v))/2)
	else
		return 2*asin(distance(v,u)/2)
	end
end

--=====================================
--	Extras, like Processing
--=====================================
--[[
function: map

Description: Take a value 'a' relative to 'rlo' and 'rhi' 
and create a new value, relative to the range 'slo' and 'shi'

--]]
function map(a, rlo, rhi, slo, shi)
	return slo + ((a-rlo)/(rhi-rlo) * (shi-slo))
end


--[[
local function IsZero(a)
    return (math.abs(a) < kEpsilon);
end

	__index = {
		AngleBetween = function(self,rhs)
			return math.acos(self:Dot(rhs))
		end,

		Assign = function(self, rhs)
			self.x = rhs.x;
			self.y = rhs.y;
			self.z = rhs.z;
		end,

		Clone = function(self)
			return ffi.new(ffi.typeof(self), self.x, self.y, self.z);
		end,

		Cross = function(self, v)
			return ffi.new(ffi.typeof(self),
				self.y*v.z - v.y*self.z,
				-self.x*v.z + v.x*self.z,
				self.x*v.y - v.x*self.y);
		end,

		Dot = function(self, rhs)
			return self.x*rhs.x + self.y*rhs.y + self.z*rhs.z;
		end,

		Length = function(self)
			return math.sqrt(self:LengthSquared())
		end,

		LengthSquared = function(self)
			return self:Dot(self)
		end,

		Normal = function(self)
			local scalar = 1/self:Length()

			return ffi.new(ffi.typeof(self),
				self.x * scalar,
				self.y * scalar,
				self.z * scalar);
		end,
	},
--]]

