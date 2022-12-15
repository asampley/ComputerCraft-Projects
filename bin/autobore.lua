local bore = require("/lib/bore")
local location = require("/lib/location")
local move = require("/lib/move")

local args = {...}

if #args ~= 3 then
  print("Usage: <depth> <forward> <right>")
  print("Ex: 20 5 4 (depth 20, and stay within a 5 x 4 area forward and right)")
  return
end

-- load arguments
local depth = tonumber(args[1])
  or error("depth must be an integer")
local forward = tonumber(args[2])
  or error("Forward must be an integer")
local right = tonumber(args[3])
  or error("Right must be an integer")

-- record chest location
local position = location.getPos()
local heading = location.getHeading()

-- create min and max positions
local min = position
local max = position + heading * forward + location.turnRight(heading * right)

min.y = -math.huge
max.y = math.huge

for _, i in ipairs({ "x", "y", "z" }) do
  min[i], max[i] = math.min(min[i], max[i]), math.max(min[i], max[i])
end

bore.setChest(position)

--[[ Tile holes like this:
  X....X....X....X...
  ...X....X....X....X
  .X....X....X....X..
  ....X....X....X....
  ..X....X....X....X.
  S....X....X....X...
--]]
for hr = 0,right-1 do
  for hf = 0,forward-1 do
    if (hf + 2 * hr) % 5 == 0 then
      -- run bore on new spot
      local top = position + heading * hf + location.turnRight(heading * hr)
      move.digTo(top)

      -- ignore hole if it is topped with cobblestone
      local found, block = turtle.inspectDown()
      if found and block.name == "minecraft:cobblestone" then
        print("Skipping ("..hf..","..hr..")")
      else
        bore.go(position + heading * hf + location.turnRight(heading * hr), depth, min, max)
      end
    end
  end

  bore.transferToChest()
end
