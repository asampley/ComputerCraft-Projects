local paths = {
  "bin", "lib", "etc", "startup", "boot"
}

for _,f in ipairs(paths) do
  local diskPath = fs.combine("disk", f)
  if fs.exists(diskPath) then
    print("rm "..f)
    fs.delete(f)
    print("cp "..diskPath.." "..f)
    fs.copy(diskPath,f)
  end
end
