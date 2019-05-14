--returns a table of functions for creating CLI systems
--PlainLine:line is an unformatted line of chat without a username, like what is returned by ChatSendFilter
--Line:line is a formatted line of chat with a username, like what is returned by Chat
--<arrows> denote optional arguments
--Current Functions:
--lib.getArguments(PlainLine:line, <String:commandPrefix>)  --returns each field of a command, seperated by spaces, as a table. If the commandPrefix is not at the start of the line, returns nil.
--lib.getCommand(PlainLine:line, <String:commandPrefix>)  --returns the command, i.e. the first field after the command prefix.
--lib.getUsername(PlainLine:line) --returns the username of whoever sent a chat line. Not guaranteed to work on all servers.
--lib.stripUsername(PlainLine:line) --returns a line of chat without the username. Not guaranteed to work on all servers.
--lib.stripFormat(Line:line)  --returns a PlainLine from a given Line. May remove regular text.

local lib={}

function lib.getArguments(line, prefix)
  local output={}
  if line==nil or line:match("^[%s]*$") then return nil end
  line=line:gsub("^[%s]*", "")
  if prefix then
    if not line:match("^"..prefix) then return nil end
    line=line:gsub("^"..prefix, ""):gsub("^[%s]*", "")
  end
  if line==nil or line:match("^[%s]*$") then return nil end
  while line do
    local a=line:find(" ")
    if not a then a=line:len()+1 end
    table.insert(output, line:sub(1, a-1))
    line=line:sub(a+1):gsub("^[%s]*", "")
    if line:match("^[%s]*$") then line=nil end
  end
  return output
end
function lib.getCommand(line, prefix)
  local args=lib.getArguments(line, prefix)
  if args then return args[1] end
  return args
end
function lib.getUsername(line)
  local a = line:find(": ")
  local b = line:find("> ")
  if a and b then
    a=math.min(a, b)
  else
    a=a or b
  end
  local c=line:find("<")
  b=line:find(" ")
  if c then
    b=math.min(b, c)
  end
  b=math.max(b, 1)
  if not a or not b then return nil end
  if b>a then b=1 end
  return line:sub(b+1, a-1)
end
function lib.stripUsername(line)
  local username=lib.getUsername(line)
  if not username then return line end
  local a, b = line:find(username)
  a=line:find(" ", b+1)
  return line:sub(a+1)
end
function lib.stripFormat(line)
  local a, b = line:find("&[0123456789abcdefklmnor]")
  while a and b do
    line=line:sub(1, a-1)..line:sub(b+1)
    a, b = line:find("&[0123456789abcdefklmnor]")
  end
  return line
end
return lib
