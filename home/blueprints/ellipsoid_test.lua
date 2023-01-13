local blueprint = require("/lib/blueprint")

local bp = blueprint.new()

bp.symbols = {
  ["Y"] = {
    slot = 1,
    comment = "Extreme vertical",
    nobuild = bp.ONLY_BUILD_Y,
  },
  ["X"] = {
    slot = 1,
    comment = "Extreme along x",
    nobuild = bp.ONLY_BUILD_X,
  },
  ["Z"] = {
    slot = 1,
    comment = "Extreme along z",
    nobuild = bp.ONLY_BUILD_Z,
  },
  ["|"] = {
    slot = 2,
    comment = "Equators",
  },
  ["C"] = {
    slot = 3,
    comment = "Surface",
  }
}

local style = { xextreme = "X", yextreme = "Y", zextreme = "Z", equator = "|", face = "C", axis = bp.AIR }

bp:ellipsoid(2, 2, 2, 4, 4, 4, style)

return bp
