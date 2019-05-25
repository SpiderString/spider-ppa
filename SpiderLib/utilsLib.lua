--returns a table of functions for various miscellenaous applications
--<arrows> denote optional arguments
--Current Functions:
--lib.cat(String:filePath)  --stores each line of a file to a table and returns it
--lib.getLines(String:filePath) --gets the number of lines in a file
--lib.split(String:str, String:delimeter) --breaks up a string into fields based on the regex and returns it as a table
--lib.search(Table:t, String:regex) --searches a table's values for matches and returns a table of matches

local lib={}
function lib.cat(filePath)
  local output={}
  if not filesystem.exists(filePath) then return nil end
  local file=filesystem.open(filePath, "r")
  while file:available()>0 do
    table.insert(output, file:readLine())
  end
  file:close()
  return output
end
function lib.getLines(filePath)
  local output=0
  if not filesystem.exists(filePath) then return 0 end
  local file=filesystem.open(filePath, "r")
  while file:available()>0 do
    output=output+1
  end
  file:close()
  return output
end
function lib.split(str, del)
  local output={}
  local index=1
  for word in str:gsub(del..del, del.." "..del):gmatch("[^"..del.."]+") do
    output[index]=word
    index=index+1
  end
  return output
end
function lib.search(t, reg)
  local output={}
  for key, value in pairs(t) do
    for match in value:gmatch(reg:gsub("%-", "%%-")) do
      table.insert(output, value)
    end
  end
  return output
end

return lib
