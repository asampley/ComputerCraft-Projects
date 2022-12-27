-- Just prints the name of the block in front of turtle
local found, block = turtle.inspect()

print("tags:")
for t, v in pairs(block.tags) do
    print(t)
end
print("name: "..block.name)
