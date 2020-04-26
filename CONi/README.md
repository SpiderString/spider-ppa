# CONi
***
###### *Writing Classes to Files in AM Lua*

## Contents
   ----
- [What is CONi?](#what-is-coni)
- [CON?](#con)
- [Getting Started with CONi](#getting-started-with-coni)
- [CON Format](#con-format)
  - [Quick Syntax Reference](#quick-syntax-reference)
  - [CON Expression Parsing](#con-expression-parsing)
  - [Field Referencing](#field-referencing)
    - [Quick Note on Scope](#quick-note-on-scope)
    - [Static versus Dynamic](#static-versus-dynamic)
  - [Bang! Strict References](#bang-strict-references)
  - [Function Application](#function-application)
    - [Function Declaration](#function-declaration)
    - [Embedded Scripts](#embedded-scripts)
  - [CON Examples](#examples)
- [Planned Features](#planned-features)


## What is CONi?
  CONi is a Lua based parser for the Concise Object Notation([CON](#con)) format for use within the [Advanced Macros(AM) Minecraft mod](https://www.curseforge.com/minecraft/mc-mods/advanced-macros). It provides full support for the **CON standards(Link to CON Format here)** and supports embedded and external Lua scripts for function declarations. CONi interprets a CON file into a CONi(CON interpreted) Object, which functions as a wrapper around the data and implementation details.

## CON?
  Concise Object Notation(CON) is a format developed by me with help from [TheIncgi](https://github.com/TheIncgi). The goal was to create a method of storing objects that is:

- Unified. A CON object can be defined all in one file.
- Idiomatic. The file should be easy to read and write with very little clutter.
- Flexible. CON supports both field references and function calls within the file itself.
- Dynamic. CON distinguishes itself from formats like JSON by being able to store dynamic fields as well as static ones.

Originally, this was meant to be used to simplify GUI creation, a task it lends itself to quite well with its embedded scripts and [lazy evaluation](#static-versus-dynamic). For more on CON formatting, see [CON Format](#con-format)

## Getting Started with CONi
  First, you should already have AM installed. From there, you can either download these files and store them in "*.minecraft/mods/advancedMacros/macros*", or you can install it as a package via [CPM](../CobwebPackageManager/) with the command `!cpm install coni`. Once installed, you can load a CON file using `run("~/CONi/coni.lua"):load(filePath::String)`, for example:
  ```lua
  local con=run("~/CONi/coni.lua")
  con:load("gui.con")
  con:log()
  ```
  The first line loads the CONi wrapper library and binds it to `con`, while the second loads `gui.con` and parses it, storing its data into `con`. The `.con` file extension is purely convention and is not necessary. Finally, the third line logs the CON data to the chat in the same way `log()` would show a table. Because of the CONi wrapper and how CON works, though, using `log(con)` would produce fairly useless data, though feel free to try it. Finally, the `:` syntax is a necessary convention due to how the wrapper works, and thus all CONi functions should be used with it, unless you like writing `con.get(con.get(con, "foo"), "bar")`and similar expressions.

  Some additional, useful functions provided by the CONi wrapper include:
  | Function | Return Type | Description |
  | :------- | :---------: | :---------- |
  | `coni:fields()` | array of keys | Returns all valid keys |
  | `coni:containers()` | array of keys | Returns all keys which point to containers |
  | `coni:properties()` | array of keys | Returns all keys which are not containers |
  | `coni:get(key::[String\|Number])` | any | Returns whatever value is stored at the key |
  | `coni:set(key::[String\|Number], <value>)` | nil | Sets the value at that key. |
  | `getmetatable(coni)` | "Coni Wrapper" | Can be used for type checking |

This is not a comprehensive list, and if you want that and more detailed documentation, you should look in the comments at the top of the [`coni.lua`](coni.lua) file. Additionally, it is possible to get the underlying CONi object out of the CONi wrapper by simply indexing `wrapper.con`, though there are very few cases if any where this would be desirable or needed. It is also possible to get and set elements in a CONi wrapper using Lua table indexing, however, this does have the possibility of field collision with the wrapper functions and the reserved `con` field, which `get` and `set` bypass.

## CON Format

  The CON format was heavily based around the look of CSS while wanting to have something as flexible as XML and doing a job similar to JSON files. Central to CON are the ideas of containers(AKA children) and properties(props). Everything in a CON file is contained in the implied root container(`/`). This is the container that, once interpreted, is returned by CONi and put in a wrapper. A CON file is tab delimited for readability and line-sensitive for interpreter simplicity(though this may change in the future). Containers are denoted by their name, a newline, and then an indentation increase. For example,
  ```python
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
  Specifically, `myChild` is considered a container which has the props `x` and `y`. If we were to then add at the end of our file the line `z: 30`, without indentation, then `z` would become a property of `/` instead of `/myChild`. This is because CON uses indentation(in the form of spaces or tabs, CONi interprets tabs as 2 spaces) to denote scope. If you've ever used Python, this should feel very familiar. While CONi is designed to be extremely lenient, you should take care that your indentation is consistent, or it may throw out lines or even produce undefined behavior. The CON format specifies several additional operators and syntax symbols which we'll get into in due time. The table below, however, gives a quick overview of these, their usage, and a brief description of their meaning.

###### Quick Syntax Reference
  | Operator | Usage | Brief Description |
  | :------: | :---: | :---------------- |
  | : | prop: "val" | String assignment |
  | = | 5="val" | Numeric assignment |
  | + | 3+2 | Numeric addition |
  | - | 3-2 | Numeric subtraction |
  | * | 3\*2 | Multiplication |
  | / | 15/3 | Division |
  | "" | "string", "foo""bar" | Denotes string values |
  | () | .func(), (1+2)/3 | Contains function arguments, mathematical parenthesis |
  | . | .prop, .func() | [Field reference](#field-referencing)/[Function application](#function-application) |
  | , | .max(5, 3) | Used to separate multiple function arguments |
  | ! | !.prop, !.func(), !prop: 5, !1="test" | [Bang operator](#bang-strict-references). Strict evaluation |
  | @ | @func | [Function Declaration](#function-declaration) |
  | $ | $"script" | [Embedded Script Definition](#embedded-scripts) |

  As we saw before, it is not necessary to specify that `x: 50` uses `x` as a string. This doesn't mean we can't have number keys, in fact, `1: "myVal"` interprets `1` as a string, but `1="myVal"` uses `1` as a number key. There is currently no way, however, to create containers with number-valued names simply because the syntax hasn't been decided on. Therefor, all children of a CON object are guaranteed to be contained within string indexes of their parent, at least for now.

#### CON Expression parsing
  CON values also support the basic math operators `+`, `-`, `*`, and `/`. These function identically to their Lua counterparts with the one exception that *any failure returns `nil` instead of crashing*. This was done for several reasons, partially for peak stability, but even more importantly to allow for the [lazy features](#static-versus-dynamic) to be more powerful. For example, all of the following are valid CON props which produce number values
  ```python
  x: 680
  y: 680/2
  scale: 680/(680/2)
  average: (680-(680/2))/2
  42=7*6
  inf:1/0
  ```
  Some of the values these properties would then have are `scale: 2`, `average: 120`, and `inf: nil`. Crucially, since `inf` is assigned the value `nil` statically [more on static vs. dynamic later](#static-versus-dynamic), it will be absent from the table after interpretation(in Lua, any variables assigned `nil` are effectively unassigned). This means you may have unexpected holes in your CON objects if you aren't careful.

  In addition to mathematical operators, CON has one more operator for its expression parsing: string concatenation. String concatenation is done by juxtaposition(Placing two string-y things next to each other), with `nil` being converted to the empty string `""` and any other value being cast into a string. For example:
  ```python
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
  ```python
  guiWidth: 680
  guiHeight: 340
  resolution: .guiWidth/.guiHeight
  ```
###### Quick Note on Scope
   So what happens if two properties have the same name? In short, scope resolution. Whenever a field is referenced, the interpreter picks the property which is "closest" to the property referencing it in the heirarchy. Specifically:

   1. If the property exists in the current container, pick it.
   2. If the property does not exist in the current container, go to the parent container. Go to step 1.
   3. If the property has not been found but you have already checked the root, return `nil`.

   As an example:
   ```python
   x: 5
   y: 10
   bg
      x: 10
      y: .y
      resolution: .x/.y
   ```
   In addition, CON does *technically* support overloading properties(that is, having the same property defined multiple times within the same scope). However, this is not considered at the moment to be a first-class feature and hence, it is not officially supported. If you *do* wish to try it, though, it should work as follows:

   - The top most property(first one) functions normally.
   - The second property(with the same name), when interpreted, will overwrite the previous. However, if it references a property with its name, it will actually use the value previously stored in itself.

###### Static versus Dynamic
  So far, all our values have been statically assigned. By *static*, I mean that the value is known at interpretation time and does not change. This means that, short of changing the field yourself, no matter what you do the value will remain the same after the file is interpreted and it is available immediately. However, by default, references to fields are *dynamic*. What this means is that, rather than setting the field to some value and being done with it, instead, everytime the field is referenced it checks for updates and will re-evaluate itself. Using the above example, this means that, while at interpretation time getting `resolution` would return `2`, if we were to change `guiWidth` to be equal to `120`, we would instead see that `resolution` has changed to be `0.5`!

  This reveals one of the most powerful features of CON: the ability to *maintain* relationships between properties. Like I said in the introduction, CON was originally designed for use with GUI elements, a purpose it lends itself very well to as it allows the user to dynamically tweak values and watch all the other elements adjust themselves accordingly. This flexibility is only expanded upon later with [function calls](#function-application), allowing you to use any function within the CON file.

#### Bang! Strict References
  With as nice as dynamic references can be, sometimes you want to just use a field as a static reference. In this scenario, rather than having the property automatically update whenever the field changes, it would simply use the value defined at interpretation time. For this purpose, CON also has the bang (`!`) operator. The bang operator should be placed before a dot reference and marks that reference *only* as being strict. For example,
  ```python
  guiWidth: 680
  guiHeight: !.guiWidth/2
  widthScale: .guiWidth/!.guiWidth
  ```
  In this example, `guiWidth` is initiated to `680`, while `guiHeight` is initiated to `340` and is strict, meaning that changing `guiWidth` after loading the CON object does *not* change `guiHeight`. The prop `widthScale` shows a mixed usage of strict and dynamic references and is initiated to `1`, but changes when `guiWidth` is updated, maintaining the scale factor of the original width that gives the new width. In other words, changing `guiWidth` to `340` causes `widthScale` to change to `0.5`.

  In addition, if you want an entire property to be strict, the bang can be placed before the property name rather than placing them before every dot operator. As a simple example:
  ```python
  guiWidth: 680
  guiHeight: 340
  !startingResolution: .guiWidth/.guiHeight
  ```
  In this example, `startingResolution` is set to be `2` statically, in the same way as if we were to have instead written `startingResolution: !.guiWidth/!.guiHeight`.

#### Function Application

  Where the power and flexibility of CON truly shines, though, is with function application. Function application uses the dot(`.`) operator in the same way that field references do, with the added necessity of a pair of parenthesis after the function name. These parenthesis contain the function's arguments, if any, and make it clear whether it is a field reference or a function call. Before functions are called, they first must be [*declared*](#function-declaration), or defined, but for now let's assume that the functions `ceil(#)` and `max(#, #)` are already defined and act like their mathematical counterparts.
  ```python
  guiWidth: 680
  guiHeight: 280
  longest: .max(.guiWidth, .guiHeight)
  resolution: .ceil(.guiWidth/.guiHeight)
  ```
  Here, `longest` would be initialized to `680`, and update whenever `guiWidth` or `guiHeight` is changed, and `resolution` would be initialized to `3` and update on any change to `guiWidth` or `guiHeight`. It should be noted that we used a comma(`,`) to separate function arguments and that we can also use *any* expression(dynamic or otherwise) as a function argument as well. Moreover, function application *also* accepts bang operators in the same way field references do, supporting both the prefix syntax(bang-before-dot) and the prop(bang-before-prop name) syntax. It should be noted, though, that if a function is strict, then all of its arguments *automatically become strict*. In other words, `!.foo(.bar, .func())` is equivalent to `!.foo(!.bar, !.func())`. However, because functions can potentially have side effects(that is, they could act differently even with the same arguments), `.foo(!.bar, !.func())` is *not* strictly evaluated(at least, not when looking at `foo`).

  A particularly interesting usage of strict functions is delegating code to be run at interpretation time. In CONi, if a strict or static property returns `nil`, then that property is effectively discarded because CONi is embedded in Lua and setting variables to `nil` in Lua is analogous to freeing them. This can be used to effectively create embedded "init" scripts which run whenever the CON is interpreted. For example:
  ```python
  !_init: .init()
  data: 5
  ```
  When the CON file is loaded and parsed, it will call `init()` once, then(since it returns `nil`) it will throw away the `_init` property, leaving just `data`. This could be done to run some code which sets a variable, or reads input from some external source and creates additional data, or anything else. As a final note with function calls, special care should be taken when working with **blocking functions**. If a function blocks thread execution(say, by waiting for input), it could halt the parser and prevent loading or simply make the process clunky and awkward. The specifics of interpret-time function execution(for those brave enough) are as follows:

  1. If a function call is strict, execute it and store its value
  2. If a field reference is strict, evaluate it and store its value, evaluating any functions as neccessary.

  This means that for *any* function which is either strict or used by a strict function or strict reference, or some nested combination of these, then that function will be executed at interpretation time. Needless to say, this can get quite complicated for large projects, and so it is best to simply avoid using functions which are blocking unless absolutely necessary and to keep careful track of those props which depend on it if you do.

###### Function Declaration
   Of course, for the interpreter to have any idea what you're talking about, you first have to declare the function to begin with. For this purpose, the function declaration(`@`) operator is used. Function declaration is handled by creating a container and prefixing its name with `@`. For example:
   ```python
   @length
      script: "embedded.lua"
   x: .length(.array)
   array
      1="a"
      2="b"
      3="c"
   ```
   In this example we have a function `length` being declared which gets its code from a script named "embedded.lua". We then have a prop `x` which calls the function using `array` for its input. We can imagine that `length` points to an alias for Lua's `#` operator and so returns the number of elements in the array, in this case, `3`. It should be noted, however, that for a function to be recognized, it has to be declared *above any usage of it* because the interpreter *only* checks the lines above a function reference for its declaration. Other than that, function scope resolution behaves identically to field scope resolution, picking the definition closest to the reference in scope. Finally, there are a few fields that a function declaration can have(any others are simply ignored.

   | Property | Example | Description | Optional? |
   | :------: | :-----: | :---------- | :-------: |
   | script | "embedded.lua" | Points to the embedded or external script supplying the function |  |
   | func | "length" | Gives the name of the function in the `script` file | Yes |
   | lang | "Lua" | Specifies the language to use to process it. Interpreter dependent. | Yes |

   A note on the `lang` and `func` props: CONi only supports Lua interpretation of scripts, and so the `lang` prop is useless for it, and the `func` prop should be used to denote that "this is the name of the function within the script". Whether a `func` prop is present or not, the function is called within a CON file by using the name when declared(what comes after `@`).

###### Embedded Scripts
   The `script` prop of a function declaration points to the path of the script which contains the function implementation. The CON format itself is language-agnostic. That is to say, language support is interpreter dependent. In the case of CONi, it supports only Lua scripts without any plans currently to expand this. In addition, CON supports both external *and* embedded scripts(scripts which are contained within the CON file itself), with preference being given to embedded scripts. This means that a CON file can handle object structure and functionality all in one file(or modularly if desired). For embedded scripts, they are defined as a container prefixed with the script operator(`$`). Embedded scripts do not have any concept of scope when and so should be placed somewhere in the root(typically at the bottom of the file). For example:
   ```python
   @length
      script: "embedded.lua"
   x: .length(.array)
   array
      1="a"
      2="b"
      3="c"
   $embedded.lua
      local funcs={}
      function funcs.length(t) return #t end
      return funcs
   ```
   A few things of note: since scripts are still containers, if you are just copy/pasting code into a CON file, you should indent each line once. And, crucially, the script should *return* the functions in some way when executed. For CONi and Lua scripts, this means that when you run it, any functions you wish to access *need* to be returned in a table. If they are not, then the script will simply not load any functions, and all functions which use it will simply be `nil`.

   And with that, you now know all the features and formatting associated with a CON file! If you still need more examples, and applications, then you can check those out [here](#examples), and if you want to know what's next then check out [Planned Features](#planned-features). Or if you're ready to start hacking it out, feel free to check out the documentation for CONi at the top of [coni.lua](coni.lua).

## Examples
   This is one of the example CON files I use during development for test cases. It is actually based off a translation of a GUI I made for CPM. If you have any examples you'd like to add, feel free to submit a pull request for the readme or to message me on Discord if you know me there.
   ```python
   @length
      script: "embedded.lua"
   @text
      func: "textArea"
      script: "embedded.lua"
   @close
      script: "embedded.lua"
   guiWidth: 680
   guiHeight: 340
   onClose: .close()
   yMargin: 40/2
   x: (.guiWidth-.guiHeight)/2
   arrayLen: .length(.array)
   array
      1=3
      2=2
      3=1
   bgPointer: .bg
   bg
      @test
         func: "length"
         script: "embedded.lua"
      type: "rect"
      x: 0
      y: 0
      width: .guiWidth
      height: .guiHeight
      color: 0x70333333
   $embedded.lua
      local funcs={}
      function funcs.length(t) return #t end
      function funcs.close() guiOpen=false end
      function funcs.textArea(packageId, AMVersion)
         return {
         "&6Your Advanced Macros installation is version &c".._MOD_VERSION..".",
         "&6while the package '&b"..packageId.."&6' uses version &c"..AMVersion..".",
         "&6It is &chighly unlikely &6that this package will work with your version.",
         "",
         "",
         "&bInstall anyway?"}
      end
      return funcs
   ```

## Planned Features
   - Number-index field referencing
   - Number-index container declaration
   - Unary minus
   - Decimal support
   - `coni:save()` function
   - Bang expansion
