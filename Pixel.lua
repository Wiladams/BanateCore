-- Pixel.lua

local ffi = require"ffi"
local C = ffi.C
require "GrayConverter"

ffi.cdef[[

	typedef struct { uint8_t Lum; } pixel_Lum_b;
	typedef struct { uint8_t Lum, Alpha;} pixel_LumAlpha_b;

	typedef struct { uint8_t Red, Green, Blue, Alpha; } pixel_RGBA_b, *Ppixel_RGBA_b;
	typedef struct { uint8_t Red, Green, Blue; } pixel_RGB_b;

	typedef struct { uint8_t Blue, Green, Red, Alpha; } pixel_BGRA_b, *Ppixel_BGRA_b;
	typedef struct { uint8_t Blue, Green, Red; } pixel_BGR_b, *Ppixel_BGR_b;
]]

local lumaker = GrayConverter.new()

-- LUMINANCE (GrayScale)
PixelLum = nil
PixelLum_mt = {
	__tostring = function(self) return string.format("PixelLum(%d)", self.Lum) end,
	__index = {
		TypeName = "pixel_Lum_b",
		BitsPerPixel = ffi.sizeof("pixel_Lum_b") * 8,
		Size = ffi.sizeof("pixel_Lum_b"),
		CreateBuffer = function(self, size)
			return ffi.new("pixel_Lum_b[?]", size)
		end,
		ToArray = function(self)
			return ffi.string(self,ffi.sizeof("pixel_Lum_b"))
		end,
		ToRGBA = function(self)
			local rgba = ffi.new("pixel_RGBA_b")
			rgba.Red = self.Lum
			rgba.Green = self.Lum
			rgba.Blue = self.Lum
			rgba.Alpha = 255
			return rgba
		end,
		CopyRGBA = function(self, rgba)
			local luminance = lumaker(rgba.Red, rgba.Green, rgba.Blue)
			self.Lum = luminance
			return self
		end,
	}
}
PixelLum = ffi.metatype("pixel_Lum_b", PixelLum_mt)

-- LUMINANCE w/ALPHA (GrayScale)
PixelLumAlpha = nil
PixelLumAlpha_mt = {
	__tostring = function(self)
		return string.format("PixelLumAlpha(%d,%d)", self.Lum, self.Alpha)
		end,

	__index = {
		TypeName = "pixel_LumAlpha_b",
		BitsPerPixel = ffi.sizeof("pixel_LumAlpha_b") * 8,
		Size = ffi.sizeof("pixel_LumAlpha_b"),
		CreateBuffer = function(self, size)
			return ffi.new("pixel_LumAlpha_b[?]", size)
		end,
		ToArray = function(self)
			return ffi.string(self,ffi.sizeof("pixel_LumAlpha_b"))
		end,
		ToRGBA = function(self)
			local rgba = ffi.new("pixel_RGBA_b")
			rgba.Red = self.Lum
			rgba.Green = self.Lum
			rgba.Blue = self.Lum
			rgba.Alpha = self.Alpha
			return rgba
		end,
		CopyRGBA = function(self, rgba)
			local luminance = lumaker(rgba.Red, rgba.Green, rgba.Blue)
			self.Lum = luminance
			self.Alpha = rgba.Alpha
			return self
		end,
	}
}
PixelLumAlpha = ffi.metatype("pixel_LumAlpha_b", PixelLumAlpha_mt)


-- RGB (Red, Green, Blue)
PixelRGB = nil
PixelRGB_mt = {
	__tostring = function(self)
			return string.format("PixelRGB(%d, %d, %d)",
			self.Red, self.Green, self.Blue)
		end,
	__index = {
		TypeName = "pixel_RGB_b",
		BitsPerPixel = ffi.sizeof("pixel_RGB_b") * 8,
		Size = ffi.sizeof("pixel_RGB_b"),
		CreateBuffer = function(self, size)
			return ffi.new("pixel_RGB_b[?]", size)
		end,
		Serialize = function(self)
			return string.format("PixelRGB(%d, %d, %d)",
			self.Red, self.Green, self.Blue)
		end,
		ToArray = function(self)
			return ffi.string(self,ffi.sizeof("pixel_RGB_b"))
		end,
		ToRGBA = function(self)
			local rgba = ffi.new("pixel_RGBA_b")
			rgba.Red = self.Red
			rgba.Green = self.Green
			rgba.Blue = self.Blue
			rgba.Alpha = 255
			return rgba
		end,
		CopyRGBA = function(self, rgba)
			self.Red = rgba.Red
			self.Green = rgba.Green
			self.Blue = rgba.Blue
			return self
		end,
	},
}
PixelRGB = ffi.metatype("pixel_RGB_b", PixelRGB_mt)


-- RGBA (Red, Green, Blue, with Alpha
PixelRGBA = nil
PixelRGBA_mt = {
	__tostring = function(self)
		return string.format("PixelRGBA(%d, %d, %d, %d)",
			self.Red, self.Green, self.Blue, self.Alpha)
		end,
	__index = {
		TypeName = "pixel_RGBA_b",
		BitsPerPixel = ffi.sizeof("pixel_RGBA_b") * 8,
		Size = ffi.sizeof("pixel_RGBA_b"),
		CreateBuffer = function(self, size)
			return ffi.new("pixel_RGBA_b[?]", size)
		end,
		ToArray = function(self)
			return ffi.string(self,ffi.sizeof("pixel_RGBA_b"))
		end,
		ToRGBA = function(self)
			local rgba = ffi.new("pixel_RGBA_b")
			rgba.Red = self.Red
			rgba.Green = self.Green
			rgba.Blue = self.Blue
			rgba.Alpha = self.Alpha
			return rgba
		end,
		CopyRGBA = function(self, rgba)
			self.Red = rgba.Red
			self.Green = rgba.Green
			self.Blue = rgba.Blue
			self.Alpha = rgba.Alpha
			return self
		end,
	},
}
PixelRGBA = ffi.metatype("pixel_RGBA_b", PixelRGBA_mt)



-- RGB (Red, Green, Blue)
PixelBGR = nil
PixelBGR_mt = {
	__tostring = function(self)
			return string.format("PixelBGR(%d, %d, %d)",
			self.Blue, self.Green, self.Red)
		end,
	__index = {
		TypeName = "pixel_BGR_b",
		BitsPerPixel = ffi.sizeof("pixel_BGR_b") * 8,
		Size = ffi.sizeof("pixel_BGR_b"),
		CreateBuffer = function(self, size)
			return ffi.new("pixel_BGR_b[?]", size)
		end,
		Serialize = function(self)
			return string.format("PixelBGR(%d, %d, %d)",
			self.Blue, self.Green, self.Red)
		end,
		ToArray = function(self)
			return ffi.string(self,ffi.sizeof("pixel_BGR_b"))
		end,
		ToRGBA = function(self)
			local rgba = ffi.new("pixel_RGBA_b")
			rgba.Red = self.Red
			rgba.Green = self.Green
			rgba.Blue = self.Blue
			rgba.Alpha = 255
			return rgba
		end,
		CopyRGBA = function(self, rgba)
			self.Red = rgba.Red
			self.Green = rgba.Green
			self.Blue = rgba.Blue
			return self
		end,
	},
}
PixelBGR = ffi.metatype("pixel_BGR_b", PixelBGR_mt)


-- RGB (Red, Green, Blue)
PixelBGRA = nil
PixelBGRA_mt = {
	__tostring = function(self)
			return string.format("PixelBGRA(%d, %d, %d %d)",
			self.Blue, self.Green, self.Red, self.Alpha)
		end,
	__index = {
		TypeName = "pixel_BGRA_b",
		BitsPerPixel = ffi.sizeof("pixel_BGRA_b") * 8,
		Size = ffi.sizeof("pixel_BGRA_b"),
		CreateBuffer = function(self, size)
			return ffi.new("pixel_BGRA_b[?]", size)
		end,
		Serialize = function(self)
			return string.format("PixelBGRA(%d, %d, %d, %d)",
			self.Blue, self.Green, self.Red, self.Alpha)
		end,
		ToArray = function(self)
			return ffi.string(self,ffi.sizeof("pixel_BGRA_b"))
		end,
		ToRGBA = function(self)
			local rgba = ffi.new("pixel_RGBA_b")
			rgba.Red = self.Red
			rgba.Green = self.Green
			rgba.Blue = self.Blue
			rgba.Alpha = self.Alpha
			return rgba
		end,
		CopyRGBA = function(self, rgba)
			self.Red = rgba.Red
			self.Green = rgba.Green
			self.Blue = rgba.Blue
			self.Alpha = rgba.Alpha
			return self
		end,
	},
}
PixelBGRA = ffi.metatype("pixel_BGRA_b", PixelBGRA_mt)


--[[
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

--]]

