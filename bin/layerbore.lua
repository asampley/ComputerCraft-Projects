local arguments = require("/lib/args")
local bore = require("/lib/bore")

local args = arguments.parse({
  flags = {
    wants = "string",
    help = "boolean",
  },
  required = {
    { name = "height", type = "number" },
    { name = "forward", type = "number" },
    { name = "right", type = "number" },
  },
},
{...})

if args.help then
  print("To dig optimally deep into bedrock, place turtle in Y where Y % 3 == 1")
  print("eg. set tutrle in layer 61")
  return
end

local dimensionVector = bore.dimensionsToVector(args.height, args.forward, args.right)

local startTime = os.clock()
bore.layerBore(dimensionVector, args)
local timeTaken = (os.clock() - startTime) / 60
print("Finished in "..timeTaken.." minutes")
