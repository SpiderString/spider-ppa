--Package for implementing random memes, copypastas, and emotes in chat
local args={...}
local commandPrefix="!"

if args[2]~="ChatSendFilter" then return end

local cli=run("commandLib.lua")
local commandArgs=cli.getArguments(args[3], commandPrefix)
if commandArgs==nil then return args[3] end
math.randomseed(os.time())

local function remove(str, n)
  if #str==1 then
    return ""
  elseif n==1 then
    return str:sub(2)
  elseif n==#str then
    return str:sub(1, -2)
  else
    return str:sub(1, n-1)..str:sub(n+1)
  end
end
local function recombine(t)
  local output=""
  for id, str in pairs(t) do
    if output~="" then output=output.." " end
    output=output..str
  end
  return output
end
local function shook(t)
  local output=""
  for id, str in pairs(t) do
    if output~="" then output=output.." " end
    for i=1, #str do
      local isUpper=(math.random(2)==2)
      if isUpper then output=output..str:sub(i, i):upper()
      else output=output..str:sub(i, i):lower() end
    end
  end
  return output
end
local function reverse(t)
  local output=""
  local buffer
  for id, str in pairs(t) do
    if output~="" then output=output.." " end
    output=output..str
  end
  buffer=output
  output=""
  for i=1, #buffer do
    output=output..buffer:sub(-i, -i)
  end
  return output
end
local function scramble(t)
  local output=""
  for id, str in pairs(t) do
    if output~="" then output=output.." " end
    while str~="" do
      local n=math.random(#str)
      output=output..str:sub(n, n)
      str=remove(str, n)
    end
  end
  return output
end

if commandArgs[1]:lower()=="shook" then
  table.remove(commandArgs, 1)
  return shook(commandArgs)
elseif commandArgs[1]:lower()=="reverse" then
  table.remove(commandArgs, 1)
  return reverse(commandArgs)
elseif commandArgs[1]:lower()=="scramble" then
  table.remove(commandArgs, 1)
  return scramble(commandArgs)
elseif commandArgs[1]:lower()=="lenny" then
  table.remove(commandArgs, 1)
  return recombine(commandArgs).." ( ͡° ͜ʖ ͡°)"
elseif commandArgs[1]:lower()=="shrug" then
  table.remove(commandArgs, 1)
  return recombine(commandArgs).." ¯\\_(ツ)_/¯"
elseif commandArgs[1]:lower()=="flip" then
  table.remove(commandArgs, 1)
  return recombine(commandArgs).." (╯°□°）╯︵ ┻━┻"
elseif commandArgs[1]:lower()=="unflip" then
  table.remove(commandArgs, 1)
  return recombine(commandArgs).." ┬─┬ ノ( ゜-゜ノ)"
else
  return args[3]
end
