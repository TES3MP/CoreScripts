# Synchronizing Data

## Data Storage

The data is stored on the server using instance of classes [Player](#players), [Cell](#cells) [WorldInstance](#world). Specifically, all of the long-term information which gets kept between server restarts is in the `data` field of each instance. 

However, simply changing the `data` table of an object will only only alter that information on the server. To distribute it to the players' clients, you need to call a relevant `Load` function. There are too many to give a comprehensive list here, so I will provide a few examples and leave the reader to explore source code for the remaining options. [scripts/player/base.lua](../scripts/player/base.lua), [scripts/cell/base.lua](../scripts/cell/base.lua).

Altering `data` tables doesn't directly change the values stored on disk either. For them to stay after server restart, you need to eventually call either `SaveToDrive` or `QuicksaveToDrive` function (if you are not sure which one to choose, use `QuicksaveToDrive`). Keep in mind that file operations are much slower than almost anything else you could do, so perform them as rarely as possible (e. g. to prevent data loss due to a crash, or when unloading data from memory).

## Players

All player instances are stored in the `Players` global table. Each player has a numeric `pid` assigned when they connect, and is reserved for them until they disconnect. If you want to identify players between sessions, use `Players[pid].accountName`.

Make players "eat" every time they log in:
```Lua
customEventHooks.registerHandlers("OnPlayerAuthentified", function(eventStatus, pid)
  if eventStatus.validCustomHandlers then
    local inventory = Players[pid].data.inventory
    -- use inventoryHelper whenever possible for inventory operations
    inventoryHelper.removeExactItem(inventory, "ingred_bread_01", 1, -1, -1, "")
    -- send updated data to the clients
    Players[pid]:LoadInventory()
  end
end)
```

Increase a player's Speed attribute by one every day, even while they are offline
```Lua
timers.Interval(time.hours(24), function()
  local player = logicHandler.GetPlayerByName("account_name")
  if player ~= nil then
    local speed = player.data.attributes.Speed
    speed.base = speed.base + 1
    if player.pid then
      tes3mp.SendMessage(pid, "Your speed increased!\n")
      player:LoadAttributes()
    else -- if a player doesn't have a pid, they are offline, and we don't need to send any packets
      -- however since they are offline, their data won't be saved automatically, and we need to do it manually
      player:QuicksaveToDrive()
    end
  end
end)
```

Some regularly updated data is not passed to Lua scripts each time it changes.  
You have to call `Players[pid]:SaveCell` for current cell and location, and `Players[pid]:SaveStatsDynamic`for current and total health, magicka and stamina.
```Lua
customEventHooks.registerHandler('OnCellLoad', function(eventStatus, pid)
    if eventStatus.validCustomHandlers then
        tableHelper.print(Players[pid].data.location) -- might be outdated or even nonsensical
        Players[pid]:SaveCell()
        tableHelper.print(Players[pid].data.location)
    end
end)
```

## Cells

Currently active cells are stored in the `LoadedCells` global table, with `cellDescription`s as keys. Unlike the players, they get unloaded from memory quite often - whenever there are no players in a cell.

Remove all pillows from a cell, whenever it is loaded
```Lua
customEventHooks.registerHandler('OnCellLoad', function(eventStatus, pid, cellDescription)
  if eventStatus.validCustomHandlers then
    local cellObjects = LoadedCells[cellDescription].data.objectData
    local toDelete = {}
    for uniqueIndex, obj in pairs(cellObjects) do
      if obj.refId == 'misc_uni_pillow_01' then
        table.insert(toDelete, uniqueIndex)
      end
    end
    LoadedCells[cellDescription]:LoadObjectsDeleted(pid, cellObjects, toDelete, true)
    for _, uniqueIndex in pairs(toDelete) do
      cellObjects[uniqueindex] = nil
    end
  end
end)
```

## World

> TODO