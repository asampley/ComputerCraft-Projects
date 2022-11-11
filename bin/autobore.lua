local bore = require("/lib/bore")
local location = require("/lib/location")
local move = require("/lib/move")

-- step one, put chest in front of the turtle
-- this is where the turtle will put things not
--   from slot 1
local depth
local holes

local args = {...}

if #args ~= 3 then
  print("Usage: <depth> <forward> <right>")
  print("Ex: 20 5 4 (depth 20, and stay within a 5 x 4 area forward and right)")
  return
end

-- load arguments
depth = tonumber(args[1])
forward = tonumber(args[2])
right = tonumber(args[3])
if not depth then error("Depth must be an integer") end
if not forward then error("Forward must be an integer") end
if not right then error("Right must be an integer") end

-- record chest location
local position = location.getPos()
local heading = location.getHeading()
bore.setChest(position)

-- create min and max positions
local minPosition = vector.new(0, -math.huge, 0) + position
local maxPosition = position + heading * forward + location.turnRight(heading * right)

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
        bore.go(position + heading * hf + location.turnRight(heading * hr), depth, minPosition, maxPosition)
      end
    end
  end

  bore.transferToChest()
end
