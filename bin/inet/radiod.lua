local inet = require("/lib/inet")
local radio = require("/lib/inet/radio")

-- table for all receive related functions
local recv = {}

local speaker = peripheral.find("speaker")

local noteMap = {}

local config = fs.open("/etc/radiod", "r")
if config then
  for line in config.readLine do
    if line:len() ~= 0 then
      local lower, upper, instrument, octaveOffset
        = line:match("([0-9]+) ([0-9]+) ([^ ]+) ([+-]?[0-9])")

      if not lower then
        error("Error parsing line of config: "..line)
      end

      local lower, upper = tonumber(lower), tonumber(upper)
      local octaveOffset = tonumber(octaveOffset) - math.floor(lower / 12)

      for i = lower,upper do
        noteMap[i] = {
          instrument = instrument,
          octaveOffset = octaveOffset
        }
      end
    end
  end
end

recv.any = function (sender, message)
  local type = message.type

  if recv[type] then
    recv[type](sender, message)
  else
    print("No server receive for "..type)
  end
end

recv.play = function(sender, message)
  local pitch = radio.pitchMap[message.pitch]
  local octave = message.octave

  local note = (pitch + 12 * octave)
  local map = noteMap[note]
  
  if map then
    note = note + 12 * map.octaveOffset
    speaker.playNote(map.instrument, 1, note)
  end
end

recv.stop = function(sender, message) end

recv.stopAll = function(sender, message)
  speaker.stop()
end

while true do
  local sender, message = inet.receive(radio.PROTOCOL)
  recv.any(sender, message)
end
