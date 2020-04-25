# CONi
###### *Writing Classes to Files in AM Lua*


## What is CONi?
  CONi is a Lua based parser for the Concise Object Notation([CON](#con)) format for use within the [Advanced Macros(AM) Minecraft mod](https://www.curseforge.com/minecraft/mc-mods/advanced-macros). It provides full support for the **CON standards(Link to CON Format here)** and supports embedded and external Lua scripts for function declarations. CONi interprets a CON file into a CONi(CON interpreted) Object, which functions as a wrapper around the data and implementation details. 
 
## CON?
  Concise Object Notation(CON) is a format developed by me with help from [TheIncgi](https://github.com/TheIncgi). The goal was to create a method of storing objects that is:
  
- Unified. A CON object can be defined all in one file.
- Idiomatic. The file should be easy to read and write with very little clutter.
- Flexible. CON supports both field references and function calls within the file itself.
- Dynamic. CON distinguishes itself from formats like JSON by being able to store dynamic fields as well as static ones.
  
Originally, this was meant to be used to simplify GUI creation, a task it lends itself to quite well with its embedded scripts and lazy evaluation. For more on CON formatting, see [CON Format](#con-format)

## Getting Started with CONi
  First, you should already have AM installed. From there, you can either download these files and store them in "*.minecraft/mods/advancedMacros/macros*", or you can install it as a package via [CPM](../CobwebPackageManager/) with the command `!cpm install coni`. Once installed, you can load a CON file using `run("~/CONi/coni.lua"):load(filePath::String)`, for example:
  ```lua
  local con=run("~/CONi/coni.lua")
  con:load("gui.con")
  con:log()
  ```
  The first line loads the CONi wrapper library and binds it to `con`, while the second loads `gui.con` and parses it, storing its data into `con`. The `.con` file extension is purely convention and is not necessary. Finally, the third line logs the CON data to the chat in the same way `log()` would show a table. Because of the CONi wrapper and how CON works, though, using `log(con)` would produce fairly useless data, though feel free to try it. Finally, the `:` syntax is a necessary convention due to how the wrapper works, and thus all CONi functions should be used with it, unless you like writing `con.get(con.get(con, "foo"), "bar")`and similar expressions.
  
  Some additional, useful functions provided by the CONi wrapper include(-> denotes return value):
  
- `coni:fields()` -> array of string/number keys which are defined(dynamic values may still return nil).
- `coni:containers()` -> array of all containers(fields which return a sub-CON object)
- `coni:properties()` -> array of all properties(fields which don't return a sub-CON object)
- `coni:get(key::[String|Number])` -> the value associated with a key. If it is a container, it returns another wrapper.
- `coni:set(key::[String|Number], <value>)` -> nil. Sets the value at the field(can overwrite dynamic relationships).
- `getmetatable(coni)=="CONi Wrapper"` -> Can be used along with type checking to tell if a table is a CONi wrapper.

This is not a comprehensive list, and if you want that and more detailed documentation, you should look in the comments at the top of the [`coni.lua`](coni.lua) file. Additionally, it is possible to get the underlying CONi object out of the CONi wrapper by simply indexing `wrapper.con`, though there are very few cases if any where this would be desirable or needed. It is also possible to get and set elements in a CONi wrapper using Lua table indexing, however, this does have the possibility of field collision with the wrapper functions and the reserved `con` field, which `get` and `set` bypass.

## CON Format
