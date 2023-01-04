local location = require("/lib/location")
local move = require("/lib/move")

local m = {}

-- Zigzags through every block in the layer formed by xChange and zChange
-- preMoveFunc: Called before each move, if it returns false the layer cut terminates
-- The preMoveFunc(direction) must dig the block in "direction if it exists,
-- otherwise the turtle won't be able to move and the program will terminate.
-- direction can be "" for forward, "Up" for up, or "Down"
-- Feel free to do whatever else with the turtle in preMove (inspect below/above), but it should be returned to the pos+orientation before returning true
-- Turtle will finish in a non-starting corner
m.horizontalLayer = function(xChange, zChange, preMoveFunc)
  local length --longer dimension
  local width --shorter dimention
  local turnOffset -- keeps track of if we should turn right or left

  -- We want to run along the longer dimension for speed optimization
  if math.abs(xChange) >= math.abs(zChange) then
    turnOffset = 0
    length = math.abs(xChange)
    width = math.abs(zChange)
    -- face towards positive or negative x
    move.turnTo(location.X()*xChange/math.abs(xChange))
  else
    turnOffset = 1
    length = math.abs(zChange)
    width = math.abs(xChange)
    -- face towards positive or negative z
    move.turnTo(location.Z()*zChange/math.abs(zChange))
  end
  -- update turnOffset to account for width's +/-
  if xChange * zChange < 0 then turnOffset = turnOffset + 1 end

  local move = function ()
    preMoveFunc("")
    if not turtle.forward() then
      error("Couldn't move forward at "..tostring(location.getPos()))
    end
  end

  local turn = function (turnOffset)
    if turnOffset % 2 == 1 then
      turtle.turnLeft()
    else
      turtle.turnRight()
    end
  end

  for w = 0, width, 1 do

    for l = 0, length - 1, 1 do
      move()
    end

    if w < width then
      -- Orient turtle for the next row
      turn(turnOffset + w)
      move()
      turn(turnOffset + w)
    else
      -- Turn back towards trodden path, and call one final preMove
      turn(turnOffset + w + 1)
      -- an additional turn is required for width==0 since trodden path is only behind
      if w == 0 then turn(turnOffset + w + 1) end
      preMoveFunc("")
    end

  end

end


-- Moves through every block in the rectangle formed from current location to toPos
-- preMoveFunc(direction): Called before each move, must dig the block in "direction" if it exists,
-- otherwise the turtle won't be able to move and the program will terminate.
-- direction can be "" for forward, or "Down"
-- Turlte will finish in an non-starting corner.
m.rectangleSimple = function(dimensionVector, preMoveFunc)
  local startPos = location.getPos()
  local yChange = dimensionVector.y
  local direction = yChange > 0 and "Up" or "Down"

  -- Start cutting
  for y = 0, math.abs(yChange), 1 do
    -- Choose the dimensions that are opposite to the current corner
    local currentPosition = location.getPos() - startPos
    local xChange = currentPosition.x == 0 and dimensionVector.x or -dimensionVector.x
    local zChange = currentPosition.z == 0 and dimensionVector.z or -dimensionVector.z

    -- Move to opposite corner
    m.horizontalLayer(xChange, zChange, preMoveFunc)
    if y == math.abs(yChange) then print("[rectangleSimple] Completed layers") return end
    preMoveFunc(direction)
    if not turtle[string.lower(direction)]() then
      error("Couldn't move "..direction.." at "..tostring(location.getPos()))
    end
  end

end

-- Faster than rectangleSimple.
-- Every 3rd layer will be cleared, but the ones inbetween are optional.
-- digFunc(direction, mustDig): direction is "Up", "Down", or "" (forward),
-- if mustDig, block in "direction" must be cleared.
m.rectangleEveryThirdLayer = function (dimensionVector, digFunc)
  local move = function (direction)
    digFunc(direction, true)
    if direction == "" then direction = "forward" end
    turtle[string.lower(direction)]()
  end

  local startPos = location.getPos()
  local shouldDig = { Up=true, Down=true, }
  local verticalDir = dimensionVector.y >= 0 and "Up" or "Down"
  local setupForRemainingLayers = function (direction, remainLayers)
    if remainLayers <= 0 then error("[rectangleEveryThirdLayer] Completed layers ('simpleVeector' is incorrect if see this)") end
    if remainLayers == 1 then shouldDig = { Up=false, Down=false, } end
    if remainLayers == 2 then shouldDig[verticalDir] = false end
    if remainLayers >= 2 then move(direction) end
  end

  setupForRemainingLayers(verticalDir, math.abs(dimensionVector.y) + 1)

  local y = dimensionVector.y
  y = y == 0 and y or math.floor(math.abs(y / 3)) * y/math.abs(y)
  local simpleVector = vector.new(dimensionVector.x, y, dimensionVector.z)
  m.rectangleSimple(simpleVector, function (direction)
    -- dig above and below as required
    if shouldDig.Up then digFunc("Up") end
    if shouldDig.Down then digFunc("Down") end

    if direction == "Down" or direction == "Up" then
      local remainLayers = math.abs(dimensionVector.y - (location.getPos().y - startPos.y)) - 1
      setupForRemainingLayers(direction, remainLayers)
      move(direction)
    end

    digFunc(direction, true)
  end)
end

return m
