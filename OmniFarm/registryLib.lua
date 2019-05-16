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
  return run("tableFileLib.lua").rename(oldName, newName, settings.farmRegPath)
end
function regLib.copyFarm(source, dest)
  run("tableFileLib.lua").copy(source, dest, settings.farmRegPath)
end
function regLib.deleteFarm(name)
  return run("tableFileLib.lua").delete(settings.farmRegPath, name)
end
function regLib.replaceFarm(name, farmData)
  regLib.deleteFarm(name)
  regLib.writeFarm(name, farmData)
end
return regLib
