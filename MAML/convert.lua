
function convert(file)
  local tokens = run("tokenizer.lua", file)
  local conversion = run("functionInjector.lua", tokens)
  tokens = run("tokenInjector.lua", tokens)
  log(tokens)

  return conversion
end

local converted = convert("~/macromodFiles/moveNorth.txt")
