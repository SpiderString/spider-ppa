--script which handles writing a new farm entry
--should be run with one argument for the name of the farm and the second the farm's data
local args={...}
local name=args[1]
local editFarm=args[2]
local tfl=run("tableFileLib.lua")
local settings=tfl.read("~/common/OmniFarm.cfg")[1]

log(settings.ofColor.."<OmniFarm>: Run over farmland to register it and punch chests to register them. Crouch to de-register blocks")
log(settings.ofColor.."<OmniFarm>: Press enter to finish registering.")
local farm={}
farm.blocks={}
farm.chests={}
farm.name=name
--prepares for editing an existing farm
if editFarm~=nil and type(editFarm)=="table" then
  farm=editFarm
  --draw holo blocks for existing farm
  for id, block in pairs(farm.blocks) do
    block.farmland=hud3D.newBlock()
    block.farmland.setPos(block.x, block.y, block.z)
    block.farmland.xray(settings.xray)
    block.farmland.changeTexture(settings.blockTexs["minecraft:farmland"])
    block.farmland.setOpacity(settings.cropOpacity)
    block.farmland.enableDraw()
    block.cropHolo=hud3D.newBlock()
    block.cropHolo.setPos(block.x, block.y+1, block.z)
    block.cropHolo.xray(settings.xray)
    block.cropHolo.changeTexture(settings.blockTexs[block.crop])
    block.cropHolo.setOpacity(settings.cropOpacity)
    block.cropHolo.enableDraw()
  end
  for id, block in pairs(farm.chests) do
    block.chest=hud3D.newBlock()
    block.chest.setPos(block.x, block.y, block.z)
    block.chest.xray(settings.xray)
    block.chest.changeTexture(settings.blockTexs["minecraft:chest"])
    block.chest.setOpacity(settings.chestOpacity)
    block.chest.enableDraw()
  end
end
local function registerChest(x, y, z)
  local doesBlockExist=false
  for id, block in pairs(farm.chests) do
    if block.x==x and block.y==y and block.z==z then
      doesBlockExist=true
    end
  end
  if getBlock(x, y, z).id=="minecraft:chest" then
    if not doesBlockExist and not getPlayer().isSneaking then
      --register new chest
      local block={}
      block.x=x; block.y=y; block.z=z
      block.chest=hud3D.newBlock()
      block.chest.setPos(x, y, z)
      block.chest.xray(settings.xray)
      block.chest.changeTexture(settings.blockTexs["minecraft:chest"])
      block.chest.setOpacity(settings.chestOpacity)
      block.chest.enableDraw()
      table.insert(farm.chests, block)
    elseif doesBlockExist and getPlayer().isSneaking then
      --remove an existing chest from the registry
      for id, block in pairs(farm.chests) do
        if block.x==x and block.y==y and block.z==z then
          block.chest.enableDraw(false)
          farm.chests[id]=nil
        end
      end
    end
  end
end
local function registerFarmland(x, y, z)
  local doesBlockExist=false
  for id, block in pairs(farm.blocks) do
    if block.x==x and block.y==y and block.z==z then
      doesBlockExist=true
    end
  end
  --register new crop block
  if not doesBlockExist and not getPlayer().isSneaking then
    local block={}
    block.x=x; block.y=y; block.z=z
    block.crop=getBlock(x, y+1, z).id

    --draw farmland and crop in holoblocks
    local holo=hud3D.newBlock()
    holo.setPos(x, y, z)
    holo.xray(settings.xray)
    holo.changeTexture(settings.blockTexs["minecraft:farmland"])
    holo.setOpacity(settings.cropOpacity)
    holo.enableDraw()
    block.farmland=holo

    holo=hud3D.newBlock()
    holo.setPos(x, y+1, z)
    holo.xray(settings.xray)
    holo.changeTexture(settings.blockTexs[getBlock(x, y+1, z).id])
    holo.setOpacity(settings.cropOpacity)
    holo.enableDraw()
    block.cropHolo=holo

    table.insert(farm.blocks, block)
  elseif doesBlockExist and getPlayer().isSneaking then
    --removes a block from the registry
    for id, block in pairs(farm.blocks) do
      if block.x==x and block.y==y and block.z==z then
        block.farmland.enableDraw(false)
        block.cropHolo.enableDraw(false)
        farm.blocks[id]=nil
      end
    end
  end
end
while isKeyDown("RETURN") do end --prevents instant registration after inputting name
--block registration loop
while not isKeyDown("RETURN") do
  local x, y, z=getPlayerBlockPos()
  local block=getBlock(x, y, z) --farmland puts you slightly below the horizon so it rounds down
  if block.id=="minecraft:farmland" then
    registerFarmland(x, y, z)
  end
  --register chests
  if isKeyDown("LMB") then
    registerChest(unpack(getPlayer().lookingAt))
  end
  while isKeyDown("LMB") do end
end
--deletes holoblocks
for id, block in pairs(farm.blocks) do
  block.farmland.enableDraw(false)
  block.farmland=nil
  block.cropHolo.enableDraw(false)
  block.cropHolo=nil
end
for id, block in pairs(farm.chests) do
  block.chest.enableDraw(false)
  block.chest=nil
end
--writes farm data
if args[2]==nil then
  --write new farm
  tfl.append(farm, settings.farmRegPath, farm.name)
  log(settings.ofColor.."<OmniFarm>: Successfully registered farm '"..farm.name.."'!")
else
  --edit existing farm
  tfl.replace(farm.name, farm, settings.farmRegPath)
  log(settings.ofColor.."<OmniFarm>: Successfully edited farm '"..farm.name.."'!")
end
