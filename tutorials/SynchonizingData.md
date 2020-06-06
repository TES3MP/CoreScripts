Synchronizing Data
===
Data Storage
---
The data is stored on the server using instance of classes [Player], [Cell], [RecordStore] and [WorldInstance]. Specifically, all of the long-term information which gets kept between server restarts is in the `data` field of each instance.  
However, simply changing the `data` table of an object will only only alter that information on the server. To distribute it to the players' clients, you need to call a relevant `Load` function. There are too many to provide a compehensive list here, so I will provide a few examples and leave the reader to explore source code for the remaining options.  
Altering `data` tables doesn't directly change the values stored on disk. For them to stay after server restart, you need to eventualy call either `SaveToDrive` or `QuicksaveToDrive` function (if you are not sure which one to choose, use `QuicksaveToDrive`). Keep in mind that file operations are much slower than almost anything else you could do, so perform them as rarely as possible (e. g. to prevent data loss due to a crash, or when unloading data from memory).

Players
---
All player instances are stored in the `Players` global table. Each player has a numeric `pid` assigned to them when they connect, and is reserved for them until they disconnect. If you want to identify them between sessions, use `Players[pid].accountName`.

A simple example of altering a player's inventory:
```Lua
  local inventory = Players[pid].data.inventory
  -- use inventoryHelper whenever possible for inventory operations
  inventoryHelper.addItem(inventory, "ingred_saltrice_01", 13, -1, -1, "")
  inventoryHelper.removeExactItem(inventory, "ingred_bread_01", 1, -1, -1, "")
  -- send updated data to the clients
  Players[pid]:LoadInventory()
  Players[pid]:QuicksaveToDrive()
```

Increase a player's Speed attribute by one even while they are offline
```Lua
  local player = logicHandler.GetPlayerName("account_name")
  local speed = player.data.attributes.Speed
  speed.base = speed.base + 1
  -- if a player doesn't have a pid, they are offline, and we don't need to send any packets
  if player.pid then
    player:LoadAttributes()
  end
  player:QuicksaveToDrive()
```

Some regularly changed data, such as players' current location, health, magicka and stamina are not passed to Lua every time they change.
> No code example, because current implementation uses `tes3mp` methods

Cells
---
Currently active cells are stored in the `LoadedCells` global table, with `cellDescription`s as keys. Unlike the players, they get loaded and unloaded from memory quite ofen - whenever there are no players in a cell, it is unloaded.
