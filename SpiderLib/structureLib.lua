--returns a table of functions for manipulating tables and emulating certain datastructures
--<arrows> denote optional arguments
--Syntax Guide:

--Emulated datastructures:
--  Arrays
--  Stacks
--  Queues
--  Double Queues/Double Ended Queues/Dequeues
--  Linked List
--  Double Linked List

--Array Functions:
--  lib.newArray(String:arrayType) --returns a table designed to emulate an array with the given datatype. arrayType should be what the value returns when passed into type()
--  array.len() --returns number of elements in the array. #array will also work.
--  array.type() --returns the array type
--  array.delete(Number:index) --removes the given element and shifts the array down, equivalent to array[index]=nil
--  array.getClass() --returns "array", can be used to check the type of the data structure.
--  array.log() --logs the array's data, emulated base log() function. log(array) will NOT work properly.
--  array.getMinIndex() --returns the smallest defined index
--  array.getMaxIndex() --returns the largest defined index
--  array.getMinValue() --returns the smallest value
--  array.getMaxValue() --returns the largest value
--  array.clear() --deletes all elements from the array
--  array.isEmpty() --returns if the array is empty or not
--  array.insert(Number:position, value) --adds the value at the given position and shifts other values down

--Array Aliases:
--  array.length() --alias for array.len()
--  array.size() --alias for array.len()
--  array.remove(Number:index) --alias for array.delete()

--Stack Functions:
--stack[anything]=val can be used, but is not recommended. Use stack.push(val) instead.
--stack[anything] can be used to return the top value, but is not recommended. Use stack.top() or stack.pop() instead.
--Iterating through the stack with pairs() or ipairs() will empty the stack.
--  lib.newStack(String:stackType) --returns a table emulating a strictly typed stack. stackType should be what the values return when passed into type()
--  stack.len() --returns number of elements in the stack. #stack will also work.
--  stack.log() --logs the stack to chat, similar to AM's log(). log(stack) will NOT work.
--  stack.top() --returns the top value of the stack without editing the stack.
--  stack.pop() --returns and removes the top value off the stack
--  stack.push(value)  --adds the value to the top of the stack
--  stack.type() --returns the datatype of the stack
--  stack.getClass() --returns "stack", can be used to check the type of the data structure.
--  stack.clear() --removes all values from the stack
--  stack.copy()  --returns an identical stack without altering the original
--  stack.isEmpty() --returns if the stack is empty or not.

--Stack Aliases:
--  stack.length() --alias for stack.len()
--  stack.size()  --alias for stack.len()
--  stack.clone() --alias for stack.copy()

--Queue Functions:
--queue[anything]=val can be used, but is not recommended. Use queue.push(val) instead.
--queue[anything] can be used to return the front value, but is not recommended. Use queue.front() or queue.pop() instead.
--Iterating through the queue with pairs() or ipairs() will empty the queue.
--  lib.newQueue(String:queueType) --returns a table emulating a strictly typed queue. queueType should be what the values return when passed into type()
--  queue.push(value) --adds the value to the back of the queue
--  queue.pop() --removes and returns the value from the front of the queue
--  queue.front() --returns the value from the front of the queue without removing it
--  queue.len() --returns the number of elements in the queue. #queue also works.
--  queue.isEmpty() --returns if the queue is empty or not
--  queue.getClass() --return "queue", can be used to check the type of the data structure.
--  queue.clear() --removes all elements from the queue.
--  queue.copy()  --returns an identical queue
--  queue.flip()  --reverses the order of all elements in the queue
--  queue.log() --logs the queue. Similar to AM's log(). log(queue) will NOT work.

--Queue Aliases:
--  queue.peek()  --alias for queue.front()
--  queue.length()  --alias for queue.len()
--  queue.size()  --alias for queue.len()
--  queue.enqueue(value)  --alias for queue.push()
--  queue.dequeue() --alias for queue.pop()
--  queue.clone() --alias for queue.copy()
--  queue.reverse() --alias for queue.flip()

--Double Queue Functions:
--dequeue[anything]=val can not be used. Use dequeue.push() or dequeue.pushFront() instead.
--dequeue[anything] can not be used. Use dequeue.front(), dequeue.pop(), dequeue.back(), or dequeue.popBack() instead.
--pairs() and ipairs() iterate through the queue from back to front, identical to a regular queue
--  lib.newDoubleQueue(String:queueType)  --returns a table emulating a strictly typed dequeue. queueType should be what the values return when passed into type()
--  dequeue.push(value) --adds the value to the back of the queue
--  dequeue.pushFront(value)  --adds the value to the front of the queue
--  dequeue.pop() --returns and removes the value at the front of the queue
--  dequeue.popBack() --returns and removes the value at the back of the queue
--  dequeue.front() --returns but leaves the value at the front of the queue
--  dequeue.back()  --returns but leaves the value at the back of the queue
--  dequeue.log() --logs the queue to chat. Emulates AM's log(). log(queue) will NOT work.
--  dequeue.len() --returns the number of elements in the queue. #dequeue will also work.
--  dequeue.getClass() --returns "dequeue". Can be used to check the type of the data structure
--  dequeue.isEmpty() --returns if the queue has no elements
--  dequeue.clear() --removes all elements from the queue
--  dequeue.copy()  --returns an identical dequeue
--  dequeue.flip()  --reverses the order of all elements in the queue

--Double Queue Aliases:
--  dequeue.popFront() --alias for dequeue.pop()
--  dequeue.pushBack() --alias for dequeue.push()
--  dequeue.peek()  --alias for dequeue.front()
--  dequeue.peekFront() --alias for dequeue.front()
--  dequeue.peekBack()  --alias for dequeue.back()
--  dequeue.size()  --alias for dequeue.len()
--  dequeue.length()  --alias for dequeue.len()
--  dequeue.clone() --alias for dequeue.copy()
--  dequeue.reverse() --alias for dequeue.flip()

--Linked List Functions:
--  lib.newLinkedList(String:listType) --returns a table emulating a strictly typed linked list. listType should be what the values return when passed into type()
--  list.append(value)  --creates a new node at the end of the list with the given value
--  list.insert(Number:nodeID, value) --inserts a node at the given nodeID's position. If nodeID is nil, inserts at the beginning of the list.
--  list.remove(Number:nodeID) --removes a node at the given nodeID's position. If nodeID is nil, removes the first node.
--  list.getNode(Number:nodeID) --returns a table representing a given node. If nodeID is nil, returns the first node. The node has the fields "value" and "next"
--  list.getValue(Number:nodeID)  --returns the value held in the node. If nodeID is nil, returns the first node's data.
--  list.getNext(Number:nodeID) --returns the id of the next node. if nodeID is nil, it returns the id of the SECOND node(first node's "next").
--  list.getPrev(Number:nodeID) --returns the id of the previous node. If nodeID is nil, returns nil. If nodeID is the first node, returns nil.
--  list.getFirst() --returns the id of the first node
--  list.getLast()  --returns the id of the last node
--  list.len()  --returns the amount of nodes in the list
--  list.getClass() --returns "linkedlist". Can be used to check the type of the data structure
--  list.isEmpty()  --returns if the list has no nodes
--  list.clear()  --removes all nodes from the list
--  list.log()  --logs the list to chat. Emulates AM's log(). log(list) will NOT work.

--Linked List Aliases:
--  list.length() --alias for list.len()
--  list.size() --alias for list.len()
--  list.getPrevious(Number:nodeID) --alias for list.getPrev()
--  list.delete(Number:nodeID)  --alias for list.remove()

--Double Linked List Functions:
--  lib.newDoubleLinkedList(String:listType) --returns a table emulating a strictly typed doubly linked list. listType should be what the values return when passed into type()
--  list.append(value)  --creates a new node at the end of the list with the given value
--  list.prepend(value) --creates a new node at the beginning of the list with the given value
--  list.insert(Number:nodeID, value) --inserts a node at the given nodeID's position. If nodeID is nil, inserts at the beginning of the list.
--  list.remove(Number:nodeID)  --removes a node at the given nodeID's position. If nodeID is nil, removes the first node.
--  list.getNode(Number:nodeID) --returns a table representing a given node. If nodeID is nil, returns the first node. The node has the fields "value", "next", and "prev".
--  list.getValue(Number:nodeID)  --returns the value held in the node. If nodeID is nil, returns the first node's data.
--  list.getNext(Number:nodeID) --returns the id of the next node. If nodeID is nil, it returns the id of the SECOND node(first node's "next").
--  list.getPrev(Number:nodeID) --returns the id of the previous node. If nodeID is nil, returns nil. If nodeID is the first node, returns nil.
--  list.getFirst() --returns the id of the first node
--  list.getLast()  --returns the id of the last node
--  list.len()  --returns the amount of nodes in the list
--  list.getClass() --returns "doublelinkedlist". Can be used to check the type of the data structure
--  list.isEmpty()  --returns if the list has no nodes
--  list.clear()  --removes all nodes from the list
--  list.log()  --logs the list to chat. Emulates AM's log(). log(list) will NOT work.

--Double Linked List Aliases:
--  list.length() --alias for list.len()
--  list.size() --alias for list.len()
--  list.getPrevious(Number:nodeID) --alias for list.getPrev()
--  list.appendFront(value) --alias for list.append()
--  list.appendBack(value)  --alias for list.prepend()
--  list.delete(Number:nodeID)  --alias for list.remove()


local lib={}
function lib.logTable(data)
  local tableColor="&e" --default &e
  local keyColor="&c" --default &c
  local valueColor="&b" --default &b
  local baseColor="&f"  --default &f
  log(tableColor..tostring(data).." "..baseColor.."{")
  local tabs=1
  --function doesn't print table header
  local function printTable(data)
    local function printValue(id, val)
      local string=string.rep("  ", tabs)..baseColor.."["
      --keys
      if type(id)=="number" then
        string=string..keyColor..id..baseColor.."] = "
      elseif type(id)=="string" then
        string=string.."\""..keyColor..id..baseColor.."\"".."] = "
      else
        error("Table key \""..id.."\" is neither of number or string type!")
      end
      --values
      if type(val)=="number" then
        string=string..valueColor..val
        log(string)
      elseif type(val)=="string" then
        string=string..baseColor.."\""..valueColor..val..baseColor.."\""
        log(string)
      elseif type(val)=="table" then
        string=string..tableColor..tostring(val).." "..baseColor.."{"
        local elements=0
        for i, j in pairs(val) do
          elements=elements+1
        end
        if elements==0 then
          string=string.."}"
          log(string)
        else
          log(string)
          tabs=tabs+1
          printTable(val)
        end
      end
    end --printValue() end
    if pcall(data.getClass())=="array" then
      for id, val in ipairs(data) do
        printValue(id, data[id])
      end
    else
      for id, val in pairs(data) do
        printValue(id, val)
      end
    end
    tabs=tabs-1
    log(string.rep("  ", tabs)..baseColor.."}")
  end --local function end
  printTable(data)
end

function lib.newArray(arrType)
  local arr={}
  local meta={}
  local data={}
  --recreation of AM's log() function for tables but with actual useful information for the array
  --adds quotes around string keys
  function arr.isEmpty()
    for id, val in pairs(data) do
      return false
    end
    return true
  end
  function arr.clear()
    for id, val in pairs(data) do
      rawset(data, id, nil)
    end
  end
  function arr.getMinIndex()
    local minIndex
    for id, val in pairs(data) do
      if minIndex==nil or id < minIndex then
        minIndex=id
      end
    end
    return minIndex
  end
  function arr.getMaxIndex()
    local maxIndex
    for id, val in pairs(data) do
      if maxIndex==nil or id > maxIndex then
        maxIndex=id
      end
    end
    return maxIndex
  end
  function arr.getMaxValue()
    local max
    for id, val in pairs(data) do
      if max==nil or val>max then
        max=val
      end
    end
    return max
  end
  function arr.getMinValue()
    local min
    for id, val in pairs(data) do
      if min==nil or val<min then
        min=val
      end
    end
    return min
  end
  function arr.getClass()
    return "array"
  end
  function arr.log()
    lib.logTable(arr)
  end
  function arr.type()
    return arrType
  end
  function arr.len()
    local length=0
    for index, val in pairs(data) do
      length=length+1
    end
    return length
  end
  function arr.length()
    return arr.len()
  end
  function arr.size()
    return arr.len()
  end
  function arr.delete(index)
    if type(index)~="number" then
      error("Attempt to delete array index of non-number type")
    elseif index%1~=0 then
      error("Attempt to delete array index of non-integer type")
    else
      --sets data[index]=nil and shifts the array down
      for id, val in ipairs(arr) do
        if id==index then
          rawset(data, index, nil)
        elseif id>index then
          rawset(data, id-1, val)
        end
      end
      rawset(data, arr.getMaxIndex(), nil) --deletes last elements
    end
  end
  function arr.remove(index)
    arr.delete(index)
  end
  function arr.insert(pos, val)
    if type(pos)~="number" then
      error("Attempt to set array index with non-number type")
    elseif index%1~=0 then
      error("Attempt to set array index with non-integer type")
    elseif type(val)=="table" and val.isArray() then
      if val.type()~=arrType then
        error("Attempt to combine mixed-type arrays")
      else
        table.insert(data, pos, val)
      end
    elseif type(val)~=arrType and val~=nil then
      error("Attempt to set "..arrType.." array with non-"..arrType.." type")
    elseif val~=nil then
      table.insert(data, pos, val)
    else
      arr.delete(pos)
    end
  end
  --metatable
  meta.__newindex=function (array, index, val)
    if type(index)~="number" then
      error("Attempt to set array index with non-number type")
    elseif index%1~=0 then
      error("Attempt to set array index with non-integer type")
    elseif type(val)=="table" and val.isArray() then --permits recursive array construction
      if val.type()~=arrType then
        error("Attempt to combine mixed-type arrays")
      else
        rawset(data, index, val)
      end
    elseif type(val)~=arrType and val~=nil then
      error("Attempt to set "..arrType.." array with non-"..arrType.." type")
    elseif val~=nil then
      rawset(data, index, val)
    else --e.g. array[5]=nil
      arr.delete(index)
    end
  end
  meta.__index=function (array, index)
    if type(index)~="number" then
      error("Attempt to index array with non-number type")
    elseif index%1~=0 then
      error("Attempt to index array with non-integer type")
    else
      return data[index]
    end
  end
  meta.__len=function (t) return t.len() end
  meta.__pairs=function (array)
    return next, data, nil
  end
  meta.__ipairs=function (array)
    if not array.isEmpty() then
      local i=array.getMinIndex()-1
      local function iter(array, i)
        i=i+1
        local v=array[i]
        if v then return i, v end
      end
      return iter, array, i
    else
      return next, data, nil
    end
  end
  setmetatable(arr, meta)
  return arr
end
function lib.newStack(stackType)
  local stack={}
  local meta={}
  local data={}
  function stack.isEmpty()
    if stack.top() then return false
    else return true end
  end
  function stack.log()
    log(data)
  end
  function stack.len()
    return #data
  end
  function stack.length()
    return #data
  end
  function stack.size()
    return #data
  end
  function stack.top()
    return rawget(data, 1)
  end
  function stack.type()
    return stackType
  end
  function stack.getClass()
    return "stack"
  end
  function stack.pop() --returns and removes the top element
    return table.remove(data, 1)
  end
  function stack.push(val) --are two dimensional stacks a thing? Should I implement that?
    if type(val)==stackType then
      table.insert(data, 1, val)
    else
      error("Attempt to push '"..type(val).."' onto "..stackType.."-type stack")
    end
  end
  function stack.clear()
    for id, val in pairs(stack) do
    end
  end
  function stack.copy()
    local t=lib.newStack(stackType)
    local v={}
    for id, val in pairs(data) do
      v[#stack-(id-1)]=val
    end
    for id, val in ipairs(v) do
      t.push(val)
    end
    return t
  end
  function stack.clone()
    return stack.copy()
  end
  --metatable functions
  meta.__newindex=function(stack, index, val) --index is ignored, essentially an alias for stack.push()
    stack.push(val)
  end
  meta.__index=function(stack, index) --index is ignored, alias for stack.top()
    return stack.top()
  end
  meta.__len=function (stack) return #data end
  meta.__pairs=function(stack)
    local i=0
    if #stack~=0 then
      local function iter(stack, i)
        i=i+1
        if #stack~=0 then return i, stack.pop() end
      end
      return iter, stack, i
    else
      return next, data
    end
  end
  meta.__ipairs=meta.__pairs
  setmetatable(stack, meta)
  return stack
end
function lib.newQueue(queueType)
  local queue={}
  local meta={}
  local data={}
  function queue.log()
    log(data)
  end
  function queue.push(val)
    if type(val)==queueType then
      table.insert(data, val)
    else
      error("Attempt to push '"..type(val).."' into "..queueType.."-type queue")
    end
  end
  function queue.enqueue(val)
    queue.push(val)
  end
  function queue.isEmpty()
    if queue.front() then return false else return true end
  end
  function queue.getClass()
    return "queue"
  end
  function queue.clear()
    for id, val in pairs(queue) do end
  end
  function queue.len()
    return #data
  end
  function queue.length()
    return #data
  end
  function queue.size()
    return #data
  end
  function queue.pop()
    return table.remove(data, 1)
  end
  function queue.dequeue()
    return queue.pop()
  end
  function queue.front()
    return data[1]
  end
  function queue.peek()
    return data[1]
  end
  function queue.copy()
    local t=lib.newQueue(queueType)
    for id, val in ipairs(data) do
      t.push(val)
    end
    return t
  end
  function queue.clone()
    return queue.copy()
  end
  function queue.flip()
    local t={}
    local len=#queue
    for id, val in ipairs(queue) do
      t[len-(id-1)]=val
    end
    for id, val in ipairs(t) do
      queue.push(t[id])
    end
  end
  function queue.reverse()
    queue.flip()
  end

  --metatable functions
  meta.__newindex=function(queue, index, val) --index is ignored, essentially this is an alias for queue.push()
      queue.push(val)
  end
  meta.__index=function(queue, index)
    return queue.pop()
  end
  meta.__len=function (queue) return #data end
  meta.__pairs=function(queue)
    local i=0
    if #queue~=0 then
      local function iter(queue, i)
        i=i+1
        if #queue~=0 then return i, queue.pop() end
      end
      return iter, queue, i
    else
      return next, data
    end
  end
  meta.__ipairs=meta.__pairs
  setmetatable(queue, meta)
  return queue
end
function lib.newDoubleQueue(queueType)
  local queue={}
  local data={}
  local meta={}
  function queue.getClass()
    return "dequeue"
  end
  function queue.copy()
    local t=lib.newDoubleQueue(queueType)
    for id, val in ipairs(data) do
      t.push(val)
    end
    return t
  end
  function queue.clone()
    return queue.copy()
  end
  function queue.flip()
    local t=queue.copy()
    queue.clear()
    for id, val in pairs(t) do
      queue.pushFront(val)
    end
  end
  function queue.reverse()
    queue.flip()
  end
  function queue.isEmpty()
    if queue.front() then return false
    else return true end
  end
  function queue.clear()
    for id, val in pairs(queue) do end
  end
  function queue.log()
    log(data)
  end
  function queue.len()
    return #data
  end
  function queue.size()
    return queue.len()
  end
  function queue.length()
    return queue.len()
  end
  function queue.pop() --pops front element
    return table.remove(data, 1)
  end
  function queue.popFront()
    return queue.pop()
  end
  function queue.popBack() --pops back element
    return table.remove(data, #data)
  end
  function queue.front()
    return data[1]
  end
  function queue.peek()
    return queue.front()
  end
  function queue.peekFront()
    return queue.front()
  end
  function queue.back()
    return data[#data]
  end
  function queue.peekBack()
    return queue.back()
  end
  function queue.push(val) --pushes to back
    if type(val)==queueType then
      table.insert(data, val)
    else
      error("Attempt to push '"..type(val).."' into "..queueType.."-type queue")
    end
  end
  function queue.pushBack(val)
    queue.push(val)
  end
  function queue.pushFront(val) --pushes to front
    if type(val)==queueType then
      table.insert(data, 1, val)
    else
      error("Attempt to push '"..type(val).."' into "..queueType.."-type queue")
    end
  end

  --metatable functions
  meta.__newindex=function(index, val) end
  meta.__index=function(index) return nil end
  meta.__len=function(queue) return #data end
  meta.__pairs=function(queue)
    local i=0
    if #queue~=0 then
      local function iter(queue, i)
        i=i+1
        if #queue~=0 then return i, queue.pop() end
      end
      return iter, queue, i
    else
      return next, data
    end
  end
  meta.__ipairs=meta.__pairs
  setmetatable(queue, meta)
  return queue
end
function lib.newLinkedList(listType)
  --nodes are of the format {value:val, next:nextID}
  local data={}
  local list={}
  local meta={}
  local first, last
  function list.len()
    local length=0
    for index, node in pairs(data) do
      length=length+1
    end
    return length
  end
  function list.log()
    local tableColor="&e" --default &e
    local keyColor="&c" --default &c
    local valueColor="&b" --default &b
    local baseColor="&f"  --default &f
    log(tableColor..tostring(data).." "..baseColor.."{")
    for id, val in pairs(list) do
      local string="  "..baseColor.."["..keyColor..id..baseColor.."] = "..valueColor..val
      log(string)
    end
    log(baseColor.."}")
  end
  function list.size()
    return list.len()
  end
  function list.length()
    return list.len()
  end
  function list.getClass()
    return "linkedlist"
  end
  function list.isEmpty()
    if list.len()==0 then
      return true
    else
      return false
    end
  end
  function list.clear()
    for id, val in pairs(data) do
      data[id]=nil
    end
  end
  function list.append(val)
    if type(val)==listType then
      local index=#data+1
      table.insert(data, {value=val, next=nil})
      if last then
        data[last].next=index --remaps previous last to the new last element
      end
      last=index
      if first==nil then
        first=index
      end
    else
      error("Attempt to append "..type(val).." to "..listType.."-type list")
    end
  end
  function list.insert(index, val)
    if index==nil then
      index=first
    end
    local prev=list.getPrev(index)
    local length=#data+1
    table.insert(data, {value=val, next=index})
    if prev then
      data[prev].next=length
    else
      first=length
    end
  end
  function list.remove(index)
    if index==nil then
      index=first
    end
    if index then
      local next=list.getNext(index)
      local prev=list.getPrev(index)
      if prev then
        data[prev].next=next
      end
      data[index]=nil
      if index==first then first=next end
      if index==last then last=prev end
    end
  end
  function list.delete(index)
    list.remove(index)
  end
  function list.getNode(nodeID)
    if not first then return nil end
    if nodeID==nil then
      return data[first]
    end
    return data[nodeID]
  end
  function list.getValue(nodeID)
    if not first then return nil end
    if nodeID==nil then
      return data[first].value
    end
    return data[nodeID].value
  end
  function list.getNext(nodeID)
    if not first then return nil end
    if nodeID==nil then
      return data[first].next
    end
    return data[nodeID].next
  end
  function list.getPrev(nodeID)
    if not first then return nil end
    if nodeID==nil then return nil end
    if nodeID==first then return nil end
    for id, val in pairs(list) do
      if list.getNext(id)==nodeID then
        return id
      end
    end
  end
  function list.getPrevious(nodeID)
    return list.getPrev(nodeID)
  end
  function list.getFirst()
    return first
  end
  function list.getLast()
    return last
  end

  --metatable functions
  meta.__newindex=function(index, val) --alias for list.insert()
    list.insert(index, val)
  end
  meta.__index=function(index) --alias for list.getValue()
    return list.getValue(index)
  end
  meta.__pairs=function(list)
    local i=first
    if first then
      i=nil
      local function iter(list, i)
        if i==nil then i=first
        else i=list.getNext(i) end
        local v=list.getNode(i)
        if v then
          return i, v.value
        end
      end
      return iter, list, i
    else
      return next, data
    end
  end
  meta.__ipairs=meta.__pairs
  meta.__len=function(t) return t.len() end
  setmetatable(list, meta)
  return list
end
function lib.newDoubleLinkedList(listType)
  --nodes are of the format {value:val, next:nextID, prev:prevID}
  local data={}
  local meta={}
  local list={}
  local first, last
  function list.len()
    local length=0
    for index, node in pairs(data) do
      length=length+1
    end
    return length
  end
  function list.log()
    local tableColor="&e" --default &e
    local keyColor="&c" --default &c
    local valueColor="&b" --default &b
    local baseColor="&f"  --default &f
    log(tableColor..tostring(data).." "..baseColor.."{")
    for id, val in pairs(list) do
      local string="  "..baseColor.."["..keyColor..id..baseColor.."] = "..valueColor..val
      log(string)
    end
    log(baseColor.."}")
  end
  function list.size()
    return list.len()
  end
  function list.length()
    return list.len()
  end
  function list.isEmpty()
    if list.len()==0 then
      return true
    end
    return false
  end
  function list.clear()
    for id, val in pairs(data) do
      data[id]=nil
    end
  end
  function getClass()
    return "doublelinkedlist"
  end
  function list.append(val)
    if type(val)==listType then
      local index=#data+1
      table.insert(data, {value=val, next=nil, prev=last})
      if last then
        data[last].next=index --remaps previous last to point to the new last node
      end
      last=index
      if first==nil then
        first=index
      end
    else
      error("Attempt to append "..type(val).." to "..listType.."-type list")
    end
  end
  function list.prepend(val)
    if type(val)==listType then
      local index=#data+1
      table.insert(data, {value=val, next=first, prev=nil})
      if first then
        data[first].last=index  --remaps previous first to point to the new first node
      end
      first=index
      if last==nil then
        last=index
      end
    else
      error("Attempt to append "..type(val).." to "..listTYpe.."-type list")
    end
  end
  function list.appendFront(val)
    list.append(val)
  end
  function list.appendBack(val)
    list.prepend(val)
  end
  function list.insert(index, val)
    if index==nil then
      index=first
    end
    local previous=list.getPrev(index)
    local length=#data+1
    table.insert(data, {value=val, next=index, prev=previous})
    data[index].prev=length
    if previous then
      data[previous].next=length
    else
      first=length
    end
  end
  function list.remove(index)
    if index==nil then
      index=first
    end
    if index then
      local next=list.getNext(index)
      local prev=list.getPrev(index)
      if prev then
        data[prev].next=next
      end
      if next then
        data[next].prev=prev
      end
      data[index]=nil
      if index==first then first=next end
      if index==last then last=prev end
    end
  end
  function list.delete(index)
    list.remove(index)
  end
  function list.getNode(nodeID)
    if not first then return nil end
    if nodeID==nil then
      return data[first]
    end
    return data[nodeID]
  end
  function list.getValue(nodeID)
    if not first then return nil end
    if nodeID==nil then
      return data[first].value
    end
    return data[nodeID].value
  end
  function list.getNext(nodeID)
    if not first then return nil end
    if nodeID==nil then
      return data[first].next
    end
    return data[nodeID].next
  end
  function list.getPrev(nodeID)
    if not first then return nil end
    if not nodeID then return nil end
    return data[nodeID].prev
  end
  function list.getPrevious(nodeID)
    return list.getPrev(nodeID)
  end
  function list.getFirst()
    return first
  end
  function list.getLast()
    return last
  end

  --metatable Functions
  meta.__newindex=function(index, val) --alias for list.insert()
    list.insert(index, val)
  end
  meta.__index=function(index) --alias for list.getValue()
    return list.getValue(index)
  end
  meta.__pairs=function(list)
    local i=first
    if first then
      i=nil
      local function iter(list, i)
        if i==nil then i=first
        else i=list.getNext(i) end
        local v=list.getNode(i)
        if v then
          return i, v.value
        end
      end
      return iter, list, i
    else
      return next, data
    end
  end
  --make ipairs() go backwards
  meta.__ipairs=function(list)
    local i=last
    if last then
      i=nil
      local function iter(list, i)
        if i==nil then i=last
        else i=list.getPrev(i) end
        local v=list.getNode(i)
        if v then
          return i, v.value
        end
      end
      return iter, list, i
    else
      return next, data
    end
  end
  meta.__len=function(t) return t.len() end
  setmetatable(list, meta)
  return list
end
return lib
