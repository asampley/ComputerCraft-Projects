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

m.broadcast.play = function(pitch, octave)
  inetBroadcast({type="play", pitch=pitch, octave=octave})
end

m.broadcast.stop = function(pitch, octave)
  inetBroadcast({type="stop", pitch=pitch, octave=octave})
end

m.broadcast.stopAll = function()
  inetBroadcast({type="stopAll"})
end

m.pitchMap = {
  ["F#"] = 0, ["Gb"] = 0,
  ["G"] = 1,
  ["G#"] = 2, ["Ab"] = 2,
  ["A"] = 3,
  ["A#"] = 4, ["Bb"] = 4,
  ["B"] = 5,
  ["C"] = 6,
  ["C#"] = 7, ["Db"] = 7,
  ["D"] = 8,
  ["D#"] = 9, ["Eb"] = 9,
  ["E"] = 10,
  ["F"] = 11
}

return m
