-- Put this at the top of any test
local ppath = package.path..';..\\?.lua;..\\out\\?.lua'
package.path = ppath;

require "BanateCore"
require "Transformers"

local width = 640
local height = -480

local vpt = ViewportTransform(width, height, 32768)


print(vpt:Transform(vec3(-1,1,0)))
