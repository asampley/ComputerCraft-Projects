local bore = require("/lib/bore")

local args = {...}

if #args ~= 3 then
  print("Usage: layerbore <+/-maxDepth> <+/-forward> <+/-right>")
  print("To prevent turtle from getting stuck in bedrock, the starting layer should be y % 3 == 0")
  print("eg. set tutrle in layer 60")
  return
end

local depth = tonumber(args[1])
local forward = tonumber(args[2])
local right = tonumber(args[3])

if not depth or depth < 1 then error("Depth must 1 or greater") end
if not forward then error("forward must be an integer") end
if not right then error("right must be an integer") end

local startTime = os.clock()
bore.layerBore(depth, forward, right)
local timeTaken = (os.clock() - startTime) / 60
print("Finished in "..timeTaken.." minutes")
