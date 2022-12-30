local m = {}

-- function that returns all the places to look for a config
--
-- a default config is expected at "/etc/name.default.lua"
-- an overridden config can be saved at "/etc/name.lua" that
-- will not be in the repository
m.paths = function(name)
  return { "/etc/" .. name .. ".lua", "/etc/" .. name .. ".default.lua" }
end

-- load a config file by calling require
--
-- uses the paths function to get a list of files to look for
m.load = function(name)
  for _, path in ipairs(m.paths(name)) do
    local f, err = loadfile(path, "bt", _ENV)

    if f then
      return f()
    end
  end

  error("Unable to find config file or default config file")
end

return m
