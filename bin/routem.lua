local success, config = pcall(require, "/etc/routem")

if not success then
  error("Unable to run config")
end

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
      for slot, item in pairs(peripheral.call(pull, "list")) do
        local push = config.push[item.name] or config.push.default

        if push then
          if not peripheral.hasType(push, "inventory") then
            print("No inventory named \"" .. push .. "\"")
          else
            peripheral.call(pull, "pushItems", push, slot)

            print("Pushed " .. item.count .. " " .. item.name .. " to " .. push)
          end
        end
      end
    end
  end

  os.sleep(config.sleep)
end
