local location = require("/lib/location")
local move = require("/lib/move")
local path = require("/lib/path")
local bore = require("/lib/bore")
local inventory = require("/lib/inventory")
local bucket = require("/lib/bucket")
local wants = require("/etc/bore/wants")

local args = {...}

if #args ~= 3 then
  print("Usage: layerbore <+/-depth> <+/-forward> <+/-right>")
  return
end

local depth = tonumber(args[1])
local forward = tonumber(args[2])
local right = tonumber(args[3])

if not depth or depth < 1 then error("Depth must 1 or greater") end
if not forward then error("forward must be an integer") end
if not right then error("right must be an integer") end

local homePos = location.getPos()
local homeHeading = location.getHeading()

-- Decrease forward and right magnitude by one for calc'ing desired position
forward = forward - forward / math.abs(forward)
right = right - right / math.abs(right)
local toPos = homePos + vector.new(forward, -depth + 1, right)

local digAndKeepOrToss = function(direction)
  if not turtle["dig"..direction]() then return end -- Nothing to dig
  local recentSlot = inventory.getLastSlotWithItem()
  if recentSlot == bucket.find() then return end -- Don't drop the bucket
  if recentSlot == 0 then return end -- Nothing to 
  if wants(turtle.getItemDetail(recentSlot)) then return end -- We want it
  -- Else drop it
  inventory.dropLastStack()
end

bore.setChest(homePos)

path.solidRectangle(toPos, function (direction)
  -- Do lava refueling
  bucket["place"..direction]()
  turtle.getFuelLevel()

  digAndKeepOrToss(direction)

  -- if we are low on fuel or inventory is full
  if not bore.enoughFuelToGetTo(homePos) or not inventory.freeSlot() then
    print("not enough fuel")
    local digPos = location.getPos()
    local digHeading = location.getHeading()  
    
    -- Go home, cleanup, then head back out
    move.goTo(homePos, "yzx")
    move.turnTo(homeHeading)
    bore.refuel()
    if not bore.enoughFuelToGetTo(digPos * 2) then
      print("Not enough fuel to dig and get home")
      return false
    end
    bore.transferToChest()
    move.goTo(digPos, "xzy")
    move.turnTo(digHeading)
  end

  return true
end)


move.goTo(homePos, "yzx")
move.turnTo(homeHeading)
bore.refuel()
bore.transferToChest()
