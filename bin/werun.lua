-- replace require with wequire and run a program
-- attempts to download the file if it does not exist

local wequire = require("/lib/wequire")

local args = require("/lib/args").parse(
  {
    flags = {
      update = "boolean"
    },
    required = {
      { name = "file" },
    },
    rest = { name = "rest" },
  },
  {...}
)

require = wequire.require
loadfile = wequire.loadfile
wequire.overwrite = args.update == true

wequire.run(_ENV, args.file, args.rest)
