local m = {}

--[[
  This will be a wrapper for rednet to send to
  an entire network, not just direct connections.
--]]

m.open = rednet.open
m.close = rednet.close
m.send = rednet.send
m.broadcast = rednet.broadcast
m.receive = rednet.receive
m.isOpen = rednet.isOpen
m.host = rednet.host
m.unhost = rednet.unhost
m.lookup = rednet.lookup

m.loopback = function(message, protocol)
  os.queueEvent("rednet_message", os.getComputerID(), message, protocol)
end

-- load config
local open = require("/lib/config").load("inet")
for _, modem in ipairs(open) do
  if peripheral.getType(modem) == "modem" then
    m.open(modem)
  end
end

return m
