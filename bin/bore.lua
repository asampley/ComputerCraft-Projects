local location = require("/lib/location")
local bore = require("/lib/bore")
local wants = require("/lib/bore/wants")

local arg = require("/lib/args")

local def = {
  required = {
    { name = "depth", type = "number" },
    { name = "minX", type = "number" },
    { name = "maxX", type = "number" },
    { name = "minZ", type = "number" },
    { name = "maxZ", type = "number" },
  },
  flags = {
    wants = "string",
    shaft = "string",
  }
}

local args = arg.parse(def, {...})

local position = location.getPos()
local heading = location.getHeading()

local min = position + heading * args.minZ + location.turnRight(heading * args.minX)
local max = position + heading * args.maxZ + location.turnRight(heading * args.maxX)

min.y = -math.huge
max.y = math.huge

for _, i in ipairs({ "x", "y", "z" }) do
  min[i], max[i] = math.min(min[i], max[i]), math.max(min[i], max[i])
end

local shaft

if not args.shaft then
  shaft = nil
elseif location[args.shaft:upper()] then
  shaft = location[args.shaft:upper()]()
else
  error(arg.usage(def))
end

wants.setProfile(args.wants)
bore.setChest(position)
bore.go(location.getPos(), args.depth, min, max, shaft)
