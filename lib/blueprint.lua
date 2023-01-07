local tensor = require("/lib/tensor")

local blueprint = {
  AIR = "."
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

function blueprint:cuboid_filled(x0, x1, y0, y1, z0, z1, value)
  for x = x0, x1 do
    for y = y0, y1 do
      for z = z0, z1 do
        self:set_block(x, y, z, value)
      end
    end
  end
end

function blueprint:cuboid_hollow(x0, x1, y0, y1, z0, z1, value)
  for x = x0, x1 do for y = y0, y1 do
    self:set_block(x, y, z0, value)
    self:set_block(x, y, z1, value)
  end end

  for x = x0, x1 do for z = z0, z1 do
    self:set_block(x, y0, z, value)
    self:set_block(x, y1, z, value)
  end end

  for y = y0, y1 do for z = z0, z1 do
    self:set_block(x0, y, z, value)
    self:set_block(x1, y, z, value)
  end end
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

return blueprint
