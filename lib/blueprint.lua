local tensor = require("/lib/tensor")

local blueprint = {
  AIR = ".",
}

-- create onlybuild property table from list
function blueprint.onlybuild(...)
  local onlybuild = {}

  for _, v in ipairs({...}) do
    onlybuild[v] = true
  end

  return onlybuild
end

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
--   -- configure the the 8 corners of the cuboid
--   -- specify specific corners (lowercase is negative on the axis e.g. xYz is -x, +y, -z)
--   -- all will apply to any unset corners.
--   corner = {
--     xyz = "1", xyZ = "1", xYz = "1", xYZ = "1", Xyz = "1", XyZ = "1", XYz = "1", XYZ = "1",
--     all = "2",
--   },
--
--   -- configure the 12 edges of the cuboid (excludes the corners)
--   -- specify specific edges (lowercase is negative on the axis. e.g. xY is -x, +y)
--   -- all will apply to any unset edges.
--   -- the "a" prefixed strings will do both positive and negative of both axes
--   edge = {
--     xy = "1", xY = "1", Xy = "1", XY = "1", axy = "2",
--     xz = "1", xZ = "1", Xz = "1", XZ = "1", axz = "2",
--     yz = "1", yZ = "1", Yz = "1", YZ = "1", ayz = "2",
--     all = "3",
--   },
--
--   frame = "4", -- combination of corner and edge
--
--   -- configure the 6 faces of the cuboid (excludes the frame)
--   -- specify specific faces (lowercase is negative on the axis. e.g. x is -x)
--   -- all will apply to any unset edges.
--   -- the "a" prefixed strings will do both positive and negative of the axis
--   face = {
--     x = "1", X = "1", ax = "2",
--     y = "1", Y = "1", ay = "2",
--     z = "1", Z = "1", az = "2",
--     all = "3",
--   },
--
--   hull = "7", -- combination of corner, edge, and face
--
--   fill = "8", -- interior volume of the cuboid (excluds the hull)
--
--   all = "9", -- all the blocks in the cuboid
-- }
--
-- The symbols can optionally be functions that also take in (x, y, z) as
-- parameters, and then output a symbol. This could be used to obtain
-- checkerboard effects, for example, or any other effect you can write
-- into a function.
function blueprint:cuboid(x0, x1, y0, y1, z0, z1, symbols)
  self:render(x0, x1, y0, y1, z0, z1, function(x, y, z)
    local bounds = ""

    if math.abs(x0 - x) < 0.5 then bounds = bounds .. "x"
    elseif math.abs(x1 - x) < 0.5 then bounds = bounds .. "X"
    end

    if math.abs(y0 - y) < 0.5 then bounds = bounds .. "y"
    elseif math.abs(y1 - y) < 0.5 then bounds = bounds .. "Y"
    end

    if math.abs(z0 - z) < 0.5 then bounds = bounds .. "z"
    elseif math.abs(z1 - z) < 0.5 then bounds = bounds .. "Z"
    end

    local block
    if #bounds == 3 then
      block = (symbols.corner and (
        symbols.corner[bounds]
        or symbols.corner["a" .. bounds:lower()]
        or symbols.corner.all
      ))
    elseif #bounds == 2 then
      block = (symbols.edge and (
        symbols.edge[bounds]
        or symbols.edge["a" .. bounds:lower()]
        or symbols.edge.all
      ))
    elseif #bounds == 1 then
      block = (symbols.face and (
        symbols.face[bounds]
        or symbols.face["a" .. bounds:lower()]
        or symbols.face.all
      ))
    end

    if #bounds >= 2 then
      block = block or symbols.frame
    end

    if #bounds >= 1 then
      block = block or symbols.hull
    end

    block = block or symbols.all

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
