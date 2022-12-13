local url = "https://raw.githubusercontent.com/asampley/ComputerCraft-Projects/master/"

local file = "/lib/wequire.lua"

local response = http.get({ url = url .. file, binary = true })
if response and response.getResponseCode() == 200 then
  fs.open(file, "wb").write(response.readAll())
end

local wequire = require("/lib/wequire")
wequire.fetch("/bin/wequire.lua")
