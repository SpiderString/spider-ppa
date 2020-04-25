--Second evaluation step
--splits a value up into tokens
local splits="[%+%-%*/!.\",()]" --@ and $ not included as these are strictly key ops

local lib={}

function lib.tokenize(str)
  local output={}
  local a=str:find(splits)
  local inString=false
  while a do
    local left = str:sub(1, a-1)
    local op = str:sub(a, a)
    --trim trailing spaces from tokens
    if not inString then
      left=left:gsub("[%s]$", "")
    end
    if op=="\"" then inString=not inString end
    if left and left~="" then
      table.insert(output, left)
    end
    table.insert(output, op)
    str = str:sub(a+1)
    --trim leading spaces
    if not inString then
      str = str:gsub("^[%s]", "")
    end
    a=str:find(splits)
  end
  if str and str~="" then
    table.insert(output, str)
  end
  return output
end
function lib.isContainer(line)
  if not line or type(line)~="table" then return false end
  return #line==2
end
function lib.getChildren(con, index)
  local output={}
  local line=con[index]
  local startDepth
  if not lib.isContainer(line) then return nil end
  index=index+1
  startDepth=con[index][1]
  while index<=#con do
    line=con[index]
    if line[1] < startDepth then break end
    if line[1] >= startDepth then
      table.insert(output, line)
    end
    index=index+1
  end
  return output, index-1
end

return lib
