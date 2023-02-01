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
      roof = "boolean",
      wall = "boolean",
    },
  },
  { ... }
)

local bp = blueprint.new()

bp.symbols = {
  ["_"] = {
    slot = 1,
    comment = "Step Detail",
    needs = "-Y",
    onlybuild = bp.onlybuild("Y"),
    heading = args.up and location.X() or -location.X(),
  },
  ["T"] = {
    slot = 2,
    comment = "Roof Detail",
    needs = "Y",
    onlybuild = bp.onlybuild("-Y"),
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
  -- air bounds
  local y0, y1 = y_i_mul * i + y_off, args.interior_height - 1 + y_i_mul * i + y_off
  local z0, z1 = 0, args.interior_width - 1

  -- air
  bp:cuboid(i, i, y0, y1, z0, z1, { all = bp.AIR })

  -- bottom
  bp:cuboid(i, i, y0 - 2, y0 - 2, z0, z1, { all = "|" })
  bp:cuboid(i, i, y0 - 1, y0 - 1, z0, z1, { all = "_" })

  -- roof
  if args.roof then
    bp:cuboid(i, i, y1 + 2, y1 + 2, z0, z1, { all = "|" })
    bp:cuboid(i, i, y1 + 1, y1 + 1, z0, z1, { all = "T" })
  end

  -- walls
  if args.wall then
    local start = y0 - (args.corner and 2 or 1)
    local stop = y1 + (args.roof and (args.corner and 2 or 1) or 0)

    bp:cuboid(i, i, start, stop, z0 - 1, z0 - 1, { all = "|" })
    bp:cuboid(i, i, start, stop, z1 + 1, z1 + 1, { all = "|" })
  end
end

return bp
