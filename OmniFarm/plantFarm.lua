--script which handles planting a farm
--should be run with one argument as the farm's data
local args={...}
local farm=args[1]
local tfl=run("tableFileLib.lua")
local inv=run("inventoryLib.lua")
local move=run("movementLib.lua")
local settings=tfl.read("~/common/OmniFarm.cfg")[1]
local planting=true

log(settings.ofColor.."<OmniFarm>: Planting farm '"..farm.name.."'... Hold 'Enter' to cancel planting.")
local function norm(...)
  local arg={...}
  local sum=0
  for i, n in pairs(arg) do
    sum=sum+(n)*(n)
  end
  return math.sqrt(sum)
end
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
local function moveTo(x, y, z, delta)
  if not delta then delta=0 end
  local px, py, pz=getPlayerPos()
  x=x-px; y=y-py; z=z-pz
  move.lookDir("east")
  move.lookRel(x, z, 0)
  move.moveDistance(norm(x, z)+delta, "forward", settings.doCrouch)
end
local function getClosestChest(chestsTable)
  local px, py, pz=getPlayerPos()
  if not next(chestsTable) then return nil end
  local closestChest=chestsTable[1]
  for id, chest in pairs(chestsTable) do
    if closestChest.y==py and chest.y==py then
      if norm(chest.x-px, chest.z-pz)<norm(closestChest.x-px, closestChest.z-pz) then
        closestChest=chest
      end
    elseif closestChest.y~=py and chest.y==py then
      closestChest=chest
    elseif closestChest.y~=py and chest.y~=py then
      if norm(chest.x-px, chest.y-py, chest.z-pz)<norm(closestChest.x-px, closestChest.y-py, closestChest.z-pz) then
        closestChest=chest
      end
    end
  end
  return closestChest
end
local function getLayers(blocks)
  --returns y levels
  local layers={}
  for id, layer in pairs(blocks) do
    table.insert(layers, id)
  end
  local output={}
  table.sort(layers)
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
  table.sort(strips)
  return strips
end
local function plantBlock(blocks, x, y, z)
  local crop
  for id, blockX in pairs(blocks[y][z]) do
    if blockX.x==x then crop=blockX.crop; break end
  end
  moveTo(x+0.5, y, z+0.5)
  move.lookRel(0, 0, -1)
  --plant code
  local inventory=openInventory()
  --till land
  local px, py, pz=getPlayerPos()
  if py==math.floor(py) and crop~="minecraft:reeds" then --height is an integer and not planting sugarcane
    getHoe()
    use()
  end
  if not inv.hasItem(inventory, settings.seedRegistry[crop]) then
    --look for seeds in registered chests
    log(settings.warnColor.."<OmniFarm>: Out of seeds, looking for seeds in chests")


    local chest=getClosestChest(farm.chests)
    local chests=farm.chests
    if chest==nil then
      log(settings.errColor.."<OmniFarm>: Out of seeds, no chests registered. Aborting planting.")
      planting=false
      return
    end
    while chest~=nil do
      moveTo(chest.x+0.5, chest.y, chest.z+0.5, -(0.5+math.sqrt(2)))
      move.lookRel(1, 0, -1)
      inventory.close()
      sleep(300)
      use()
      sleep(300)
      local chestInv=openInventory()
      while chestInv.getType()=="inventory" do
        chestInv=openInventory()
        sleep(100)
      end
      if inv.hasItem(chestInv, settings.seedRegistry[crop]) then
        inv.combine(chestInv, settings.seedRegistry[crop])
        local itemStacks=inv.getItemStacks(chestInv, settings.seedRegistry[crop])
        for id, is in pairs(itemStacks) do
          for i=0, 35 do --loops through every player inventory slot
            if inv.isEmpty(chestInv, chestInv.getTotalSlots()-i) then
              inv.getItem(chestInv, settings.seedRegistry[crop], 0, chestInv.getTotalSlots()-i)
              break
            end
          end
        end
        chestInv.close()
        key("ESCAPE")
        log(settings.ofColor.."<OmniFarm>: Found seeds, resuming planting.")
        inventory=openInventory()
        break
      else
        chestInv.close()
        key("ESCAPE")
      end
      for id, block in pairs(chests) do
        if block.x==chest.x and block.y==chest.y and block.z==chest.z then
          table.remove(chests, id)
        end
      end
      chest=getClosestChest(chests)
    end
    if chest==nil then
      log(settings.errColor.."<OmniFarm>: No seeds found in any chests. Aborting planting.")
      planting=false
      return
    end

    --return to plot
    moveTo(x+0.5, y, z+0.5)
    move.lookRel(0, 0, -1)

  end
  inv.getItem(inventory, settings.seedRegistry[crop])
  inv.selectItem(settings.seedRegistry[crop])
  sleep(settings.plantDelay)
  use()
end
local function plantStrip(blocks, layer, strip)
  local xs={}
  for id, block in pairs(blocks[layer][strip]) do
    table.insert(xs, block.x)
  end
  table.sort(xs)
  for id, x in pairs(xs) do
    if isKeyDown("RETURN") or not planting then planting=false; break end
    plantBlock(blocks, x, layer, strip)
  end
end
local function plantLayer(blocks, layer)
  for id, strip in pairs(getStrips(blocks, layer)) do
    if isKeyDown("RETURN") or not planting then planting=false; break end
    plantStrip(blocks, layer, strip)
  end
end
local function plantFarm()
  local blocks=sortBlocks()
  for id, layer in pairs(getLayers(blocks)) do
    if isKeyDown("RETURN") or not planting then planting=false; break end
    plantLayer(blocks, layer)
  end
end
plantFarm()
if planting then
  log(settings.ofColor.."<OmniFarm>: Finished planting!")
else
  log(settings.warnColor.."<OmniFarm>: Planting terminated.")
end
