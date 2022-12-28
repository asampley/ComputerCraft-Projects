-- Just prints the name of the block in front of turtle
local found, block = turtle.inspect()

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
