local bucket = require("/lib/bucket")
local inventory = require("/lib/inventory")
local location = require("/lib/location")
local move = require("/lib/move")

local m = {}

-- load config files to determine blocks to search for and items to refuel with
local wants = require("/etc/bore/wants")
local fuel = require("/etc/bore/fuel")

-- record chest location
local chestPos = nil

m.setChest = function(position)
  chestPos = position
end

-- check if block is wanted
local function isDesired(inspectFunc)
  local found, block = inspectFunc()
  return found and wants[block.name] or wants.default
end

local function bruteDig(moveFunc, digFunc, inspectFunc)
  while not moveFunc() do
    local blockFound, block = inspectFunc()
    if blockFound and block.name == "minecraft:bedrock" then
      return false
    end
    digFunc()
  end
  return true
end

local stack = {}
local stackI = -1

m.transferToChest = function()
  move.digTo(chestPos)

  for i = 2, 16 do

    turtle.select(i)
    -- don't transfer fuel unless we are full
    local item = turtle.getItemDetail()
    if not m.shouldFuel() or not item or not fuel[item.name] then
      turtle.dropUp()
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

  for i = 2, 16 do
    turtle.select(i)
    local item = turtle.getItemDetail()

    if item then print(item.name) end
    if item then print(fuel[item.name]) end

    while m.shouldFuel() and item and fuel[item.name] do
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
  return turtle.getFuelLevel() > #stack + #stack - stackI + 2
end

local function init(position)
  stack = { {
    pos = position,
    todo = { -location.Y() },
    shaft = true
  } }
  stackI = #stack
end

local function expand(minPosition, maxPosition, shaft)
  local position = location.getPos()
  local heading = location.getHeading()

  local node = {
    pos = position,
    todo = {},
    shaft = shaft
  }

  local headings = { location.Y(), -location.Y() }
  for i = 0, 3 do
    heading = location.turnLeft(heading)
    table.insert(headings, heading)
  end

  for _, heading in ipairs(headings) do
    local todo = position + heading
    if todo.x >= minPosition.x and todo.x <= maxPosition.x
        and todo.y >= minPosition.y and todo.y <= maxPosition.y
        and todo.z >= minPosition.z and todo.z <= maxPosition.z
    then
      table.insert(node.todo, heading)
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

    local headings = stack[#stack].todo
    -- check for useful block in all flat directions
    for h in function() return table.remove(headings) end do
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

      if isDesired(inspect) then
        -- push new position onto stack, and continue
        bruteDig(movement, dig, inspect)
        expand(minPosition, maxPosition)

        -- we need to continue the main loop when we
        -- push to the stack
        found = true
        break
      end
    end

    -- if we find nothing valuable on all headings
    if not found then
      if stack[#stack].shaft then
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

return m
