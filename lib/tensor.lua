local tensor = {}

function tensor.new()
  return setmetatable({}, { __index = tensor })
end

function tensor:get(...)
  local get = self

  -- keep appending indices until nil or the
  -- value is reached
  for _, i in ipairs({...}) do
    get = get[i]

    if get == nil then
      break
    end
  end

  return get
end

function tensor:set(value, ...)
  local args = { ... }
  local last = table.remove(args)
  local set = self
  local sets = {}

  -- keep appending indices excluding the last one
  for i, a in ipairs(args)  do
    if set[a] == nil then
      if value == nil then
        return
      else
        set[a] = {}
      end
    end

    -- tracking for cleaning up tables
    if value == nil then
      sets[i] = set
    end

    set = set[a]
  end

  -- set the value
  set[last] = value

  -- if the value was nil, clean up whatever tables
  -- are now empty
  if value == nil then
    for i = #sets, 1, -1 do
      local a = args[i]

      if next(sets[i][a]) == nil then
        sets[i][a] = nil
      else
        break
      end
    end
  end
end

return tensor
