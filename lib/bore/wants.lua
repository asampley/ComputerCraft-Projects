
local blocks = require("/lib/blocks")
local config = require("/lib/config")
local wants = config.load("bore/wants")

local name, tag, mtag = blocks.filter.name, blocks.filter.tag, blocks.filter.mtag

local profileRules = nil

local m = {}

-- Used to choose a profile from /etc/bore/wants.lua
-- if profileName == nil, uses a defaultProfile if it exists, else a random profile
m.setProfile = function (profileName)
  if not profileName then
    if wants["defaultProfile"] then
      profileName = "defaultProfile"
    else
      -- if defaultProfile DNE, try a random profile
      for k, v in pairs(wants) do
        profileName = k
        print('Warning: No "defaultProfile", using wants profile: "'..profileName..'"')
        break
      end
      if not profileName then
        error("No wants profiles found")
      end
    end
  end
  profileRules = wants[profileName]
  if not profileRules or type(profileRules) ~= "table" then
    error('Warning: No wants profile found for "'..profileName..'"')
  end
end

-- Returns true or false if the block is wanted
m.wants = function(block)
  -- Check cache first (or by name rules)
  local want = profileRules[block.name]
  if want ~= nil then return want end

  -- Else, check the rules
  if want == nil then want = blocks.map(block, profileRules) end
  if want == nil then want = profileRules.default end

  -- Add to the cache
  profileRules[block.name] = want
  return want
end

-- Try to set a default profile
wants.setProfile()

return m
