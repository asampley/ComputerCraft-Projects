local blueprint = require("/lib/blueprint")
local location = require("/lib/location")

local args = require("/lib/args").parse(
  {
    required = {
      { name = "interior_width", "number" },
      { name = "interior_height", "number"},
      { name = "length", "number" },
    },
    flags = {
      up = "boolean",
      corner = "boolean",
    },
  },
  { ... }
)

local bp = blueprint.new()

bp.symbols = {
  ["_"] = {
    slot = 1,
    comment = "Step Detail",
    onto = "-Y",
    heading = args.up and location.X() or -location.X(),
  },
  ["T"] = {
    slot = 2,
    comment = "Roof Detail",
    onto = "Y",
    heading = args.up and -location.X() or location.X(),
  },
  ["|"] = {
    slot = 3,
    comment = "Frame",
  },
}

local y_i_mul = args.up and 1 or -1
local y_off = args.up and 1 or 0

for i = 0, args.length - 1 do
  local y0, y1 = -2 + y_i_mul * i + y_off, 1 + args.interior_height + y_i_mul * i + y_off
  local z0, z1 = -1, args.interior_width

  bp:cuboid(i, i, y0, y1, z0, z1, {
    edge = "|",
    corner = args.corner and "|",
    xface = bp.AIR,
    yface = "|",
    zface = "|",
    fill = bp.AIR,
  })
  bp:cuboid(i, i, y0 + 1, y0 + 1, z0 + 1, z1 - 1, { all = "_" })
  bp:cuboid(i, i, y1 - 1, y1 - 1, z0 + 1, z1 - 1, { all = "T" })
end

return bp
