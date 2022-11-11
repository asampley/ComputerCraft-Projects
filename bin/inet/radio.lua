-- reads a music file and plays it
-- each line of the file should be
-- <on> <note> [time]
-- time is optional and in seconds

local radio = require("/lib/inet/radio")

args = {...}

-- load song
local song = fs.open(args[1], "r")
if not song then
  error("Unable to read "..args[1])
  return
end

-- make sure to shut down speaker when exiting
local function cleanUp()
  radio.broadcast.stopAll()
end

-- play song
for line in song.readLine do
  if line:len() ~= 0 and line:sub(1,1) ~= "#" then
    -- parse numbers in line
    local parser = line:gmatch("[0-9A-G#%.]+") -- number iterator
    local on = tonumber(parser()) == 1
    local note = parser()
    local pitch = note:match("[A-G#]+")
    local octave = tonumber(note:match("[-0-9]+"))
    local time = tonumber(parser())
    
    if not pitch or not octave then
      print("Invalid line: "..line)
    else
      if on then
        radio.broadcast.play(pitch, octave)
      else
        radio.broadcast.stop(pitch, octave)
      end
    end
    
    if time then
      -- catch termination
      if not pcall(function() os.sleep(time) end)
      then
        cleanUp()
        error("Terminated")
      end
    end
  end
end

cleanUp()
