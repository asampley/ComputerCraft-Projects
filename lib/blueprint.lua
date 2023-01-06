local blueprint = {
  AIR = ".",

  volume = {}
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

function blueprint:add_volume(volume)
  self.volumes[#self.volumes+1] = volume
end

function blueprint.volume:get_block(x, y, z)
  return self[x] and self[x][y] and self[x][y][z]
end

-- returns the index of the volume
function blueprint.volume.cuboid_filled(x0, x1, y0, y1, z0, z1, value)
  local volume = setmetatable(
    { x0 = x0, x1 = x1, y0 = y0, y1 = y1, z0 = z0, z1 = z1 },
    { __index = blueprint.volume }
  )

  for x = x0, x1 do
    volume[x] = {}
    for y = y0, y1 do
      volume[x][y] = {}
      for z = z0, z1 do
        volume[x][y][z] = value or blueprint.AIR
      end
    end
  end

  return volume
end

function blueprint.volume.cuboid_hollow(x0, x1, y0, y1, z0, z1, value)
  local volume = blueprint.cuboid_filled(x0, x1, y0, y1, z0, z1)

  for x = x0, x1 do for y = y0, y1 do
    volume[x][y][z0] = value or blueprint.AIR
    volume[x][y][z1] = value or blueprint.AIR
  end end

  for x = x0, x1 do for z = z0, z1 do
    volume[x][y0][z] = value or blueprint.AIR
    volume[x][y1][z] = value or blueprint.AIR
  end end

  for y = y0, y1 do for z = z0, z1 do
    volume[x0][y][z] = value or blueprint.AIR
    volume[x1][y][z] = value or blueprint.AIR
  end end

  return volume
end

function blueprint.volume:rebound(x0, x1, y0, y1, z0, z1, value)
  -- remove now out of bounds areas
  for x = self.x0, self.x1 do
    if x < x0 or x1 < x then
      self[x] = nil
    else
      for y = self.y0, self.y1 do
        if y < y0 or y1 < y then
          self[x][y] = nil
        else
          for z = self.z0, self.z1 do
            if z < z0 or z1 < z then
              self[x][y][z] = nil
            end
          end
        end
      end
    end
  end

  -- add now in bound areas
  for x = x0, x1 do
    if not self[x] then self[x] = {} end
    for y = y0, y1 do
      if not self[x][y] then self[x][y] = {} end
      for z = z0, z1 do
        if not self[x][y][z] then
          self[x][y][z] = value or blueprint.AIR
        end
      end
    end
  end
end

-- combine volumes by doing the first volume or the second volume, etc.
-- bounds expanded to contain both
function blueprint.volume.bitor(...)
  local volume = {}

  for _, v2 in ipairs({...}) do
    volume.x0 = math.min(volume.x0 or v2.x0, v2.x0)
    volume.x1 = math.max(volume.x1 or v2.x1, v2.x1)
    volume.y0 = math.min(volume.y0 or v2.y0, v2.y0)
    volume.y1 = math.max(volume.y1 or v2.y1, v2.y1)
    volume.z0 = math.min(volume.z0 or v2.z0, v2.z0)
    volume.z1 = math.max(volume.z1 or v2.z1, v2.z1)

    -- add now in bound areas
    for x = volume.x0, volume.x1 do
      if not volume[x] then volume[x] = {} end
      for y = volume.y0, volume.y1 do
        if not volume[x][y] then volume[x][y] = {} end
        for z = volume.z0, volume.z1 do
          if not volume[x][y][z] then
            volume[x][y][z] = volume[x][y][z] or v2:get_block(x, y, z) or blueprint.AIR
          end
        end
      end
    end
  end

  return volume
end

-- get the volume index for the first volume containing [x][y][z]
function blueprint:get_volume(x, y, z)
  for i, volume in ipairs(self.volumes) do
    if volume:get_block(x, y, z) then
      return i
    end
  end
end

-- return the block stored in the blueprint, in the first volume that contains it
function blueprint:get_block(x, y, z)
  for _, volume in ipairs(self.volumes) do
    local block = volume:get_block(x, y, z)

    if block then return block end
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
