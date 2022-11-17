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
  inetSend(remote, { type = "get", path = path })
end

m.send.list = function(remote, path)
  inetSend(remote, { type = "list", path = path })
end

m.send.put = function(remote, filePath, remotePath)
  local file = fs.open(filePath, "r")
  local fileContents = file.readAll()
  file.close()
  inetSend(remote, { type = "put", contents = fileContents, path = remotePath })
end

m.send.nofile = function(remote, path)
  inetSend(remote, { type = "nofile", path = path })
end

m.send.file = function(remote, path, file)
  inetSend(remote, { type = "file", path = path, contents = file })
end

m.send.dir = function(remote, path, dir)
  inetSend(remote, { type = "dir", path = path, dir = dir })
end

m.send.files = function(remote, path, list)
  inetSend(remote, { type = "files", path = path, list = list })
end

m.send.nodir = function(remote, path)
  inetSend(remote, { type = "nodir", path = path })
end

return m
