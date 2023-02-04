-- play a random music disk
-- read config to see which disks we have,
--   we know the time
-- place the turtle facing a disk drive

-- name, duration
local music = {
  ["minecraft:music_disc_13"] = 185,
  ["minecraft:music_disc_cat"] = 178,
  ["minecraft:music_disc_blocks"] = 345,
  ["minecraft:music_disc_chirp"] = 185,
  ["minecraft:music_disc_far"] = 174,
  ["minecraft:music_disc_mall"] = 197,
  ["minecraft:music_disc_mellohi"] = 96,
  ["minecraft:music_disc_stal"] = 150,
  ["minecraft:music_disc_strad"] = 188,
  ["minecraft:music_disc_ward"] = 251,
  ["minecraft:music_disc_11"] = 71,
  ["minecraft:music_disc_wait"] = 258
}

-- loop
math.randomseed(os.time())
while true do
  -- take disk out of machine
  turtle.suck()

  -- pick random item
  local slot = math.random(16)

  -- get duration of disc if it exists
  local info = turtle.getItemDetail(slot)

  if info and info.name then
    local duration = music[turtle.getItemDetail(slot).name]

    if duration then
      -- select disc
      turtle.select(slot)

      -- put disk in
      turtle.drop()

      -- get duration

      -- play music
      shell.run("rom/programs/fun/dj")

      -- wait for song to finish
      sleep(duration)
    end
  end
end
