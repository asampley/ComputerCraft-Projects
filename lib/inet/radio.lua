local inet = require("/lib/inet")

local m = {}

-- server program
m.PROTOCOL = "radio"

-- tables for all send related functions
m.broadcast = {}
m.loopback = {}
m.send = {}

--[[
  The following messages are defined

  Play a note
  {type="play", pitch, octave}
  {type="stop", pitch, octave}
  {type="stopAll"}

--]]
local function broadcast(message)
  inet.broadcast(message, m.PROTOCOL)
end

local function send(recipient, message)
  inet.send(recipient, message, m.PROTOCOL)
end

local function loopback(message)
  inet.loopback(message, m.PROTOCOL)
end

m.loopback.play = function(key, velocity)
  loopback({ type = "play", key = key, velocity = velocity })
end

m.send.play = function(recipient, key, velocity)
  send(recipient, { type = "play", key = key, velocity = velocity })
end

m.loopback.stop = function(recipient, key, velocity)
  loopback({ type = "stop", key = key, velocity = velocity })
end

m.send.stop = function(recipient, key, velocity)
  send(recipient, { type = "stop", key = key, velocity = velocity })
end

m.loopback.stopAll = function(recipient)
  loopback({ type = "stopAll" })
end

m.send.stopAll = function(recipient)
  send(recipient, { type = "stopAll" })
end

for k,v in pairs(m.send) do
  m.broadcast[k] = function(...)
    v(rednet.CHANNEL_BROADCAST, ...)
  end
end

return m
