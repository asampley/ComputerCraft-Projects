local times = { ingame = {}, utc = {} }

for k, v in pairs(times) do
  v.start = os.epoch(k)
end

local args = { ... }

shell.run(args[1], table.unpack(args, 2))

for k, v in pairs(times) do
  v.stop = os.epoch(k)
end

for k, v in pairs(times) do
  print(k .. ": " .. (v.stop - v.start) / 1000 .. "s")
end
