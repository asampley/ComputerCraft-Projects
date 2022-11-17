--[[
This api is for inventory management
It will keep track of items in each
slot.

To properly allow numbers to be kept,
the api must run its "eventListen"
function. It is recommended to do this
in the startup file, using the parallel
API.

Alternatively, for greater efficiency,
one should call this manually, using
scan to refresh the view of the
inventory.

Some functionality does not require
constant updating of inventory info.
For example, auto-refill, which is
one of the only uses right now.

--]]

local m = {}

if not turtle then return end

local slotToCount = {}
local autoRefill = false

turtle.select(1)

local selected = 1
local _turtle = {}
_turtle.select = turtle.select
_turtle.placeDown = turtle.placeDown
_turtle.placeUp = turtle.placeUp
_turtle.place = turtle.place

turtle.select = function(slot)
  if (_turtle.select(slot)) then
    selected = slot
    return true
  end
  return false
end

turtle.getSelectedSlot = function()
  return selected
end

--[[

Listens for when the inventory of the
turtle changes. Note, however, that
this function never returns. It is
therefore recommended to run this
function using the parallel API.

--]]
m.eventListen = function()
  while true
  do
    os.pullEvent("turtle_inventory")
    scan()
  end
end

--[[

Automatically ensure that when a block
is placed, at least one remains in the
slot after use, if possible.

These replace normal calls to place,
placeUp, and placeDown in the turtle
API, when auto-refill is on.

--]]
m.placeRefill = function(placeFunc, ...)

  if autoRefill and turtle.getItemCount(selected) == 1
  then
    local refillSlot = turtle.getSelectedSlot()

    for slot = 1,16
    do
      if slot ~= refillSlot
      then
        if turtle.compareTo(slot)
        then
          turtle.select(slot)
          turtle.transferTo(refillSlot)
          turtle.select(refillSlot)
          break
        end
      end
    end
  end

  return placeFunc(arg)
end

turtle.place = function(...) return placeRefill(_turtle.place, ...) end
turtle.placeUp = function() return placeRefill(_turtle.placeUp) end
turtle.placeDown = function() return placeRefill(_turtle.placeDown) end

--[[

It is important that this function
cannot yield while executing. All work
must be done before another process
expects the inventory back.

As well, this function must NOT change
the inventory.

--]]
m.scan = function()
  for slot = 1,16 do
    local count = turtle.getItemCount(slot)
    slotToCount[slot] = count
  end
end

m.printSlotCounts = function()
  for y = 1,4  do
    for x = 1,4 do
      write(string.format("%2d ", turtle.getItemCount((y-1)*4+x)))
    end
    write("\n")
  end
end

m.setAutoRefill = function(flag)
  autoRefill = flag
end

m.getAutoRefill = function()
  return autoRefill
end

-- Return the first free slot, otherwise nil
m.freeSlot = function()
  for slot = 1,16 do
    if turtle.getItemCount(slot) == 0 then
      return slot
    end
  end
end

return m
