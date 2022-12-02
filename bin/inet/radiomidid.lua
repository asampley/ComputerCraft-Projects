local inet = require("/lib/inet")
local radio = require("/lib/inet/radio")
local synth = require("/lib/synth")

-- table for all receive related functions
local recv = {}

local speaker = peripheral.find("speaker")

local args = require("/lib/args").parse({ mode = "string" }, { ... })

local notes = {}
local wave

local config = fs.open("/etc/radiomidid", "r")
if config then
  for line in config.readLine do
    wave = synth[line]

    if not wave then
      error("Error reading config, check the synth library for valid waves")
    end
  end
end

if not wave then
  wave = synth.sine
end

recv.any = function(sender, message)
  local type = message.type

  if recv[type] then
    recv[type](sender, message)
  else
    print("No server receive for " .. type)
  end
end

recv.play = function(sender, message)
  -- offset pitch from midi standard to minecraft note blocks
  local key = message.key
  local velocity = message.velocity

  local hertz = 13.75 * 2 ^ ((key + 3) / 12)
  if velocity == 0 then
    notes[key] = nil
  else
    notes[key] = wave(hertz, velocity * 31, 0.9999)
  end
end

recv.stop = function(sender, message)
  notes[message.key] = nil
end

recv.stopAll = function(sender, message)
  speaker.stop()
end

parallel.waitForAny(
  function()
    while true do
      local sender, message = inet.receive(radio.PROTOCOL)
      recv.any(sender, message)
    end
  end,
  function()
    while true do
      local buffer = {}

      for tick = 1, 8 do
        synth.buffer(buffer, notes, (tick - 1) * 2400, tick * 2400)
        sleep(0)
      end

      while not speaker.playAudio(buffer) do
        print("waiting for speaker")
        os.pullEvent("speaker_audio_empty")
      end
    end
  end
)
