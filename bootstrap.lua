local args = {...}

if #args ~= 1 then
    print("Usage: bootstrap <raw repo url>")
    return
end

local baseUrl = args[1]

for _, file in ipairs({
  "/lib/args.lua",
  "/lib/config.lua",
  "/etc/wequire.default.lua",
  "/lib/wequire.lua",
  "/bin/werun.lua",
}) do
  local response = http.get({ url = baseUrl .. file, binary = true })
  if response and response.getResponseCode() == 200 then
    fs.open(file, "wb").write(response.readAll())
  end
end

local wequire = require("/lib/wequire")

for _, f in ipairs({"/startup"}) do
  pcall(wequire.run, _ENV, "/bin/werun.lua", f)
end

os.reboot()
