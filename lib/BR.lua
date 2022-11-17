local m = {}

-- list of turbines
m.reactors = {}
m.turbines = {}

-- functions to act on all
m.allReactors = {}
m.allTurbines = {}

-- find and connect to all reactors
m.connectAllBigReactors = function()
  for _,name in pairs(peripheral.getNames())
  do
    if name:sub(1,11) == "BigReactors"
    then
      if name:sub(13,19) == "Reactor"
      then
        m.reactors[#m.reactors + 1] = peripheral.wrap(name)
      elseif name:sub(13,19) == "Turbine"
      then
        m.turbines[#m.turbines + 1] = peripheral.wrap(name)
      end

      print("Connected to " .. name)
    end
  end
end

-- helper, which returns a function which calls
-- a reactor function for all reactors
--
-- if the reactor function returns a result, then
-- a table containing the results is returned
--
-- The function returned has the same arguments as
-- the original reactor function, plus a combineFunc
-- f(...)
local function forEachGen(funcName, table)
  return function(...)
    local results = {}
    for _,item in pairs(table)
    do
      results[#results + 1] = item[funcName](...)
    end
    if #results > 0
    then
      return results
    end
  end
end

local function forEachReactorGen(funcName)
  return forEachGen(funcName, m.reactors)
end

local function forEachTurbineGen(funcName)
  return forEachGen(funcName, m.turbines)
end

-- create all functions that BigReactors has,
-- but so they iterate over all reactors/turbines
-- must load a reactor and turbine for successful
-- execution
m.loadAllFunctions = function()
  -- get all reactor functions
  -- add functions to the "reactor" api
  for fname, f in pairs(m.reactors[1])
  do
    if type(f) == "function"
    then
      m.allReactors[fname] = forEachReactorGen(fname)
    --  print("Loaded reactor function: " .. fname)
    end
  end

  for fname, f in pairs(m.turbines[1])
  do
    if type(f) == "function"
    then
      m.allTurbines[fname] = forEachTurbineGen(fname)
    --  print("Loaded turbine function: " .. fname)
    end
  end
end

-- call a function for all reactors
-- each function should be of the form
-- f(reactor, ...)
-- this can be used to provide checks
-- and operations on the reactor if they fail
-- the function, may also return a value, and
-- if this is the case, a table of results
-- will be returned
m.forEachReactor = function(f, ...)
  for _,reactor in pairs(m.reactors) do
    f(reactor, ...)
  end
end

-- same, for turbine
m.forEachTurbine = function(f, ...)
  for _,turbine in pairs(m.turbines) do
    f(turbine, ...)
  end
end

return m
