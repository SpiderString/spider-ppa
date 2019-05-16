--returns a table of functions fo manipulating player position and rotation, i.e. bot functions
--<arrows> denote optional arguments
--Current Functions:
--lib.moveDistance(Number:blocks, String:direction, <Boolean:crouch>, <Boolean:debug>)  --moves the player a number of blocks "forward", "back", "left", or "right".
--lib.lookRel(Number:u, Number:v, Number:w) --faces the player <u, v, w> blocks in relation to them. +w is upwards, +u is forward, +v is rightward.
--lib.lookDir(String:direction) --Orients the player in a given cardinal direction


local lib={}
--Moves the player by a float number of blocks, dependent on original orientation, can handle angles.
--Returns the error, positive error means you went further than necessary. Error seems to be within 0-0.05m
--moveDistance(float:blocks, String:[forward|left|right|back], <Boolean:debug>)
function lib.moveDistance(blocks, dir, doCrouch, debug)
  if debug == nil then debug=false end
  if doCrouch == nil then doCrouch=true end
  local yawAddend=0
  if dir == "left" then
    yawAddend=-90
  elseif dir == "right" then
    yawAddend=90
  elseif dir == "back" then
    yawAddend=180
  else
    yawAddend=0
  end
  local x, y, z = getPlayerPos()
  local player = getPlayer() --south=+z, west=-x, north=-z, east=+x
  local yaw = player.yaw --0=south, 90=west, 180=North, -90=East
  local pitch = player.pitch

  --blocks+1 gives a target 1 block's distance from the actual
  --target, so if distance < 1 you can stop. workaround for rare bugs.
  local targetX=x - (blocks+1) * math.sin((yaw+yawAddend) * math.pi / 180)
  local targetZ=z + (blocks+1) * math.cos((yaw+yawAddend) * math.pi / 180)
  if debug then
    log("Target: ("..targetX..","..targetZ..")")
    log("Position: ("..x..","..z..")")
  end
  local distance = math.sqrt(math.pow(targetX-x, 2) + math.pow(targetZ-z, 2))
  while distance > 1 do
    x, y, z = getPlayerPos()
    distance = math.sqrt(math.pow(targetX-x, 2) + math.pow(targetZ-z, 2))
    if debug then
      log("Distance From Target: "..distance)
    end
    --There seems to be a bug in which after running a certain number of times,
    --it will stop and start and lag significantly if look(yaw, pitch) isn't commented out
    --look(yaw, pitch)
    if distance < 2 and doCrouch then
      sneak(-1)
    end
    local moveTime = 1
    if dir == "left" then
        left(moveTime)
    elseif dir == "right" then
        right(moveTime)
    elseif dir == "back" then
        back(moveTime)
    else
        forward(moveTime)
    end
  end
  sneak(100)
  sneak(0)
  --returns error amount
  x,y,z = getPlayerPos()
  distance=math.sqrt(math.pow(targetX-x, 2) + math.pow(targetZ-z, 2))
  return 1-distance
end
--Looks at a block relative to facing
function lib.lookRel(u, v, w)
  --+u, +v, +w correspond to forward, right, and up respectively
  --w axis is always perpendicular to the horizon
  --so w is only perpendicular to the uv plane when pitch = 0
  --if u and v are 0, makes you look up if w>0, look down if w<=0
  --For reference, 1.62 is the eye position of your player
  w=w+1.62

  local yaw = getPlayer().yaw
  local pitch = getPlayer().pitch

  local x, y, z = getPlayerPos()
  local r = math.sqrt(math.pow(u, 2)+math.pow(v, 2))
  local yawAddend
  --Quadrant I
  if u >= 0 and v >= 0 then
    yawAddend = math.acos(u/r)
  --Quadrant II
  elseif u >= 0 and v < 0 then
    yawAddend = -math.acos(u/r)
  --Quadrant III
  elseif u < 0 and v < 0 then
    yawAddend = -math.acos(u/r)
  --Quadrant IV
  elseif u < 0 and v >= 0 then
    yawAddend = math.pi/2 - math.asin(u/r)
  end

  local targetYaw = ((yaw*math.pi/180) + yawAddend)
  --log(targetYaw*180/math.pi%360)
  local targetX = x - r*math.sin(targetYaw)
  local targetY = y + w
  local targetZ = z + r*math.cos(targetYaw)

  if r==0 then
    targetX=x
    targetZ=z
  end

  lookAt(targetX, targetY, targetZ)
end
--Looks in a given cardinal direction
function lib.lookDir(dir)
  local pitch = getPlayer().pitch
  if dir == "South" or dir == "south" then
    look(0, pitch)
  elseif dir == "West" or dir == "west" then
    look(90, pitch)
  elseif dir == "East" or dir == "east" then
    look(-90, pitch)
  else look(180, pitch)
  end
end

return lib
