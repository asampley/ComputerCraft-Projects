-- replace require with wequire and run a program
-- attempts to download the file if it does not exist

local wequire = require("/lib/wequire")

local args = {...}

require = wequire.require
loadfile = wequire.loadfile
os.run = wequire.run

wequire.run(_ENV, args[1], table.unpack(args, 2))
