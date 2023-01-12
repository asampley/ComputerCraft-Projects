local args = require("/lib/args").parse({
    optional = {
      { name = "blocks", type = "number" },
      { name = "signalDir", type = "string" },
    },
  },
  {...})

local blocks = args.blocks or 28 -- Signal distance
local direction = args.signalDir or "bottom" -- where we should check signal

print("To ensure the distance is correct, check speeds:")
print("Player walking speed should be close to: 4.32 block/s")
print("Player sprinting speed should be close to: 5.61 block/s")

local startTime = os.clock()
local result

local round2 = function (num)
  return math.floor((num)*100 +.5)/100
end

while true do
  print("Ready (Hold ctrl+T to end)")
  -- wait for signal to turn on
  while os.pullEvent("redstone") and not rs.getInput(direction) do end
  startTime = os.clock()
  print("Started count!")
  -- wait for signal to turn off
  while os.pullEvent("redstone") and rs.getInput(direction) do end
  -- wait for signal to turn on
  while os.pullEvent("redstone") and not rs.getInput(direction) do end
  result = round2(os.clock() - startTime)
  print("Time taken: "..result.." seconds")
  print(blocks.." blocks @ ~"..round2(blocks/result).." blocks/s")
  -- wait for signal to turn off
  while os.pullEvent("redstone") and rs.getInput(direction) do end
end
