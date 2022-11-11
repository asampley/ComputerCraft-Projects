local inventory = require("/lib/inventory")
local location = require("/lib/location")
local move = require("/lib/move")

local air = "."

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
  <symbol1> <invSlot1>
  <symbol2> <invSlot2>
  ...
  <symbolN> <invSlotN>
  Blueprint:
  <blueprint goes here>

A blueprint must match the defined
width, depth, and height. Each layer is
separated by a new line. The build file
may look something like this (note: "."
is the symbol for nothing):

  4 3 2
  A 1 Comment for A
  B 2 Comment for B
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
Read a blueprint, return 
width, depth, height, design, invMap, commentMap}
--]]
function readBlueprint(fileName)
  
  local blueprint = {}
  
  
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
  dimensions:gsub("%d+", function (i) table.insert(dimStrings, i) end)
  
  blueprint.width = tonumber(dimStrings[1])
  blueprint.depth = tonumber(dimStrings[2])
  blueprint.height = tonumber(dimStrings[3])
  
  -- read all symbol and slot pairs
  local symbolLine = nil
  blueprint.invMap = {}
  blueprint.commentMap = {}
  while symbolLine ~= "Blueprint:"
  do
    symbolLine = file.readLine()
    lineNumber = lineNumber + 1
    local symbol = symbolLine:sub(1,1)
    local nextSpace = symbolLine:find(" ", 3)
    print(nextSpace)
    if not nextSpace
    then
        nextSpace = -1
    end
    local invSlot = tonumber(symbolLine:sub(3, nextSpace))
    local comment = symbolLine:sub(nextSpace + 1)
    
    blueprint.invMap[symbol] = invSlot
    blueprint.commentMap[symbol] = comment
  end
  
  -- read blueprint
  local blueprintLine = nil
  blueprint.design = {}
  
  for x = 0,blueprint.width-1 do
    blueprint.design[x] = {}
    for y = 0,blueprint.height-1 do
      blueprint.design[x][y] = {}
    end
  end
        
  
  for y = 0,blueprint.height-1
  do
    for z = 0,blueprint.depth-1
    do
      blueprintLine = file.readLine()
      lineNumber = lineNumber + 1
      if not blueprintLine
      then
        error("at line "..lineNumber..": number of lines in block does not match depth")
      elseif blueprintLine:len() ~= blueprint.width
      then 
        error("at line "..lineNumber..":"..
              "\nline is not the same as <width>"..
                "\nExpected: "..blueprint.width..
                "\nGot: "..blueprintLine:len()) 
      end
      for x = 0,blueprint.width-1
      do
        blueprint.design[x][y][z] = blueprintLine:sub(x+1,x+1)
      end
      
    end
    -- read newline after block
    blueprintLine = file.readLine()  
    lineNumber = lineNumber + 1
  end
  
  return blueprint
end

--[[

Build the blueprint, going forward,
to complete a line, right to do the
next lines and complete a plane, and
up to complete the next planes and
complete the structure

--]]
function build(blueprint)
  local start = location.getPos()
  local forward = location.getHeading()
  turtle.turnRight()
  local right = location.getHeading()
  local up = vector.new(0,1,0)
 
  --print("init done")
    
  local invertX = false
  local invertZ = false
  local xi, yi, zi = 0,0,0
  for y = 0,blueprint.height-1
  do
    local yi = y
    for x = 0,blueprint.width-1
    do
      if invertX then
        xi = blueprint.width-1-x
      else
        xi = x
      end
        
      for z = 0,blueprint.depth-1
      do
        if invertZ then
          zi = blueprint.depth-1-z
        else
          zi = z
        end
        
        -- move to location above block
        local buildPos = start + (forward*zi) + (right*xi) + (up*(yi+1))
        move.digTo(buildPos)
        
        -- remove block underneath
        turtle.digDown()
        
        -- select correct inventory slot
        local block = blueprint.design[xi][yi][zi]
        
        if block ~= air
        then
          local slot = blueprint.invMap[block]
          turtle.select(slot)
        
          -- place a block down
          while not turtle.placeDown() do turtle.digDown() end
        end
      end -- end z
      -- we are on the other side, so
      -- switch directions
      invertZ = not invertZ
      
    end -- end x
      -- we are on the other side, so
      -- switch directions
      invertX = not invertX
  end -- end y        
end

-- First, let's turn autofill on
local initAutoRefill = inventory.getAutoRefill()
inventory.setAutoRefill(true)

-- Now, let's see what file we're
-- using
args = {...}
if #args ~= 1
then
  print("Usage: <fileName>")
  return
end

local fileName = args[1]
local blueprint = readBlueprint(fileName)

print("Loaded blueprint:")
print("  width=  "..blueprint.width)
print("  depth=  "..blueprint.depth)
print("  height= "..blueprint.height)
print("  inventory:")
for symbol,slot in pairs(blueprint.invMap)
do
  print("    "..symbol.."->"..slot.." "..blueprint.commentMap[symbol])
end

-- wait for user confirmation
print("Press any key to continue...")
os.pullEvent("key")

-- now, let's build
build(blueprint)

-- Let's turn autorefill to its
-- previous setting.
inventory.setAutoRefill(initAutoRefill)
