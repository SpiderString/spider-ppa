local lib={}

function lib.cat(file)
  local output={}
  local file = filesystem.open(file, "r")
  while file:available()>0 do
    table.insert(output, file:readLine())
  end
  file.close()
  return output
end

function lib.write(data, file)
  local file = filesystem.open(file, "w")
  for _, line in ipairs(data) do
    file.writeLine(line)
  end
  file.close()
end

return lib
