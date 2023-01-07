local location = require("/lib/location")
local bore = require("/lib/bore")
local wants = require("/lib/bore/wants")

local args = require("/lib/args").parse(
  {
    required = {
      { name = "depth", type = "number" },
      { name = "minX", type = "number" },
      { name = "maxX", type = "number" },
      { name = "minZ", type = "number" },
      { name = "maxZ", type = "number" },
    },
    flags = {
      wants = "string",
    }
  },
  {...}
)

local position = location.getPos()
local heading = location.getHeading()

local min = position + heading * args.minZ + location.turnRight(heading * args.minX)
local max = position + heading * args.maxZ + location.turnRight(heading * args.maxX)

min.y = -math.huge
max.y = math.huge

for _, i in ipairs({ "x", "y", "z" }) do
  min[i], max[i] = math.min(min[i], max[i]), math.max(min[i], max[i])
end

wants.setProfile(args.wants)
bore.setChest(position)
bore.go(location.getPos(), args.depth, min, max)
