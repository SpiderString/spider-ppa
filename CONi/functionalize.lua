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
local function runEmbeddedScript(script)
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
local function executeEmbeddedScript(con, index)
  local script=lib.getScript(con, index)
  if not script then return nil end
  return runEmbeddedScript(script)
end
function lib.executeEmbeddedScripts(con)
  local output={}
  local script
  local scriptName
  local line
  for i=1, #con do
    line=con[i]
    if lib.isScript(line) then
      script=executeEmbeddedScript(con, i)
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
--returns {name, scriptName, depth, script, ...}
local function getFunc(con, index)
  local func={}
  local line = con[index]
  local props
  local funcName
  if not lib.isFunc(line) then return nil end
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
  if not func.script then return nil end --required prop
  func.name=funcName
  func.scriptName=func.func or func.name
  return func
end
function lib.getFuncs(con)
  local scripts=lib.executeEmbeddedScripts(con)
  local funcs={}
  local line
  --get func declarations
  for i=1, #con do
    line=con[i]
    if lib.isFunc(line) then
      table.insert(funcs, getFunc(con, i))
    end
  end
  --get external scripts and bind functions
  for i, f in ipairs(funcs) do
    if not scripts[f.script] then
      if filesystem.exists(f.script) then
        scripts[f.script]=run(f.script)
      else
        --Script doesn't exist. Could choose to error here or warn.
        funcs[i]=nil; f=nil
      end
    end
    f.func=f and scripts[f.script][f.scriptName]
  end
  return funcs
end

return lib
