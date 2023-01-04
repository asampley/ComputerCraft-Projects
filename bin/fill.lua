local arguments = require("/lib/args")
local inventory = require("/lib/inventory")
local location = require("/lib/location")
local path = require("/lib/path")

local args = {...}

if #args < 3 or #args > 4 then
  print("Usage: fill <+/-height> <+/-forward> <+/-right> [<placecDirection>]")
  print("Will place whatever block is in the inventory 'Up' or 'Down'")
  return
end

local dimensionVector = arguments.dimensionsToVector(args[1], args[2], args[3])
local placeDir = args[4]

if dimensionVector.y >= 0 and not placeDir then
  placeDir = "down" -- place below turtle as it will be moving up
else
  placeDir = "up"
end
if placeDir ~= "up" and placeDir ~= "down" then error("placecDirection must be 'up' or 'down'") end
placeDir = string.upper(string.sub(placeDir, 1, 1))..string.sub(placeDir, 2)
if dimensionVector.y >= 0 and placeDir ~= "Down" then print("placeDirection should probably be 'Down' when filling a positive height") end
if dimensionVector.y < 0 and placeDir ~= "Up" then print("placeDirection should probably be 'Up' when filling a negative height ") end


local toPos = location.getPos() + dimensionVector

local slot = 1
turtle.select(slot)

path.rectangleSimple(toPos, function (direction)
  while turtle.getItemCount() == 0 and slot < 16 do
    slot = slot + 1
    turtle.select(slot)
  end
  if turtle.getItemCount() == 0 then error("Ran out of items to place") end
  turtle["place"..placeDir]()
  return true
end)

inventory.setAutoRefill(false)
