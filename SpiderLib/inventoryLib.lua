--returns a table of functions for manipulating inventories
--Inventory:inv is always the first argument when applicable
--"Inventory:" denotes a table returned by openInventory(), not getInventory().
--<arrows> denote optional arguments
--Current Functions:
--lib.selectItem(String:itemId, <Number:dmg>) --selects a given item in your hotbar
--lib.search(Inventory:inv, String:itemID, <Number:dmg>) --returns true/false, amount of items, and each itemstack it matches
--lib.combine(Inventory:inv, String:itemID, <Number:dmg>) --condenses all matching items into item stacks
--lib.getItem(Inventory:inv, String:itemID, <Number:dmg>, <Number:invSlot>) --grabs the first matching item and tries to put it in the specified slot. Attempts to default to hotbar slot 1
--lib.getAmount(Inventory:inv, String:itemID, <Number:dmg>) --returns amount of matching items, as does lib.search()
--lib.getItemStacks(Inventory:inv, String:itemID, <Number:dmg>) --returns a table of information about each matching item stack, including slot number, as does lib.search(). Returns false if not found
--lib.hasItem(Inventory:inv, String:itemID, <Number:dmg>) --returns true/false if it matches, as does lib.search()
--lib.grabAmount(Inventory:inv, String:itemID, Number:dmg, Number:amount, <Number:slot>) --puts as close to the given amount of items in the slot as possible. Note the metadata(dmg value) must be included.
--lib.isEmpty(Inventory:inv, Number:slot) --returns if a slot has an item stack in it
--lib.compare(Inventory:inv, Number:slot1, Number:slot2) --returns if two itemstacks are identical, fields unique to slot1, fields unique to slot2, and fields in common with both
--lib.hasEnchantment(Inventory:inv, Number:slot, Number:enchantmentID, <Number:level>) --returns if the itemstack has a given enchantment and the enchantment which it matched with
--lib.getEnchantmentID(String:enchantmentName) --returns the id of an enchantment. Hardcoded as a modifiable table, use spaces instead of underscores.
--lib.hasEnchantmentTable(Inventory:inv, Number:slot, Table:enchants) --returns if an item has all the given enchantments and the enchantments it matched with

--aliases
--lib.doesItemExist(Inventory:inv, String:itemID, <Number:dmg>) --alias for lib.hasItem()
--lib.getItems(Inventory:inv, String:itemID, <Number:dmg>) --alias for lib.getItemStacks()
--lib.pickupAmount(Inventory:inv, String:itemID, Number:dmg, Number:amount, <Number:slot>) --alias for lib.grabAmount()
--lib.getItemByAmount(Inventory:inv, String:itemID, Number:dmg, Number:amount, <Number:slot>) --alias for lib.grabAmount()
--lib.comm(Inventory:inv, Number:slot1, Number:slot2) --alias for lib.compare()
--lib.getEnchantID(String:enchantmentName) --alias for lib.getEnchantmentID()
--lib.hasEnchant(Inventory:inv, Number:slot, Number:enchantmentID, <Number:level>) --alias for lib.hasEnchantment()
--lib.hasEnchantTable(Inventory:inv, Number:slot, Table:enchants) --alias for lib.hasEnchantmentTable()
--lib.hasEnchants(Inventory:inv, Number:slot, Table:enchants) --alias for lib.hasEnchantmentTable()


local enchants={
  ["protection"]=0,
  ["fire protection"]=1,
  ["feather falling"]=2,
  ["blast protection"]=3,
  ["projectile protection"]=4,
  ["respiration"]=5,
  ["aqua affinity"]=6,
  ["thorns"]=7,
  ["depth strider"]=8,
  ["sharpness"]=16,
  ["smite"]=17,
  ["bane of arthropods"]=18,
  ["knockback"]=19,
  ["fire aspect"]=20,
  ["looting"]=21,
  ["efficiency"]=32,
  ["silk touch"]=33,
  ["unbreaking"]=34,
  ["fortune"]=35,
  ["power"]=48,
  ["punch"]=49,
  ["flame"]=50,
  ["infinity"]=51,
  ["luck of the sea"]=61,
  ["lure"]=62
}
local lib={}
--selects an item in the hotbar, optionally checks for a given metadata
--returns true/false depending on if the item is found.
function lib.selectItem(itemID, dmg)
  local inv=getInventory()
  for id, item in pairs(inv) do
    if id < 10 and item and not dmg then
      if item.id==itemID then
        setHotbar(id)
        return true
      end
    elseif id < 10 and item then
      if item.id==itemID and item.dmg==dmg then
        setHotbar(id)
        return true
      end
    end
  end
  return false
end
--returns true/false, the total amount of items, and a table with the matching item's slot data
--additional field "slot" is added to each item returned, note that changing the inventory type will change its slot number
function lib.search(inv, itemID, dmg)
  local foundItem=false
  local itemAmnt=0
  local items={}
  local item
  for i=1, inv.getTotalSlots(), 1 do
    item=inv.getSlot(i)
    if item then
      if dmg then
        if item.id==itemID and item.dmg==dmg then
          foundItem=true
          itemAmnt=itemAmnt+item.amount
          item.slot=i
          table.insert(items, item)
        end
      else
        if item.id==itemID then
          foundItem=true
          itemAmnt=itemAmnt+item.amount
          item.slot=i
          table.insert(items, item)
        end
      end
    end
  end
  return foundItem, itemAmnt, items
end
--combines all item stacks of the given item
function lib.combine(inv, itemID, dmg)
  local function combineStack(inv, itemID, dmg)
    local lastSlot
    for i=1, inv.getTotalSlots(), 1 do
      if inv.getSlot(i) then
        if inv.getSlot(i).id==itemID and (inv.getSlot(i).dmg==dmg or dmg==nil) then
          dmg=inv.getSlot(i).dmg
          if lastSlot then
            inv.click(i)
          end
          inv.click(i)
          lastSlot=i
        end
      end
    end
    inv.click(lastSlot)
    return lastSlot
  end

  if dmg==nil then
    local metadatas={}
    for i=1, inv.getTotalSlots(), 1 do
      if inv.getSlot(i) then
        if inv.getSlot(i).id==itemID then
          local doesDmgExist=false
          for id, val in pairs(metadatas) do
            if inv.getSlot(i).dmg==val then
              doesDmgExist=true
            end
          end
          if not doesDmgExist then
            table.insert(metadatas, inv.getSlot(i).dmg)
          end
        end
      end
    end
    for id, data in pairs(metadatas) do
      local lastSlot=combineStack(inv, itemID, data)
      if inv.getHeld() then
        while inv.getSlot(lastSlot) do
          lastSlot=lastSlot-1
        end
        inv.click(lastSlot)
      end
    end
  else
    local lastSlot=combineStack(inv, itemID, data)
    if inv.getHeld() then
      while inv.getSlot(lastSlot) do
        lastSlot=lastSlot-1
      end
      inv.click(lastSlot)
    end
  end

end

--gets any item from an inventory and places it in the specified slot. Tries to default to hotbar slot 1
function lib.getItem(inv, itemID, dmg, slot)
  if inv.getType()=="inventory" then
    slot=slot or inv.mapping.inventory.hotbar[1]
  else
    slot=slot or inv.getTotalSlots()-8
  end

  local foundItem=false
  for i=1, inv.getTotalSlots(), 1 do
    if inv.getSlot(i) and not foundItem then
      if inv.getSlot(i).id==itemID and (inv.getSlot(i).dmg==dmg or dmg==nil) and i~=slot then
        inv.click(i)
        inv.click(slot)
        inv.click(i) --drops item back in case it picked something up
        foundItem=true
      end
    end
  end
  lib.selectItem(inv, itemID, dmg)
  return foundItem
end
--returns the total amount of items it matches
--this and more is handled by lib.search(), so this is essentially an alias
function lib.getAmount(inv, itemID, dmg)
  local found, amount = lib.search(inv, itemID, dmg)
  if found then return amount else return 0 end
end
function lib.getItemStacks(inv, itemID, dmg)
  local found, amount, stacks = lib.search(inv, itemID, dmg)
  if found then return stacks else return false end
end
--returns if the item exists in the inventory or not
--lib.search() does this as well, but this can be more efficient depending on dataset
function lib.hasItem(inv, itemID, dmg)
  for i=1, inv.getTotalSlots(), 1 do
    if inv.getSlot(i) then
      if inv.getSlot(i).id==itemID and (inv.getSlot(i).dmg==dmg or dmg==nil) then
        return true
      end
    end
  end
  return false
end
--puts the given amount of items into the specified slot
--if not enough items are found, it puts as many as it can in the slot and returns false.
--if enough items are found, it returns true.
--if no slot is specified, attempts to default to hotbar slot 1
--metadata(dmg value) must be specified for this function.
function lib.grabAmount(inv, itemID, dmg, amount, slot)
  local targetAmount=amount --container variable for final condition testing
  if not lib.hasItem(inv, itemID, dmg) then return false end
  --slot definition
  if inv.getType()=="inventory" then
    slot=slot or inv.mapping.inventory.hotbar[1]
  else
    slot=slot or inv.getTotalSlots()-8
  end
  local itemStacks=lib.getItemStacks(inv, itemID, dmg)
  if inv.getSlot(slot) then
    if inv.getSlot(slot).id==itemID and inv.getSlot(slot).dmg==dmg then
      amount=amount-inv.getSlot(slot).amount
    else
      --swap item stacks
      inv.click(slot)
      inv.click(itemStacks[1].slot)
      inv.click(slot)
      amount=amount-inv.getSlot(slot).amount
      itemStacks[1].slot=slot
    end
  end
  --the target slot is now either empty or contains the matching itemstack already
  if amount < 0 then
    --picks up target stack, then right clicks one down at a time onto each item stack until the exact amount is reached
    inv.click(slot)
    amount=inv.getHeld().amount+amount --makes amount smaller, this is the target amount
    local lastAmount=inv.getHeld().amount+1
    for i, itemStack in ipairs(itemStacks) do
      while inv.getHeld().amount>amount and lastAmount-inv.getHeld().amount == 1 and itemStack.slot~=slot do
        lastAmount=inv.getHeld().amount
        inv.click(itemStack.slot, 1) --right click
      end
    end
    --repeat the process but looking for empty slots instead
    --This may cause unwanted results
    if inv.getHeld().amount~=amount then
      local i=slot-1
      while i>0 and inv.getSlot(i) do
        i=i-1 --looks for an empty slot
      end
      if i~=0 then
        --found an empty slot
        while inv.getHeld().amount>amount and lastAmount-inv.getHeld().amount==1 do
          lastAmount=inv.getHeld().amount
          inv.click(i, 1) --right click
        end
      end
    end
    inv.click(slot)
    if inv.getSlot(slot).amount~=amount then return false else return true end
  end

  for i, itemStack in pairs(itemStacks) do
    if itemStack.amount<=amount and itemStack.slot~=slot then
      --adds item stacks
      inv.click(itemStack.slot)
      inv.click(slot)
      if inv.getHeld() then
        --reached maximum stack size
        inv.click(itemStack.slot)
        return false
      end
      amount=amount-itemStack.amount
    elseif itemStack.amount>amount and amount>0 and itemStack.slot~=slot then
      --picks up item stack, then right clicks one down at a time until the exact amount needed is reached
      inv.click(itemStack.slot)
      while inv.getHeld().amount>amount do
        inv.click(itemStack.slot, 1) --right click
      end
      inv.click(slot) --combine item stacks
      if inv.getHeld() then
        --reached maximum stack size
        inv.click(itemStack.slot)
        return false
      end
    end
  end
  if inv.getSlot(slot).amount==targetAmount then return true else return false end
end
function lib.isEmpty(inv, slot)
  if inv.getSlot(slot) then return true else return false end
end
local function getTableElements(table)
  local elements=0
  for id, val in pairs(table) do
    elements=elements+1
  end
  return elements
end

local function compareTable(table1, table2)
  local areIdentical=true
  local unique1={}
  local unique2={}
  local comm={}
  for id, val in pairs(table1) do
    if val~=table2[id] and type(val)~="table" and type(table2[id])~="table" then
      areIdentical=false
      unique1[id]=val
      unique2[id]=table2[id]
    elseif type(val)=="table" and type(table2[id])=="table" then
      local identical, uniq1, uniq2, common = compareTable(val, table2[id])
      areIdentical=areIdentical and identical
      if getTableElements(uniq1)~=0 then
        unique1[id]=uniq1
      end
      if getTableElements(uniq2)~=0 then
        unique2[id]=uniq2
      end
      if getTableElements(common)~=0 then
        comm[id]=common
      end
    elseif type(val)=="table" or type(table2[id])=="table" then
      areIdentical=false
      unique1[id]=val
      unique2[id]=table2[id]
    else
      comm[id]=val
    end
  end
  if getTableElements(unique1)==0 and getTableElements(unique2)==0 then
    comm={}
  end
  if getTableElements(unique1)==0 then
    unique1=nil
  end
  if getTableElements(unique2)==0 then
    unique2=nil
  end
  return areIdentical, unique1, unique2, comm
end
--returns if two itemstacks are identical, fields unique to slot1, fields unique to slot2, and fields shared between them
--similar to Bash's "comm" command
function lib.compare(inv, slot1, slot2)
  if inv.getSlot(slot1) and inv.getSlot(slot2) then
    local areIdentical=true
    local unique1={}
    local unique2={}
    local comm={}
    local stack1=inv.getSlot(slot1)
    local stack2=inv.getSlot(slot2)
    for id, val in pairs(stack1) do
      if val~=stack2[id] and type(val)~="table" and type(stack2[id])~="table" then
        areIdentical=false
        unique1[id]=val
        unique2[id]=stack2[id]
      elseif type(val)=="table" or type(stack2[id])=="table" then
        local identical, uniq1, uniq2, common=compareTable(val, stack2[id])
        areIdentical=areIdentical and identical
        unique1[id]=uniq1
        unique2[id]=uniq2
        comm[id]=common
      else
        comm[id]=val
      end
    end
    for id, val in pairs(stack2) do
      if stack1[id]==nil then
        --only occurs if stack2 has a unique field type
        areIdentical=false
        unique2[id]=val
      end
    end

    return areIdentical, unique1, unique2, comm
  elseif inv.getSlot(slot1) then
    return false, inv.getSlot(Slot1), {}, {}
  else
    return false, {}, inv.getSlot(slot2), {}
  end
end
function lib.getEnchantmentID(enchant)
  return enchants[enchant:lower()]
end
function lib.hasEnchantment(inv, slot, enchantID, level)
  if not inv.getSlot(slot) then return false end
  for id, enchant in pairs(inv.getSlot(slot).enchants) do
    if enchant.id==enchantID and (enchant.lvl==level or level==nil) then
      return true, enchant
    end
  end
  return false, {}
end
function lib.hasEnchantmentTable(inv, slot, enchants)
  if not inv.getSlot(slot) then return false, {} end
  local hasEnchants=true
  local matchedEnchants={}
  for id, enchant in pairs(enchants) do
    local doesExist, match = lib.hasEnchantment(inv, slot, enchant.id, enchant.lvl)
    hasEnchants=hasEnchants and doesExist
    if doesExist then
      table.insert(matchedEnchants, match)
    end
  end
  return hasEnchants, matchedEnchants
end


--aliases
function lib.doesItemExist(inv, itemID, dmg)
  return lib.hasItem(inv, itemID, dmg)
end
function lib.getItems(inv, itemID, dmg)
  return lib.getItemStacks(inv, itemID, dmg)
end
function lib.pickupAmount(inv, itemID, dmg, amount, slot)
  return lib.grabAmount(inv, itemID, dmg, amount, slot)
end
function lib.getItemByAmount(inv, itemID, dmg, amount, slot)
  return lib.grabAmount(inv, itemID, dmg, amount, slot)
end
function lib.comm(inv, slot1, slot2)
  return lib.compare(inv, slot1, slot2)
end
function lib.getEnchantID(enchant)
  return lib.getEnchantmentID(enchant)
end
function lib.hasEnchant(inv, slot, enchantID, level)
  return lib.hasEnchantment(inv, slot, enchantID, level)
end
function lib.hasEnchantTable(inv, slot, enchants)
  return lib.hasEnchantmentTable(inv, slot, enchants)
end
function lib.hasEnchants(inv, slot, enchants)
  return lib.hasEnchantmentTable(inv, slot, enchants)
end

return lib
