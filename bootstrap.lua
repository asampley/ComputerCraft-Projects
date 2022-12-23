local args = {...}

if #args ~= 1 then
    print("Usage: bootstrap <raw repo url>")
    return
end

local baseUrl = args[1]

local file = "/lib/wequire.lua"

local response = http.get({ url = baseUrl .. file, binary = true })
if response and response.getResponseCode() == 200 then
  -- Hacky... But works, inject the desired url directly into lib/wequire.lua
  fs.open(file, "wb").write("local baseUrl = \""..baseUrl.."\"\n"..response.readAll())
end

local wequire = require("/lib/wequire")

for _, f in ipairs({"/bin/wequire.lua"}) do
  pcall(wequire.fetch, f)
end

for _, f in ipairs({"/startup"}) do
  pcall(wequire.run, _ENV, "/bin/wequire.lua", f)
end

-- Grab werun as well for devs
wequire.fetch("/bin/werun.lua")
