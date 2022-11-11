local inet = require("/lib/inet")

local m = {}

m.PROTOCOL = "ftp"

-- table for all send related functions
m.send = {}

--[[
  The following messages are defined
  
  Get request should return either a file or a dir
  {"get", path}
  {"nofile", path}
  {"file", path, file}
  {"dir", path, {{<"file" or "dir">, <file or {...}>}, ...}
  
  Put request should place a file on the server
  {"put", path, file}

  List request should return a "files" list of files
  {"list", path}
  {"files", path, list}
  {"nodir", path}
--]]
local function inetSend(remote, message)
  inet.send(remote, message, m.PROTOCOL)
end

m.send.get = function(remote, path)
  inetSend(remote, {"get", path})
end

m.send.list = function(remote, path)
  inetSend(remote, {"list", path})
end

m.send.put = function(remote, filePath, remotePath)
  local file = fs.open(filePath, "r")
  local fileContents = file.readAll()
  file.close()
  inetSend(remote, {"put", fileContents, remotePath})
end

m.send.nofile = function(remote, path)
  inetSend(remote, {"nofile", path})
end

m.send.file = function(remote, path, file)
  inetSend(remote, {"file", path, file})
end

m.send.dir = function(remote, path, dir)
  inetSend(remote, {"dir", path, dir})
end

m.send.files = function(remote, path, list)
  inetSend(remote, {"files", path, list})
end

m.send.nodir = function(remote, path)
  inetSend(remote, {"nodir", path})
end

return m
