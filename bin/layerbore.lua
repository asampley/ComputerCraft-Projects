local arguments = require("/lib/args")
local bore = require("/lib/bore")

local args = {...}

if #args ~= 3 then
  print("Usage: layerbore <+/-height> <+/-forward> <+/-right>")
  print("To prevent turtle from getting stuck in bedrock, the starting layer should be y % 3 == 0")
  print("eg. set tutrle in layer 60")
  return
end

local dimensionVector = arguments.dimensionsToVector(args[1], args[2], args[3])

local startTime = os.clock()
bore.layerBore(dimensionVector)
local timeTaken = (os.clock() - startTime) / 60
print("Finished in "..timeTaken.." minutes")
