local blocks = require("/lib/blocks")

local name, tag, mtag = blocks.filter.name, blocks.filter.tag, blocks.filter.mtag

return {
  defaultProfile = {
    default = true,

    -- bedrock is always unmineable
    {false, name, "minecraft:bedrock"},

    -- liquids can't be mined
    {false, name, "minecraft:water"},
    {false, name, "minecraft:lava"},
    {false, name, "minecraft:flowing_water"},
    {false, name, "minecraft:flowing_lava"},

    -- don't mine inventories
    {false, name, "minecraft:.*chest"},
    {false, name, "minecraft:.*barrel"},
    {false, name, "minecraft:furnace"},

    -- trees
    {false, tag, "minecraft:logs"},
    {false, tag, "minecraft:leaves"},

    -- common wood structures
    {false, tag, "minecraft:planks"},
    {false, tag, "minecraft:fences"},
    {false, tag, "minecraft:fence_gates"},
    {false, tag, "minecraft:signs"},

    -- common stone structures
    {false, mtag, "minecraft:.*bricks"},
    {false, name, "mineacraft:.*bricks"},
    {false, tag, "mineacraft:walls"},
    {false, name, "minecraft:cobbled_.*"},

    -- common dirt structures
    {false, name, "minecraft:farmland"},
    {false, name, "minecraft:dirt_path"},

    -- sub-blocks
    {false, tag, "minecraft:stairs"},
    {false, tag, "minecraft:slabs"},

    -- common overworld
    {false, tag, "minecraft:base_stone_overworld"}, -- stone, granite, tuff, deepslate, etc
    {false, name, "minecraft:cobblestone"}, -- required for inventory checks
    {false, tag, "minecraft:dirt"},
    {false, name, "minecraft:gravel"},
    {false, tag, "minecraft:sand"},
    {false, name, "minecraft:.*sandstone"},

    -- common nether
    {false, name, "minecraft:netherrack"},
    {false, name, "minecraft:basalt"},
  },
}
