local config = require("/lib/config").load("wequire")

local m = {}

-- cache functions in case these global functions are overwritten with these versions
local _require = require
local _loadfile = loadfile

m.overwrite = false

m.fetch = function(file)
  for _, url in ipairs(config) do
    local response = http.get({ url = url .. file, binary = true })

    if response and response.getResponseCode() == 200 then
      if not m.overwrite and fs.exists(file) then
        error("Failed to write '" .. file .. "': file already exists.")
      else
        fs.open(file, "wb").write(response.readAll())

        print("Fetched " .. file .. " from " .. url .. file)

        return true
      end
    end
  end

  return false
end

m.require = function(file)
  if package.loaded[file] then
    return package.loaded[file]
  end

  if not m.overwrite then
    local ok, val = pcall(_require, file)

    if ok then return val end
  end

  for search in package.path:gmatch("[^;]+") do
    local f = search:gsub("?", file)

    if m.fetch(f) then
      return _require(file)
    end
  end

  error("Unable to find file locally or online")
end

m.run = function(env, file, ...)
  if not m.overwrite then
    local f = _loadfile(file, "bt", env)

    if f then return f(...) end
  end

  local fetchList = { file }

  for p in shell.path():gmatch("[^:]+") do
    if fs.getDrive(p) ~= "rom" then
      for _, pp in ipairs({ file, file .. ".lua"}) do
        local ppp = p .. "/" .. pp

        if not m.overwrite then
          local f = _loadfile(ppp, "bt", env)

          if f then return f(...) end
        end

        fetchList[#fetchList + 1] = ppp
      end
    end
  end

  for _, fet in ipairs(fetchList) do
    if m.fetch(fet) then
      local f = m.loadfile(fet, "bt", env)

      if f then return f(...) end
    end
  end
end

m.loadfile = function(file, mode, env)
  if not m.overwrite then
    local f = _loadfile(file, mode, env)

    if f then return f end
  end

  if m.fetch(file) then
    return _loadfile(file, mode, env)
  else
    return nil, "Unable to find file '" .. file .. "' locally or online"
  end
end

return m
