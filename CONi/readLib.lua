--Basic read functions and initial step of parsing
--Nesting is handled with \t=two spaces

local lib={}
local bang='!' --forces strict evaluation
local assignment=':'
local numAssignment='='
local tokenLib = run("tokenize.lua")

--*****Utility Functions*****--

--returns equivalent number of spaces and modified string
local function getDepth(line)
  local a = line:find("[%S]")
  local char = line:sub(1, 1)
  local depth=0
  if not a or a == 1 then return depth, line end
  while char and char:find("^[%s]$") do
    if char == " " then
      depth=depth+1
    elseif char == "\t" then
      depth=depth+2
    end
    line=line:sub(2)
    char=line:sub(1, 1)
  end
  return depth, line
end
--splits a line into {depth::Int, key::String, [assignmentOp::Char, tokens::Table]}
local function split(line)
  local depth, line = getDepth(line)
  local a = line:find(assignment) or line:find(numAssignment)
  if not a then return {depth, line} end
  local keystr = line:sub(1, a-1):gsub("[%s]+$", "")
  local assignOp = line:sub(a, a)
  local val = line:sub(a+1):gsub("^[%s]+", ""):gsub("[%s]+$", "")
  local tokens = tokenLib.tokenize(val)
  return {depth, keystr, assignOp, tokens}
end
--get and process one line, returning a table representing it
local function readNextLine(file)
  if file.available()==0 then return nil end
  local line = file.readLine()
  line = split(line)
  return line
end

--*****Library Functions*****--

function lib.readCon(fileName)
  if not filesystem.exists(fileName) then return nil end
  local file=filesystem.open(fileName, "r")
  local output={}
  local line=readNextLine(file)
  while line do
    table.insert(output, line)
    line=readNextLine(file)
  end
  file:close()
  return output
end

return lib
