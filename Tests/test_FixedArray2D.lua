-- Put this at the top of any test
local ppath = package.path..';..\\?.lua'
package.path = ppath;

require "FixedArray2D"

local arr1 = FixedArray2D(4,4,"float")

function printArray(arr)
	for row=0,arr.Height-1 do
		for col=0,arr.Width-1 do
			io.write(string.format(" %f", arr:Get(col, row)))
		end
		io.write('\n')
	end
end

printArray(arr1)

function test_FixedArray()
	local arr1 = FixedArray2D(20, 1, "short", 15)

	local arr2 = FixedArray2D(5, 1, "short", 0)
print("Array 2: ", arr2)
	arr2:Set(0, 0, 1)
	arr2:Set(1, 0, 2)
	arr2:Set(2, 0, 3)
	arr2:Set(3, 0, 4)
	arr2:Set(4, 0, 5)

	arr1:Copy(arr2, 2, 2, 2)

	printArray(arr1)
end

test_FixedArray()
