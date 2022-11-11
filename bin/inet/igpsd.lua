local inet = require("/lib/inet")
local igps = require("/lib/inet/igps")

-- table for all receive related functions
local recv = {}

recv.any = function (sender, message)
  local type = message.type

  if recv[type] then
    recv[type](sender, message)
  else
    print("No server receive for "..type)
  end
end

recv.where = function(sender, message)
  x, y, z = gps.locate()
  if not x then
    igps.send.lost(sender)
  else
    igps.send.here(sender, x,y,z)
  end
end

while true do
  local sender, message = inet.receive(igps.PROTOCOL)
  recv.any(sender, message)
end  
