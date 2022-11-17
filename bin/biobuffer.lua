local function usage()
  print("Usage: <#diverse> <check frequency>")
  print("Begin the turtle facing the bioreactor")
  print("#diverse is the number of diverse specimens")
  print("check frequency is the number of seconds between inventory checking")
end

if not turtle.detect()
then
  print("No bioreactor detected.")
  usage()
  return
end

args = { ... }
if #args ~= 2
then
  print("Not enough arguments")
  usage()
  return
end

-- the number of diverse plants required
local diverse = tonumber(args[1])
-- the number of ms to check inventory
local frequency = tonumber(args[2])

-- identifiers to see which slots are filled with the same plant
local slot2item = {}
local item2slots = {}
local item2count = {}

-- function to visualize inventory
local function show()
  write("slot2item   item2count      \n")
  for y = 0, 3 do
    for x = 0, 3 do
      local slot = y * 4 + x + 1
      local formatS = "%2d "
      write(formatS:format(slot2item[slot]))
    end
    for i = 1, 4 do
      local item = y * 4 + i
      local formatS = "%3d "
      write(formatS:format(item2count[item]))
    end
    write("\n")
  end
  write("\n")
end

-- function to check inventory slots for ids
-- return the number of unique slots
local function scan()

  local numUnique = 0

  -- clear all data
  for i = 1, 16 do
    slot2item[i] = 0
    item2slots[i] = {}
    item2count[i] = 0
  end

  -- populate data
  local itemID = 1

  for i = 1, 16 do
    turtle.select(i)
    local unique = true

    -- check if the slot is empty
    if turtle.getItemCount(i) == 0
    then
      unique = false
      -- if not, compare to other slots
    else
      for j = 1, i - 1 do
        if turtle.compareTo(j)
        then
          unique = false
          local item = slot2item[j]
          slot2item[i] = item
          if item2slots[item]
          then
            table.insert(item2slots[item], i)
          else
            item2slots[item] = { i }
          end
          item2count[item] = item2count[item] + turtle.getItemCount(i)
          break
        end
      end
    end

    -- if it is a new slot, add up
    if unique
    then
      slot2item[i] = itemID
      item2slots[itemID] = { i }
      item2count[itemID] = turtle.getItemCount(i)
      numUnique = numUnique + 1
      itemID = itemID + 1
    end
  end

  return numUnique
end

-- main execution
while true do
  -- count and set slot and item maps
  local numPlants = scan()

  -- show the inventory
  show()

  -- if enough plants, turn of bioreactor, and transfer items
  if numPlants >= diverse
  then

    -- turn off bioreactor
    rs.setOutput("front", true)

    local items2transfer = 64
    -- find the number of items to transfer (max 64)
    for item = 1, 16 do
      if item2count[item] ~= 0
      then
        items2transfer = math.min(items2transfer, item2count[item])
      end
    end

    -- transfer that number of items
    for item = 1, 16 do
      local still2transfer = items2transfer
      for _, slot in pairs(item2slots[item]) do

        turtle.select(slot)
        local toTransfer = math.min(still2transfer, turtle.getItemCount(slot))
        still2transfer = still2transfer - toTransfer
        turtle.drop(toTransfer)
        print("Transfered " .. toTransfer)

        if still2transfer <= 0
        then
          break
        end
      end
    end

  end

  -- turn on bioreactor
  rs.setOutput("front", false)

  -- sleep until next execution
  sleep(frequency)
end
