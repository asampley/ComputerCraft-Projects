local m = {}

m.sum = function(list)
  local result = 0
  for _, value in pairs(list) do
    result = result + value
  end
  return result
end

m.trueCount = function(list)
  local result = 0
  for _, value in pairs(list) do
    if value
    then
      result = result + 1
    end
  end
  return result
end

m.min = function(...)
  return math.min(...)
end

m.max = function(...)
  return math.max(...)
end

m.mean = function(list)
  local result = 0
  local count = 0
  for _, value in pairs(list) do
    result = result + value
    count = count + 1
  end
  return result / count
end

return m
