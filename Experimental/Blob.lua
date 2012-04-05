ffi = require("ffi")


function CreateBlobType(typename, size, name)
	typename = typename or "uint8_t"
	size = size or 1
	name = name or "Blob"..'_'..typename

	local typedecl = string.format("local ffi = require(\"ffi\")\nffi.cdef([[\ntypedef struct {\n\t%s Data[%d];uint32_t Size;\n\t\n} %s;\n]])", typename, size, name)

	local f = loadstring(typedecl)
	f()

	return ffi.typeof(name)
end

BlobFactory={}
BlobFactory_mt = {}

function BlobFactory.new()
	local new_inst = {}

	setmetatable(new_inst, BlobFactory_mt)

	return new_inst
end

function BlobFactory.Execute(self, typename, size, name)
	local bt = CreateBlobType(typename, size, name)
	local blob = bt(size)

	return blob
end

BlobFactory_mt.__call = BlobFactory.Execute;
Blob = BlobFactory.new()



