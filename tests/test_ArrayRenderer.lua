-- Put this at the top of any test
local ppath = package.path..';..\\?.lua'
package.path = ppath;

local BC = require "BanateCore"
local FixedArray2D = BC.FixedArray2D


function PrintArrayASCII(arr)
	for row=0,arr.Height-1 do
		for col=0,arr.Width-1 do
			io.write(string.format(" %s", string.char(arr:Get(col, row))))
		end
		io.write('\n')
	end
end

local fb = FixedArray2D(20, 20, "unsigned char", string.byte("."))

local graphPort = ArrayRenderer(fb)


--Triangle(fb, 1,1,10,5,1,10, string.byte("X"))
--Triangle(fb, 5,1,10,5,1,10, string.byte("X"))
--Triangle(fb, 20,1, 1,15, 20,20, string.byte("x"))
--graphPort:FillTriangle(1,1, 12,7, 1,15, string.byte("x"))
--graphPort:FillTriangle(18,1, 8,7, 18,15, string.byte("O"))

--graphPort:FillRectangle(1,1,10,10,string.byte("x"))
graphPort:FillTriangle(19,1,10,10,19,10, string.byte("0"))
graphPort:FillTriangle(10,5,1,15,18,15, string.byte("#"))
graphPort:FillTriangle(0,0, 0,4, 4,4, string.byte("#"))

print("=== Frame Buffer ====")
PrintArrayASCII(fb)

