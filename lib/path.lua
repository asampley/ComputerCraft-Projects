local location = require("/lib/location")
local move = require("/lib/move")

local m = {}

-- Zigzags through every block block layer from current position to xPos,zPos
-- preMoveFunc: Called before each move, if it returns false the layer cut terminates
-- The preMoveFunc(direction) must dig the block in "direction if it exists,
-- otherwise the turtle won't be able to move and the program will terminate.
-- direction can be "" for forward, "Up" for up, or "Down"
-- Feel free to do whatever else with the turtle in preMove (inspect below/above), but it should be returned to the pos+orientation before returning true
-- Turtle will finish in a non-starting corner
m.horizontalLayer = function(xPos, zPos, preMoveFunc)
  local xChange = xPos - location.getPos().x
  local zChange = zPos - location.getPos().z

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
    if not preMoveFunc("") then
      error("preMoveFunc returned false")
    end
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

  local success, error = pcall(function()

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
        preMoveFunc("")
      end

    end
  end)

  if error then print(error) end
  return success

end


-- Moves through every block in the rectangle formed from current location to toPos
-- preMoveFunc: Called before each move, if it returns false the layer cut terminates
-- The preMoveFunc(direction) must dig the block in "direction if it exists,
-- otherwise the turtle won't be able to move and the program will terminate.
-- direction can be "" for forward, or "Down"
-- Turlte will finish in an non-starting corner.
m.solidRectangle = function(toPos, preMoveFunc)
  local startPos = location.getPos()

  -- Figure out how many blocks we have to move vertically
  -- and create an fn to move vertically
  if toPos.y > location.getPos().y then
    print("toPos must have a lower y value")
    return false
  end

  -- Start cutting
  while location.getPos().y >= toPos.y do
    -- Choose the coordinate that is opposite to the current corner
    local xto
    local zto
    local currentPosition = location.getPos()
    if currentPosition.x == startPos.x then
      xto = toPos.x
    else
      xto = startPos.x
    end
    if currentPosition.z == startPos.z then
      zto = toPos.z
    else
      zto = startPos.z
    end
-- print("do from "..currentPosition.x..","..currentPosition.z.." to "..xto..","..zto)
    -- Move to opposite corner
    if not m.horizontalLayer(xto, zto, preMoveFunc) then return false end

    if currentPosition.y <= toPos.y then return true end
    if not preMoveFunc("Down") then return false end
    if not turtle.down() then
      print("[solidRectangle] Couldn't move down at "..tostring(location.getPos()))
      return false
    end
  end

end

return m
