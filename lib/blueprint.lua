local blueprint = {
  AIR = "."
}

-- create an empty blueprint
function blueprint.new()
  return setmetatable(
    {
      blocks = {},
    },
    { __index = blueprint }
  )
end

-- get the block, nil if air or out of bounds
function blueprint:get_block(x, y, z)
  return self.blocks[x] and self.blocks[x][y] and self.blocks[x][y][z]
end

-- set the block only if it is in bounds
-- return boolean indicating whether it was in bounds
function blueprint:set_block(x, y, z, value)
  if not self.blocks[x] then
    if value == nil then
      return
    else
      self.blocks[x] = {}
    end
  end
  if not self.blocks[x][y] then
    if value == nil then
      return
    else
      self.blocks[x][y] = {}
    end
  end

  self.blocks[x][y][z] = value

  if next(self.blocks[x][y]) == nil then
    self.blocks[x][y] = nil
  end
  if next(self.blocks[x]) == nil then
    self.blocks[x] = nil
  end
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
