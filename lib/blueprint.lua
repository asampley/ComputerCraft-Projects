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

function blueprint:cuboid(x0, x1, y0, y1, z0, z1, frame, face, volume)
  for x = x0, x1 do
    for y = y0, y1 do
      for z = z0, z1 do
        local edges = 0

        if x == x0 or x == x1 then edges = edges + 1 end
        if y == y0 or y == y1 then edges = edges + 1 end
        if z == z0 or z == z1 then edges = edges + 1 end

        local block
        if edges >= 2 then
          block = frame
        elseif edges == 1 then
          block = face
        else
          block = volume
        end

        self.blocks:set(block, x, y, z)
      end
    end
  end
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
