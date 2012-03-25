-- Put this at the top of any test
local ppath = package.path..';..\\?.lua'
package.path = ppath;


require "Pixel"



print("Pixel.lua - TEST")


local lum1 = PixelLum(15)
print("PixelLum:BitsPerPixel - ", lum1.BitsPerPixel)
print(lum1)

local lum2 = PixelLumAlpha(127, 255)
print("PixelLumAlpha Size: ", lum2.Size)
print(lum2)

local pixrgba1 = PixelRGBA(2, 4, 6, 255)
print("PixelRGBA Size: ", pixrgba1.Size)
print(pixrgba1)

local pixrgb1 = PixelRGB(65, 66, 67)
print("PixelRGB Size: ", pixrgb1.Size)
print(pixrgb1)
local rgbarray = pixrgb1:ToArray()
--print("RGB Array: ", rgbarray[1]), rgbarray[2], rgbarray[3]);
--print("RGB Array: ", rgbarray);

local pixrgba2 = PixelRGBA()
print("RGBA - Default")
print(pixrgba2)



