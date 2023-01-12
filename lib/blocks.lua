local m = {}

m.filter = {
  name = function(block, pattern)
    return string.match(block.name, "^" .. pattern .. "$")
  end,

  tag = function(block, tag)
    return block.tags and block.tags[tag]
  end,

  mtag = function(block, pattern)
    if not block.tags then return false end

    for t, v in pairs(block.tags) do
      if string.match(t, "^" .. pattern .. "$") then
        return v
      end
    end

    return false
  end,
}

-- takes in a list of filters in the format
-- { map, filter, additionalParameters... }
--
-- The first filter that returns true returns
-- the corresponding value of map
-- Returns true or false if a matching filter was found, else nil
m.map = function(block, filters)
  for _, v in ipairs(filters) do
    local map = v[1]
    local filter = v[2]

    if filter(block, table.unpack(v, 3)) then
      return map
    end
  end
end

m.isBedrock = function (block)
  return block.name == "minecraft:bedrock"
end

-- wheat, carrots, potatoes, beets
m.isSimpleCrop = function (block)
  local simpleCrops = {
    ["minecraft:wheat"] = true,
    ["minecraft:carrots"] = true,
    ["minecraft:potatoes"] = true,
    ["minecraft:beetroots"] = true,
  }
  return simpleCrops[block.name] or false
end

m.isHarvestable = function (block)
  if not block.state then return false end
  if block.name == "minecraft:beetroots" and block.state.age == 3 then return true end
  if m.isSimpleCrop(block) and block.state.age == 7 then return true end
  return false
end

return m
