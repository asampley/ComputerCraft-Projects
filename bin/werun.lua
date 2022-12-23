-- basically bin/wequire but
-- always download and overwrite all files
_ENV.isWerun = true

local wequire = require("/lib/wequire")

local args = {...}

require = wequire.require
loadfile = wequire.loadfile


wequire.run(_ENV, args[1], table.unpack(args, 2))
