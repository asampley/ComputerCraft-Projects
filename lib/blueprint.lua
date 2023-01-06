local blueprint = {
  AIR = ".",
}

-- create an empty blueprint
function blueprint.new()
  return setmetatable(
    {
      volumes = {},
    },
    { __index = blueprint }
  )
end

-- returns the index of the volume
function blueprint:add_volume(x0, x1, y0, y1, z0, z1, value)
  local volume = { x0 = x0, x1 = x1, y0 = y0, y1 = y1, z0 = z0, z1 = z1 }

  for x = x0, x1 do
    volume[x] = {}
    for y = y0, y1 do
      volume[x][y] = {}
      for z = z0, z1 do
        volume[x][y][z] = value or blueprint.AIR
      end
    end
  end

  self.volumes[#self.volumes+1] = volume

  return #self.volumes
end

-- get the volume index for the first volume containing [x][y][z]
function blueprint:get_volume(x, y, z)
  for i, volume in ipairs(self.volumes) do
    if volume[x] and volume[x][y] and volume[x][y][z] then
      return i
    end
  end
end

-- return the block stored in the blueprint, in the first volume that contains it
function blueprint:get_block(x, y, z)
  local v = self:get_volume(x, y, z)

  if v then
    return self.volumes[v][x][y][z]
  end
end

-- set the block stored in the blueprint, in the first volume that contains it
function blueprint:set_block(x, y, z, value)
  local v = self:get_volume(x, y, z)

  if v then
    self.volumes[v][x][y][z] = value

    return true
  end

  return false
end

-- run through the blueprint and count the occurence of each symbol
function blueprint:counts()
  local counts = {}

  for i, volume in ipairs(self.volumes) do
    for x = volume.x0, volume.x1 do
      for y = volume.y0, volume.y1 do
        for z = volume.z0, volume.z1 do
          if i == self:get_volume(x, y, z) then
            local symbol = volume[x][y][z]
            counts[symbol] = (counts[symbol] or 0) + 1
          end
        end
      end
    end
  end

  return counts
end

return blueprint
