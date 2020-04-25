--library of operator implementations
local lib={}

function lib.add(l, r)
  if not l or not r then return nil end
  if type(l)=="function" and type(r)=="function" then
    return function() return lib.add(l(), r()) end
  elseif type(l)=="function" then
    return function() return lib.add(tonumber(r), l()) end
  else
    return tonumber(l)+tonumber(r)
  end
end

function lib.sub(l, r)
  if not l then return lib.sub(0, r) end
  if not r then return nil end
  if type(l)=="function" and type(r)=="function" then
    return function() return lib.sub(l(), r()) end
  elseif type(r)=="function" then
    return function() return lib.sub(tonumber(l), r()) end
  elseif type(l)=="function" then
    return function() return lib.sub(l(), tonumber(r)) end
  else
    return tonumber(l)-tonumber(r)
  end
end

function lib.mult(l, r)
  if not l or not r then return nil end
  if type(l)=="function" and type(r)=="function" then
    return function() return lib.mult(l(), r()) end
  elseif type(l)=="function" then
    return function() return lib.mult(tonumber(r), l()) end
  else
    return tonumber(l)*tonumber(r)
  end
end

function lib.div(l, r)
  if not l or not r or r==0 then return nil end
  if type(l)=="function" and type(r)=="function" then
    return function() return lib.div(l(), r()) end
  elseif type(r)=="function" then
    return function() return lib.div(tonumber(l), r()) end
  elseif type(l)=="function" then
    return function() return lib.div(l(), tonumber(r)) end
  else
    return tonumber(l)/tonumber(r)
  end
end

function lib.str(l, r)
  if not l then l="" end
  if not r then r="" end
  --if not l then return lib.str("", r) end
  --if not r then return lib.str(l, "") end
  if type(l)=="function" and type(r)=="function" then
    return function() return lib.str(l(), r()) end
  elseif type(r)=="function" then
    return function() return lib.str(l, r()) end
  elseif type(l)=="function" then
    return function() return lib.str(l(), r) end
  else
    return tostring(l)..tostring(r)
  end
end
--references a field in a CON object or returns nil if not found
function lib.getField(con, path)
  --example: "/bg/type" "/" - root, "bg" -prop bg in root, etc
  --all original paths are absolute(in that exact format)
  if not path or type(path)~="string" then return nil end
  local t=con
  local slash
  local field
  local output
  if path=="/" then return con end
  path=path:sub(2)
  slash=path:find("/") or #path+1
  field=path:sub(1, slash-1)
  if not field then return nil end
  if slash<#path then
    if not con[field] then return nil end
    return lib.getField(con[field], path:sub(slash))
  end
  return con[field]
end
return lib
