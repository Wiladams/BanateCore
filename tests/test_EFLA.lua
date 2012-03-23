-- Put this at the top of any test
local ppath = package.path..';..\\?.lua'
package.path = ppath;

-- test_EFLA.lua
require "EFLA"
require "Triangle"

--[[
local liner = EFLA_Iterator(10,5,1,15, false)
for x,y,u in liner do
	print(x,y,u)
end

print("=============")
local liner2 = Triangle_DDA(10,5,1,15, false)
for x,y,u in liner2 do
	print(x,y,u)
end
print("=============")

local triscan = ScanTriangle (5,0, 0,4, 10,4)
print("lx", "rx", "newx1", "newx2", "len", "newlen")
for lx, ly, len, rx, ry, lu, ru in triscan do
	local newx1 = math.floor(lx+0.5)
	local newx2 = math.floor(rx+0.5)
	local newlen = newx2-newx1+1
	print(lx, rx, newx1, newx2, len, newlen)
end
--]]

local x0,y0,x1,y1,x2,y2 = sortTriangle(0,0, 4,4, 0,4)
print(x0,y0,x1,y1, x2,y2)
