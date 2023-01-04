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

  local position = 1

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
        local rest = false

        local posDef = definition.required and definition.required[position]

        if not posDef then
          local offset = (definition.required and #definition.required) or 0
          posDef = definition.optional and definition.optional[position - offset]
        end

        if not posDef then
          posDef = definition.rest
          rest = true
        end

        if not posDef then
          error("Too many arguments supplied")
        else
          if not posDef.name then
            error("'name' not set for positional argument")
          end

          local parsed
          if not posDef.type or posDef.type == "string" then
            parsed = v
          elseif posDef.type == "number" then
            parsed = tonumber(v) or error("Expected number for \"" .. posDef.name .. "\"")
          else
            error("Unknown type for positional \"" .. posDef.type .. "\"")
          end

          if rest then
            if not args[posDef.name] then
              args[posDef.name] = {}
            end

            args[posDef.name][#args[posDef.name] + 1] = parsed
          else
            args[posDef.name] = parsed
            position = position + 1
          end
        end
      end
    end
  end

  if definition.required and position <= #definition.required then
    error("Too few arguments supplied")
  end

  return args
end

m.usage = function(definition)
  local usage = ""

  if definition.required then
    for _, def in ipairs(definition.required) do
      usage = usage .. " " .. def.name
    end
  end

  if definition.optional then
    for _, def in ipairs(definition.optional) do
      usage = usage .. " [" .. def.name .. "]"
    end
  end

  if definition.rest then
    usage = usage .. " [" .. definition.rest.name .. "...]"
  end

  for flag, def in pairs(definition.flags) do
    if #flag > 1 then
      usage = usage .. " [--" .. flag
    else
      usage = usage .. " [-" .. flag
    end

    if def == "string" or def.type == "string" then
      usage = usage .. " STRING"
    elseif def == "number" or def.type == "number" then
      usage = usage .. " NUMBER"
    end

    usage = usage .. "]"
  end

  return usage
end

return m
