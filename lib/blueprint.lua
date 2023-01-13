local tensor = require("/lib/tensor")

local blueprint = {
  AIR = ".",

  -- constants for nobuild property
  ONLY_BUILD_X = { ["Y"] = true, ["-Y"] = true, ["Z"] = true, ["-Z"] = true },
  ONLY_BUILD_Y = { ["X"] = true, ["-X"] = true, ["Z"] = true, ["-Z"] = true },
  ONLY_BUILD_Z = { ["X"] = true, ["-X"] = true, ["Y"] = true, ["-Y"] = true },
}

-- create an empty blueprint
function blueprint.new()
  return setmetatable(
    {
      blocks = tensor.new(),
    },
    { __index = blueprint }
  )
end

-- render a region based on a render function.
--
-- If the function returns a value, that value is put into the blueprint
-- unless below is true. If below is true, the value is only put in if
-- that current value is nil.
function blueprint:render(x0, x1, y0, y1, z0, z1, render_f, below)
  for x = x0, x1 do
    for y = y0, y1 do
      for z = z0, z1 do
        if not below or not self.blocks:get(x, y, z) then
          local symbol = render_f(x, y, z)

          if symbol then
            self.blocks:set(symbol, x, y, z)
          end
        end
      end
    end
  end
end

-- Return a function for rendering a cuboid
--
-- Specify options to change what symbols are where. The most specific
-- will be taken.
-- {
--   corner = "1", -- any of the up to 8 corners of the cuboid
--   edge = "2", -- any block on an edge (excludes the corners)
--   xyedge = "3", -- edge that is on an x and y bound (4 total)
--   xzedge = "3", -- edge that is on an x and z bound (4 total)
--   yzedge = "3", -- edge that is on a y and z bound (4 total)
--   frame = "4", -- combination of corner and edge
--   xface = "5", -- face on an x boundary (2 total)
--   yface = "5", -- face on a y boundary (2 total)
--   zface = "5", -- face on a z boundary (2 total)
--   face = "6", -- interior area of face (excludes the frame)
--   hull = "7", -- combination of corner, edge, and face
--   fill = "8", -- interior volume of the cuboid (excluds the hull)
--   all = "9", -- all the blocks in the cuboid
-- }
--
-- The symbols can optionally be functions that also take in (x, y, z) as
-- parameters, and then output a symbol. This could be used to obtain
-- checkerboard effects, for example, or any other effect you can write
-- into a function.
function blueprint:cuboid(x0, x1, y0, y1, z0, z1, symbols)
  local corner = symbols.corner or symbols.frame or symbols.hull or symbols.all
  local edge = symbols.edge or symbols.frame or symbols.hull or symbols.all
  local face = symbols.face or symbols.hull or symbols.all

  local blocks = {
    xyz = corner,
    xy = symbols.xyedge or edge,
    xz = symbols.xzedge or edge,
    yz = symbols.yzedge or edge,
    x = symbols.xface or face,
    y = symbols.yface or face,
    z = symbols.zface or face,
    [""] = symbols.fill or symbols.all,
  }

  self:render(x0, x1, y0, y1, z0, z1, function(x, y, z)
    local bounds = ""

    if x == x0 or x == x1 then bounds = bounds .. "x" end
    if y == y0 or y == y1 then bounds = bounds .. "y" end
    if z == z0 or z == z1 then bounds = bounds .. "z" end

    local block = blocks[bounds]

    if type(block) == "function" then
      block = block(x, y, z)
    end

    return block
  end)
end

-- run through the blueprint and count the occurence of each symbol
function blueprint:counts()
  local counts = {}

  for _, bx in pairs(self.blocks) do
    for _, by in pairs(bx) do
      for _, bz in pairs(by) do
        counts[bz] = (counts[bz] or 0) + 1
      end
    end
  end

  return counts
end

function blueprint:symbol(x, y, z)
  local symbol = self.blocks:get(x, y, z)
  return symbol, self.symbols and self.symbols[symbol]
end

return blueprint
