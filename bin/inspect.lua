
local args = {...}

if #args > 1 then
  print("Usage: inspect [<direction>]")
  return
end

local direction = args[1]
if direction ~= "" and direction ~= "Up" and direction ~= "Down" then
  print('direction must be "" (forward), "Up", or "Down"')
  return
end

-- Just prints the name of the block in front of turtle
local found, block = turtle["inspect"..direction]()
print("found:")
print(found)
if not found then
  print(block)
  return
end

print("tags:")
local a = 1
for t, v in pairs(block.tags) do
    if a < 9 then
        print(t)
    end
    if a == 10 then
        print("...")
    end
    a = a + 1
end
print("name: "..block.name)
