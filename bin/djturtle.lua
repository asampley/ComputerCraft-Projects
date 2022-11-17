-- play a random music disk
-- read config to see which disks we have,
--   we know the time
-- place the turtle facing a disk drive

-- name, duration
local music = {
  cat      = 178,
  thirteen = 185,
  blocks   = 345,
  chirp    = 185,
  far      = 174,
  mall     = 197,
  mellohi  = 96,
  stal     = 150,
  strad    = 188,
  ward     = 251,
  eleven   = 71,
  wait     = 258
}

-- read config
local config_path = "/etc/djturtle"
local disks = {}
local config = fs.open(config_path, "r")

if not config
then
  print("Config file not found at:\n" .. config_path)
  return
end
while true do
  local line = config.readLine()
  if line
  then
    -- if the music is invalid, complain
    if not music[line]
    then
      print("I don't know the music \"" .. line .. "\"")
      print("Please fix the config file")
      return
    else
      print("Loaded \"" .. line .. "\"")
      table.insert(disks, line)
    end
  else
    break
  end
end

config.close()

-- loop
math.randomseed(os.time())
while true do
  -- take disk out of machine
  turtle.suck()

  -- pick random track
  local num = math.random(#disks)
  turtle.select(num)

  -- put disk in
  turtle.drop()

  -- get duration
  local duration = music[disks[num]]

  -- play music
  shell.run("dj")

  -- wait for song to finish
  sleep(duration)
end
