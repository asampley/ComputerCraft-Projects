local blueprint = require("/lib/blueprint")

local bp = blueprint.new()

bp.symbols = {
  ["|"] = {
    slot = 1,
    comment = "Frame vertical",
    onlybuild = bp.onlybuild("Y", "-Y"),
  },
  ["-"] = {
    slot = 1,
    comment = "Frame along x",
    onlybuild = bp.onlybuild("X", "-X"),
  },
  ["_"] = {
    slot = 1,
    comment = "Frame along z",
    onlybuild = bp.onlybuild("Z", "-Z"),
  },
  ["^"] = {
    slot = 2,
    comment = "Corner",
  },
}

local style = {
  edge = { axy = "_", ayz = "-", axz = "|" },
  corner = { all = "^" }
}

bp:cuboid(0, 5, 0, 5, 0, 5, style)
bp:cuboid(1, 4, 5, 8, 1, 4, style)
bp:cuboid(2, 3, 8, 9, 2, 3, style)

return bp
