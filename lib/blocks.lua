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
m.map = function(block, filters)
  for _, v in ipairs(filters) do
    local map = v[1]
    local filter = v[2]

    if filter(block, table.unpack(v, 3)) then
      return map
    end
  end
end

return m
