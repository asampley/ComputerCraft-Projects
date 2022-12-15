local location = require("/lib/location")
local bore = require("/lib/bore")

local args = {...}

if #args ~= 5 then
  print("Usage: bore <depth> <minX> <maxX> <minZ> <maxZ>")
  return
end

local depth = tonumber(args[1])
local minX = tonumber(args[2])
local maxX = tonumber(args[3])
local minZ = tonumber(args[4])
local maxZ = tonumber(args[5])

if not depth then error("Depth must be an integer") end
if not minX then error("Min X must be an integer") end
if not maxX then error("Max X must be an integer") end
if not minZ then error("Min Z must be an integer") end
if not maxZ then error("Max Z must be an integer") end

local position = location.getPos()
local heading = location.getHeading()

local min = position + heading * minZ + location.turnRight(heading * minX)
local max = position + heading * maxZ + location.turnRight(heading * maxX)

min.y = -math.huge

for _, i in ipairs({ "x", "y", "z" }) do
  min[i], max[i] = math.min(min[i], max[i]), math.max(min[i], max[i])
end

bore.setChest(position)
bore.go(location.getPos(), depth, min, max)
