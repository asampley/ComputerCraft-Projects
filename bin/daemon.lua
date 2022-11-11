local daemon = require("/lib/daemon")

local args = {...}

if #args ~= 1 then
  error("Usage: daemon startup")
end

local command = args[1]

if command == "startup" then
  daemon.startup()
else
  error("Unrecognized command: "..command)
end
