args={...}
run("spiderLib")
if args[3]:match("&cPlease type '") then
  say(split(args[4], "'")[2])
end
