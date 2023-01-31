local blueprint = require("/lib/blueprint")

local bp = blueprint.new()

bp.symbols = {
  ["|"] = {
    slot = 1,
    comment = "Frame vertical",
    nobuild = bp.ONLY_BUILD_Y,
  },
  ["-"] = {
    slot = 1,
    comment = "Frame along x",
    nobuild = bp.ONLY_BUILD_X,
  },
  ["_"] = {
    slot = 1,
    comment = "Frame along z",
    nobuild = bp.ONLY_BUILD_Z,
  },
  ["^"] = {
    slot = 2,
    comment = "Corner",
  },
}

local style = { frame = "|", xyedge = "_", yzedge = "-", corner = "^" }

bp:cuboid(0, 5, 0, 5, 0, 5, style)
bp:cuboid(1, 4, 5, 8, 1, 4, style)
bp:cuboid(2, 3, 8, 9, 2, 3, style)

return bp
