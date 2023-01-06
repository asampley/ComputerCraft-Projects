local m = {}

local function bad(definition, message)
  error(message .. "\n" .. m.usage(definition))
end

--[[
  definition:
  {
    flags = {
      flag1 = "boolean", -- either there or not
      flag2 = "string", -- takes the next argument and stores it in a string
      flag3 = "number", -- takes the next argument and converts it to a number
      flag4 = "count", -- can appear multiple times, the value will be how many times it appeared
      flag5 = { type = "boolean" }, -- all the above types can likewise be done like this
    },
    -- first n arguments are required
    required = {
      { name = "required1", type = "string" } -- first argument is a string
      { name = "required2", type = "number" } -- second argument is a number
      { name = "required3" } -- third argument is a string (as string is the default)
    },
    -- next m arguments are optional
    optional = {
      { name = "optional1", type = "string" } -- same types as required can be
      { name = "optional2" } -- also defaults to string
    },
    -- all remaining arguments can optionally be collected into a list with a type
    -- likewise can implicitly be a string
    rest = { name = "remaining", type = "string" },
  }
  Returns:
  {
    flag1 = false,
    flag2 = "somestring",
    flag3 = 33,
    flag4 = 2,
    flag5 = true,
    required1 = "anotherstring",
    required2 = 5,
    required3 = "stringisthedefaulttype",
    optional1 = "mightbehereornot",
    optional2 = "alsostrings",
    rest = { "also", "may", "not", "be", "here" },
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
      local flag = v:match("^%-%-(%a%w*)$")

      if not flag then
        local short = v:match("^%-(%a)$")

        if short then
          flag = definition.flags[short]

          if not flag then
            bad(definition, "Unknown short form for flag \"" .. short "\"")
          end
        end
      end

      if flags and flag then
        -- check the flag definition and grab the value if it is required
        local flagDef = definition.flags[flag]

        if not flagDef then
          bad(definition, "\nNo definition for flag \"" .. flag .. "\"")
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
            bad(definition, "\nMissing value for flag \"" .. flag .. "\"")
          end
        elseif flagDef.type == "number" or flagDef == "number" then
          k, v = iter(invariant, k)

          if k then
            args[flag] = tonumber(v) or bad(definition, "\nCould not parse number from \"" .. v .. "\"")
          else
            bad(definition, "Missing value for flag \"" .. flag .. "\"")
          end
        else
          bad(definition, "Unknown type of flag \"" .. flagDef .. "\"")
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
          bad(definition, "Too many arguments supplied")
        else
          if not posDef.name then
            bad(definition, "'name' not set for positional argument")
          end

          local parsed
          if not posDef.type or posDef.type == "string" then
            parsed = v
          elseif posDef.type == "number" then
            parsed = tonumber(v) or bad(definition, "Expected number for \"" .. posDef.name .. "\"")
          else
            bad(definition, "Unknown type for positional \"" .. posDef.type .. "\"")
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
    bad(definition, "Too few arguments supplied")
  end

  return args
end

m.usage = function(definition)
  local usage = "usage:"

  if definition.flags then
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
  end

  if definition.required or definition.optional or definition.rest then
    usage = usage .. " [--]"
  end

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

  return usage
end

return m
