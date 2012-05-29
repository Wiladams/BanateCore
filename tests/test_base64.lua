-- Put this at the top of any test
local ppath = package.path..';..\\?.lua'
package.path = ppath;

--local BC = require "BanateCore"
--local base64 = BC.Base64
require "base64"


--[[
print("\\n: ", base64.isspace(string.byte('\n')))
print("\\r: ", base64.isspace(string.byte('\r')))
print("\\t: ", base64.isspace(string.byte('\t')))
print("  : ", base64.isspace(string.byte(' ')))
print("\\f: ", base64.isspace(string.byte('\f')))
print("\\b: ", base64.isspace(string.byte('\b')))
print("a: ", base64.isspace(string.byte('a')))
--]]

--[[
print("A", base64.char64index(string.byte('A')))
print("/", base64.char64index(string.byte('/')))
print("*", base64.char64index(string.byte('*')))
--]]



---[[
assert(base64.encode("") == "")
assert(base64.encode("f") == "Zg==")
assert(base64.encode("fo") == "Zm8=")
assert(base64.encode("foo") == "Zm9v")
assert(base64.encode("foob") == "Zm9vYg==")
assert(base64.encode("fooba") == "Zm9vYmE=")
assert(base64.encode("foobar") == "Zm9vYmFy")


assert(base64.encode("pleasure.") == "cGxlYXN1cmUu")
assert(base64.encode("leasure.")	== "bGVhc3VyZS4=")
assert(base64.encode("easure.")	== "ZWFzdXJlLg==")
assert(base64.encode("asure.")	== "YXN1cmUu")
assert(base64.encode("sure.")		== "c3VyZS4=")

--]]

---[[
-- Test cases from
-- http://tools.ietf.org/html/rfc4648

print(base64.decode("cGxl"))		-- ple
print(base64.decode("YXN1"))		-- asu
print(base64.decode("cmUu"))		-- re.

print(base64.decode("Zg=="))		-- f
print(base64.decode("Zm8="))		-- fo
print(base64.decode("Zm9v"))		-- foo
print(base64.decode("Zm9vYg=="))	-- foob
print(base64.decode("Zm9vYmE="))	-- fooba
print(base64.decode("Zm9vYmFy"))	-- foobar
--]]

---[[
assert(base64.decode("cGxlYXN1cmUu") == "pleasure.")
assert(base64.decode("bGVhc3VyZS4=") == "leasure.")
assert(base64.decode("ZWFzdXJlLg==") == "easure.")
assert(base64.decode("YXN1cmUu") == "asure.")
assert(base64.decode("c3VyZS4=") == "sure.")

--print(base64.encode("All good things come to those who wait"));
--print(base64.decode("QWxsIGdvb2QgdGhpbmdzIGNvbWUgdG8gdGhvc2Ugd2hvIHdhaXQ="))


print(base64.decode("TWFuIGlzIGRpc3Rpbmd1aXNoZWQsIG5vdCBvbmx5IGJ5IGhpcyByZWFzb24sIGJ1dCBieSB0aGlzIHNpbmd1bGFyIHBhc3Npb24gZnJvbSBvdGhlciBhbmltYWxzLCB3aGljaCBpcyBhIGx1c3Qgb2YgdGhlIG1pbmQsIHRoYXQgYnkgYSBwZXJzZXZlcmFuY2Ugb2YgZGVsaWdodCBpbiB0aGUgY29udGludWVkIGFuZCBpbmRlZmF0aWdhYmxlIGdlbmVyYXRpb24gb2Yga25vd2xlZGdlLCBleGNlZWRzIHRoZSBzaG9ydCB2ZWhlbWVuY2Ugb2YgYW55IGNhcm5hbCBwbGVhc3VyZS4="));
--]]

print("OK")


