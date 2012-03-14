-- Put this at the top of any test
local ppath = package.path..';..\\?.lua'
package.path = ppath;


require "PixelBuffer"


print("pixelbuffer.lua - TEST")

local pb = PixelBuffer({Width=320, Height=240})
local x = 10;
local y = 10;

pb:SetPixel(x, y, PixelRGB(10,20,30))
local offset = pb:GetOffset(x,y)
local p = pb:GetPixel(x,y)
print("Offset: ", offset)
print(p)

