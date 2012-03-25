-- Put this at the top of any test
local ppath = package.path..';..\\?.lua'
package.path = ppath;

-- test_EFLA.lua
require "EFLA"


local liner = EFLA_Iterator(10,5,1,15, false)
for x,y,u in liner do
	print(x,y,u)
end

