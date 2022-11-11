local m = {}

m.sum = function(list)
  local result = 0
  for _,value in pairs(list)
  do
    result = result + value
  end
  return result
end

m.trueCount = function(list)
  local result = 0
  for _,value in pairs(list)
  do
    if value
    then
      result = result + 1
    end
  end
  return result
end

m.min = function(list)
  return math.min(unpack(list))
end

m.max = function(list)
  return math.max(unpack(list))
end

m.mean = function(list)
  result = 0
  count = 0
  for _,value in pairs(list)
  do
    result = result + value
    count = count + 1
  end
  return result / count
end

return m
