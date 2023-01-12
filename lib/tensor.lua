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

  -- keep appending indices excluding the last one
  for _, a in ipairs(args) do
    if set[a] == nil then
      if value == nil then
        return
      else
        set[a] = {}
      end
    end

    set = set[a]
  end

  -- set the value
  set[last] = value

  -- if the value was nil, clean up whatever tables
  -- are now empty
  if value == nil then
    set = self
    local remove

    for i = 1, #args do
      local last_set = set

      set = set[args[i]]

      -- can prune if next_set only contains the one key, which is the next argument
      --
      -- as soon as next_set does not contain only that one key, it and others above
      -- cannot be pruned
      if next(set) ~= args[i + 1] or next(set, args[i + 1]) ~= nil then
        remove = nil
      elseif not remove then
        remove = { last_set, args[i] }
      end
    end

    if remove then
      remove[1][remove[2]] = nil
    end
  end
end

return tensor
