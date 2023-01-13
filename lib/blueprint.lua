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

-- Renders a cuboid
--
-- Specify options to change what symbols are where. The most specific
-- will be taken.
-- {
--   corner = "1", -- any of the up to 8 corners of the cuboid
--   xyedge = "2", -- edge that is on an x and y bound (4 total)
--   xzedge = "2", -- edge that is on an x and z bound (4 total)
--   yzedge = "2", -- edge that is on a y and z bound (4 total)
--   edge = "3", -- any block on an edge (excludes the corners)
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

-- returns true when the coordinates are inside an ellipsoid centered at 0
local function ellipsoid(x, y, z, xr, yr, zr)
  return x * x / xr / xr + y * y / yr / yr + z * z / zr / zr <= 1
end

-- Renders an ellipsoid at x, y, z with radii xr, yr, and zr
--
-- Specify options to change what symbols are where. The most specific
-- will be taken.
-- {
--   xextreme = "1", -- extreme points at the end of the x radius
--   yextreme = "1", -- extreme points at the end of the y radius
--   zextreme = "1", -- extreme points at the end of the z radius
--   extreme = "2", -- any of the up to 8 end points of the radii
--   xequator = "3", -- ellipse around the ellipsoid where x is about xc (excludes extreme)
--   yequator = "3", -- ellipse around the ellipsoid where y is about yc (excludes extreme)
--   zequator = "3", -- ellipse around the ellipsoid along z is about zc (excludes extreme)
--   equator = "4", -- ellipse around the ellipsoid along the axes (excludes extreme)
--   frame = "5", -- combination of extremes and equators
--   face = "6", -- interior area of face (excludes the frame)
--   hull = "7", -- combination of extreme, equator, and face
--   xaxis = "8", -- line along x axis (excluding center, extreme, equator)
--   yaxis = "8", -- line along y axis (excluding center, extreme, equator)
--   zaxis = "8", -- line along z axis (excluding center, extreme, equator)
--   axis = "9", -- line along all axes (excluding center, extreme, equator)
--   center = "10", -- center blocks
--   fill = "10", -- interior volume of the ellipsoid (excluds the hull)
--   all = "11", -- all the blocks in the ellipsoid
-- }
--
-- The symbols can optionally be functions that also take in (x, y, z) as
-- parameters, and then output a symbol. This could be used to obtain
-- checkerboard effects, for example, or any other effect you can write
-- into a function.
function blueprint:ellipsoid(xc, yc, zc, xr, yr, zr, symbols)
  local extreme = symbols.extreme or symbols.frame or symbols.hull or symbols.all
  local equator = symbols.equator or symbols.frame or symbols.hull or symbols.all
  local axis = symbols.axis or symbols.fill or symbols.all

  local blocks = {
    xextreme = symbols.xextreme or extreme,
    yextreme = symbols.yextreme or extreme,
    zextreme = symbols.zextreme or extreme,
    xequator = symbols.xequator or equator,
    yequator = symbols.yequator or equator,
    zequator = symbols.zequator or equator,
    xaxis = symbols.xaxis or axis,
    yaxis = symbols.yaxis or axis,
    zaxis = symbols.zaxis or axis,
    center = symbols.center or symbols.fill or symbols.all,
    face = symbols.face or symbols.hull or symbols.all,
    fill = symbols.fill or symbols.all,
  }

  local function inside(x, y, z)
    return ellipsoid(x, y, z, xr, yr, zr)
  end

  self:render(
    math.floor(xc - xr), math.floor(xc + xr),
    math.floor(yc - yr), math.floor(yc + yr),
    math.floor(zc - zr), math.floor(zc + zr),
    function(x, y, z)
      local block

      local dx, dy, dz = x - xc, y - yc, z - zc

      if not ellipsoid(dx, dy, dz, xr, yr, zr) then
        return nil
      end

      if x == xc - xr or x == xc + xr then block = blocks.xextreme
      elseif y == yc - yr or y == yc + yr then block = blocks.yextreme
      elseif z == zc - zr or z == zc + zr then block = blocks.zextreme
      else
        local sx = dx <= 0 and -1 or 1
        local sy = dy <= 0 and -1 or 1
        local sz = dz <= 0 and -1 or 1

        if not inside(dx + sx, dy + sy, dz + sz) then
          if math.abs(dx) < 0.5 then block = blocks.xequator
          elseif math.abs(dy) < 0.5 then block = blocks.yequator
          elseif math.abs(dz) < 0.5 then block = blocks.zequator
          else block = blocks.face
          end
        else
          local zeros = ""
          if math.abs(dx) < 0.5 then zeros = zeros .. "x" end
          if math.abs(dy) < 0.5 then zeros = zeros .. "y" end
          if math.abs(dz) < 0.5 then zeros = zeros .. "z" end

          if zeros == "xyz" then block = blocks.center
          elseif zeros == "xy" then block = blocks.zaxis
          elseif zeros == "xz" then block = blocks.yaxis
          elseif zeros == "yz" then block = blocks.xaxis
          else block = blocks.fill
          end
        end
      end

      if type(block) == "function" then
        block = block(x, y, z)
      end

      return block
    end
  )
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
