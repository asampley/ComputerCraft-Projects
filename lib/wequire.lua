local m = {}

-- cache functions in case these global functions are overwritten with these versions
local require = require
local loadfile = loadfile

m.fetch = function(file)
  local response = http.get({ url = baseUrl .. file, binary = true })

  if response and response.getResponseCode() == 200 then
    if fs.exists(file) then
      error("Failed to download '" .. file .. "': file already exists.")
    else
      fs.open(file, "wb").write(response.readAll())

      print("Fetched " .. file .. " from " .. baseUrl .. file)

      return true
    end
  end

  return false
end

m.require = function(file)
  
  if _ENV.isWerun then fs.delete(file..".lua") end

  local ok, val = pcall(require, file)

  if ok then return val end

  for search in package.path:gmatch("[^;]+") do
    local f = search:gsub("?", file)

    if m.fetch(f) then
      return require(file)
    end
  end

  error("Unable to find file locally or online")
end

m.loadfile = function(file)
  local f = loadfile(file)

  if f then return f end

  local fetchList = {}

  fetchList[#fetchList + 1] = file

  for p in shell.path():gmatch("[^:]+") do
    for _, pp in ipairs({ file, file .. ".lua"}) do
      local ppp = p .. "/" .. pp

      if _ENV.isWerun and string.sub(ppp, 1, 5) ~= "/rom/" then
        fs.delete(ppp)
      end

      f = loadfile(ppp)

      if f then return f end

      fetchList[#fetchList + 1] = ppp
    end
  end

  for _, fet in ipairs(fetchList) do
    if m.fetch(fet) then
      return loadfile(fet)
    end
  end

  error("Unable to find file locally or online")
end

m.run = function(environment, file, ...)
  local r = m.loadfile(file)

  setfenv(r, environment)

  r(...)
end

return m
