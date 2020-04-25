--Parses an entire CON file, final evaluation step(before interpretation)
local operators = {
  "+",
  "-",
  "*",
  "/",
  "\"",
  ".",
  "!"
} --'(', ')' handled separately

local ops = run("operatorLib.lua")
local read = run("readLib.lua").readCon
local tokenLib = run("tokenize.lua")
local isContainer = tokenLib.isContainer
local getChildren = tokenLib.getChildren
local funcLib = run("functionalize.lua")
--requires "shuntingYard.lua"


local lib={}
--*****Utility Functions*****--
--returns regular lines and interpreted data separately
--third return is original line numbers of remaining CON lines
local function splitCon(conFile)
  local tokens=read(conFile)
  local funcs=funcLib.getFuncs(tokens)
  local origLines={}
  for i=1, #tokens do
    origLines[i]=i
  end
  local childLines
  local i=1
  while i<=#tokens do
    if funcLib.isFunc(tokens[i]) or funcLib.isScript(tokens[i]) then
      _, childLines=getChildren(tokens, i)
      for j=i, childLines do
        table.remove(tokens, i)
        table.remove(origLines, i)
      end
      i=i-1
    end
    i=i+1
  end
  return tokens, funcs, origLines
end

local function isOp(token)
  for _, op in ipairs(operators) do
    if token==op then return true end
  end
  return false
end

local function nextOp(expr)
  for i=1, #expr do
    if isOp(expr[i]) then return i end
  end
  return nil
end

--returns the line number pointed to by a path(root is 0)
local function getIndex(lines, path)
  if not path or path=="" then path="/" end
  local curPath=""
  local targetPath=path
  local depth
  path=path:sub(2)
  local slash=path:find("/") or #path+1
  local nextCont=path:sub(1, slash-1)

  if targetPath=="/" then return 0 end
  for index, line in ipairs(lines) do
    if curPath.."/"..line[2]==targetPath then return index end
    if depth==-1 then depth = line[1] end
    --check for next container in the path

    if line[3]~=":" and line[2]==nextCont then
      curPath=curPath.."/"..nextCont
      path=path:sub(slash+1)
      slash=path:find("/") or #path+1
      depth=-1 --trigger depth setting on the next loop when the cont is entered
    end
  end
  return nil
end

--returns a table of lines(without children but with container headers) within the path
local function getLines(lines, path)
  local output={}
  local index=getIndex(lines, path)
  local depth
  local line
  if not index then return nil end
  depth=lines[index+1][1]
  if index~=0 and lines[index][3]==":" then return nil end --must be a container
  for i=index+1, #lines do
    line=lines[i]
    if line[1]<depth then return output end --exited container
    if line[1]==depth then --writes container header but not contents
      table.insert(output, line)
    end
  end
  return output
end

local function isEmpty(t)
  for _,_ in pairs(t) do return false end
  return true
end

--returns path of the given line. Assumes 1 <= index <= #lines
local function getPath(lines, index)
  local depth=0
  local path=""
  local containers={}
  local i=1
  while i<index and i<#lines do
    if lines[i][1]<depth then
      containers[depth]=nil --remove containers that don't contain the line
    end
    depth=lines[i][1]
    if lines[i][3]~=":" then --container
      containers[depth]=lines[i][2]
    end
    i=i+1
  end
  --build path
  i=0
  local cont
  while not isEmpty(containers) do
    cont=containers[i]
    containers[i]=nil
    if cont then path=path.."/"..cont end
    i=i+1
  end
  if path=="" then path="/" end
  return path
end

local function eval(con, index, line, funcs, expr)
  if expr and type(expr)~="table" then return expr end --already evaluated
  if not line and #expr==1 and type(expr)~="function" then return expr[1] end --already evaluated
  --eval recursion for binary arithmetic operators
  local function arithEval(expr, index, func)
    local result = func(expr[index-2], expr[index-1])
    table.remove(expr, index)
    table.remove(expr, index-1)
    expr[index-2]=result
  end
  expr = expr or run("shuntingYard.lua", line[4])
  --if line and line[2]=="type" then log(expr) end

  if not expr or type(expr)~="table" then return nil end
  if #expr==1 then
    if type(expr[1])=="function" then return expr[1] end
    return tonumber(expr[1])
  end
  local opIndex = nextOp(expr)
  local op=expr[opIndex] --potential error? opIndex can be nil
  local oper1, oper2
  while opIndex do
    if op=="+" then
      arithEval(expr, opIndex, ops.add)
    elseif op=="-" then
      arithEval(expr, opIndex, ops.sub)
    elseif op=="*" then
      arithEval(expr, opIndex, ops.mult)
    elseif op=="/" then
      arithEval(expr, opIndex, ops.div)
    elseif op=="\"" then
      oper2, oper1 = expr[opIndex-1], expr[opIndex-2]
      table.remove(expr, opIndex)
      table.remove(expr, opIndex-1)
      if #expr==0 then opIndex=opIndex+1 end
      expr[opIndex-2]=ops.str(oper1, oper2)
    elseif op=="." then
      --field reference
      if expr[opIndex-1]~=")" then
        local fieldName=expr[opIndex-1]
        local depth=line[1]
        local matchPath
        local path=getPath(con, index) --path to this line
        local lastSlash=path:find("/[%S]*$")
        local cont
        local result
        while lastSlash do
          cont=getLines(con, path)
          for _, l in ipairs(cont) do
            if l[2]==fieldName then
              matchPath=path
              break
            end
          end
          if matchPath then break end
          if path:find("/$") then path=path:sub(1, #path-1) end
          path=path:sub(1, lastSlash)
          lastSlash=path:find("/[%S]*$")
        end
        if not matchPath then return nil end
        if matchPath=="/" then matchPath="" end
        result = function() return ops.getField(con, matchPath.."/"..fieldName) end
        table.remove(expr, opIndex) --remove (.)

        --Concrete application, Bangs
        if expr[opIndex]=="!" then
          --find line pointed to, evaluate it, if it's a function
          local refLine=getIndex(con, matchPath.."/"..fieldName)
          assert(refLine~=nil, "Field Reference: Line reference not found")
          refLine=con[refLine]
          local val = eval(nil, nil, nil, nil, refLine[4])
          refLine[4]=val
          table.remove(expr, opIndex) --remove bang
          if type(val)=="function" then val=val() end
          result=val
        end
        expr[opIndex-1]=result

      --function application
      else
        --get function args
        local func
        local depth=line[1]
        local args={}
        local argBegin=opIndex
        local result
        while expr[argBegin]~="(" and argBegin>0 do argBegin=argBegin-1 end
        if argBegin>opIndex or argBegin==1 then return nil end --malformed tokens
        for i=argBegin+1, opIndex-2 do
          table.insert(args, eval(nil, nil, nil, nil, {expr[i]}))
        end
        --lookup function
        for _, f in ipairs(funcs) do
          if f.line>index then break end
          if f.depth<=depth and f.name==expr[argBegin-1] then --func match
            func=f.func
          end --continue so as to pick the match defined furthest down
        end
        if not func then return nil end --func not declared
        --remove args from token stream, parenthesis
        for i=opIndex, argBegin, -1 do
          table.remove(expr, i)
        end
        result = function()
          local output={}
          for _, arg in ipairs(args) do
            if type(arg)=="function" then
              table.insert(output, arg())
            else
              table.insert(output, arg)
            end
          end
          return func(table.unpack(output))
        end

        --Concrete Applications, Bangs
        if expr[argBegin]=="!" then
          --unitialized values handled by bang insertion in shuntingYard.lua
          table.remove(expr, argBegin)
          result=result()
        end
        expr[argBegin-1]=result

      end
    elseif op=="!" then
      --Handled underneath field reference and function application "."
      --Shouldn't trigger except in unnecessary application of bangs
      table.remove(expr, opIndex)
    else
      return nil
    end
    opIndex=nextOp(expr)
    op=expr[opIndex]
  end
  if #expr~=1 then return nil end
  return expr[1]
end

local function collapseTable(lines, reuseOriginal)
  local curDepth=lines[1][1]
  local output={}
  local statics={}
  local line
  while #lines>0 do
    line=lines[1]
    if line[1]<curDepth then break end
    table.remove(lines, 1)
    if line[3]==":" then
      output[line[2]]=line[4]
      statics[line[2]]=line.isStatic
    else --container
      output[line[2]], statics[line[2]]=collapseTable(lines)
    end
  end
  if not reuseOriginal then return output, statics end
  for id, val in pairs(output) do
    lines[id]=val
  end
  return lines, statics
end

local function evalStatics(con, statics)
  for prop, val in pairs(con) do
    if type(val)=="function" and statics[prop] then
      con[prop]=val()
    elseif type(val)=="table" then
      evalStatics(con[prop], statics[prop])
    end
  end
end

local function buildMeta(con)
  local output={}
  local meta={}
  for field, val in pairs(con) do
    if type(val)=="table" then output[field]=buildMeta(val) end
  end
  meta.__index=function(_, field)
    if type(con[field])=="function" then return con[field]() end
    if type(con[field])~="table" then return con[field] end
  end
  meta.__newindex=function(_, field, val)
    con[field]=val
  end
  meta.__metatable="CONi Object"
  meta.__pairs=function(t)
    local function iter(tbl, k)
      local v
      k, v = next(tbl, k)
      if not v then return nil end
      if type(v)=="table" then return k, t[k] end
      return k, v
    end
    return iter, con, nil
  end
  meta.__ipairs=function(t)
    local function iter(tbl, i)
      i=i+1
      local v = tbl[i]
      if not v then return nil end
      if type(v)=="table" then return i, t[i] end
      return i, v
    end
    return iter, con, 0
  end
  meta.__len=function(_) return #con end

  setmetatable(output, meta)
  return output
end


function lib.parse(conFile)
  local con, funcs, origIndices = splitCon(conFile)
  local expr
  local curDepth=0
  --evaluate values
  for index, line in ipairs(con) do
    if not isContainer(line) then
      if line[2]:find("^!") then
        line[2]=line[2]:sub(2)
        line.isStatic=true
      end
      if line[3]=="=" then line[2]=tonumber(line[2]); line[3]=":" end
      con[index][4]=eval(con, origIndices[index], line, funcs)
    end
  end
  --`con` from here on must not be reassigned
  --due to field references

  --create proper structure
  local statics
  con, statics = collapseTable(con, true)
  --evaluate static bangs
  evalStatics(con, statics)
  --create metatable
  return buildMeta(con)
end


return lib
