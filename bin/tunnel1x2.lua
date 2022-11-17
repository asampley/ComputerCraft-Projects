local bucket = require("/lib/bucket")

-- make a 2 high, 1 wide tunnel, and return to start
local args = { ... }

-- arg[1] is the depth
if #args < 1
then
  print("Usage: tunnel1x2 <depth>")
  print("Options: -r = return")
  print("         -b <bSlot> = use bucket for refuel")
  print("         -w <wSlot> = place walls around tunnel")
  return
end

local depth = 0
local r = false
local b = false
local w = false
local bSlot = 0
local wSlot = 0
local fuelReq = 0

-- evaluate arguments
local i = 1
while i <= #args do
  if args[i] == "-r"
  then
    r = true
  elseif args[i] == "-b"
  then
    b = true
    bSlot = tonumber(args[i + 1])
    i = i + 1
  elseif args[i] == "-w"
  then
    w = true
    wSlot = tonumber(args[i + 1])
    i = i + 1
  else
    depth = tonumber(args[i])
  end
  i = i + 1
end

-- calculate fuel requirements
if r
then
  fuelReq = depth * 2
else
  fuelReq = depth
end

-- refuse to go without sufficient fuel
print("Fuel required: " .. fuelReq)
print("Current Levels: " .. turtle.getFuelLevel())
if turtle.getFuelLevel() < fuelReq
then
  print("Not enough fuel, please add more")
  return
end

local _forward, _up, _place, _placeUp, _placeDown

-- set move and place functions, based on bucket flat
if b then
  _forward = bucket.forward
  _up = bucket.up
  _place = function() bucket.place(bSlot) end
  _placeUp = function() bucket.placeUp(bSlot) end
  _placeDown = function() bucket.placeDown(bSlot) end
else
  _forward = turtle.forward
  _up = turtle.up
  _place = turtle.place
  _placeUp = turtle.placeUp
  _placeDown = turtle.placeDown
end

for i = 1, depth do
  -- dig forward until able to move
  while not _forward() do
    turtle.dig()
  end
  turtle.digUp()

  -- place walls on lower half, if required
  if w
  then
    turtle.turnLeft()

    turtle.select(wSlot)

    _place()
    _placeDown()

    turtle.turnRight()
    turtle.turnRight()

    _place()

    turtle.turnLeft()
  end
end

-- go to start
-- wall upper portion if required
if w then
  while not _up() do
    turtle.digUp()
  end
end

if r then
  turtle.turnLeft()
  turtle.turnLeft()

  for i = 1, depth do
    while not _forward() do
      turtle.dig()
    end

    if w then
      turtle.turnLeft()

      turtle.select(wSlot)

      _place()
      _placeUp()

      turtle.turnRight()
      turtle.turnRight()

      _place()

      turtle.turnLeft()
    end
  end
end
