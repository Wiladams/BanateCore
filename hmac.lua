--[[
	HMAC implementation
	http://tools.ietf.org/html/rfc2104
	http://en.wikipedia.org/wiki/HMAC

	hmac.compute(key, message, hash_function, blocksize, [opad], [ipad]) -> HMAC string, opad, ipad

	hmac.new(hash_function, block_size) -> function(message, key) -> HMAC string
--]]

local string = string
local sha2 = require "sha2"

local function Decode( aValue )
    local aDecoder = function( aValue )
        return string.char( tonumber( aValue, 16 ) )
    end

    return ( aValue:lower():gsub( '(%x%x)', aDecoder ) )
end

local function Encode( aValue )
    local anEncoder = function( aValue )
        return ( '%02x' ):format( aValue:byte() )
    end

    return ( aValue:gsub( '.', anEncoder ) )
end

local function Hash(aValue)
	return Decode( sha2.sha256( aValue ) )
end

-- blocksize is that of the underlying hash function
-- (64 for MD5 and SHA-256, 128 for SHA-384 and SHA-512)

local function NormalizeKey(aKey, blocksize)
	blocksize = blocksize or 64

	--keys longer than blocksize are shortened
	if aKey:len() > blocksize then
		aKey = Hash(aKey)
	end

	--keys shorter than blocksize are zero-padded
	aKey = aKey..string.char(0):rep(blocksize-aKey:len())

	return aKey
end

local function HMAC_SHA_256(aKey, message, hash, blocksize, opad, ipad)
	blocksize = blocksize or 64
	aKey = NormalizeKey(aKey, blocksize)

    local opad = opad or aKey:gsub( '.', function( aChar ) return string.char( bit.bxor( aChar:byte(), 0x5c ) ) end )
    local ipad = ipad or aKey:gsub( '.', function( aChar ) return string.char( bit.bxor( aChar:byte(), 0x36 ) ) end )

    return Encode( Hash( opad .. Hash( ipad .. message ) ) ) -- , opad, ipad --opad and ipad can be cached for the same key

end

return {
	HMAC_SHA_256 = HMAC_SHA_256,
}



