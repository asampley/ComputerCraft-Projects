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
      ["skip-horizontal-frame"] = "boolean",
    },
  },
  { ... }
)

local bp = blueprint.new()

bp.symbols = {
  ["_"] = {
    slot = 1,
    comment = "Step Detail",
    nobuild = bp.ONLY_BUILD_Y_POS,
    heading = args.up and location.X() or -location.X(),
  },
  ["T"] = {
    slot = 2,
    comment = "Roof Detail",
    nobuild = bp.ONLY_BUILD_Y_NEG,
    heading = args.up and -location.X() or location.X(),
  },
  ["|"] = {
    slot = 3,
    comment = "Frame",
  },
}

local y_i_mul = args.up and 1 or -1

for i = 0, args.length - 1 do
  local y0, y1 = -2 + y_i_mul * i, 1 + args.interior_height + y_i_mul * i
  local z0, z1 = -1, args.interior_width

  bp:cuboid(i, i, y0, y1, z0, z1, {
    xyedge = not args["skip-horizontal-frame"] and "|" or nil,
    yzedge = not args["skip-horizontal-frame"] and "|" or nil,
    yface = not args["skip-horizontal-frame"] and "|" or nil,
    corner = args.corner and "|",
    xzedge = "|",
    zface = "|",
    xface = bp.AIR,
    fill = bp.AIR,
  })
  bp:cuboid(i, i, y0 + 1, y0 + 1, z0 + 1, z1 - 1, { all = "_" })
  bp:cuboid(i, i, y1 - 1, y1 - 1, z0 + 1, z1 - 1, { all = "T" })
end

return bp
