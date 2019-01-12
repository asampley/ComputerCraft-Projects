args = {...}

if #args ~= 3
then
  print("Usage: <on time (s)> <off time (s)> <rs side>")
  return
end

local on = tonumber(args[1])
local off = tonumber(args[2])
local side = args[3]

while true
do
  rs.setOutput(side, true)
  sleep(on)
  rs.setOutput(side, false)
  sleep(off)
end  
