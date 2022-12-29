local inventory = require("/lib/inventory")
local location = require("/lib/location")
local path = require("/lib/path")

local args = {...}

if #args ~= 4 then
  print("Usage: fill <+/-depth> <+/-forward> <+/-right> <placecDirection>")
  print("Will place whatever block is in the inventory Up or Down")
  return
end

local depth = tonumber(args[1])
local forward = tonumber(args[2])
local right = tonumber(args[3])
local placeDir = args[4]

if not depth or depth < 1 then error("Depth must 1 or greater") end
if not forward then error("forward must be an integer") end
if not right then error("right must be an integer") end
if placeDir ~= "Up" and placeDir ~= "Down" then error("placecDirection must be 'Up' or 'Down'") end


-- Decrease forward and right magnitude by one for calc'ing desired position
-- (because we are already on the first space)
forward = forward - forward / math.abs(forward)
right = right - right / math.abs(right)
local toPos = location.getPos() + vector.new(forward, -depth + 1, right)

turtle.select(1)
inventory.setAutoRefill(true)

path.solidRectangle(toPos, function (direction)
  turtle["place"..placeDir]()
  return true
end)

inventory.setAutoRefill(false)
