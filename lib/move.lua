local location = require("/lib/location")

local m = {}

-- move the turtle to the position
local function _to(position, upFunc, downFunc, forwardFunc, digUpFunc, digDownFunc, digFunc, orderOfMoves)
  local moveOrder = orderOfMoves or "xzy"
  local currPosition = location.getPos()
  local path = position - currPosition

  -- move in each axis, xyz
  for i = 1,3
  do
    local move = moveOrder:sub(i,i)
    if move == "x"
    then
      if path.x < 0
      then
        m.turnTo(vector.new(-1,0,0))
        path.x = -(path.x)
      elseif path.x > 0
      then
        m.turnTo(vector.new(1,0,0))
      end
      for x = 1, path.x
      do
        while not forwardFunc() 
        do 
          if digFunc then digFunc() end
        end
      end
    elseif move == "z"
    then
      if path.z < 0
      then
        m.turnTo(vector.new(0,0,-1))
        path.z = -(path.z)
      elseif path.z > 0
      then
        m.turnTo(vector.new(0,0,1))
      end
      for z = 1, path.z
      do
        while not forwardFunc()
        do 
          if digFunc then digFunc() end  
        end
      end
    else
      if path.y < 0
      then
        for y = 1,-(path.y)
        do
          while not downFunc()
          do 
            if digDownFunc then digDownFunc() end
          end
        end
      else
        for y = 1,path.y
        do
          while not upFunc()
          do
            if digUpFunc then digUpFunc() end
          end
        end
      end
    end
  end
end

-- go to
m.goTo = function(position, moveOrder)
  _to(position, turtle.up, turtle.down, turtle.forward, nil, nil, nil, orderOfMoves)
end

-- dig to
m.digTo = function(position, moveOrder)
  _to(position, turtle.up, turtle.down, turtle.forward, turtle.digUp, turtle.digDown, turtle.dig, orderOfMoves)
end

-- turn the turtle to the heading in as few turns as possible
m.turnTo = function(heading)
  local currHeading = location.getHeading()

  if currHeading.x == -heading.x and currHeading.z == -heading.z
  then
    turtle.turnLeft()
    turtle.turnLeft()
  elseif currHeading.x == heading.z and currHeading.z == -heading.x
  then
    turtle.turnRight()
  elseif currHeading.x == -heading.z and currHeading.z == heading.x
  then
    turtle.turnLeft()
  elseif currHeading.x == heading.x and currHeading.z == heading.z
    or heading.x == 0 and heading.y == 1 and heading.z == 0
  then
    
  else
    error("Invalid heading: "..heading:tostring())
  end
end

return m
