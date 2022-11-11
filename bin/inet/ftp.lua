local inet = require("/lib/inet")
local ftp = require("/lib/inet/ftp")

-- copy file to here from another host
local args = {...}

if
  not (#args == 3 and args[1] == "list")
  and not (#args == 4 and args[1] == "get")
  and not (#args == 4 and args[1] == "put")
then
  print("Usage: get <remote> <remotePath> <localPath>")
  print("Usage: list <remote> <remotePath>")
  print("Usage: put <remote> <localPath> <remotePath>")
  return
end

local operation = args[1]
local remote = tonumber(args[2])
local filePath = args[3]
local savePath = nil
local remotePath = nil
if operation == "get"
then
  savePath = args[4]
elseif operation == "put"
then
  remotePath = args[4]
end

if operation == "get" then
  ftp.send.get(remote, filePath)
elseif operation == "list" then
  ftp.send.list(remote, filePath)
elseif operation == "put" then
  ftp.send.put(remote, filePath, remotePath)
end

while operation == "get" or operation == "list" do
  local sender, message, proto = inet.receive()
   
  if sender == remote and proto == ftp.PROTOCOL
  then
    if operation == "get" then
      if message[1] == "file" then
        local path = message[2]
        local contents = message[3]
        if path == filePath then 
          if not fs.exists(savePath) then
            print("Writing file to " .. savePath)
            local file = fs.open(savePath, "w")
            file.write(contents)
            file.close()
            print("done")
          else
            error("File \"" .. savePath 
              .. "\" already exists"
            )
          end
          break
        end
      elseif message[1] == "nofile" then
        local path = message[2]
        if path == filePath then
          error("No file "..path)
          break
        end
      elseif message[1] == "dir" then
        error("Getting directories is incomplete")
        break
      end
    elseif operation == "list" then
      if message[1] == "files" then
        local path = message[2]
        local list = message[3]
        
        if path == filePath then
          for _,file in pairs(list) do
            print(file)
          end
          break
        end
      elseif message[1] == "nodir" then
        local path = message[2]
        if path == filePath then
          error("No directory "..path)
          break
        end
      end
    end
  end
end
