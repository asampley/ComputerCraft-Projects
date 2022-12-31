local arguments = require("/lib/args")
local bore = require("/lib/bore")

local args = {...}

if #args ~= 3 then
  print("Usage: cleave <+/-height> <+/-forward> <+/-right>")
  return
end

local dimensionVector = arguments.dimensionsToVector(args[1], args[2], args[3])

local startTime = os.clock()

bore.cleave(dimensionVector)

local timeTaken = (os.clock() - startTime) / 60
print("Finished in "..timeTaken.." minutes")
