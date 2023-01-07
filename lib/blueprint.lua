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
        self.blocks:set(value, x, y, z)
      end
    end
  end
end

function blueprint:cuboid_hollow(x0, x1, y0, y1, z0, z1, value)
  for x = x0, x1 do for y = y0, y1 do
    self.blocks:set(value, x, y, z)
    self.blocks:set(value, x, y, z)
  end end

  for x = x0, x1 do for z = z0, z1 do
    self.blocks:set(value, x, y0, z)
    self.blocks:set(value, x, y1, z)
  end end

  for y = y0, y1 do for z = z0, z1 do
    self.blocks:set(value, x0, y, z)
    self.blocks:set(value, x1, y, z)
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
