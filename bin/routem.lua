local config = require("/lib/config").load("routem")

if not config.pull then
  error("No \"pull\" element in config")
end

if not config.push then
  error("No \"push\" element in config")
end

if not config.sleep then
  error("No sleep period specified")
end

while true do
  for _, pull in ipairs(config.pull) do
    if not peripheral.hasType(pull, "inventory") then
      print("No inventory named \"" .. pull .. "\"")
    else
      local ppull = peripheral.wrap(pull);

      for slot, item in pairs(ppull.list()) do
        local toPush = item.count

        for _, push in ipairs(config.push[item.name] or config.push.default) do
          if push then
            if not peripheral.hasType(push, "inventory") then
              print("No inventory named \"" .. push .. "\"")
            else
              local pushed = ppull.pushItems(push, slot)

              print(pushed .. " " .. item.name .. " from " .. pull .. " to " .. push)

              toPush = toPush - pushed

              if toPush == 0 then break end
            end
          end
        end
      end
    end
  end

  sleep(config.sleep)
end
