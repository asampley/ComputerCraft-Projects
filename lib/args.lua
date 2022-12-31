local m = {}

--[[
  definition:
  {
    flags = {
      flag1 = "boolean", -- either there or not
      flag2 = "string", -- takes the next argument and stores it in a string
      flag3 = "number", -- takes the next argument and converts it to a number
      flag4 = "count", -- can appear multiple times, the value will be how many times it appeared
    }
  }
  Returns:
  {
    flag1 = false,
    flag2 = "somestring",
    flag3 = 33,
    flag4 = 2,
  }
]]--
m.parse = function(definition, arguments)
  local flags = true

  local args = {}

  local iter, invariant, k, v = ipairs(arguments)

  while true do
    k, v = iter(invariant, k)

    if not k then break end

    if v:match("^%-%-$") then
      -- if the argument is just two dashes, turn of flag parsing
      flags = false
    else
      -- check for long flags and then short flags
      local flag = v:match("^%-%-(.+)$")

      if not flag then
        local short = v:match("^%-(.)$")

        if short then
          flag = definition.flags[short]

          if not flag then
            error("Unknown short form for flag \"" .. short "\"")
          end
        end
      end

      if flags and flag then
        -- check the flag definition and grab the value if it is required
        local flagDef = definition.flags[flag]

        if not flagDef then
          error("No definition for flag \"" .. flag .. "\"")
        end

        if flagDef.type == "boolean" or flagDef == "boolean" then
          args[flag] = true
        elseif flagDef.type == "count" or flagDef == "count" then
          args[flag] = (args[flag] or 0) + 1
        elseif flagDef.type == "string" or flagDef == "string" then
          k, v = iter(invariant, k)

          if k then
            args[flag] = v
          else
            error("Missing value for flag \"" .. flag .. "\"")
          end
        elseif flagDef.type == "number" or flagDef == "number" then
          k, v = iter(invariant, k)

          if k then
            args[flag] = tonumber(v) or error("Could not parse number from \"" .. v .. "\"")
          else
            error("Missing value for flag \"" .. flag .. "\"")
          end
        else
          error("Unknown type of flag \"" .. flagDef .. "\"")
        end
      else
        -- append a positional argument
        args[#args+1] = v
      end
    end
  end

  return args
end


m.dimensionsToVector = function (height, forward, right)
  local dimensions = {
    height = height,
    forward = forward,
    right = right,
  }
  for dimension, value in pairs(dimensions) do
    value = tonumber(value)
    if value == nil then error(dimension.." must be an integer") end
    if value == 0 then error("0 for "..dimension..", nothing to do") end
    -- Decrement magnitude by 1 so that the to position is correct
    dimensions[dimension] = value - value/math.abs(value)
  end
  return vector.new(dimensions.forward, dimensions.height, dimensions.right)
end

return m
