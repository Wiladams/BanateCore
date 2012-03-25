require "GrayConverter"

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


