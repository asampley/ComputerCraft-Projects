local inet = require("/lib/inet")
local ftp = require("/lib/inet/ftp")

-- table for all receive related functions
local recv = {}

recv.any = function (sender, message)
  local type = message.type

  if recv[type] then
    recv[type](sender, message)
  else
    print("No server receive for "..type)
  end
end

recv.get = function(sender, message)
  local path = message.path
  if not fs.exists(path) then
    ftp.send.nofile(sender, path)
  else
    if fs.isDir(path) then
      local dir = packDir(path)
      ftp.send.dir(sender, path, dir)
    else
      local file = fs.open(path, "r")
      local fileContents = file.readAll()
      file.close()
      ftp.send.file(sender, path, fileContents)
    end
  end
end

recv.put = function(sender, message)
  local path = message.path
  local contents = message.contents
  if fs.exists(path) then
    error("File already exists: "..path)
  else
    local file = fs.open(path, "w")
    file.write(contents)
    file.close()
  end
end

recv.list = function(sender, message)
  local path = message.path
  if fs.isDir(path) then
    local files = fs.list(path)
    ftp.send.files(sender, path, files)
  else
    ftp.send.nodir(sender, path, nil)
  end
end


--[[ returns a packet friendly directory
  in the form of a list, of directories and files
  within each inner directory is similarly packed
]]
function packDir(path)
  fs.list(path)
end

while true do
  local sender, message = inet.receive(ftp.PROTOCOL)
  recv.any(sender, message)
end  
