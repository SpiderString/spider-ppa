--CON Wrapper
--Wrappers are immutable
--Internal structure: Wrapper{functions, CON object}
--CON structure: Empty table with containers defined and pointing to sub-CONs
--each CON has a metatable which contains the data and interactions with it
--You can grab the CON object with wrapper.con and use it on its own safely
--functions
--wrapper:log() --emulates AM's log() but displays the CON data instead of the object
--wrapper:get(field::[String|Number]) --returns the value contained in a field. If the field is a CON object, returns a new wrapper around it.
--wrapper:set(field::[String|Number], <value>) --sets the value of a field. If value is not supplied, sets it to nil
--wrapper:fields() --returns an array of all valid field values
--wrapper:containers() --returns an array of all container names
--wrapper:children()  --alias of wrapper:containers()
--wrapper:properties() --returns an array of all properties(fields() that are not children())
--wrapper:load(fileName::String) --interprets a CON file and loads it into the wrapper
--wrapper:save(fileName::String) --TODO: UNIMPLEMENTED. Saves a CON object to a file
local wrapper={}
local parse = run("parse.lua").parse
local meta={}
meta.__newindex=function() log("Warning: Attempt to modify CON Wrapper") end
meta.__metatable="CONi Wrapper"
meta.__index=function(w, field) return w:get(field) end
meta.__newindex=function(w, field, val) w:set(field, val) end 

local function isCon(t)
  if not t or type(t)~="table" or getmetatable(t)~="CONi Object" then
    return false
  end
  return true
end

local function newWrapper(w, con)
  local new={}
  for f, val in pairs(w) do
    if f~="con" then new[f]=val end
  end
  new.con=con
  setmetatable(new, meta)
  return new
end

function wrapper.log(wrapper)
  local data=wrapper.con
  local tableColor="&e" --default &e
  local keyColor="&c" --default &c
  local valueColor="&b" --default &b
  local baseColor="&f"  --default &f
  log(tableColor..tostring(data).." "..baseColor.."{")
  local tabs=1
  --function doesn't print table header
  local function printTable(data)
    local function printValue(id, val)
      local string=string.rep("  ", tabs)..baseColor.."["
      --keys
      if type(id)=="number" then
        string=string..keyColor..id..baseColor.."] = "
      elseif type(id)=="string" then
        string=string..keyColor.."\""..id.."\""..baseColor.."] = "
      else
        error("Table key \""..id.."\" is neither of number or string type!")
      end
      --values
      if type(val)=="string" then
        string=string..baseColor.."\""..valueColor..val..baseColor.."\""
        log(string)
      elseif type(val)=="table" then
        string=string..tableColor..tostring(val).." "..baseColor.."{"
        local elements=0
        for i, j in pairs(val) do
          elements=elements+1
        end
        if elements==0 then
          string=string.."}"
          log(string)
        else
          log(string)
          tabs=tabs+1
          printTable(val)
        end
      else
        string=string..valueColor..tostring(val)
        log(string)
      end
    end --printValue() end
    for id, val in pairs(data) do
      printValue(id, val)
    end
    tabs=tabs-1
    log(string.rep("  ", tabs)..baseColor.."}")
  end --local function end
  printTable(data)
end
function wrapper.get(wrapper, field)
  if not wrapper.con then return nil end
  local v = wrapper.con[field]
  if isCon(v) then
    return newWrapper(wrapper, v)
  end
  return v
end
function wrapper.set(wrapper, field, val)
  if not wrapper.con then return end
  wrapper.con[field]=val
end
function wrapper.fields(wrapper)
  local fields={}
  if not wrapper.con then return fields end
  for f,_ in pairs(wrapper.con) do
    table.insert(fields, f)
  end
  return fields
end
function wrapper.containers(wrapper)
  local childs={}
  if not wrapper.con then return childs end
  for f, v in pairs(wrapper.con) do
    if isCon(v) then table.insert(childs, f) end
  end
  return childs
end
wrapper.children=wrapper.containers
function wrapper.properties(wrapper)
  local props={}
  if not wrapper.con then return props end
  for k, v in pairs(wrapper.con) do
    if not isCon(v) then table.insert(props, k) end
  end
  return props
end
function wrapper.load(wrapper, filePath)
  local con=parse(filePath)
  rawset(wrapper, "con", con)
end
function wrapper.save(wrapper, filePath)
  --TODO
end
setmetatable(wrapper, meta)
return wrapper
