local arguments = require("/lib/args")
local bore = require("/lib/bore")
local location = require("/lib/location")
local move = require("/lib/move")
local path = require("/lib/path")

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
  optional = {
    { name = "placeDirection", type = "string" }
  }
},
{...})

if args.help then
  print("Will place whatever block is in the inventory 'up' or 'down'")
  return
end


local dimensionVector = bore.dimensionsToVector(args.forward, args.height, args.right)
local placeDir = args.placeDirection

if not placeDir then
  if dimensionVector.y >= 0 then
    placeDir = "down" -- place below turtle as it will be moving up
  else
    placeDir = "up"
  end
end

if placeDir ~= "up" and placeDir ~= "down" then error("placecDirection must be 'up' or 'down'") end
placeDir = string.upper(string.sub(placeDir, 1, 1))..string.sub(placeDir, 2)
if dimensionVector.y >= 0 and placeDir ~= "Down" then print("placeDirection should probably be 'Down' when filling a positive height") end
if dimensionVector.y < 0 and placeDir ~= "Up" then print("placeDirection should probably be 'Up' when filling a negative height ") end


local startPos = location.getPos()
local startHeading = location.getHeading()

local slot = 1
turtle.select(slot)

path.rectangleSimple(dimensionVector, function (direction)
  while turtle.getItemCount() == 0 and slot < 16 do
    slot = slot + 1
    turtle.select(slot)
  end
  if turtle.getItemCount() == 0 then error("Ran out of items to place") end
  turtle["place"..placeDir]()
  return true
end)

startPos.y = location.getPos().y
move.goTo(startPos)
move.turnTo(startHeading)
