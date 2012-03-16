-- This is a template
-- In order to create a functor:
-- 1) Copy this code
-- 2) Change the Moniker: 'Functor' to the name of
--		Whatever functor is being created
-- 3) Implement the specific code in the Execute() function
--

GrayConverter={}
GrayConverter_mt = {}

function GrayConverter.new(...)
	local new_inst = {}
	new_inst.redfactor = {}
	new_inst.greenfactor = {}
	new_inst.bluefactor = {}

	-- Based on old NTSC
	-- static float redcoeff = 0.299f;
	-- static float greencoeff = 0.587f;
	-- static float bluecoeff = 0.114f;

	-- New CRT and HDTV phosphors
	local redcoeff = 0.2225;
	local greencoeff = 0.7154;
	local bluecoeff = 0.0721;

	for i=1,256 do
		new_inst.redfactor[i] = math.min(56, math.floor(((i-1) * redcoeff) + 0.5));
		new_inst.greenfactor[i] = math.min(181, math.floor(((i-1) * greencoeff) + 0.5));
		new_inst.bluefactor[i] = math.min(18, math.floor(((i-1) * bluecoeff) + 0.5));
	end

	setmetatable(new_inst, GrayConverter_mt)

	return new_inst
end

function GrayConverter.Execute(self, r,g,b)
	local lum =
		self.redfactor[r+1] +
		self.greenfactor[g+1] +
		self.bluefactor[b+1];

	return lum
end

GrayConverter_mt.__call = GrayConverter.Execute;


--[[
print("GrayConverter.lua - TEST")
local gray = GrayConverter.new()

local rd = gray(255, 0, 0)
local gr = gray(0, 255, 0)
local bl = gray(0, 0, 255)
local gr = gray(127, 127, 127)
local bk = gray(0,0,0)
local wt = gray(255, 255, 255)

print("Red: ", rd)
print("Green: ", gr)
print("Blue: ", bl)
print("Gray: ", gr)
print("Black: ", bk)
print("White: ", wt)
--]]


