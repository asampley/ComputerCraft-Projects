local m = {}

-- 0 for no bucket, nil for not searched
local bucketSlot

-- list of fuels to bucket up
local fuel = require("/lib/config").load("bucket")

m.find = function()
  if bucketSlot ~= 0 then
    local item = turtle.getItemDetail(bucketSlot)

    if item and item.name == "minecraft:bucket" then
      return bucketSlot
    end
  end

  bucketSlot = 0

  for i = 1, 16 do
    item = turtle.getItemDetail(i)

    if item and item.name == "minecraft:bucket" then
      bucketSlot = i

      break
    end
  end

  return bucketSlot
end

-- try to take lava and refuel, and then move
local function _bucket(finalFunc, placeFunc, inspectFunc)
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

  -- now do final action
  return finalFunc()
end

m.forward = function()
  return _bucket(turtle.forward, turtle.place, turtle.inspect)
end

m.up = function()
  return _bucket(turtle.up, turtle.placeUp, turtle.inspectUp)
end

m.down = function()
  return _bucket(turtle.down, turtle.placeDown, turtle.inspectDown)
end

m.place = function()
  return _bucket(turtle.place, turtle.place, turtle.inspect)
end

m.placeUp = function()
  return _bucket(turtle.placeUp, turtle.placeUp, turtle.inspectUp)
end

m.placeDown = function()
  return _bucket(turtle.placeDown, turtle.placeDown, turtle.inspectDown)
end

return m
