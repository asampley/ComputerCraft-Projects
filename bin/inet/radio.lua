-- reads a music file and plays it

local radio = require("/lib/inet/radio")
local midi_play = require("/lib/midi-play")

local args = { ... }

local function broadcast(midiFile)
  midi_play.play(
    midiFile,
    function(type, ...)
      if type == "noteOn" then
        local channel, key, velocity = ...

        if velocity > 0 then
          radio.broadcast.play(key, velocity)
          radio.loopback.play(key, velocity)
        else
          radio.broadcast.stop(key, velocity)
          radio.loopback.stop(key, velocity)
        end
      elseif type == "noteOff" then
        local channel, key, velocity = ...

        radio.broadcast.stop(key, velocity)
        radio.loopback.stop(key, velocity)
      end
    end
  )

  sleep(4)

  radio.broadcast.stopAll()
  radio.loopback.stopAll()
end

if fs.isDir(args[1]) then
  local files = fs.list(args[1])

  while true do
    local i = math.random(#files)
    local file = args[1] .. "/" .. files[i]
    print("Playing " .. i .. "/" .. #files .. ": " .. file)
    broadcast(file)
  end
else
  print("Playing " .. args[1])
  broadcast(args[1])
end
