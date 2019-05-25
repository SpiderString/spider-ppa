--Allows you to make complex keybinds
--Runs scripts in a separate thread
local keybindFile="~/common/KeyDaemon.cfg"

local args={...}

if KEYDAEMONRUNNING==nil then KEYDAEMONRUNNING=false end
KEYDAEMONRUNNING=not KEYDAEMONRUNNING
if args[2]=="JoinWorld" then KEYDAEMONRUNNING=true
elseif args[2]=="LeaveWorld" then KEYDAEMONRUNNING=false end
if not KEYDAEMONRUNNING then return end

local utils=run("utilsLib.lua")
local tfl=run("tableFileLib.lua")
local keybinds=tfl.read(keybindFile)[1]
if keybinds==nil or not next(keybinds) then KEYDAEMONRUNNING=false; return end --no point in running if there's no keybinds, is there?

for id, keybind in pairs(keybinds) do
  keybind.running=false
end
--keybind fields: keycode, running, action
while KEYDAEMONRUNNING do
  for id, keybind in pairs(keybinds) do
    local doAction=true
    local keys=utils.split(keybind.keycode, "+")
    for index, key in pairs(keys) do
      if not isKeyDown(key) then doAction = false end
    end

    if doAction and not keybind.running then
      runThread("~/macros/"..keybind.action)
      keybind.running=true
    end

    for index, key in pairs(keys) do
      if not isKeyDown(key) then keybind.running=false end
    end
  end
end
