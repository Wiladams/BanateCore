-- Put this at the top of any test
local ppath = package.path..';..\\?.lua'
package.path = ppath;

local BC = require "BanateCore"
local base64 = BC.Base64


--[[
print("\\n: ", iswhitespace('\n'))
print("\\r: ", iswhitespace('\r'))
print("\\t: ", iswhitespace('\t'))
print("  : ", iswhitespace(' '))
print("\\f: ", iswhitespace('\f'))
print("\\b: ", iswhitespace('\b'))
print("a: ", iswhitespace('a'))
--]]

--[[
print("A", base64.char64index('A'))
print("/", base64.char64index('/'))
print("*", base64.char64index('*'))
--]]


-- p	112
-- l	108
-- e	101

--[[
print(base64.Ldecode("cGxl"))
print(base64.Ldecode("YXN1"))
print(base64.Ldecode("cmUu"))
print(base64.Ldecode("Zg=="))		-- f
print(base64.Ldecode("Zm8="))		-- fo
print(base64.Ldecode("Zm9v"))		-- foo
print(base64.Ldecode("Zm9vYg=="))	-- foob
print(base64.Ldecode("Zm9vYmE="))	-- fooba
print(base64.Ldecode("Zm9vYmFy"))	-- foobar

print(Ldecode("ZWFzdXJlLg=="))
--]]


assert(base64.encode("pleasure.") == "cGxlYXN1cmUu")
assert(base64.encode("leasure.")	== "bGVhc3VyZS4=")
assert(base64.encode("easure.")	== "ZWFzdXJlLg==")
assert(base64.encode("asure.")	== "YXN1cmUu")
assert(base64.encode("sure.")		== "c3VyZS4=")

-- Test cases from
-- http://tools.ietf.org/html/rfc4648

assert(base64.encode("") == "")
assert(base64.encode("f") == "Zg==")
assert(base64.encode("fo") == "Zm8=")
assert(base64.encode("foo") == "Zm9v")
assert(base64.encode("foob") == "Zm9vYg==")
assert(base64.encode("fooba") == "Zm9vYmE=")
assert(base64.encode("foobar") == "Zm9vYmFy")



assert(base64.decode("cGxlYXN1cmUu") == "pleasure.")
assert(base64.decode("bGVhc3VyZS4=") == "leasure.")
assert(base64.decode("ZWFzdXJlLg==") == "easure.")
assert(base64.decode("YXN1cmUu") == "asure.")
assert(base64.decode("c3VyZS4=") == "sure.")

print(base64.decode("TWFuIGlzIGRpc3Rpbmd1aXNoZWQsIG5vdCBvbmx5IGJ5IGhpcyByZWFzb24sIGJ1dCBieSB0aGlz IHNpbmd1bGFyIHBhc3Npb24gZnJvbSBvdGhlciBhbmltYWxzLCB3aGljaCBpcyBhIGx1c3Qgb2Yg dGhlIG1pbmQsIHRoYXQgYnkgYSBwZXJzZXZlcmFuY2Ugb2YgZGVsaWdodCBpbiB0aGUgY29udGlu dWVkIGFuZCBpbmRlZmF0aWdhYmxlIGdlbmVyYXRpb24gb2Yga25vd2xlZGdlLCBleGNlZWRzIHRo ZSBzaG9ydCB2ZWhlbWVuY2Ugb2YgYW55IGNhcm5hbCBwbGVhc3VyZS4="))



print("OK")


