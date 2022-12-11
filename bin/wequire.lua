-- replace require with wequire and run a program
-- attempts to download the file if it does not exist

local wequire = require("/lib/wequire")

local args = {...}

require = wequire.require

local run = wequire.loadfile(args[1])

setfenv(run, _ENV)

run(table.unpack(args, 2))
