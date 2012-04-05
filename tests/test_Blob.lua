
--ByteBlob = CreateBlobType("uint8_t", 256, "ByteBlob")
--local blob1 = ByteBlob(256)
--print("size: ", blob1.Size)



local blob2 = Blob("uint32_t", 256, "IntBlob")
local blob3 = Blob("uint32_t", 256, "IntBlob")
print("size: ", blob2.Size)

