if not turtle then error("Missing turtle library") end

local m = {}

-- track location globally
if not _G.location then
  _G.location = {
    position = vector.new(0, 0, 0),
    heading = vector.new(1, 0, 0),
  }

  -- save old turtle functions
  local _turtle = {}
  _turtle.forward = turtle.forward
  _turtle.up = turtle.up
  _turtle.down = turtle.down
  _turtle.back = turtle.back
  _turtle.turnLeft = turtle.turnLeft
  _turtle.turnRight = turtle.turnRight

  -- new forward function
  local function forward()
    local success = _turtle.forward()
    if success then
      _G.location.position = _G.location.position + _G.location.heading
    end
    return success
  end

  -- new up function
  local function up()
    local success = _turtle.up()
    if success
    then
      _G.location.position = _G.location.position + m.Y()
    end
    return success
  end

  -- new down function
  local function down()
    local success = _turtle.down()
    if success then
      _G.location.position = _G.location.position - m.Y()
    end
    return success
  end

  local function back()
    local success = _turtle.back()
    if success then
      _G.location.position = _G.location.position - _G.location.heading
    end
    return success
  end

  -- new turn left function
  local function turnLeft()
    local success = _turtle.turnLeft()
    if success then
      local newX = _G.location.heading.z
      local newZ = -_G.location.heading.x
      _G.location.heading.x = newX
      _G.location.heading.z = newZ
    end
    return success
  end

  -- new turn right function
  local function turnRight()
    local success = _turtle.turnRight()
    if success then
      local newX = -_G.location.heading.z
      local newZ = _G.location.heading.x
      _G.location.heading.x = newX
      _G.location.heading.z = newZ
    end
    return success
  end

  -- override turtle functions
  _G.turtle.forward = forward
  _G.turtle.up = up
  _G.turtle.down = down
  _G.turtle.back = back
  _G.turtle.turnLeft = turnLeft
  _G.turtle.turnRight = turnRight
end

-- public constants for headings (unit vectors for each axis)
m.X = function() return vector.new(1, 0, 0) end
m.Y = function() return vector.new(0, 1, 0) end
m.Z = function() return vector.new(0, 0, 1) end
m["-X"] = function() return vector.new(-1, 0, 0) end
m["-Y"] = function() return vector.new(0, -1, 0) end
m["-Z"] = function() return vector.new(0, 0, -1) end

-- helper functions to rotate headings
m.turnLeft = function(heading)
  local new = vector.new(0, 0, 0) + heading
  new.x = heading.z
  new.z = -heading.x
  return new
end

m.turnRight = function(heading)
  local new = vector.new(0, 0, 0) + heading
  new.x = -heading.z
  new.z = heading.x
  return new
end
-- return copy of position vector
m.getPos = function()
  return vector.new(0, 0, 0) + _G.location.position
end

-- return copy of heading vector
m.getHeading = function()
  return vector.new(0, 0, 0) + _G.location.heading
end

return m
