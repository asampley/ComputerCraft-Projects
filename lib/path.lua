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

  -- Rotate the Turtle's heading so that it has to move forward and right
  -- Update the bounds to reflect this
  if xChange >= 0 and zChange >= 0 then
    -- both pos
    move.turnTo(vector.new(1, 0, 0))
  elseif zChange < 0 and xChange < 0 then
    -- both neg
    move.turnTo(vector.new(-1, 0, 0))
  elseif zChange < 0 or xChange < 0 then
    -- exactly 1 is neg
    if zChange < 0 then
      move.turnTo(vector.new(0, 0, -1))
    elseif xChange < 0 then
      move.turnTo(vector.new(0, 0, 1))
    end
    -- In these cases the x/y bounds switch places
    local temp = zChange
    zChange = xChange
    xChange = temp
  end
  xChange = math.abs(xChange)
  zChange = math.abs(zChange)

  local x = 0
  local z = 0
  local turn
  local move = function ()
    if not preMoveFunc("") then
      error("preMoveFunc returned false")
    end
    if not turtle.forward() then
      error("Couldn't move forward")
    end
  end

  local success, error = pcall(function()
    -- Start cutting
    while z < zChange + 1 do
      while x < xChange do
        move()
        x = x + 1
      end
      x = 0
      -- Orient turtle for the next row
      if z < zChange then
        if z % 2 == 1 then
          turn = turtle.turnLeft
        else
          turn = turtle.turnRight
        end
        turn()
        move()
        turn()
      end
      z = z + 1
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
    m.horizontalLayer(xto, zto, preMoveFunc)

    if not preMoveFunc("Down") then return false end
    if currentPosition.y > toPos.y then
      if not turtle.down() then 
        print("[solidRectangle] Couldn't move down")
        return false
      end
    end
  end
  
end

return m
