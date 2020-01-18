--This package allows you to register basic crop farms such as wheat, potatos, or carrots and
--will harvest and replant automatically as well as store/retrieve from registered chests
--pathfinding is very rudimentary, however, so don't expect it to be able to find chests around corners
--can be bound to ChatSendFilter(CLI) or a key(GUI)
local args={...}
local ul=run("utilsLib.lua")
local cli=run("commandLib.lua")

local tfl=run("tableFileLib.lua")
local cfgPath="~/common/OmniFarm.cfg"
local defaultCfgURL="https://raw.githubusercontent.com/SpiderString/spider-ppa/master/OmniFarm/OmniFarm.cfg"

--gets a file from a url and puts it in a table
--used to grab the default config if necessary
local function getFile(url)
  local http=httpRequest({url=url}, {url=url, requestMethod="GET", timeout=15})
  local file=http["input"]
  local err=http.getResponseCode()
  local line=file:readLine()
  local output={}
  while line~=nil do
    table.insert(output, line)
    line=file:readLine()
  end
  return output
end
if not filesystem.exists(cfgPath) then
  local cfg=getFile(defaultCfgURL)
  local file=filesystem.open(cfgPath, "w")
  for id, line in pairs(cfg) do
    file.write(line.."\n")
  end
  file:close()
end
local settings=tfl.read(cfgPath)[1]
local regLib=run("registryLib.lua")

--type checking functions
--return if the argument is a valid color code
local function isColorCode(str)
  str=tostring(str)
  if str:len()%2~=0 then
    return false
  else
    while str:len()>0 do
      local code=str:sub(1, 2)
      if str:len() > 2 then
        str=str:sub(3)
      else
        str=""
      end
      if code=="&0" or code=="&1" or code=="&2" or code=="&3" or code=="&4" or code=="&5" or code=="&6" or code=="&7" or code=="&8" or code=="&9" or code=="&a" or code=="&b" or code=="&c" or code=="&d" or code=="&e" or code=="&f" or code=="&k" or code=="&l" or code=="&m" or code=="&n" or code=="&o" or code=="&r" then
        return true
      else
        return false
      end
    end
  end
end
--return if the argument is a boolean
local function isBool(val)
  val=tostring(val)
  return val:lower()=="true" or val:lower()=="false"
end

if args[2]=="ChatSendFilter" then
  --CLI
  local commandArgs=cli.getArguments(args[3], settings.commandPrefix)
  if commandArgs then
    --command matching
    if commandArgs[1]:lower()=="register" then
      if commandArgs[2]==nil or regLib.doesFarmExist(commandArgs[2]) then
        local name=prompt("Enter a name for this farm", "text")
        if name then
          while regLib.doesFarmExist(name) and name~="" and name~=nil do
            name=prompt("\""..name.."\" already taken. Please choose a different name.", "text")
          end
          if name~="" then
            run("registerFarm.lua", name)
          end
        end
      else
        local name=commandArgs[2]
        while regLib.doesFarmExist(name) and name~=nil and name~="" do
          name=prompt("\""..name.."\" already taken. Please choose a different name.", "text")
        end
        if name~="" then
          run("registerFarm.lua", name)
        end
      end
    elseif commandArgs[1]:lower()=="edit" then
      if commandArgs[2]==nil or not regLib.doesFarmExist(commandArgs[2]) then
        local names=regLib.getFarmNames()
        table.sort(names)
        local name=prompt("Choose a farm to edit", "choice", table.unpack(names))
        if name~=nil then
          run("registerFarm.lua", name, tfl.search(settings.farmRegPath, name))
        end
      else
        run("registerFarm.lua", commandArgs[2], tfl.search(settings.farmRegPath, commandArgs[2]))
      end
    elseif commandArgs[1]:lower()=="remove" or commandArgs[1]:lower()=="delete" then
      if commandArgs[2]==nil or not regLib.doesFarmExist(commandArgs[2]) then
        local names=regLib.getFarmNames()
        table.sort(names)
        local name=prompt("Choose a farm to delete", "choice", table.unpack(names))
        if name~=nil then
          if prompt("Are you sure you want to delete '"..name.."'?", "choice", "No", "Yes")=="Yes" then
            regLib.deleteFarm(name)
          end
        end
      else
        regLib.deleteFarm(commandArgs[2])
      end
    elseif commandArgs[1]:lower()=="copy" then
      if commandArgs[2]==nil or not regLib.doesFarmExist(commandArgs[2]) then
        local names=regLib.getFarmNames()
        table.sort(names)
        local name=prompt("Choose a farm to copy", "choice", table.unpack(names))
        if name~=nil then
          local dest=prompt("Enter a name for the new farm", "text")
          if dest~=nil and dest~="" then
            regLib.copyFarm(name, dest)
          end
        end
      end
    elseif commandArgs[1]:lower()=="rename" then
      local names=regLib.getFarmNames()
      table.sort(names)
      local name=prompt("Choose a farm to rename", "choice", table.unpack(names))
      if name~=nil then
        local newName=prompt("Enter a new name for the farm", "text")
        if newName~=nil and newName~="" then
          regLib.renameFarm(name, newName)
        end
      end
    elseif commandArgs[1]:lower()=="settings" or commandArgs[1]:lower()=="configure" or commandArgs[1]:lower()=="config" then
      local settingsFields={}
      for field, val in pairs(settings) do
        table.insert(settingsFields, field)
      end
      local choice=true
      while choice do
        table.sort(settingsFields)
        local choice=prompt("Choose a setting to modify", "choice", table.unpack(settingsFields))
        if not choice then break end
        --table settings
        if choice=="blockTexs" then
          local blockTexsFields={}
          for field, val in pairs(settings.blockTexs) do
            table.insert(blockTexsFields, field)
          end
          table.sort(blockTexsFields)
          local id=prompt("Choose a block ID to modify", "choice", "Add Block", "Remove Block", table.unpack(blockTexsFields))
          if not id then break end
          if id=="Add Block" then
            --add new block id
            id=prompt("Input the block ID, e.g. 'minecraft:farmland'.", "text")
            if not id or id=="" then break end
            if settings.blockTexs[id] then
              log(settings.errColor.."Failed to create new block texture, ID already taken.")
              break
            end
            local tex=prompt("Input the texture path, e.g. 'block:minecraft:blocks/glass_brown'.", "text")
            if not tex or tex=="" then break end
            settings.blockTexs[id]=tex
          elseif id=="Remove Block" then
            --remove existing block id
            table.sort(blockTexsFields)
            id=prompt("Choose a block ID to remove", "choice", table.unpack(blockTexsFields))
            if not id then break end
            local confirm=prompt("Are you sure you want to remove '"..id.."' from the texture registry?", "choice", "No", "Yes")
            if confirm=="Yes" then settings.blockTexs[id]=nil end
          else
            --edit existing block id
            local tex=prompt("Input the new texture path. Current path: '"..settings.blockTexs[id].."'.", "text")
            if not tex or tex=="" then break end
            settings.blockTexs[id]=tex
          end
        elseif choice=="seedRegistry" then
          local seedRegFields={}
          for field, val in pairs(settings.seedRegistry) do
            table.insert(seedRegFields, field)
          end
          table.sort(seedRegFields)
          local id=prompt("Choose a crop ID to modify seeds", "choice", "Add crop", "Remove crop", table.unpack(seedRegFields))
          if not id then break end
          if id=="Add crop" then
            --add new crop
            id=prompt("Input the crop ID, e.g. 'minecraft:wheat'.", "text")
            if not id or id=="" then break end
            if settings.seedRegistry[id] then
              log(settings.errColor.."Failed to create new crop, ID already taken.")
              break
            end
            local seed=prompt("Input the seed ID, e.g. 'minecraft:wheat_seeds'.", "text")
            if not seed or seed=="" then break end
            settings.seedRegistry[id]=seed
          elseif id=="Remove crop" then
            --remove existing crop
            table.sort(seedRegFields)
            id=prompt("Choose a crop ID to remove", "choice", table.unpack(seedRegFields))
            if not id then break end
            local confirm=prompt("Are you sure you want to remove '"..id.."' from the seed registry?", "choice", "No", "Yes")
            if confirm=="Yes" then settings.seedRegistry[id]=nil end
          else
            --edit existing crop
            local seed=prompt("Input the new seed. Current seed: '"..settings.seedRegistry[id].."'.", "text")
            if not seed or seed=="" then break end
            settings.seedRegistry[id]=seed
          end
        elseif choice=="hoeRegistry" then
          local hoeIDs={}
          for key, hoe in pairs(settings.hoeRegistry) do
            table.insert(hoeIDs, hoe.id)
          end
          table.sort(hoeIDs)
          local id=prompt("Choose a hoe to modify", "choice", "Add hoe", "Remove hoe", table.unpack(hoeIDs))
          if not id then break end
          if id=="Add hoe" then
            --add new hoe
            id=prompt("Input the hoe's ID. E.G. 'minecraft:diamond_hoe'.", "text")
            if not id then break end
            local regID
            for key, hoe in pairs(settings.hoeRegistry) do
              if hoe.id==id then regID=key; break end
            end
            if regID then
              log(settings.errColor.."Failed to create new hoe. Hoe ID already taken.")
              break
            end
            local priority=prompt("Input the hoe's priority. Higher numbers take priority.", "text")
            if not priority then break end
            if not tonumber(priority) then
              log(setting.errColor.."Failed to create new hoe. Hoe priority must be a number.")
              break
            end
            local hoe={}
            hoe.id=id
            hoe.priority=priority
            table.insert(settings.hoeRegistry, hoe)
          elseif id=="Remove hoe" then
            --remove existing hoe
            table.sort(hoeIDs)
            id=prompt("Choose a hoe to remove", "choice", table.unpack(hoeIDs))
            if not id then break end
            local regID
            for key, hoe in pairs(settings.hoeRegistry) do
              if hoe.id==id then regID=key; break end
            end
            local confirm=prompt("Are you sure you want to remove hoe '"..settings.hoeRegistry[regID].id.."' from the hoe registry?", "choice", "No", "Yes")
            if confirm=="Yes" then settings.hoeRegistry[regID]=nil end
          else
            --modify existing hoe
            local regID
            for key, hoe in pairs(settings.hoeRegistry) do
              if hoe.id==id then regID=key; break end
            end
            local priority=prompt("Input new hoe priority. Current priority: "..settings.hoeRegistry[regID].priority, "text")
            if not priority or not tonumber(priority) then
              log(settings.errColor.."Failed to update hoe priority. New priority is not a number.")
              break
            end
            settings.hoeRegistry[regID].priority=priority
          end
        else
          --simple settings
          local newVal=prompt("Current Value: "..choice.."="..tostring(settings[choice])..". Input new value:")
          if not newVal then break end
          --settings type matching
          if choice=="regLibPath" then
            if filesystem.isDir(newVal) then
              log(settings.errColor.."Failed to change setting '"..choice.."'. Path is a directory.")
              break
            end
            settings.regLibPath=newVal
          elseif choice=="commandPrefix" then
            if newVal=="" then break end
            settings.commandPrefix=newVal
          elseif choice=="plantDelay" then
            if not tonumber(newVal) then
              log(settings.errColor.."Failed to change setting '"..choice.."'. Not a number.")
              break
            else
              newVal=tonumber(newVal)
              if newVal<0 then
                log(settings.errColor.."Failed to change setting '"..choice.."'. New value is less than zero.")
                break
              end
            end
            settings[choice]=newVal
          elseif choice=="ofColor" or choice=="warnColor" or choice=="errColor" then
            if not isColorCode(newVal) then
              log(settings.errColor.."Failed to change setting '"..choice.."'. Invalid color code.")
              break
            end
            settings[choice]=newVal
          elseif choice=="cropOpacity" or choice=="chestOpacity" then
            if not tonumber(newVal) then
              log(settings.errColor.."Failed to change setting '"..choice.."'. Not a number.")
              break
            else
              newVal=tonumber(newVal)
              if newVal<0 or newVal > 1 then
                log(settings.errColor.."Failed to change setting '"..choice.."'. New value is outside of [0,1].")
                break
              end
            end
            settings[choice]=newVal
          --boolean settings
          elseif choice=="xray" or choice=="doCrouch" or choice=="drawSoil" then
            if not isBool(newVal) then
              log(settings.errColor.."Failed to change settings '"..choice.."'. Not a boolean value.")
              break
            end
            if newVal:lower()=="true" then settings[choice]=true
            elseif newVal:lower()=="false" then settings[choice]=false end
          end --end simple settings matching
        end --end settings matching
        tfl.write(settings, cfgPath)
      end --end command matching
    elseif commandArgs[1]:lower()=="plant" then
      if commandArgs[2]==nil or not regLib.doesFarmExist(commandArgs[2]) then
        local names=regLib.getFarmNames()
        table.sort(names)
        local name=prompt("Choose a farm to plant", "choice", table.unpack(names))
        if name then
          run("plantFarm.lua", tfl.search(settings.farmRegPath, name))
        end
      else
        run("plantFarm.lua", tfl.search(settings.farmRegPath, commandArgs[2]))
      end
    else
      --help
    end
  else
    return args[3]
  end
else
  --GUI
end
