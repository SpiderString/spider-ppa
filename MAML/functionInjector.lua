--first step in the compilation process
local output={}
local tokens = {...}
tokens=tokens[1]
local json=run("tableFileLib.lua")
local utils=run("utilsLib.lua")
local funcs = json.read("functions.json")[1]
local funcDict = json.read("functionLib.json")[1]
local funcsToInject={}

function isFunc(token)
  for mFunc, lFunc in pairs(funcs) do
    if mFunc == token then return lFunc end
  end
  return nil
end

function getFuncsToInject()
  for _, token in ipairs(tokens) do
    table.insert(funcsToInject, isFunc(token))
  end
  funcsToInject = utils.nodups(funcsToInject)
end

function injectFunc(func)
  local funcStr="local "..func.." = "
  table.insert(output, funcStr..funcDict[func])
end

function injectFuncs()
  getFuncsToInject()
  for _, func in ipairs(funcsToInject) do
    injectFunc(func)
  end
end

injectFuncs()
return output
