local args = {...}

if #args ~= 1 then
    print("Usage: bootstrap <raw repo url>")
    return
end

local baseUrl = args[1]

for _, file in ipairs({
  "/lib/args.lua",
  "/lib/config.lua",
  "/lib/wequire.lua",
  "/bin/werun.lua",
}) do
  local response = http.get({ url = baseUrl .. file, binary = true })
  if response and response.getResponseCode() == 200 then
    local handle = fs.open(file, "wb")
    handle.write(response.readAll())
    handle.close()
  end
end

local handle = fs.open("/etc/wequire.lua", "w")
handle.write("return {\n  '" .. baseUrl .. "',\n}")
handle.close()

local wequire = require("/lib/wequire")

for _, f in ipairs({"/startup"}) do
  wequire.run(_ENV, "/bin/werun.lua", f)
end

os.reboot()
