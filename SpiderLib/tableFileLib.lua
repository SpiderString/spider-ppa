--returns a table of functions for writing, reading, and editing tables in files
--Current Functions:
--<arrows> denote optional arguments
--Generally, I keep to obj, filePath, tableID order unless it makes more sense in another order
--
--lib.write(Table:obj, String:filePath, <String:tableID>) --writes a table to the file, overwriting any previous data
--lib.append(Table:obj, String:filePath, <String:tableID>) --appends a table to the end of the file
--lib.read(String:filePath) --returns an entire file as a table
--lib.search(String:filePath, String:tableID) --searches for a given table in the file and returns it or "false" if not found
--lib.doesTableExist(String:filePath, String:tableID) --returns true/false if a given table is found
--lib.replace(String:tableID, Table:obj, String:filePath) --replaces a given table with another in the file
--lib.delete(String:filePath, String:tableID) --removes a given table from the file
--lib.rename(String:oldID, String:newID, String:filePath) --renames a table in the file, returns 0, 1, 2, 3 as status codes
--lib.copy(String:sourceID, String:destinationID, String:filePath) --produces a copy of the table. returns 0, 1, 2, 3 as status codes

--lib.doesObjExist(String:filePath, String:tableID) --alias for lib.doesTableExist()
--lib.insert(Table:obj, String:filePath, <String:tableID>) --alias for lib.append()
--lib.remove(String:filePath, String:tableID) --alias for lib.delete()
--
--basic format of a file is
--TableID{
--  "stringKey":"stringVal"
--  numKey:{
--    numKey:numVal
--    "stringKey":numVal
--  }
--}
--TableID is optional but is used to decide which table is which. If each table is an object, this could be its name
local lib={}
local function writeObj(obj, file, tableID)
  if tableID then
    file.write(tableID.."{\n")
  else
    file.write("{\n")
  end
  local tabs=1 --a "tab" technically is just two spaces in this format since that's what the in-game editor uses
  local function writeTable(table)
    for id, val in pairs(table) do
      --write key
      if type(id)=="string" then
        file.write(string.rep("  ", tabs).."\""..id.."\":")
      elseif type(id)=="number" then
        file.write(string.rep("  ", tabs)..id..":")
      end
      --write value
      if type(val)=="string" then
        file.write("\""..val.."\"\n")
      elseif type(val)=="number"  or type(val)=="boolean" then
        file.write(val.."\n")
      elseif type(val)=="table" then
        file.write("{\n")
        tabs=tabs+1
        writeTable(val)
      end
    end
    tabs=tabs-1
    file.write(string.rep("  ", tabs).."}\n")
  end
  writeTable(obj)
end
function lib.write(obj, filePath, tableID)
  if tableID and tableID~="" then
    tableID=tostring(tableID)
  else
    tableID=nil
  end
  local file=filesystem.open(filePath, "w")
  writeObj(obj, file, tableID)
  file:close()
end
function lib.append(obj, filePath, tableID)
  local tableID=tostring(tableID) or ""
  local file=filesystem.open(filePath, "a")
  writeObj(obj, file, tableID)
  file:close()
end

local function readTable(file)
  line=""
  local data={}
  local tableEnded=false
  while not tableEnded  do
    line=file.readLine()
    if line:match("[%s]*}") then tableEnded=true end
    local key
    local value
    --key matching
    --string key
    if line:match("\":") and line:match("[%s]+\"") then
      local a = line:find("\"")
      local b = line:find("\"", a+1)
      if a and b then
        key=line:sub(a+1, b-1)
      end
      --numerical key
    elseif line:match("[%d]+:") then
      local a=line:find("[%S]")
      local b=line:find(":", a+1)
      if a and b then
        key=tonumber(line:sub(a, b-1))
      end
    end
    --value matching
    --string value
    if line:match(":\"") then
      local a, b = line:find(":\"")
      local c = line:find("\"", b+1)
      if b and c then
        value=line:sub(b+1, c-1)
      elseif b then
        --fallback if mismatched quotations
        value=line:sub(b+1)
      end
    --numerical value
    elseif line:match(":%-[%d]+") or line:match(":[%d]+") then
      local a, b = line:find(":[%s]*")
      local c = line:find("[%s]", b+1)
      if b and c then
        value=tonumber(line:sub(b+1, c-1))
      elseif b then
        value=tonumber(line:sub(b+1))
      end
    elseif line:match(":true") or line:match(":false") then
      local a = line:find(":")
      local b = line:find(" ", a+1)
      if a and b then
        value=line:sub(a+1, b-1)
      else
        value=line:sub(a+1)
      end
      if value=="true" then value=true end
      if value=="false" then value=false end
    --table
    elseif line:match(":{") then
      value=readTable(file)
    end
    if key and value then
      data[key]=value
    end
  --while loop end
  end
  return data
  --function end
end

function lib.read(filePath)
  local file=filesystem.open(filePath, "r")
  local obj={}
  local tableID
  local doLoop=true
  while doLoop do
    local line=file.readLine()
    if file.available()==0 then doLoop=false end
    if line:match("[%S]+[%s]*{") then
      tableID=line:sub(1, line:find("{")-1):gsub("^[%s]+", ""):gsub("[%s]+$", "")
      obj[tableID]=readTable(file)
    elseif line:match("[%s]*{") then
      table.insert(obj, readTable(file))
    end
  end
  file:close()
  return obj
end
function lib.search(filePath, tableID)
  local file=filesystem.open(filePath, "r")
  local obj={}
  local foundTable=false
  local doLoop=true
  while not foundTable and doLoop do
    local line=file.readLine()
    if file.available()==0 then doLoop=false end
    if line:match("[%S]+[%s]*{") then
      if line:sub(1, line:find("{")-1):gsub("^[%s]+", ""):gsub("[%s]+$", "") == tableID then
        foundTable=true
        obj=readTable(file)
      end
    end
  end
  file:close()
  if foundTable then return obj else return false end
end
function lib.doesTableExist(filePath, tableID)
  local file=filesystem.open(filePath, "r")
  local foundTable=false
  local doLoop=true
  while not foundTable and doLoop do
    local line=file.readLine()
    if file.available()==0 then doLoop=false end
    if line:match("[%S]+[%s]*{") then
      if line:sub(1, line:find("{")-1):gsub("^[%s]+", ""):gsub("[%s]+$", "") == tableID then
        foundTable=true
      end
    end
  end
  file:close()
  return foundTable
end

local function writeFile(fileData, filePath)
  filesystem.open(filePath, "w"):close()
  for id, obj in pairs(fileData) do
    if type(id)=="string" then
      lib.append(obj, filePath, id)
    else
      lib.append(obj, filePath)
    end
  end
end
--could also technically be used as an "insert", though append works just as well and faster
function lib.replace(tableID, obj, filePath)
  local data=lib.read(filePath)
  data[tableID]=obj
  writeFile(data, filePath)
end
function lib.delete(filePath, tableID)
  local data=lib.read(filePath)
  data[tableID]=nil
  writeFile(data, filePath)
end
--renames a table/object and returns a status code
--0: successful; 1:new table ID already used, 2:old ID nonexistant 3:both 1 and 2
function lib.rename(oldID, newID, filePath)
  if lib.doesTableExist(filePath, oldID) and not lib.doesTableExist(filePath, newID) then
    local data=lib.read(filePath)
    data[newID]=data[oldID]
    data[oldID]=nil
    writeFile(data, filePath)
    return 0
  elseif lib.doesTableExist(filePath, oldID) and lib.doesTableExist(filePath, newID) then
    return 1
  elseif not lib.doesTableExist(filePath, oldID) and not lib.doesTableExist(filePath, newID) then
    return 2
  else
    return 3
  end
end
--produces a copy of the source table with the id "dest"
--status codes are identical to lib.rename()
function lib.copy(source, dest, filePath)
  if lib.doesTableExist(filePath, source) and not lib.doesTableExist(filePath, dest) then
    local data=lib.search(filePath, source)
    lib.append(data, filePath, dest)
    return 0
  elseif lib.doesTableExist(filePath, source) and lib.doesTableExist(filePath, dest) then
    return 1
  elseif not lib.doesTableExist(filePath, source) and not lib.doesTableExist(filePath, dest) then
    return 2
  else
    return 3
  end
end
--aliases
function lib.doesObjExist(filePath, tableID)
  return lib.doesTableExist(filePath, tableID)
end
function lib.insert(obj, filePath, tableID)
  lib.append(obj, filePath, tableID)
end
function lib.remove(filePath, tableID)
  lib.delete(filePath, tableID)
end

return lib
