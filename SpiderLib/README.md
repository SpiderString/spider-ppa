This is a standard library used in nearly every project in the spider-ppa repository. By default, it is possible to manually download SpiderLib using an install command such as '!cpm install spiderlib'. However, this is intended for users who want to develop with it and in no way has standalone functionality. You should also be aware that, since there is no version number in the scripts file, any upgrade will always upgrade SpiderLib so long as it is installed. In addition, while I do everything I can to maintain backwards compatability so as to prevent rewrite of scripts and programs, it is possible certain functions may have their functionality tweaked, especially those which are under heavy development. 

tableFileLib is a library which returns a table of functions aimed at the interaction of tables and files. It is capable of storing tables into files in a JSON-like format. Currently, its functions include:

  write()
  
  append()/insert()
  
  read()
  
  search()
  
  doesTableExist()/doesObjectExist()
  
  replace()
  
  delete()/remove()
  
  rename()
  
A full syntax guide can be found in comments at the top of its file. 

inventoryLib is a library which returns a table of functions for inventory manipulation and querying. Currently it has 12 unique functions and 9 aliases, a full syntax guide and description of which can be found in comments at the top of the file.
To include it, do the same as you would for tableFileLib. Run it, grab the table it returns, and use that table to call its functions.


To use tableFileLib, you should catch the table it returns in a variable, e.g. local tfl=run("tableFileLib.lua"). You can then call its functions by prefixing it with "tfl.", e.g. tfl.write(obj, filePath, tableID).

structureLib is a library which returns a table of functions for creating various strictly typed emulated datastructures such as stacks, queues, linked lists, and arrays. For a full list of implemented data structures and syntax guide, view the comments at the top of the file.

commandLib is a library which returns a table of functions for creating command line interfaces(CLI's). This is based around the concept of "command prefixes"(think "!" or "/") and "fields", or different parts(arguments) of the command based on space seperation. Though this library is aimed mostly towards ingame chat CLI's, it should be usable for any text source.


Please note that spiderLib.lua is deprecated. Instead, its functions are being swapped over to various modules with expanded functionality, more efficiency, and more stable design. The file will be kept to avoid breaking existing projects, but use it at your own risk. To use spiderLib, simply run() the file in your script with a call such as run("spiderLib"). All its functions may then simply be called by name.
