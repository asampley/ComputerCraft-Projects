local paths = {
  "bin", "lib", "etc", "startup", "boot"
}

for _,f in ipairs(paths) do
  local diskPath = fs.combine("disk", f)
  if fs.exists(f) then
    print("rm "..diskPath)
    fs.delete(diskPath)
    print("cp "..f.." "..diskPath)
    fs.copy(f, diskPath)
  end
end
