--Fourth step in parsing
--Evaluates operator expressions and function calls
local funcLib = run("functionalize.lua")
local lib={}

--returns if a line is of the form `!field[: | =] val`
local function isConcrete(line)
  if not line or type(line) ~= "table" then return nil end
  if line[2]:find("^!") then return true end
  return false
end


return lib
