--returns a table of functions for various miscellenaous applications
--<arrows> denote optional arguments
--Current Functions:
--lib.cat(String:filePath)  --stores each line of a file to a table and returns it
--lib.getLines(String:filePath) --gets the number of lines in a file
--lib.split(String:str, String:delimeter) --breaks up a string into fields based on the regex and returns it as a table
--lib.search(Table:t, String:regex) --searches a table's values for matches and returns a table of matches. Requires values be strings.
--lib.map(Function:f, Table:t) --applies a function over every entry in a table, returning a new table.
--lib.intercalate(Value:v, Table:t) --takes a 2+ dimensional array and a value to place between the each of the first layers.
--  E.G. intercalate("\n", {{1, 2}, {3, 4}}) -> {1, 2, "\n", 3, 4}
--lib.concat(Table:t) -- takes a 2+ dimensional array and removes one layer of nesting.
--  E.G. concat({{1, 2}, {3, 4}}) -> {1, 2, 3, 4}
--lib.intersperse(Value:v, Table:t) --takes an array t and places a value v between each entry
--lib.nodups(Table:t) --takes an array and removes all duplicates, keeping the first entry. No guaranteed efficiency for larger arrays.
--lib.contains(Value:v, Table:t) --takes a table and return true/false depending on if it contains a value equal to the value supplied
--lib.combinations(Int:n, Array:t) --returns an array of all combinations of t with length n. E.G. combinations(2, {"a", "b", "c"} -> {{"a", "b"}, {"a", "c"}, {"b", "c"}}

local lib={}
function lib.cat(filePath)
  local output={}
  if not filesystem.exists(filePath) then return nil end
  local file=filesystem.open(filePath, "r")
  while file:available()>0 do
    table.insert(output, file:readLine())
  end
  file:close()
  return output
end
function lib.getLines(filePath)
  local output=0
  if not filesystem.exists(filePath) then return 0 end
  local file=filesystem.open(filePath, "r")
  while file:available()>0 do
    output=output+1
  end
  file:close()
  return output
end
function lib.split(str, del)
  local output={}
  local index=1
  for word in str:gsub("%"..del.."%"..del, "%"..del.." ".."%"..del):gmatch("[^".."%"..del.."]+") do
    output[index]=word
    index=index+1
  end
  return output
end
function lib.search(t, reg)
  local output={}
  for key, value in pairs(t) do
    for match in value:gmatch(reg:gsub("%-", "%%-")) do
      table.insert(output, value)
    end
  end
  return output
end
function lib.map(f, t)
  local output={}
  for key, value in pairs(t) do
    output[key]=f(value)
  end
  return output
end
function lib.intercalate(v, t)
  local output={}
  for _, value in ipairs(t) do
    for _, v2 in ipairs(value) do
      table.insert(output, v2)
    end
    table.insert(output, v)
  end
  table.remove(output)
  return output
end
function lib.concat(t)
  local output={}
  for _, value in ipairs(t) do
    for _, v2 in ipairs(value) do
      table.insert(output, v2)
    end
  end
  return output
end
function lib.intersperse(v, t)
  local output={}
  for _, value in ipairs(t) do
    table.insert(output, value)
    table.insert(output, v)
  end
  table.remove(output)
  return output
end
function lib.nodups(t)
  local output={}
  for _, value in ipairs(t) do
    if not lib.contains(value, output) then
      table.insert(output, value)
    end
  end
  return output
end
function lib.contains(v, t)
  for _, value in pairs(t) do
    if value==v then return true end
  end
  return false
end
function lib.combinations(n, t)
  assert(math.floor(n) == n)
  local output={}
  if #t == 0 then return {} end
  if n == 0 then return {} end
  if n == 2 and #t == 1 then return {} end
  if n == 1 then
    for _, v in ipairs(t) do
      table.insert(output, {v})
    end
    return output
  end
  local buffer={}
  for i, v in pairs(t) do buffer[i]=v end
  local t = buffer
  local head = table.remove(t, 1)
  local inner = lib.combinations(n-1, t)
  local tail = lib.combinations(n, t)
  local cons = function(_t) table.insert(_t, 1, head); return _t; end
  local init = lib.map(cons, inner)

  return lib.concat({init, tail})
end

return lib
