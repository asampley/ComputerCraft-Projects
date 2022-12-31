local inventory = require("/lib/inventory")
local location = require("/lib/location")
local path = require("/lib/path")

local args = {...}

if #args < 3 or #args > 4 then
  print("Usage: fill <+/-height> <+/-forward> <+/-right> [<placecDirection>]")
  print("Will place whatever block is in the inventory 'Up' or 'Down'")
  return
end

local height = tonumber(args[1])
local forward = tonumber(args[2])
local right = tonumber(args[3])
local placeDir = args[4]

if height < 0 and not placeDir then
  placeDir = "Up" -- place above as turtle will be moving down
else
  placeDir = "Down"
end

if not height then error("Height must be an integer") end
if not forward then error("forward must be an integer") end
if not right then error("right must be an integer") end
if height == 0 or forward == 0 or right == 0 then error("0 for a height/forward/right, nothing to do") end
if placeDir ~= "Up" and placeDir ~= "Down" then error("placecDirection must be 'Up' or 'Down'") end
if height < 0 and placeDir ~= "Up" then print("placecDirection should be 'Up' when filling a negative height ") end
if height > 1 and placeDir ~= "Down" then print("placeDirection should be 'Down' when filling a positive height") end


-- Decrease forward and right magnitude by one for calc'ing desired position
-- (because we are already on the first space)
forward = forward - forward / math.abs(forward)
right = right - right / math.abs(right)
height = height - height/math.abs(height)
local toPos = location.getPos() + vector.new(forward, height, right)

turtle.select(1)
inventory.setAutoRefill(true)

path.solidRectangle(toPos, function (direction)
  turtle["place"..placeDir]()
  return true
end)

inventory.setAutoRefill(false)
