--converts a token table into reverse polish notation
--For the purposes of strings, they are considered a type of parenthetical
--E.G. "foo".bar()"foobar" → foo bar() . " foobar "
--Supports function composition and multi-argument functions
local ops={
  ["!"] = 5,
  ["."] = 5,
  ["+"] = 3,
  ["-"] = 3,
  ["*"] = 4,
  ["/"] = 4,
  [","] = 5
}
local quotes=0
local funcs=0
local parens=0
local opStack={}
local outputQ={}
local inputQ=...
--return a token from opStack
local function pop()
  return table.remove(opStack)
end
--peak at a token from opStack
local function top()
  return opStack[#opStack]
end
--push a token to outputQ
local function push(token)
  table.insert(outputQ, token)
end
--pull token from opStack and push to outputQ
local function pull()
  push(pop())
end
local function precedance(token)
  if token=="(" or token==")" or token=="\"" then return 0 end
  return ops[token]
end

local function isOp(token)
  for op, _ in pairs(ops) do
    if token==op then return true end
  end
  return false
end

if not inputQ or type(inputQ)~="table" then return nil end
--main algorithm
for pos, token in ipairs(inputQ) do
  if token=="," then --throw it away
  elseif isOp(token) then
    if #opStack==0 or precedance(top()) <= precedance(token) then
      table.insert(opStack, token)
    else
      while #opStack>0 and isOp(top()) do pull() end
      table.insert(opStack, token)
    end
  elseif token=="(" then
    if top()=="." then --function application
      push(token)
      table.insert(opStack, ")")
      funcs=funcs+1
    else
      table.insert(opStack, token)
    end
  elseif token==")" then
    if funcs>0 then --function end
      while #opStack>0 and top()~=")" do pull() end
      pull() --closing parenthesis
      pull() --function application(.)
      funcs=funcs-1
    else --regular parenthesis
      while #opStack>0 and top()~="(" do pull() end
      pop()
    end
  elseif token=="\"" then
    quotes=quotes+1
    if quotes==0 then
      push(token)
    end
    if math.fmod(quotes, 2) ~= 0 then --skip closing quotes
      table.insert(opStack, token)
    end
    if math.fmod(quotes, 4) == 3 then --should be 2 quotes in a row, possible failure point
      pop()
      local i = 2
      while #opStack>0 and i>0 do
        if top()=="\"" then i=i-1 end
        pull()
      end
      quotes=quotes-4
    elseif pos==#inputQ then
      pull()
      opStack={}
    end
  else --literal
    push(token)
  end
end
for _=1, #opStack do
  if top()~="(" then
    pull()
  end
end
--insert bangs inside static function calls
--Done inefficiently for algorithm simplicity
--{"foo", "(", "bar", "(", ")", ".", "5", ")", ".", "!"}
--Needs to insert a bang after the `.` for "bar()"
local function insertBangs(startIndex, endIndex)
  local argBegin
  local argEnd
  local isStrict=false
  for i=startIndex, #outputQ do
    if outputQ[i]=="(" then argBegin=i+1; break end
  end
  if not argBegin then return end
  --find close parenthesis
  for i=endIndex, argBegin, -1 do
    if outputQ[i]==")" then argEnd=i-1; break end
  end
  if not argEnd then return end
  if outputQ[argEnd+2]~="." or outputQ[argEnd+3]~="!" then return end
  argEnd=insertBangs(argBegin, argEnd) or argEnd --insert into any embedded functions
  --insert bangs
  local i=argBegin
  while i<argEnd do
    if outputQ[i]=="." and outputQ[i+1]~="!" then
      table.insert(outputQ, i+1, "!")
      argEnd=argEnd+1
    end
    i=i+1
  end
  return argEnd
end
insertBangs(1, #outputQ)

--Small bug in string parsing, hacky fix
--Might actually be unnecessary, Remove at own risk.
--{"\"", "foo", "\""} will be output instead of {"foo", "\""}
if #outputQ==3 and outputQ[1]=="\"" and outputQ[3]=="\"" then
  table.remove(outputQ, 1)
end
return outputQ
