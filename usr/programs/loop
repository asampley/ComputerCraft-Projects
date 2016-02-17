-- loop program every x seconds
args = {...}

if #args < 2
then
  print("Usage: <period(in s)> <command>")
  return
end


period = tonumber(args[1])
command = args[2]

for i = 3,#args
do
  arguments = arguments .. args[i]
end

while true
do
  shell.run(command, arguments)
  sleep(period)
end
