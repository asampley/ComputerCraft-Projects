local bore = require("/lib/bore")

local args = {...}

if #args ~= 3 then
  print("Usage: layerbore <+/-height> <+/-forward> <+/-right>")
  print("To prevent turtle from getting stuck in bedrock, the starting layer should be y % 3 == 0")
  print("eg. set tutrle in layer 60")
  return
end

local height = tonumber(args[1])
local forward = tonumber(args[2])
local right = tonumber(args[3])

if not height then error("Height must be an integer") end
if not forward then error("forward must be an integer") end
if not right then error("right must be an integer") end
if height == 0 or forward == 0 or right == 0 then error("0 for a height/forward/right, nothing to do") end

local startTime = os.clock()
bore.layerBore(height, forward, right)
local timeTaken = (os.clock() - startTime) / 60
print("Finished in "..timeTaken.." minutes")
