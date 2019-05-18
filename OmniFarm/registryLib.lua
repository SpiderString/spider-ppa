--returns a table of registry functions
local tfl=run("tableFileLib.lua")
local settings=tfl.read("~/common/OmniFarm.cfg")[1]
local regLib={}

function regLib.doesFarmExist(name)
  if name==nil then return false end
  local names=regLib.getFarmNames()
  local doesExist=false
  for id, farmName in pairs(names) do
    if farmName==name then doesExist=true end
  end
  return doesExist
end
function regLib.getFarmNames()
  local names={}
  if not filesystem.exists(settings.farmRegPath) then
    filesystem.open(settings.farmRegPath, "w"):close()
  end
  for id, obj in pairs(run("tableFileLib.lua").read(settings.farmRegPath)) do
    if type(id)=="string" then
      table.insert(names, id)
    end
  end
  return names
end
function regLib.renameFarm(oldName, newName)
  local farm=tfl.search(settings.farmRegPath, oldName)
  farm.name=newName
  tfl.replace(oldName, farm, settings.farmRegPath)
  tfl.rename(oldName, newName, settings.farmRegPath)
end
function regLib.copyFarm(source, dest)
  tfl.copy(source, dest, settings.farmRegPath)
end
function regLib.deleteFarm(name)
  tfl.delete(settings.farmRegPath, name)
end
function regLib.replaceFarm(name, farmData)
  regLib.deleteFarm(name)
  regLib.writeFarm(name, farmData)
end
return regLib
