local inet = require("/lib/inet")

while true do
  local sender, message, _ = inet.receive("ping")
  if message == "?" then
    print("Replying to ping from " .. sender)
    inet.send(sender, "!", "ping")
  end
end
