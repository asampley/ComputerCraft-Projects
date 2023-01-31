local blueprint = require("/lib/blueprint")

local bp = blueprint.new()

bp.symbols = {
  ["T"] = {
    slot = 1,
    comment = "Trunk",
    nobuild = bp.ONLY_BUILD_Y,
  },
  ["L"] = {
    slot = 2,
    comment = "Leaves",
  },
}

bp:ellipsoid(0, 8, 0, 2.5, 4.5, 2.5, { all = "L" })
bp:cuboid(0, 0, 0, 9, 0, 0, { all = "T" })

return bp
