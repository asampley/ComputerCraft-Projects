-- reads a music file and plays it

local radio = require("/lib/inet/radio")
local midi_play = require("/lib/midi-play")
local synth = require("/lib/synth")

local config = require("/etc/radio")

local args = require("/lib/args").parse({}, {...})

local play, stop
local notes = {}

if config.mode == "midi" then
  play = function(key, velocity)
    radio.broadcast.play(key, velocity)
    radio.loopback.play(key, velocity)
  end

  stop = function(key, velocity)
    radio.broadcast.stop(key, velocity)
    radio.loopback.stop(key, velocity)
  end
else
  local wave = synth[config.wave]

  play = function(key, velocity)
    local hertz = 13.75 * 2 ^ ((key + 3) / 12)

    notes[key] = wave(hertz, velocity * 31, 0.9999)
  end

  stop = function(key, velocity)
    notes[key] = nil
  end
end

local function broadcast(midiFile)
  if config.mode == "midi" then
    midi_play.play(
      midiFile,
      function(type, ...)
        if type == "noteOn" then
          local channel, key, velocity = ...

          if velocity > 0 then
            play(key, velocity)
          else
            stop(key, velocity)
          end
        elseif type == "noteOff" then
          local channel, key, velocity = ...

          stop(key, velocity)
        end
      end
    )
  else
    local co = coroutine.create(function()
      midi_play.minecraftTicks(midiFile, coroutine.yield)
    end)

    repeat
      local buffer = {}

      for tick = 1, config.ticks or 8 do
        if coroutine.status(co) == "dead" then break end

        local result = table.pack(coroutine.resume(co))

        if result[1] and result[2] then
          for _, event in ipairs(result[2]) do
            local type = event[1]

            if type == "noteOn" then
              local channel, key, velocity = table.unpack(event, 2)

              if velocity > 0 then
                play(key, velocity)
              else
                stop(key, velocity)
              end
            elseif type == "noteOff" then
              local channel, key, velocity = table.unpack(event, 2)

              stop(key, velocity)
            end
          end

          synth.buffer(buffer, notes, (tick - 1) * 2400, tick * 2400)
        end
      end

      if #buffer > 0 then
        radio.broadcast.sample(buffer)
        radio.loopback.sample(buffer)
      end

      sleep(0.05 * (config.ticks or 8))
    until coroutine.status(co) == "dead"
  end

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
