local m = {}

-- 0 for no bucket, nil for not searched
local bucketSlot = nil

-- list of fuels to bucket up
local fuel = require("/lib/config").load("bucket")

-- Assumes the bucket does not change slot within a program's running
m.find = function()
  if bucketSlot == nil then
    for i = 1, 16 do
      item = turtle.getItemDetail(i)
  
      if item and item.name == "minecraft:bucket" then
        bucketSlot = i
  
        break
      end
    end
  end

  return bucketSlot
end

-- try to take lava and refuel
local function _tryRefuelByLava(placeFunc, inspectFunc)
  m.find()

  if bucketSlot and bucketSlot ~= 0 then
    -- save previous slot to reselect
    local slotOld = turtle.getSelectedSlot()

    -- select the slot with the bucket
    turtle.select(bucketSlot)

    -- try to grab lava, assumes an empty bucket
    -- may run into trouble if water is picked up
    local success, data = inspectFunc()
    if success then
      if fuel[data.name] then
        placeFunc()
        -- attempt to refuel, would work if lava
        turtle.refuel()
      end
    end

    -- reselect old slot
    turtle.select(slotOld)
  end
end

m.forward = function()
  m.place()
  return turtle.forward()
end

m.up = function()
  m.placeUp()
  return turtle.up()
end

m.down = function()
  m.placeDown()
  return turtle.down()
end

m.place = function()
  return _tryRefuelByLava(turtle.place, turtle.inspect)
end

m.placeUp = function()
  return _tryRefuelByLava(turtle.placeUp, turtle.inspectUp)
end

m.placeDown = function()
  return _tryRefuelByLava(turtle.placeDown, turtle.inspectDown)
end

return m
