This is a standard library used in nearly every project in the spider-ppa repository. By default, it is possible to manually download SpiderLib using an install command such as '!cpm install spiderlib'. However, this is intended for users who may want to develop with it and in no way has standalone functionality. You should also be aware that, since there is no version number in the scripts file, any upgrade will always upgrade SpiderLib so long as it is installed. In addition, while I do everything I can to maintain backwards compatability so as to prevent rewrite of scripts and programs, it is possible certain functions may have their functionality tweaked, especially those which are under heavy development. 

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

I am currently looking at the possibility of deprecating spiderLib and rewriting it as a several different, newer, and better modules. tableFileLib would be one such example. If I do, of course, spiderLib will still be available to prevent older packages and scripts from breaking, but would not be under active development.
