local bore = require("/lib/bore")

local args = {...}

if #args ~= 3 then
  print("Usage: cleave <+/-depth> <+/-forward> <+/-right>")
  return
end

local depth = tonumber(args[1])
local forward = tonumber(args[2])
local right = tonumber(args[3])

if not depth or depth < 1 then error("Depth must 1 or greater") end
if not forward then error("forward must be an integer") end
if not right then error("right must be an integer") end

bore.cleave(depth, forward, right)
