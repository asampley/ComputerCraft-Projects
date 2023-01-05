local arguments = require("/lib/args")
local bore = require("/lib/bore")
local location = require("/lib/location")
local move = require("/lib/move")
local path = require("/lib/path")
local wants = require("/lib/bore/wants")

local args = arguments.parse({
    flags = { wants = "string" },
    required = {
      { name = "height", type = "number" },
      { name = "forward", type = "number" },
      { name = "right", type = "number" },
    },
  },
  {...})

local startTime = os.clock()

local dimensionVector = bore.dimensionsToVector(args.forward, args.height, args.right)
local homePos = location.getPos()
local homeHeading = location.getHeading()

wants.setProfile(args.wants)
bore.setChest(homePos)

local success, error = pcall(function()
  path.rectangleEveryThirdLayer(dimensionVector, function (direction, mustDig)

    bore.smartDig(direction, true, homePos, homeHeading)

  end)
end)
if error then print(error) end

move.digTo(homePos, "yzx")
move.turnTo(homeHeading)
bore.cleanInventory() -- So we don't drop off stuff picked up on move.digTo
bore.transferToChest()

local timeTaken = (os.clock() - startTime) / 60
print("Finished in "..timeTaken.." minutes")
