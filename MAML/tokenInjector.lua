--Second step in conversion
--Removes and inserts tokens as needed
--Converts global vars to their functional equivalents
--Converts local vars to a safe auto-gen'd equivalent
--Converts functions to their AM equivalents

local tokens={...}
tokens=tokens[1]
local json=run("tableFileLib.lua")
local tokenLib=run("tokenLib.lua")
local funcs = json.read("functions.json")[1]
local funcDict = json.read("functionLib.json")[1]
local opers = json.read("operators.json")[1]
local vars={}
local lastVar=""

function isFunc(token)
  return tokenLib.isKey(token, funcs)
end
function isOper(token)
  return tokenLib.isKey(token, opers)
end

function genVar()

end
function replaceFunc(token)
  return funcDict[isFunc(token)]
end
function replaceVar(token)

end
function replaceOper(token)
  return isOper(token)
end

function injectTokens()
  for i, token in ipairs(tokens) do
    token = replaceFunc(token) or replaceVar(token) or replaceOper(token)
    tokens[i]=token or tokens[i]
  end
end

injectTokens()
return tokens
