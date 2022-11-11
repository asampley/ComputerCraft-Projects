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

-- load config
local configPath = "/etc/inet"
local config = fs.open(configPath, "r")
if config then
  for line in config.readLine do
    if peripheral.getType(line) == "modem" then
      m.open(line)
    end
  end
end

return m
