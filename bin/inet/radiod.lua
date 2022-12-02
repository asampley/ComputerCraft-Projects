local inet = require("/lib/inet")
local radio = require("/lib/inet/radio")

-- table for all receive related functions
local recv = {}

local speaker = peripheral.find("speaker")

recv.any = function(sender, message)
  local type = message.type

  if recv[type] then
    recv[type](sender, message)
  else
    print("No server receive for " .. type)
  end
end

recv.sample = function(sender, message)
  while not speaker.playAudio(message.sample) do
    print("waiting for speaker")
    os.pullEvent("speaker_audio_empty")
  end
end

while true do
  local sender, message = inet.receive(radio.PROTOCOL)
  recv.any(sender, message)
end
