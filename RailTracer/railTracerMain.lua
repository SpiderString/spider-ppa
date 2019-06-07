if RAILTRACKERRUNNING==nil then RAILTRACKERRUNNING=false end
RAILTRACKERRUNNING=not RAILTRACKERRUNNING
if RAILTRACKERRUNNING then log("Rail Tracer running") end
local routeRegDir="~/common"
local routeRegPath=routeRegDir.."/routeRegistry"
if not filesystem.exists(routeRegDir) then filesystem.mkDir(routeRegDir) end
if not filesystem.exists(routeRegPath) then filesystem.open(routeRegPath, "w"):close() end
local routeReg=catRel(routeRegPath, true)
local rtLib=run("railTracerLib.lua")
--Example route entry
--name{
--	{x:-404;y:55;z:1591}
--	{x:-404;y:55;z:1590}
--	{x:-404;y:55;z:1589}
--	{x:-404;y:55;z:1588}
--	{x:-405;y:55;z:1590}
--	{x:-406;y:55;z:1590}
--}

local recordingRoute=false
local currentRoute={}

local railIds={
  "minecraft:golden_rail",
  "minecraft:activator_rail",
  "minecraft:rail",
  "minecraft:detector_rail"
}
local function isRail(str)
  for key, id in pairs(railIds) do
    if str==id then
      return true
    end
  end
  return false
end
local function isOnRail()
  local isOnGround=getPlayer().onGround
  local x, y, z=getPlayerBlockPos()
  local underBlock=getBlock(x, y, z)
  local block=getBlock(x, y+1, z)
  if not isOnGround and (isRail(block.id) or isRail(underBlock.id)) then
    return true
  else
    return false
  end
end

local function tracePath()
  local x, y, z = getPlayerBlockPos()
  if isRail(getBlock(x, y+1, z).id) then
    y=y+1
  end
  if not rtLib.doesPointExist(currentRoute, x, y, z) then
    if currentRoute.path==nil then currentRoute.path={} end
    table.insert(currentRoute.path, {x=x, y=y, z=z})
  end
end

while RAILTRACKERRUNNING do
  if isOnRail() and not recordingRoute then
    local routeName
    while routeName==nil or rtLib.doesRouteExist(routeRegPath, routeName) do
      routeName=prompt("Enter a name for the route.", "text")
    end
    currentRoute.name=routeName
    recordingRoute=true
  end
  if recordingRoute and isOnRail() then
    tracePath()
  end
  if not isOnRail() and recordingRoute then
    recordingRoute=false
    rtLib.logRoute(routeRegPath, currentRoute)
    RAILTRACKERRUNNING=false
  end
end
