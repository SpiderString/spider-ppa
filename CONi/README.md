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
  
Originally, this was meant to be used to simplify GUI creation, a task it lends itself to quite well with its embedded scripts and [lazy evaluation](#lazy-expressions). For more on CON formatting, see [CON Format](#con-format)

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

  The CON format was heavily based around the look of CSS while wanting to have something as flexible as XML while doing a job similar to JSON files. CON is based around the ideas of containers(AKA children) and properties(props). Everything in a CON file is contained in the implied root container(`/`). This is the container that, once interpreted, is returned by CONi and put in a wrapper. A CON file is tab delimited for readability and line-sensitive for interpreter simplicity(though this may change in the future). Containers are denoted by their name, a newline, and then an indentation increase. For example,
  ```json
  myprop: "Hello World!"
  x: 50
  myChild
    x: 100
    y: 500
  ```
  This example would create a CON data table of
  ```lua
  {myprop="Hello World!"
  ,x=50
  ,myChild={x=100,
           ,y=500}
  }
  ```
  Specifically, `myChild` is considered a container which has the props `x` and `y`. If we were to then add at the end of our file the line `z: 30`, without indentation, then `z` would become a property of `/` instead of `/myChild`. This is because CON uses indentation(in the form of spaces or tabs, CONi interprets tabs as 2 spaces) to denote scope. If you've ever used Python, this should feel very familiar. While CONi is designed to be extremely lenient, you should take care that your indentation is consistent, or it may throw out lines or even produce undefined behavior. 
  
  As we saw before, it is not necessary to specify that `x: 50` uses `x` as a string. This doesn't mean we can't have number keys, in fact, `1: "myVal"` interprets `1` as a string, but `1="myVal"` uses `1` as a number key. There is currently no way, however, to create containers with number-valued names simply because the syntax hasn't been decided on. Therefor, all children of a CON object are guaranteed to be contained within string indexes of their parent, at least for now. 
  
#### CON Expression parsing
  CON values also support the basic math operators `+`, `-`, `*`, and `/`. These function identically to their Lua counterparts with the one exception that *any failure returns `nil` instead of crashing*. This was done for several reasons, partially for peak stability, but even more importantly to allow for the [lazy features](#lazy-expressions) to be more powerful. For example, all of the following are valid CON props which produce number values
  ```json
  x: 680
  y: 680/2
  scale: 680/(680/2)
  average: (680-(680/2))/2
  42=7*6
  inf:1/0
  ```
  Some of the values these properties would then have are `scale: 2`, `average: 120`, and `inf: nil`. Crucially, since `inf` is assigned the value `nil` statically[more on static vs. dynamic later](#static-versus-dynamic), it will be absent from the table after interpretation(in Lua, any variables assigned `nil` are effectively unassigned). This means you may have unexpected holes in your CON objects if you aren't careful. 

  In addition to mathematical operators, CON has one more operator for its expression parsing: string concatenation. String concatenation is done by juxtaposition(Placing two string-y things next to each other), with `nil` being converted to the empty string `""` and any other value being cast into a string. For example:
  ```json
  txt: "Hell" "o Worl" "d!"
  close: "Spaces don't mat""ter either!"
  5:"15/3="15/3
  ```
  And this would produce the data table
  ```lua
  {txt="Hello World!"
  ,close="Spaces don't matter either!"
  ,["5"]="15/3=5"
  }
  ```
  Due to the lack of error messages in CONi, though, you should be particularly careful to make sure you close all your quotes. Only double quotes `"` are supported for strings and there is currently **NOT** any way to escape quotes and use them inside strings. This is planned to be released soon and will be done by simply using a single backslash `\` before the quote. 

#### Field Referencing
  CON also supports references to fields(properties or containers) by using the dot(`.`) operator. This is done by placing the dot before the name of the field you wish to reference. There is currently **NOT** any way to reference number-index fields. This will likely be implemented by using brackets`[#]` around the number. For example:
  ```json
  guiWidth: 680
  guiHeight: 340
  resolution: .guiWidth/.guiHeight
  ```
###### Static versus Dynamic
  So far, all our values have been statically assigned. By *static*, I mean that the value is known at interpretation time and does not change. This means that, short of changing the field yourself, no matter what you do the value will remain the same after the file is interpreted and it is available immediately. However, by default, references to fields are *dynamic*. What this means is that, rather than setting the field to some value and being done with it, instead, everytime the field is referenced it checks for updates and will re-evaluate itself. Using the above example, this means that, while at interpretation time getting `resolution` would return `2`, if we were to change `guiWidth` to be equal to `120`, we would instead see that `resolution` has changed to be `0.5`!
  
  This reveals one of the most powerful features of CON: the ability to *maintain* relationships between properties. Like I said in the introduction, CON was originally designed for use with GUI elements, a purpose it lends itself very well to as it allows the user to dynamically tweak values and watch all the other elements adjust themselves accordingly. This flexibility is only expanded upon later with [function calls](#function-application), allowing you to use any function within the CON file.

#### Bang! Strict References
  

#### Function Application

  Application syntax here

###### Function Declaration

###### Embedded Scripts

#### Lazy Expressions

## Planned Features
