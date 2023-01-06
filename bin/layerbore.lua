local arguments = require("/lib/args")
local bore = require("/lib/bore")
local location = require("/lib/location")
local move = require("/lib/move")
local path = require("/lib/path")
local wants = require("/lib/bore/wants")

local args = arguments.parse({
  flags = {
    wants = "string",
    help = "boolean",
  },
  required = {
    { name = "height", type = "number" },
    { name = "forward", type = "number" },
    { name = "right", type = "number" },
  },
},
{...})

if args.help then
  print("To dig optimally deep into bedrock, place turtle in Y where Y % 3 == 1")
  print("eg. set tutrle in layer 61")
  return
end

local startTime = os.clock()

local dimensionVector = bore.dimensionsToVector(args.forward, args.height, args.right)

local homePos = location.getPos()
local homeHeading = location.getHeading()
local toPos = homePos + dimensionVector
local lastPosition = homePos

wants.setProfile(args.wants)
bore.setChest(homePos)

local success, error = pcall(function()
  path.rectangleEveryThirdLayer(toPos, function (direction, mustDig)
    if mustDig and (direction == "Down" or direction == "Up") and foundBedrock then
      error("Will not do anymore layers because next layer contains bedrock")
    end

    if bore.smartDig(direction, mustDig, homePos, homeHeading) == "BEDROCK" then
      if mustDig then error("Ran into bedrock, ending") end
      -- If bedrock will block our escape in the y direction
      if dimensionVector.y >= 0 and direction == "Down" or dimensionVector.y < 0 and direction == "Up" then
        move.digTo(lastPosition) -- retreat 1 space and end
        error("Ending because we might get trapped by bedrock")
      end

      foundBedrock = true
    end
    lastPosition = location.getPos()
  end)
end)
if error then print(error) end

move.digTo(homePos, "yzx")
move.turnTo(homeHeading)
bore.cleanInventory() -- So we don't drop off stuff picked up on move.digTo
bore.transferToChest()

local timeTaken = (os.clock() - startTime) / 60
print("Finished in "..timeTaken.." minutes")
