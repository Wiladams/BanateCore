
-- Put this at the top of any test
local ppath = package.path..';..\\?.lua'
package.path = ppath;

require "RectI"

local rect1 = RectI(0,0,10,10)

local rhs = RectI(1,1,10,10)

print("Contains: 0,0 - ", rect1:Contains(0,0))
print("Contains: 9,9 - ", rect1:Contains(9,9))
print("Contains: 10,10 - ", rect1:Contains(10,10))

local inter = rect1:Intersection(rhs)
print("Intersection: ", inter)

print("IsEmpty inter: ", inter:IsEmpty())

local empty = RectI(5,5,0,0)
print("IsEmpty empty: ", empty:IsEmpty())
