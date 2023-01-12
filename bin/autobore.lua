local bore = require("/lib/bore")
local location = require("/lib/location")
local move = require("/lib/move")
local wants = require("/lib/bore/wants")

local args = require("/lib/args").parse({
  flags = {
    wants = "string",
    help = "boolean",
  },
  required = {
    { name = "depth", type = "number" },
    { name = "forward", type = "number" },
    { name = "right", type = "number" },
  },
},
{...})

if args.help then
  print("Ex: 20 5 4 (depth 20, and stay within a 5 x 4 area forward and right)")
  return
end

-- load arguments
local depth = args.depth
local forward = args.forward
local right = args.right

-- record chest location
local position = location.getPos()
local heading = location.getHeading()

-- create min and max positions
local min = position + vector.new(0, -math.huge, 0)
local max = position + heading * forward + location.turnRight(heading * right)

max.y = math.huge

for _, i in ipairs({ "x", "y", "z" }) do
  min[i], max[i] = math.min(min[i], max[i]), math.max(min[i], max[i])
end

wants.setProfile(args.wants)
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
