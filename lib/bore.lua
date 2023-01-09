local blocks = require("/lib/blocks")
local bucket = require("/lib/bucket")
local inventory = require("/lib/inventory")
local location = require("/lib/location")
local move = require("/lib/move")
local path = require("/lib/path")
local wants = require("/lib/bore/wants")

local m = {}

-- load config files to determine blocks to search for and items to refuel with
local config = require("/lib/config")
local fuel = config.load("bore/fuel")

-- record chest location
local chestPos
-- save slots that should be handled externally
local reservedSlots = {}

m.setChest = function(position)
  chestPos = position
end

-- slots - eg. {[1] = true, [3] = true} to skip slots 1 and 3
m.setReservedSlots = function (slots)
  reservedSlots = slots or {}
end

-- check if block is wanted
m.wanted = function(inspectFunc)
  local found, block = inspectFunc()
  return found and wants.wants(block)
end

local function bruteDig(moveFunc, digFunc, inspectFunc)
  while not moveFunc() do
    local found, block = inspectFunc()
    if found and blocks.isBedrock(block) then return false end
    digFunc()
  end
  return true
end

local function orderedHeadings()
  local heading = location.getHeading()

  local headings = { heading }

  for _ = 1, 3 do
    heading = location.turnLeft(heading)
    table.insert(headings, heading)
  end

  table.insert(headings, location.Y())
  table.insert(headings, -location.Y())

  return headings
end

local stack = {}
local stackI = -1
local todo = {}

m.transferToChest = function()
  move.digTo(chestPos)

  local direction
  if peripheral.hasType("top","inventory") then direction = "Up" end
  if peripheral.hasType("bottom","inventory") then direction = "Down" end
  if not direction then
    error("No inventory above or below turtle")
  end

  local bucketSlot = bucket.find()

  for i = 1, 16 do
    if i ~= bucketSlot and not reservedSlots[i] then
      -- don't transfer fuel unless we are full
      local item = turtle.getItemDetail(i)
      if item and (not fuel[item.name] or not m.shouldFuel()) then
        turtle.select(i)
        turtle["drop"..direction]()
      end
    end
  end
end

m.shouldFuel = function()
  return turtle.getFuelLevel() ~= "unlimited"
      and turtle.getFuelLevel() < turtle.getFuelLimit() - 1000
end

m.refuel = function()
  if turtle.getFuelLevel() == "unlimited"
  then return end

  for i = 1, 16 do
    turtle.select(i)
    local item = turtle.getItemDetail()

    while m.shouldFuel() and item and fuel[item.name] do
      print("Refueling with " .. item.name)
      turtle.refuel()
      item = turtle.getItemDetail()
    end

    if not m.shouldFuel() then
      break
    end
  end
end

local function debug()
  print("DEBUG")
  for _, node in ipairs(stack) do
    print(node.pos)
  end
end

-- Is there enough fuel for forward and backward trip
m.enoughFuel = function()
  if turtle.getFuelLevel() == "unlimited" then return true end
  return turtle.getFuelLevel() > #stack + #stack - stackI + 2
end

m.enoughFuelToGetTo = function(position)
  if turtle.getFuelLevel() == "unlimited" then return true end
  local path = position - location.getPos()
  return turtle.getFuelLevel() > math.abs(path.x) + math.abs(path.y) + math.abs(path.z) + 2
end

local function init(position)
  stack = { {
    pos = position,
    shaft = true
  } }

  todo[tostring(position - location.Y())] = true

  stackI = #stack
end

local function expand(minPosition, maxPosition, shaft)
  local position = location.getPos()

  local node = {
    pos = position,
    shaft = shaft
  }

  for _, heading in ipairs(orderedHeadings()) do
    local t = position + heading
    if todo[tostring(t)] == nil
        and t.x >= minPosition.x and t.x <= maxPosition.x
        and t.y >= minPosition.y and t.y <= maxPosition.y
        and t.z >= minPosition.z and t.z <= maxPosition.z
    then
      todo[tostring(t)] = true
    end
  end

  table.insert(stack, node)
  stackI = stackI + 1
end

m.go = function(position, depth, minPosition, maxPosition)
  init(position)

  move.digTo(position)

  -- if we are unable to complete, it should be due to fuel
  if not m.continue(depth, minPosition, maxPosition) then
    print("Unable to go")
  end

  m.refuel()
  m.transferToChest()
end

m.continue = function(depth, minPosition, maxPosition)
  if not chestPos then
    print("Unable to run without specifying the chest location")
    return false
  end

  while true do
    -- if we find something this round, switch to true
    local found = false

    -- try to refuel if we don't have enough
    if not m.enoughFuel() then
      m.refuel()
    end

    -- exit criteria
    if not m.enoughFuel() then
      print("Must return before running out of fuel")
      print("Fuel: " .. turtle.getFuelLevel())
      print("Blocks: " .. #stack)

      m.retreat()

      return false
    elseif not inventory.freeSlot() then
      print("Must return to make space for any new items")

      m.retreat()
      m.transferToChest()

      if not m.enoughFuel() then
        print("Not enough fuel to make it there and back")
        print("Fuel: " .. turtle.getFuelLevel())
        print("Blocks: " .. #stack)

        return false
      end

      advance()
    end

    -- check for useful block in all flat directions
    for _, h in ipairs(orderedHeadings()) do
      local next = tostring(stack[#stack].pos + h)

      if todo[next] then
        todo[next] = false

        -- set proper inspect function
        local inspect = nil
        local movement = nil
        local dig = nil

        if h.y == 1 then
          inspect = turtle.inspectUp
          movement = bucket.up
          dig = turtle.digUp
        elseif h.y == -1 then
          inspect = turtle.inspectDown
          movement = bucket.down
          dig = turtle.digDown
        else
          inspect = turtle.inspect
          movement = bucket.forward
          dig = turtle.dig
          move.turnTo(h)
        end

        if m.wanted(inspect) then
          -- push new position onto stack, and continue
          bruteDig(movement, dig, inspect)
          expand(minPosition, maxPosition)

          -- we need to continue the main loop when we
          -- push to the stack
          found = true
          break
        end
      end
    end

    -- if we find nothing valuable on all headings
    if not found then
      if stack[#stack].shaft then
        -- clear todo list to save space
        todo = {}

        if #stack >= depth + 1 then
          -- break if we reach max depth
          break
        else
          -- continue down
          bruteDig(bucket.down, turtle.digDown, turtle.inspectDown)
          expand(minPosition, maxPosition, true)
        end
      else
        -- back up
        table.remove(stack)
        move.digTo(stack[#stack].pos)
        stackI = stackI - 1
      end
    end
  end

  print("Returning home")

  m.retreat()
  return true
end

-- go to beginning of stack
m.retreat = function()
  while stackI ~= 1 do
    move.digTo(stack[stackI - 1].pos)
    stackI = stackI - 1
  end

  return true
end

-- go to end of stack
m.advance = function()
  while stackI ~= #stack do
    move.digTo(stack[stackI + 1].pos)
    stackI = stackI + 1
  end

  return true
end

-- Creates a movement vector which includes the starting block in the vector
-- (so we need minus 1 magnitude off each dimension)
-- Checks and converts dimensions to numbers
m.dimensionsToVector = function (forward, height, right)
  local dimensions = {
    height = height,
    forward = forward,
    right = right,
  }
  for dimension, value in pairs(dimensions) do
    value = tonumber(value)
    if value == nil then error(dimension.." must be an integer") end
    if value == 0 then error("0 for "..dimension..", nothing to do") end
    -- Decrement magnitude by 1 so that the to position is correct
    dimensions[dimension] = value - value/math.abs(value)
  end

  local heading = location.getHeading()
  if heading.x > 0 then
    return vector.new(dimensions.forward, dimensions.height, dimensions.right)
  elseif heading.x < 0 then
    return vector.new(-dimensions.forward, dimensions.height, -dimensions.right)
  elseif heading.z > 0 then
    return vector.new(-dimensions.right, dimensions.height, dimensions.forward)
  elseif heading.z < 0 then
    return vector.new(dimensions.right, dimensions.height, -dimensions.forward)
  end
end

-- direction is "" for forward, "Down", or "Up"
-- Will attempt to pick up lava and refuel, then
-- dig the space in front, check the inventory item against
-- wants, and keep or toss it
m.smartDig = function(direction, alwaysDig, homePos, homeHeading)
  bucket["place"..direction]() -- Do  any lava refueling
  m.fuelAndInventoryCheck(homePos, homeHeading) -- Throws error if we can't continue
  local found, block = turtle["inspect"..direction]()
  if not found then return end
  if blocks.isBedrock(block) then return "BEDROCK" end
  if not alwaysDig and not wants.wants(block) then return end -- Don't want it
  -- Otherwise we want it, or we need to alwaysDig ittry to dig it
  if not turtle["dig"..direction]() then return end -- Nothing to dig
  -- need to clear all falling blocks if we're trying to move in that direction
  while alwaysDig and turtle["dig"..direction]() do end
end

-- Checks if we need to go home, if we do, it will try to return to the same
-- position and will return true, else returns false (preferably from homePos)
m.fuelAndInventoryCheck = function(homePos, homeHeading)
  local goHome = false

  if not inventory.freeSlot() then
    m.cleanInventory()
  end
  if not inventory.freeSlot() then
    print("Inventory is full")
    goHome = true
  end

  -- if we are low on fuel or inventory is full
  if not m.enoughFuelToGetTo(homePos) then
    print("Fuel is low, go home")
    goHome = true
  end

  if goHome then
    local digPos = location.getPos()
    local digHeading = location.getHeading()

    -- Go home, cleanup, then head back out
    move.digTo(homePos, "yzx")
    move.turnTo(homeHeading)
    m.cleanInventory() -- So we don't drop off stuff picked up on move.digTo
    m.transferToChest()
    if not inventory.freeSlot() then
      error("Could not empty inventory, can't continue")
    end
    if not m.enoughFuelToGetTo(digPos * 2) then
      error("Not enough fuel to continue")
    end
    move.digTo(digPos, "xzy")
    move.turnTo(digHeading)
  end

end

-- Drops everything that is not wanted and isn't the bucket
m.cleanInventory = function ()
  local bucketSlot = bucket.find()
  for slot = 1, 16, 1 do
    if turtle.getItemCount(slot) > 0
      and slot ~= bucketSlot
      and not reservedSlots[slot]
      and not wants.wants(turtle.getItemDetail(slot, true)) then
        turtle.select(slot)
        turtle.drop()
    end
  end
end

return m
