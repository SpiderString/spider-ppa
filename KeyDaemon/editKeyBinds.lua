local keybindFile="~/common/KeyDaemon.cfg"

local tfl=run("tableFileLib.lua")
local utils=run("utilsLib.lua")

function isValidScript(path)
  if filesystem.exists("~/macros/"..path) and not filesystem.isDir("~/macros/"..path) then return true
  else return false end
end
function isValidKeybind(code)
  local keycode=utils.split(code, "+")
  for id, key in pairs(keycode) do
    if pcall(isKeyDown, key) then
    else
      return "Invalid key '"..key.."'"
    end
  end
  return true
end


local keybinds=tfl.read(keybindFile)[1]
if keybinds==nil then keybinds={} end

local action=prompt("Pick an action", "choice", "Add keybind", "Edit keybind", "Remove keybind")
if not action then return end
if action=="Add keybind" then
  local script=prompt("Path to the script from '.minecraft/advancedMacros/macros/': ", "text")
  if not script or script=="" then return end
  while not isValidScript(script) do
    script=prompt("ERROR: Invalid script path. Input the path from '.minecraft/advancedMacros/macros/': ", "text")
    if not script or script=="" then return end
  end
  local keycode=prompt("Keybind (E.G. 'LCONTROL+C'): ", "text")
  if not keycode or keycode=="" then return end
  while isValidKeybind(keycode)~=true do
    local err=isValidKeybind(keycode)
    keycode=prompt("ERROR: "..err..". Keybind (E.G. 'LCONTROL+C'): ", "text")
  end
  table.insert(keybinds, {keycode=keycode, action=script})
elseif action=="Edit keybind" then
  local display={}
  for id, bind in pairs(keybinds) do
    table.insert(display, bind.keycode..": "..bind.action)
  end
  local choice=prompt("Pick a keybind to edit.", "choice", table.unpack(display))
  if not choice then return end
  local index
  for id, bind in pairs(keybinds) do
    if bind.keycode..": "..bind.action==choice then index=id; break end
  end
  --start editing
  local keycode=prompt("Current keybind: '"..keybinds[index].keycode.."'. New keybind (E.G. 'LCONTROL+C'): ", "text")
  if not keycode or keycode=="" then return end
  while isValidKeybind(keycode)~=true do
    local err=isValidKeybind(keycode)
    keycode=prompt("ERROR: "..err..". Current keybind: '"..keybinds[index].keycode.."'. New Keybind (E.G. 'LCONTROL+C'): ", "text")
  end
  keybinds[index].keycode=keycode
elseif action=="Remove keybind" then
  local display={}
  for id, bind in pairs(keybinds) do
    table.insert(display, bind.keycode..": "..bind.action)
  end
  local choice=prompt("Pick a keybind to remove.", "choice", table.unpack(display))
  if not choice then return end
  local index
  for id, bind in pairs(keybinds) do
    if bind.keycode..": "..bind.action==choice then index=id; break end
  end
  local confirm=prompt("Are you sure you want to remove binding '"..keybinds[index].keycode..": "..keybinds[index].action.."'?", "choice", "No", "Yes")
  if confirm=="Yes" then
    keybinds[index]=nil
  end
end
tfl.write(keybinds, keybindFile)
if KEYDAEMONRUNNING then run("keyDaemon.lua") end
runThread("keyDaemon.lua")
