local inet = require("/lib/inet")

local m = {}

m.PROTOCOL = "igps"

-- table for all send related functions
m.send = {}

--[[
  The following messages are defined

  Get gps location
  {type="where"}

  Send gps location
  {type="here", x: number, y: number, z: number}
  {type="lost"}
--]]

local function inetSend(remote, message)
  inet.send(remote, message, m.PROTOCOL)
end

m.send.where = function(remote)
  inetSend(remote, { type = "where" })
end

m.send.here = function(remote, x, y, z)
  inetSend(remote, { type = "here", x = x, y = y, z = z })
end

m.send.lost = function(remote)
  inetSend(remote, { type = "lost" })
end

return m
