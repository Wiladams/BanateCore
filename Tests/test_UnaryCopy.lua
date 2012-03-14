-- Put this at the top of any test
local ppath = package.path..';..\\?.lua'
package.path = ppath;


require "UnaryCopyArray"
require "FixedArray2D"

function printArrayI(arr)
	for row=0,arr.Height-1 do
		for col=0,arr.Width-1 do
			io.write(string.format(" %3d", arr:Get(col, row)))
		end
		io.write('\n')
	end
end

local framebuffer = FixedArray2D(20, 20, "unsigned char")
local window = FixedArray2D(10,10, "unsigned char")

-- Draw diagonal line on window
for i=0,window.Width-1 do
	window:Set(i,i,255)
end

--print("  WINDOW  ")
--printArrayI(window)

CopyArray2D(framebuffer, window, 15,5)

print("=== Frame Buffer ====")
printArrayI(framebuffer)
