--Third evaluation step
--Extracts embedded scripts and parses function declarations

local tokenLib = run("tokenize.lua")

local lib={}

--*****Script Parsing Functions*****--

function lib.isScript(line)
  if not line or type(line)~="table" then return false end
  if tokenLib.isContainer(line) and line[2]:find("^%$") then return true end
end
local function concatTable(t)
  local str=""
  for i=1, #t do
    str=str..t[i]
  end
  return str
end
local function reconstructVal(line)
  local str=""
  for i=2, #line do
    if type(line[i])=="table" then line[i]=concatTable(line[i]) end
    str=str..line[i]
  end
  return string.rep(" ", line[1])..str
end
function lib.getScript(con, index)
  local output={}
  local line=con[index]
  local baseDepth
  if not lib.isScript(line) then return nil end
  output = tokenLib.getChildren(con, index)
  baseDepth=output[1][1]
  for id, val in ipairs(output) do
    val[1]=val[1]-baseDepth
    output[id]=reconstructVal(val)
  end
  return output
end
local function runScript(script)
  local filename="tmp"
  local num=1
  while filesystem.exists(filename..tostring(num)..".lua") do
    num=num+1
  end
  filename=filename..tostring(num)..".lua"
  local file=filesystem.open(filename, "w")
  for _, line in ipairs(script) do
    file.write(line.."\n")
  end
  file:close()
  local output=run(filename)
  filesystem.delete(filename)
  return output
end
local function getScriptName(line)
  if not lib.isScript(line) then return nil end
  return line[2]:sub(2):gsub("^[%s]", "")
end
local function executeScript(con, index)
  local script=lib.getScript(con, index)
  if not script then return nil end
  return runScript(script)
end
function lib.executeScripts(con)
  local output={}
  local script
  local scriptName
  local line
  for i=1, #con do
    line=con[i]
    if lib.isScript(line) then
      script=executeScript(con, i)
      scriptName=getScriptName(line)
      output[scriptName]=script
    end
  end
  return output
end

--*****Function Parsing Functions*****--

function lib.isFunc(line)
  if not line or type(line)~="table" then return false end
  if tokenLib.isContainer(line) and line[2]:find("^@") then return true end
end
local function getFunc(scripts, con, index)
  local func={}
  local line = con[index]
  local props
  local funcEnd
  local str
  local funcName
  if not scripts or not lib.isFunc(line) then return nil end
  func.depth=line[1]
  func.line=index
  funcName=line[2]:sub(2):gsub("^[%s]", "")
  props = tokenLib.getChildren(con, index)
  --write func declaration data
  for _, line in ipairs(props) do
    if not tokenLib.isContainer(line) then
      func[line[2]] = concatTable(line[4]):gsub("\"", "")
    end
  end
  if not func.script then return nil end
  func.name=funcName
  func.scriptName=func.func or func.name
  if not scripts[func.script] then return nil end --script not found error
  func.func=scripts[func.script][func.scriptName]
  return func
end
function lib.getFuncs(con)
  local scripts = lib.executeScripts(con)
  local funcs={}
  local line
  if not scripts then return nil end
  for i=1, #con do
    line=con[i]
    if lib.isFunc(line) then
      table.insert(funcs, getFunc(scripts, con, i))
    end
  end
  return funcs
end

return lib
