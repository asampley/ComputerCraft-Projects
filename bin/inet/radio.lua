-- reads a music file and plays it
-- each line of the file should be
-- <on> <note> [time]
-- time is optional and in seconds

local radio = require("/lib/inet/radio")
local midi = require("/lib/midi")

local args = { ... }

local function broadcast(midiFile)
  -- load song
  local song = io.open(midiFile, "rb")
  if not song then
    error("Unable to read " .. midiFile)
    return
  end

  -- play song
  local tracks, ticks_per_beat
  local s_per_beat = 0.5

  midi.processHeader(
    song,
    function(_, _, t, tpb)
      tracks = t
      ticks_per_beat = tpb
    end
  )

  print("Playing " .. tracks .. " tracks in parallel")
  print("Ticks per beat: " .. ticks_per_beat)

  local playTrack = function(i)
    midi.processTrack(io.open(midiFile, "rb"), coroutine.yield, i)
  end

  local trackPlayers = {}
  for i = 1, tracks do
    trackPlayers[i] = {
      co = coroutine.create(function()
        playTrack(i)
      end),
      tick = 0,
    }
  end

  local lastEpoch = os.epoch()

  while #trackPlayers ~= 0 do
    local currEpoch = os.epoch()

    local deltaTick = (currEpoch - lastEpoch) * ticks_per_beat / s_per_beat / 1000 / 72

    lastEpoch = currEpoch

    for _, tp in ipairs(trackPlayers) do
      tp.tick = tp.tick - deltaTick

      if coroutine.status(tp.co) ~= "dead" and tp.tick <= 0 then
        repeat
          local result = table.pack(coroutine.resume(tp.co))

          if result[1] then
            local type = result[2]

            if type == "deltatime" then
              tp.tick = tp.tick + result[3]
            elseif type == "noteOn" then
              local channel, key, velocity = result[3], result[4], result[5]

              if velocity > 0 then
                radio.broadcast.play(key, velocity)
              else
                radio.broadcast.stop(key, velocity)
              end
            elseif type == "setTempo" then
              s_per_beat = 60 / result[3]
            end
          end
        until coroutine.status(tp.co) == "dead" or tp.tick > 0
      end
    end

    -- clean up track players
    local i = 1
    while i <= #trackPlayers do
      if coroutine.status(trackPlayers[i].co) == "dead" then
        trackPlayers[i] = trackPlayers[#trackPlayers]
        trackPlayers[#trackPlayers] = nil
      else
        i = i + 1
      end
    end

    sleep(0)
  end
  --  parallel.waitForAll(table.unpack(trackPlayers))

  radio.broadcast.stopAll()
end

if fs.isDir(args[1]) then
  local files = fs.list(args[1])

  for i, v in ipairs(files) do
    local file = args[1] .. "/" .. v
    print("Playing " .. i .. "/" .. #files .. ": " .. file)
    broadcast(file)
  end
else
  print("Playing " .. args[1])
  broadcast(args[1])
end
