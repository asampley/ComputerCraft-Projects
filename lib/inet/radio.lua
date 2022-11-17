local inet = require("/lib/inet")

local m = {}

-- server program
m.PROTOCOL = "radio"

-- table for all send related functions
m.broadcast = {}

--[[
  The following messages are defined

  Play a note
  {type="play", pitch, octave}
  {type="stop", pitch, octave}
  {type="stopAll"}

--]]
local function inetBroadcast(message)
  inet.broadcast(message, m.PROTOCOL)
end

m.broadcast.play = function(key, velocity)
  inetBroadcast({ type = "play", key = key, velocity = velocity })
end

m.broadcast.stop = function(key, velocity)
  inetBroadcast({ type = "stop", key = key, velocity = velocity })
end

m.broadcast.stopAll = function()
  inetBroadcast({ type = "stopAll" })
end

return m
