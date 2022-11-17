-- loop program every x seconds
local args = { ... }

if #args < 2
then
  print("Usage: <period(in s)> <command>")
  return
end


local period = tonumber(args[1])
local command = args[2]

while true do
  shell.run(command, table.unpack(args, 3))
  sleep(period)
end
