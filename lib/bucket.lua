local m = {}

local defaultSlot = 1

-- list of fuels to bucket up
local fuel = require("/etc/bucket")

-- try to take lava and refuel, and then move
local function _bucket(finalFunc, placeFunc, inspectFunc, bucketSlot)
  -- save previous slot to reselect
  local slotOld = turtle.getSelectedSlot()

  -- select the slot with the bucket
  local slot = bucketSlot or defaultSlot
  turtle.select(slot)

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

  -- now do final action
  return finalFunc()
end

m.forward = function(bucketSlot)
  return _bucket(turtle.forward, turtle.place, turtle.inspect, bucketSlot)
end

m.up = function(bucketSlot)
  return _bucket(turtle.up, turtle.placeUp, turtle.inspectUp, bucketSlot)
end

m.down = function(bucketSlot)
  return _bucket(turtle.down, turtle.placeDown, turtle.inspectDown, bucketSlot)
end

m.place = function(bucketSlot)
  return _bucket(turtle.place, turtle.place, turtle.inspect, bucketSlot)
end

m.placeUp = function(bucketSlot)
  return _bucket(turtle.placeUp, turtle.placeUp, turtle.inspectUp, bucketSlot)
end

m.placeDown = function(bucketSlot)
  return _bucket(turtle.placeDown, turtle.placeDown, turtle.inspectDown, bucketSlot)
end

return m
