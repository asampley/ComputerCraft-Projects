local inet = require("/lib/inet")
local igps = require("/lib/inet/igps")

local args = { ... }

if #args ~= 1 then
  error("Usage: igps <id>")
end

local id = tonumber(args[1])
if not id then
  error("Id must be a number")
end

igps.send.where(id)

while true do
  local sender, message = inet.receive(igps.PROTOCOL)
  if sender == id then
    if message.type == "here" then
      local position = vector.new(message.x, message.y, message.z)
      print("Location: " .. position:tostring())
      break
    elseif message.type == "lost" then
      print("Unknown location")
      break
    end
  end
end
