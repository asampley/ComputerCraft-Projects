local blueprint = require("/lib/blueprint")

local bp = blueprint.new()

bp.symbols = {
  ["A"] = {
    slot = 1,
    comment = "Frame",
  }
}

bp:cuboid(0, 5, 0, 5, 0, 5, "A")
bp:cuboid(1, 4, 5, 8, 1, 4, "A")
bp:cuboid(2, 3, 8, 10, 2, 3, "A")

return bp
