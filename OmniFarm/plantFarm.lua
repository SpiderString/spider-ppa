--script which handles planting a farm
--should be run with one argument as the farm's data
local args={...}
local farm=args[1]
local tfl=run("tableFileLib.lua")
local inv=run("inventoryLib.lua")
local move=run("movementLib.lua")
local settings=tfl.read("~/common/OmniFarm.cfg")[1]

log(settings.ofColor.."<OmniFarm>: Planting farm '"..farm.name.."'...")
local function sortBlocks()
  --sorts blocks by y level, then z strip, then x coordinate
  local blocks={}
  for id, block in pairs(farm.blocks) do
    if blocks[block.y]==nil then blocks[block.y]={} end
    if blocks[block.y][block.z]==nil then blocks[block.y][block.z]={} end
    blocks[block.y][block.z][block.x]=block
  end
  return blocks
end
local function getHoe()
  --selects highest priority hoe
  local hoes={}
  local hoeID
  local inventory=openInventory()
  for id, hoe in pairs(settings.hoeRegistry) do
    if inv.hasItem(inventory, hoe.id) then
      if hoeID==nil or hoe.priority>settings.hoeRegistry[hoeID].priority then
        hoeID=hoe.id
      end
    end
  end
  if not hoeID then
    log(settings.warnColor.."<OmniFarm>: No hoe found. Land left untilled.")
  end
  inv.getItem(inventory, hoeID)
  inv.selectItem(hoeID)
end
local function moveTo(x, y, z, dx, dz)
  local px, py, pz=getPlayerPos()
  local err, angle
  x=x-px; y=y-py; z=z-pz
  move.lookDir("east")
  move.lookRel(x, z, 0)
  err=move.moveDistance(math.sqrt((x*x-dx*dx)+(z*z-dz*dz)), "forward", settings.doCrouch)
  angle=math.atan2(x, z)
  dx=err*math.cos(angle)
  dy=err*math.sin(angle)
  return dx, dy
end
local function getLayers(blocks)
  --returns y levels
  local layers={}
  for id, layer in pairs(blocks) do
    table.insert(layers, id)
  end
  local output={}
  layers=sort(layers)
  for id, layer in pairs(layers) do
    table.insert(output, 1, layer)
  end
  return output
end
local function getStrips(blocks, layer)
  --returns z strips
  local strips={}
  for id, strip in pairs(blocks[layer]) do
    table.insert(strips, id)
  end
  return sort(strips)
end
local function plantBlock(blocks, x, y, z, dx, dz)
  local crop
  for id, blockX in pairs(blocks[y][z]) do
    if blockX.x==x then crop=blockX.crop; break end
  end
  moveTo(x+0.5, y, z+0.5, dx, dz)
  move.lookRel(0, 0, -1)
  --plant code
  local inventory=openInventory()
  --till land
  local px, py, pz=getPlayerPos()
  if py==math.floor(py) and crop~="minecraft:reeds" then --height is an integer and not planting sugarcane
    getHoe()
    use()
  end
  inv.getItem(inventory, settings.seedRegistry[crop])
  inv.selectItem(settings.seedRegistry[crop])
  use()
end
local function plantStrip(blocks, layer, strip, dx, dz)
  local xs={}
  for id, block in pairs(blocks[layer][strip]) do
    table.insert(xs, block.x)
  end
  xs=sort(xs)
  for id, x in pairs(xs) do
    plantBlock(blocks, x, layer, strip, dx, dz)
  end
end
local function plantLayer(blocks, layer, dx, dz)
  for id, strip in pairs(getStrips(blocks, layer)) do
    plantStrip(blocks, layer, strip, dx, dz)
  end
end
local function plantFarm()
  local blocks=sortBlocks()
  local dx=0
  local dz=0
  for id, layer in pairs(getLayers(blocks)) do
    plantLayer(blocks, layer, dx, dz)
  end
end
plantFarm()
log(settings.ofColor.."<OmniFarm>: Finished planting!")
