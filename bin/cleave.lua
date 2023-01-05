local arguments = require("/lib/args")
local bore = require("/lib/bore")

local args = arguments.parse({
    flags = { wants = "string" },
    required = {
      { name = "height", type = "number" },
      { name = "forward", type = "number" },
      { name = "right", type = "number" },
    },
  },
  {...})

local dimensionVector = bore.dimensionsToVector(args.forward, args.height, args.right)

local startTime = os.clock()

bore.cleave(dimensionVector, args)

local timeTaken = (os.clock() - startTime) / 60
print("Finished in "..timeTaken.." minutes")
