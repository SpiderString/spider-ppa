local lib={}
local utils=run("utilsLib.lua")
local tfl=run("tableFileLib.lua")

function lib.getRoute(routeReg, line)
  local route={}
  local foundRoute=false
  while line <= #routeReg and not foundRoute do
    if routeReg[line]:match("{") then
      local name=routeReg[line]:match("^[^{]*")
      line=line+1
      route.name=name
      local path={}
      local pathId=1
      while not routeReg[line]:match("^%}$") do
        local entry=routeReg[line]:gsub("^[%s]*", "")
        local a=entry:find("[%a]")
        entry=entry:sub(a)
        entry=entry:gsub("}", "")
        local fields=utils.split(entry, ";")
        fields.length=nil
        path[pathId]={}
        for id, field in pairs(fields) do
          local key=utils.split(field, ":")[1]
          local value=utils.split(field, ":")[2]
          path[pathId][key]=value
        end
        line=line+1
        pathId=pathId+1
      end
      route.path=path
      foundRoute=true
    else
      line=line+1
    end
  end
  return route, line
end

function lib.doesRouteExist(routeRegPath, routeName)
  return tfl.doesTableExist(routeRegPath, routeName)
end

function lib.doesPointExist(currentRoute, x, y, z)
  local points=currentRoute.path
  local doesExist=false
  if points~= nil then
    for id, point in pairs(points) do
      if x==point.x and y==point.y and z==point.z then
        doesExist=true
      end
    end
  end
  return doesExist
end

function lib.logRoute(routeRegPath, currentRoute, suppressLog)
  tfl.append(currentRoute, routeRegPath, currentRoute.name)
  if not suppressLog then
    log("Finished tracing "..currentRoute.name)
    log("Successfully traced "..tostring(#currentRoute.path).." blocks")
  end
end

return lib
