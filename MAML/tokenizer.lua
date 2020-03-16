local files = run("fileLib.lua")
local json = run("tableFileLib.lua")
local utils = run("utilsLib.lua")
local tokenLib = run("tokenLib.lua")

local funcs = json.read("functions.json")[1]
local operators = json.read("operators.json")[1]
local file = {...}
file=file[1]

function isFunc(token)
  return tokenLib.isKey(token, funcs)
end

function isOper(token)
  for mOp, lOp in pairs(operators) do
    if mOp==token then return true end
  end
  return false
end

function hasOper(token, n)
  if isOper(token) then return nil end
  n = n or 1
  for i=1, #token do
    local char = token:sub(i, i)
    if i>=n and isOper(char) then return i end
  end
  return nil
end

function _splitOpers(token)
  local buffer={}
  local pos = hasOper(token)
  while pos do
    table.insert(buffer, token:sub(1, pos-1))
    table.insert(buffer, token:sub(pos, pos))
    token = token:sub(pos+1)
    pos = hasOper(token)
  end
  table.insert(buffer, token)
  local str=table.concat(utils.intersperse(" ", buffer))
  return str:gsub("[ ]+", " "):gsub("[ ]+$", ""):gsub("^[ ]+", "")
end

function splitOpers(tokens)
  for i, token in ipairs(tokens) do
    tokens[i]=_splitOpers(token)
  end
  tokens = utils.map(function(s) return utils.split(s, " ") end, tokens)
  return utils.concat(tokens)
end

function tokenize(file)
  local file = files.cat(file)
  local tokens = utils.map(function(s) return utils.split(s, " ") end, file)
  --do shtuff
  tokens = utils.intercalate("\n", tokens)
  tokens = splitOpers(tokens)
  return tokens
end

return tokenize(file)
