local args={...} --should be bound to ChatSendFilter
local commandPrefix="!rt"
local routeRegDir="~/common"
local routeRegPath=routeRegDir.."/routeRegistry"
if not filesystem.exists(routeRegDir) then filesystem.mkDir(routeRegDir) end
if not filesystem.exists(routeRegPath) then filesystem.open(routeRegPath, "w"):close() end

local routeReg
local blockTex="block:minecraft:blocks/glass_lime"
local xray=true
local rtLib=run("railTracerLib.lua")

local tfl=run("tableFileLib.lua")

--Rounds a number to a digits number of decimals
local function roundDig(num, digits)
  return math.floor(num*math.pow(10, digits))/math.pow(10,digits)
end

local function getRoutes()
  return tfl.read(routeRegPath)
end

local function getNames(routes)
  local names={}
  for id, route in pairs(routes) do
    table.insert(names, route.name)
  end
  return names
end

local function findRoute(routes, name)
  local output=nil
  for id, route in pairs(routes) do
    if route["name"]==name then
      output=route
    end
  end
  return output
end
local function signum(num)
  if num==0 then return 0 end
  return math.abs(num)/num
end
local function getDistance(route)
  local distance=0
  local oldX, oldZ
  for id, point in pairs(route.path) do
    if not (point.x==oldX and point.z==oldZ) then
      if not oldX or not oldZ then
        oldX=point.x
        oldZ=point.z
      end
      while oldX~=point.x and oldZ~=point.z do
        oldX=oldX+signum(point.x-oldX)
        oldZ=oldZ+signum(point.z-oldZ)
        distance=distance+1
      end
        --additional distance should now be an integer
        distance=distance+math.sqrt(math.pow(point.x-oldX, 2)+math.pow(point.z-oldZ, 2))
      oldX=point.x
      oldZ=point.z
    end
  end
  return distance
end

local function drawBlock(x, y, z)
  local block=hud3D.newBlock()
  block.setPos(x, y, z)
  block.xray(xray)
  block.changeTexture(blockTex)
  block.enableDraw()
end

local function drawRoute(route)
  local path=route["path"]
  for id, point in pairs(path) do
    drawBlock(point.x, point.y, point.z)
  end
end

local function deleteRoute(routes, routeName)
  for id, currentRoute in pairs(routes) do
    if currentRoute.name==routeName then
      routes[id]=nil
    end
  end
  local newRouteReg=filesystem.open(routeRegPath, "w")
  newRouteReg:close()
  for id, currentRoute in pairs(routes) do
    rtLib.logRoute(routeRegPath, currentRoute, true)
  end
end

local function parseCommands(chatLine)
  local cli=run("commandLib.lua")
  local utils=run("utilsLib.lua")
  local commandArgs
  local command
  commandArgs=cli.getArguments(chatLine, commandPrefix)
  if not commandArgs then return chatLine end
  command=commandArgs[1]
  table.remove(commandArgs, 1)
  --Begin command Matching
  --lists info on a route
  if command=="list" then
    routeReg=utils.cat(routeRegPath)

    local routes=getRoutes()
    local names=getNames(routes)
    table.sort(names)
    local routeChoice=prompt("Pick a Route", "choice", table.unpack(names))
    if routeChoice~=nil then
      local route=findRoute(routes, routeChoice)
      local distanceErr=0.0670 --Heuristic from data
      local distance=getDistance(route)
      log(routeChoice)
      log("Blocks Registered: "..#routes[routeChoice].path)
      log("Estimated Length: "..distance.."±"..math.ceil(distanceErr*distance))
    end
  --draws a line of holoblocks
  elseif command=="trace" then
    routeReg=utils.cat(routeRegPath)

    local routes=getRoutes()
    if commandArgs[1]==nil then
      local names=getNames(routes)
      table.sort(names)
      local routeChoice=prompt("Pick a Route", "choice", table.unpack(names))
      if routeChoice~=nil then
        local route=findRoute(routes, routeChoice)
        drawRoute(route)
      end
    else
      local route=findRoute(routes, commandArgs[1])
      if route==nil then
        log("No route exists with the name '"..commandArgs[1].."'")
      else
        drawRoute(route)
      end
    end
  elseif command=="clear" then
    hud3D.clearAll()
  elseif command=="delete" then
    routeReg=utils.cat(routeRegPath)

    local routes=getRoutes()
    if commandArgs[1]~=nil then
      local route=findRoute(routes, commandArgs[1])
      if route==nil then
        log("No route exists with the name '"..commandArgs[1].."'")
      else
        deleteRoute(routes, commandArgs[1])
      end
    else
      local names=getNames(routes)
      table.sort(names)
      local routeChoice=prompt("Pick a Route", "choice", table.unpack(names))
      if routeChoice~=nil then
        local confirm=prompt("Are you sure you want to delete "..routeChoice.."?", "choice", "Yes", "No")
        if confirm=="Yes" then
          deleteRoute(routes, routeChoice)
        end
      end
    end
  elseif command=="record" then
    run("railTracerMain.lua")
  end
  --end command matching
end
if args[2]=="ChatSendFilter" then
  local output=parseCommands(args[3])
  return output
end
