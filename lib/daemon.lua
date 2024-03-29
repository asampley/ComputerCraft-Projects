local m = {}

local configPath = "/etc/daemon"

local daemons = {}

-- override print to do nothing
-- override term.write to do nothing
-- override eventPull to not terminate
local noop = function() end
local environment = {
  print = noop,
  os = { pullEvent = os.pullEventRaw },
  term = { write = noop },
  require = require,
}
setmetatable(environment.os, { __index = os })
setmetatable(environment.term, { __index = term })

-- shamelessly stolen from /rom/programs/shell
local function tokenise(...)
  local sLine = table.concat({ ... }, " ")
  local tWords = {}
  local bQuoted = false
  for match in string.gmatch(sLine .. "\"", "(.-)\"") do
    if bQuoted then
      table.insert(tWords, match)
    else
      for m in string.gmatch(match, "[^ \t]+") do
        table.insert(tWords, m)
      end
    end
    bQuoted = not bQuoted
  end
  return tWords
end

-- run all programs in background
m.startup = function()
  print("Running daemons:")

  local funcs = {}
  for name, daemon in pairs(daemons) do
    if not daemon.disable then
      table.insert(funcs, daemon.f)
      print("  " .. name)
    end
  end

  parallel.waitForAll(
    table.unpack(funcs)
  )
end

-- check status of daemon
m.status = function(name)
  local daemon = daemons[name]
  if daemon then return daemon.status else return nil end
end

-- load list of programs to run
-- configs have the following format:
-- command args...
-- [reboot]
local function loadConfigs(relPath)
  local path = fs.combine(configPath, relPath)

  for _, f in ipairs(fs.list(path)) do

    local fullPath = fs.combine(path, f)

    -- load all configs under the other directory
    if fs.isDir(fullPath) then
      loadConfigs(fs.combine(relPath, f))

      -- load this config
    else
      local filePath = fs.combine(relPath, f)

      local config = fs.open(fullPath, "r")
      -- first line is the command
      local line = config.readLine()

      if line then
        -- create entry
        local tokens = tokenise(line)
        local command = table.remove(tokens, 1)

        -- check if command exists
        if not fs.exists(command) or fs.isDir(command) then
          print("Unable to find \"" .. command .. "\"")
        else
          daemons[filePath] = {
            status = "off",
            f = function()
              daemons[filePath].status = "on"
              local run = function()
                os.run(environment, command, table.unpack(tokens))
              end
              repeat
                run()
              until not daemons[filePath].reboot or daemons[filePath].disable
              daemons[filePath].status = "off"
            end
          }

          -- subsequent lines are options
          for line in config.readLine do
            if line == "reboot" or line == "disable" then
              daemons[filePath][line] = true
            else
              print("Unrecognized option \"" .. line .. "\" in " .. fullPath)
            end
          end
        end
      end
    end
  end
end

loadConfigs("")

return m
