local bucket = require("/lib/bucket")
local inventory = require("/lib/inventory")
local location = require("/lib/location")
local move = require("/lib/move")
local path = require("/lib/path")

local m = {}

-- load config files to determine blocks to search for and items to refuel with
local config = require("/lib/config")
local wants = config.load("bore/wants")
local fuel = config.load("bore/fuel")

-- record chest location
local chestPos

m.setChest = function(position)
  chestPos = position
end

-- check if block is wanted
m.wanted = function(inspectFunc)
  local found, block = inspectFunc()
  return found and wants(block)
end

m.isBedrock = function (inspectFunc)
  local blockFound, block = inspectFunc()
  return blockFound and block.name == "minecraft:bedrock"
end

local function bruteDig(moveFunc, digFunc, inspectFunc)
  while not moveFunc() do
    if m.isBedrock(inspectFunc) then return false end
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

  if not peripheral.hasType("top", "inventory") then
    error("Block above chestPos is not an inventory")
  end

  local bucketSlot = bucket.find()

  for i = 1, 16 do
    if i ~= bucketSlot then
      -- don't transfer fuel unless we are full
      local item = turtle.getItemDetail(i)
      if item and (not fuel[item.name] or not m.shouldFuel()) then
        turtle.select(i)
        turtle.dropUp()
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

-- direction is "" for forward, "Down", or "Up"
-- Will attempt to pick up lava and refuel, then
-- dig the space in front, check the inventory item against
-- wants, and keep or toss it
m.smartDig = function(direction, alwaysDig, homePos, homeHeading)
  bucket["place"..direction]() -- Do  any lava refueling
  m.fuelAndInventoryCheck(homePos, homeHeading) -- Throws error if we can't continue
  if not alwaysDig and not m.wanted(turtle["inspect"..direction]) then return end -- Don't want it
  -- try to dig it
  if not turtle["dig"..direction]() and m.isBedrock(turtle["inspect"..direction]) then return "BEDROCK" end -- Nothing or bedrock
  if alwaysDig and turtle["detect"..direction]() then
    -- need to clear all falling blocks
    m.smartDig(direction, alwaysDig, homePos, homeHeading)
  end
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
    move.goTo(digPos, "xzy")
    move.turnTo(digHeading)
  end

end

-- Drops everything that is not wanted and isn't the bucket
m.cleanInventory = function ()
  local bucketSlot = bucket.find()
  for slot = 1, 16, 1 do
    if turtle.getItemCount(slot) > 0
      and slot ~= bucketSlot
      and not wants(turtle.getItemDetail(slot, true)) then
        turtle.select(slot)
        turtle.drop()
    end
  end
end

m.cleave = function(height, forward, right)
  local homePos = location.getPos()
  local homeHeading = location.getHeading()
  -- Decrease forward and right magnitude by one for calc'ing desired position
  -- (because we are already on the first space)
  forward = forward - forward / math.abs(forward)
  right = right - right / math.abs(right)
  height = height - height/math.abs(height)
  local toPos = homePos + vector.new(forward, height, right)

  m.setChest(homePos)

  path.solidRectangle(toPos, function (direction)
    local success, error = pcall(function()

      m.smartDig(direction, true, homePos, homeHeading)

    end)
    if error then print(error) end
    return success
  end)

  move.digTo(homePos, "yzx")
  move.turnTo(homeHeading)
  m.cleanInventory() -- So we don't drop off stuff picked up on move.digTo
  m.transferToChest()
end

m.layerBore = function (height, forward, right)
  local homePos = location.getPos()
  local homeHeading = location.getHeading()
  -- Decrease forward and right magnitude by one for calc'ing desired position
  -- (because we are already on the first space)
  forward = forward - forward / math.abs(forward)
  right = right - right / math.abs(right)
  height = height - height/math.abs(height)
  local toPos = homePos + vector.new(forward, math.floor(height/3), right)

  local lastCompleteLayer = 0
  local foundBedrock = false

  m.setChest(homePos)

  path.solidRectangle(toPos, function (direction)
    local success, error = pcall(function()

      -- Check above and below for good stuff
      m.smartDig("Up", false, homePos, homeHeading)
      m.smartDig("Down", false, homePos, homeHeading)
      if direction == "Down" or direction == "Up" then
        if foundBedrock then
          error("Completed last layer before bedrock.")
        end
        lastCompleteLayer = location.getPos().y

        -- Try to skip 2 layers (we don't care if it fails)
        for i = 1, 2, 1 do
          m.smartDig(direction, true, homePos, homeHeading)
          turtle[string.lower(direction)]()
        end
      end

      -- Handle bedrock, we will move up/down to avoid it until we are back at the last layer
      while m.smartDig(direction, true, homePos, homeHeading) == "BEDROCK" do
        print("found bedrock, last "..lastCompleteLayer.." cur "..location.getPos().y)
        foundBedrock = true
        -- Try to move away from bedrock layer (move opposite direction)
        local awayDir = height > 0 and "Down" or "Up"
        print("dir "..direction.." awayDir "..awayDir)
        if m.smartDig(awayDir, true, homePos, homeHeading) == "BEDROCK" then
          error("Stuck in bedrock at "..tostring(location.getPos()))
        end
        turtle[string.lower(awayDir)]()
        if awayDir == "Up" and location.getPos().y >= lastCompleteLayer
          or awayDir == "Down" and location.getPos().y <= lastCompleteLayer
        then
          error("Hit bedrock, and backtracked to last layer, done.")
        end
      end

    end)
    if error then print(error) end
    return success
  end)

  move.digTo(homePos, "yzx")
  move.turnTo(homeHeading)
  m.cleanInventory() -- So we don't drop off stuff picked up on move.digTo
  m.transferToChest()

end

return m
