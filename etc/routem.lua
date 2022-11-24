return {
  -- names of peripherals to pull from
  pull = {
    "top",
  },
  -- time to sleep between scans in seconds
  sleep = 4,
  -- names of items mapped to peripherals to push into
  -- default can be used to push everything else into
  push = {
    --["minecraft:cobblestone"] = "right",
    default = "left"
  },
}
