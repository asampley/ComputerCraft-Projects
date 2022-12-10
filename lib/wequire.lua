local baseUrl = "https://raw.githubusercontent.com/asampley/ComputerCraft-Projects/master/"

local wequire = function(file)
  local ok, val = pcall(require, file)

  if ok then return val end

  for search in package.path:gmatch("[^;]+") do
    local f = search:gsub("?", file)

    local response = http.get({ url = baseUrl .. f, binary = true })

    if response and response.getResponseCode() == 200 then
      if fs.exists(f) then
        error("Failed to download '" .. f .. "': file already exists.")
      else
        fs.open(f, "wb").write(response.readAll())

        print("Fetched " .. file .. " from " .. baseUrl .. f)

        return require(file)
      end
    end
  end

  error("Unable to find file locally or online")
end

return wequire
