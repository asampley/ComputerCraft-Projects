local inventory = require("/lib/inventory")
local location = require("/lib/location")
local move = require("/lib/move")
local blueprint = require("/lib/blueprint")
local collect = require("/lib/collect")
local tensor = require("/lib/tensor")

--[[

Load a build file, and build
the structure, bottom up. Any blocks
in the way will be dug. One layer of
blocks above will also be dug, to give
the turtle the room it needs.

Each build file should be formatted in
the following way (replace <...> with
value, use symbols in blueprint):

  <width> <depth> <height>
  <symbol1>
  <symbol2>
  ...
  <symbolN>
  Blueprint:
  <blueprint goes here>

A blueprint must match the defined
width, depth, and height. Each layer is
separated by a new line. The build file
may look something like this (note: "."
is the symbol for nothing):

  4 3 2
  A Comment for A
  B Comment for B
  Blueprint:
  AAAA
  AAAA
  BAAA

  AAAA
  A..A
  AAAA

The starting location of the turtle
happends to coincide with the single
"B" block, but as a rule, the turtle
builds forward, right, and up. Note,
that the first layer is the bottom,
and the next layer is the top.

--]]

--[[
Read and return a blueprint
--]]
local function readBlueprint(fileName)
  local bp = blueprint.new()
  local lineNumber = 0
  local file = fs.open(fileName, "r")
  if not file
  then
    return nil
  end

  -- read dimensions
  local dimensions = file.readLine()
  lineNumber = lineNumber + 1
  local dimStrings = {}
  dimensions:gsub("%d+", function(i) table.insert(dimStrings, i) end)

  local width = tonumber(dimStrings[1])
  local depth = tonumber(dimStrings[2])
  local height = tonumber(dimStrings[3])

  local invSlot = 1
  -- read all symbol and slot pairs
  local symbolLine = nil
  bp.symbols = {}
  while true do
    symbolLine = file.readLine()
    lineNumber = lineNumber + 1

    if not symbolLine or symbolLine == "Blueprint:" then
      break
    end

    local symbol, comment = symbolLine:match("(.) (.*)")

    bp.symbols[symbol] = {
      slot = invSlot,
      comment = comment,
    }

    invSlot = invSlot + 1
  end

  -- read blueprint
  local blueprintLine = nil

  for y = 0, height - 1 do
    for z = 0, depth - 1 do
      blueprintLine = file.readLine()
      lineNumber = lineNumber + 1
      if not blueprintLine
      then
        error("at line " .. lineNumber .. ": number of lines in block does not match depth")
      elseif blueprintLine:len() ~= width
      then
        error("at line " .. lineNumber .. ":" ..
          "\nline is not the same as <width>" ..
          "\nExpected: " .. width ..
          "\nGot: " .. blueprintLine:len())
      end
      for x = 0, width - 1 do
        local symbol = blueprintLine:sub(x + 1, x + 1)

        bp.blocks:set(symbol, x, y, z)
      end

    end
    -- read newline after block
    blueprintLine = file.readLine()
    lineNumber = lineNumber + 1
  end

  return bp
end

local function directions()
  return { "-Y", "Y", "-X", "X", "-Z", "Z" }
end

--[[

Build the blueprint, going forward,
to complete a line, right to do the
next lines and complete a plane, and
up to complete the next planes and
complete the structure

--]]
local function build(bp)
  -- create distance map
  local distance = tensor.new()
  distance:set(0, 0, 0, 0)

  local expand = collect.deque.new()
  expand:push_back(vector.new(0, 0, 0))

  while not expand:empty() do
    local v = expand:pop_front()

    local d = distance:get(v.x, v.y, v.z) + 1

    for _, direction in ipairs(directions()) do
      local adj = v + location[direction]()

      local symbol, symbol_info = bp:symbol(adj.x, adj.y, adj.z)

      if symbol
        and not (symbol_info and symbol_info.nobuild and symbol_info.nobuild[direction])
        and not distance:get(adj.x, adj.y, adj.z)
      then
        distance:set(d, adj.x, adj.y, adj.z)
        expand:push_back(adj)
      end
    end
  end

  for x, xx in pairs(bp.blocks) do
    for y, yy in pairs(xx) do
      for z, _ in pairs(yy) do
        if not distance:get(x, y, z) then
          error("Unable to create a path to all blocks: Could not reach " .. x .. "," .. y .. "," .. z)
        end
      end
    end
  end

  local start = location.getPos()
  local forward = location.getHeading()
  --local right = location.turnRight(forward)
  local up = location.Y()

  repeat
    local pos = location.getPos() - start

    local function local_max(vec)
      local dist = distance:get(vec.x, vec.y, vec.z)

      for _, d in ipairs(directions()) do
        local a = vec + location[d]()

        local adj_dist = distance:get(a.x, a.y, a.z)
        if adj_dist and dist < adj_dist then
          return false
        end
      end

      return true
    end

    local above = pos + up
    if distance:get(above.x, above.y, above.z) then
      if local_max(above) then
        local symbol, info = bp:symbol(above.x, above.y, above.z)

        if symbol == blueprint.AIR then
          turtle.digUp()

          distance:set(nil, above.x, above.y, above.z)
        elseif not info or not info.nobuild or not info.nobuild["Y"] then
          turtle.select(info.slot)

          while not turtle.placeUp() do turtle.digUp() end

          distance:set(nil, above.x, above.y, above.z)
        end
      end
    end

    local below = pos - up
    if distance:get(below.x, below.y, below.z) then
      if local_max(below) then
        local symbol, info = bp:symbol(below.x, below.y, below.z)

        if symbol == blueprint.AIR then
          turtle.digUp()

          distance:set(nil, below.x, below.y, below.z)
        elseif not info or not info.nobuild or not info.nobuild["-Y"] then
          turtle.select(info.slot)

          while not turtle.placeDown() do turtle.digDown() end

          distance:set(nil, below.x, below.y, below.z)
        end
      end
    end

    local heading = location.getHeading()

    for _ = 1, 4 do
      local beside = pos + heading
      if distance:get(beside.x, beside.y, beside.z) then
        if local_max(beside) then
          local symbol, info = bp:symbol(beside.x, beside.y, beside.z)

          if symbol == blueprint.AIR then
            move.turnTo(heading)

            turtle.dig()

            distance:set(nil, beside.x, beside.y, beside.z)
          elseif not info or not info.nobuild
            or (heading.x == 1 and not info.nobuild["X"])
            or (heading.x == -1 and not info.nobuild["-X"])
            or (heading.z == 1 and not info.nobuild["Z"])
            or (heading.z == -1 and not info.nobuild["-Z"])
          then
            move.turnTo(heading)

            turtle.select(info.slot)

            while not turtle.place() do turtle.dig() end

            distance:set(nil, beside.x, beside.y, beside.z)
          end
        end
      end

      heading = location.turnRight(heading)
    end

    local best
    for _, direction in ipairs(directions()) do
      local a = pos + location[direction]()

      local _, info = bp:symbol(pos.x, pos.y, pos.z)

      local d = distance:get(a.x, a.y, a.z)
      if d and (
        not best or best.dist < d
        -- ties must be broken by going a direction that can build on the current location
        -- otherwise a loop can be reached
        or (best.dist == d and info and info.nobuild and not info.nobuild[direction])
      ) then
        best = { dist = d, coords = a }
      end
    end

    if best then
      move.digTo(start + best.coords)
    end
  until not best
end

-- First, let's turn autofill on
local initAutoRefill = inventory.getAutoRefill()
inventory.setAutoRefill(true)

-- Now, let's see what file we're
-- using
local args = { ... }
if #args ~= 1
then
  print("Usage: <fileName>")
  return
end

local fileName = args[1]
local bp = loadfile(fileName, "bt", _ENV)
if bp then
  bp = bp()
else
  bp = readBlueprint(fileName)
end

if not bp then
  error("Unable to read blueprint "..fileName)
end

print("Loaded blueprint:")
print("  inventory:")
local counts = bp:counts()
local i = 1
while i <= 16 do
  for symbol, info in pairs(bp.symbols) do
    if info.slot == i then
      local text = "    " .. symbol .. "->" .. info.slot .. " " .. info.comment
        .. " x" .. counts[symbol]

      if counts[symbol] > 64 then
        text = text .. " ("
          .. math.floor(counts[symbol] / 64) .. "x64 + "
          .. counts[symbol] % 64
        .. ")"
      end

      print(text)
      break
    end
  end
  i = i + 1
end

-- wait for user confirmation
print("Press enter to continue...")
repeat until table.pack(os.pullEvent("key"))[2] == keys.enter

-- now, let's build
build(bp)

-- Let's turn autorefill to its
-- previous setting.
inventory.setAutoRefill(initAutoRefill)
