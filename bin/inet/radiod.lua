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
  -- offset pitch from midi standard to minecraft note blocks
  local key = message.key + 6
  local velocity = message.velocity

  local map = noteMap[key]

  if map then
    key = (key + 12 * map.octaveOffset) % 24
    speaker.playNote(map.instrument, velocity, key)
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
