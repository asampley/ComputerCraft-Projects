local location = require("/lib/location")

local m = {}

-- move the turtle to the position
local function _to(position, upFunc, downFunc, forwardFunc, backFunc, digUpFunc, digDownFunc, digFunc, orderOfMoves)
  local moveOrder = orderOfMoves or "xzy"
  local currPosition = location.getPos()
  local path = position - currPosition

  -- move in each axis, xyz
  for i = 1, 3 do
    local move = moveOrder:sub(i, i):lower()

    if path[move] ~= 0 then
      if move == "x" or move == "z" then
        local forward = location[move:upper()]()
        if path[move] < 0 then
          forward = -forward
        end

        local heading = location.getHeading()
        local back = heading[move] == -forward[move]

        if not heading[move] == forward[move] or not back then
          m.turnTo(forward)
        end

        while path[move] ~= 0 do
          if back then
            if backFunc() then
              path[move] = path[move] - forward[move]
            else
              m.turnTo(forward)
              back = false
            end
          else
            if forwardFunc() then
              path[move] = path[move] - forward[move]
            else
              digFunc()
            end
          end
        end
      else
        if path.y < 0
        then
          for _ = 1, -(path.y) do
            while not downFunc() do
              if digDownFunc then digDownFunc() end
            end
          end
        else
          for _ = 1, path.y do
            while not upFunc() do
              if digUpFunc then digUpFunc() end
            end
          end
        end
      end
    end
  end
end

-- go to
m.goTo = function(position, moveOrder)
  _to(position, turtle.up, turtle.down, turtle.forward, turtle.back, nil, nil, nil, moveOrder)
end

-- dig to
m.digTo = function(position, moveOrder)
  _to(position, turtle.up, turtle.down, turtle.forward, turtle.back, turtle.digUp, turtle.digDown, turtle.dig, moveOrder)
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
    error("Invalid heading: " .. heading:tostring())
  end
end

return m
