local inet = require("/lib/inet")

-- ping a host
local args = { ... }

if #args ~= 1 then
  error("Usage: ping <remoteid>")
end

local remote = tonumber(args[1])

inet.send(remote, "?", "ping")
while true do
  local sender, message = inet.receive("ping")
  if sender == remote and message == "!" then
    print("Recieved ping back from " .. remote)
    break
  end
end
