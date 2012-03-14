-- Put this at the top of any test
local ppath = package.path..';..\\?.lua'
package.path = ppath;

require "TransferArray2D"
require "FixedArray2D"
require "EFLA"

function PrintArrayASCII(arr)
	for row=0,arr.Height-1 do
		for col=0,arr.Width-1 do
			io.write(string.format(" %s", string.char(arr:Get(col, row))))
		end
		io.write('\n')
	end
end

local framebuffer = FixedArray2D(20, 20, "unsigned char", string.byte("#"))
local window = FixedArray2D(10,10, "unsigned char",string.byte("O"))

function frameRect(dst, value)
	for i=0,dst.Width-1 do
		dst:Set(i,0, string.byte("-"))
		dst:Set(i,dst.Height-1,string.byte("_"))
	end

	-- Draw vertical sides
	for i=0,(dst.Height-1) do
		dst:Set(0,i, string.byte("|"))
		dst:Set(dst.Width-1, i, string.byte("|"))
	end
end

-- Draw diagonal line on window
diagonal = EFLA_Iterator(0,0,window.Width-1,window.Width-1)
for x,y in diagonal do
	window:Set(x,y,string.byte("\\"))
end



frameRect(window, string.byte("*"))

--print("  WINDOW  ")
--printArrayI(window)

function threshold(dst, src)
	if src >120 then return src end
	return nil
end

--TransferArray2D(framebuffer, window, 5,2,RectI(0,0,window.Width,window.Height),ComposeRect, threshold)
--TransferArray2D(framebuffer, window, 5,2,RectI(0,0,window.Width,window.Height),ComposeRect)
--TransferArray2D(framebuffer, window, 5,2,RectI(0,0,window.Width,window.Height),CopyRect)
TransferArray2D(framebuffer, window, 5,2)


print("=== Frame Buffer ====")
PrintArrayASCII(framebuffer)

