# Using the customEventHooks API:

## Handling events:

To handle various events you will need to use two functions:
* `customEventHooks.registerValidator(event, callback)`
* `customEventHooks.registerHandler(event, callback)`

Both of these functions accept an `event` string and a `callback` function as their arguments.   
There is a [table of tes3mp events](#event-table), and you can [create your own](#custom-events)  

Validators are called first, before the handlers. Both validator and handler callback functions will be called with a guaranteed argument of `eventStatus` and a few arguments (potentially none) depending on the particular event.

`eventStatus` is a table that defines the way handlers should behave. It has two fields: `validDefaultHandler` and `validCustomHandlers`. By default both of these are `true`.  
`validDefaultHandler` defines if default behaviour should be performed. Technically, this just means all the handlers in CoreScripts check this flag. You want to set this to `false` if you are overriding default behaviour, or cancelling the event entirely.  
`validCustomHandlers` signals handlers from other scripts whether the event has been canceled. However, their callbacks still run, and it is each script's responsibility to handle `eventStatus.validCustomHandlers` being `false`.

`eventStatus` can only be changed by validators. If your validator returns nothing, `eventStatus` stays the same. However if you return a non-`nil` value for either of the two fields, it will override the previous one. It is recommended to use the following function to construct an `eventStatus`:
* `customEventHooks.makeEventStatus(validDefaultHandler, validCustomHandlers)`

### Examples:
Imagine you want to taunt players whenever they die.
```Lua
customEventHooks.registerHandler("OnPlayerDeath", function(eventStatus, pid)
    if eventStatus.validCustomHandlers then --check if some other script made this event obsolete
        tes3mp.SendMessage(pid, "Don't worry, he'll be gentle!\n")
    end
end)
```

Now let's do something more practical: limiting players' level:
```Lua
local maxLevel = 20
customEventHooks.registerValidator("OnPlayerLevel", function(eventStatus, pid)
    if eventStatus.validCustomHandlers then
        local player = Players[pid]
        if player.data.stats.level >= maxLevel then
            player.data.stats.level = maxLevel
            player.data.stats.levelProgress = 0
            player:LoadLevel() --override level progress on the client

            --first false prevents the default handler from firing, preventing level progress increase
            --second false prevents custom handlers - since we've canceled the level up, this event is not valid anymore
            return customEventHooks.makeEventStatus(false,false) 
        end
    end
end)
```

## Custom events

You can also use this API to allow other scripts to interact with yours. For that you will need
* `customEventHooks.triggerValidators(event, args)`
  * `event` is the event name which will be used for `registerHandler` and `registerValidator`
  * `args` is a table of arguments which will be passed to the event callbacks (do not include eventStatus)
* `customEventHooks.triggerHandlers(event, eventStatus, args)`
  * `eventStatus` here should be whatever was returned by `triggerValidators` or `customEventHooks.makeEventStatus(true, true)`

### Examples

Here's an example from `eventHandler.lua`:
```Lua
local eventStatus = customEventHooks.triggerValidators("OnPlayerLevel", {pid})
if eventStatus.validDefaultHandler then
    Players[pid]:SaveLevel()
    Players[pid]:SaveStatsDynamic()
end
customEventHooks.triggerHandlers("OnPlayerLevel", eventStatus, {pid})
```

If you don't want other scripts replacing logic from yours, you can provide just the handlers:
```Lua
customEventHooks.triggerHandlers("OnServerExit", customEventHooks.makeEventStatus(true, true), {})
```

# Event table

This table will follow this format: `event(args)`, where `event` and `args` are as described in [Custom events](#custom-events). Don't forget that the first argument is always `eventStatus` (omitted in the table).  
It is recommended to check the source code instead of relying on this table, however. Don't forget that each event has a corresponding `triggerHandlers` call, so it should be very easy to find them all by searching for `customEventHooks.triggerHandlers(`. Similarly you can search for a specific event.  
Most (but not all) of them will be in [eventHandler.lua](../scripts/eventHandler.lua) or [serverCore.lua](../scripts/serverCore.lua).

* OnPlayerConnect(pid)
* OnPlayerDisconnect(pid)
* OnGUIAction(pid, idGui, data)
* OnPlayerSendMessage(pid, message)
* OnPlayerDeath(pid)
* OnDeathTimeExpiration(pid)
* OnPlayerAttribute(pid)
* OnPlayerSkill(pid)
* OnPlayerLevel(pid)
* OnPlayerShapeshift(pid)
* OnPlayerCellChange(pid)
* OnPlayerEndCharGen(pid)
* OnPlayerEquipment(pid)
* OnPlayerInventory(pid)
* OnPlayerSpellbook(pid)
* OnPlayerQuickKeys(pid)
* OnPlayerJournal(pid)
* OnPlayerFaction(pid, action)  
  `action` is the result of `tes3mp.GetFactionChangesAction(pid)` (0 for RANK, 1 for EXPULSION, 2 for REPUTATION)
* OnPlayerTopic(pid)
* OnPlayerBounty(pid)
* OnPlayerReputation(pid)
* OnPlayerBook(pid)
* OnPlayerItemUse(pid, itemRefId)
* OnPlayerMiscellaneous(pid)
* OnCellLoad(pid, cellDescription)
* OnCellUnload(pid, cellDescription)
* OnCellDeletion(cellDescription)
* OnActorList(pid, cellDescription)
* OnActorEquipment(pid, cellDescription)
* OnActorAI(pid, cellDescription)
* OnActorDeath(pid, cellDescription)
* OnActorCellChange(pid, cellDescription)
* OnObjectActivate(pid, cellDescription, objects, players)  
  `objects` and `players` contain lists of activated objects and players respectively.  
  elements of `objects`:
  ```Lua
  {
      uniqueIndex = ...,
      refId = ...
  }
  ```
  elements of `players`:
  ```Lua
  {
      pid = ...
  }
    ```
* OnObjectPlace(pid, cellDescription, objects)  
  `objects` has the same structure as in `OnObjectActivate`
* OnObjectSpawn(pid, cellDescription, objects)  
  `objects` has the same structure as in `OnObjectActivate`
* OnObjectDelete(pid, cellDescription, objects)  
  `objects` has the same structure as in `OnObjectActivate`
* OnObjectLock(pid, cellDescription, objects)  
  `objects` has the same structure as in `OnObjectActivate`
* OnObjectTrap(pid, cellDescription, objects)  
  `objects` has the same structure as in `OnObjectActivate`
* OnObjectScale(pid, cellDescription, objects)  
  `objects` has the same structure as in `OnObjectActivate`
* OnObjectState(pid, cellDescription, objects)  
  `objects` has the same structure as in `OnObjectActivate`
* OnDoorState(pid, cellDescription, objects)  
  `objects` has the same structure as in `OnObjectActivate`
* OnContainer(pid, cellDescription, objects)  
  `objects` has the same structure as in `OnObjectActivate`
* OnVideoPlay(pid, videos)  
  `videos` is a list of video filenames 
* OnRecordDynamic(pid)
* OnWorldKillCount(pid)
* OnWorldMap(pid)
* OnWorldWeather(pid)
* OnObjectLoopTimeExpiration(pid, loopIndex)  
  `pid` is the loop's `targetPid`
* OnServerInit()
* OnServerPostInit()
* OnServerExit()  
  Only has a handler trigger and no default behaviour to cancel.
* OnLoginTimeExpiration(pid)
* OnPlayerResurrect(pid)  
  Only has a handler trigger and no default behaviour to cancel.
* OnPlayerFinishLogin(pid)  
  Only has a handler trigger and no default behaviour to cancel.
* OnPlayerAuthentified(pid)  
  Only has a handler trigger and no default behaviour to cancel.  
  Is triggered after a player has finished joining the server, whether it was by making a new character (`OnPlayerEndCharGen`) or by logging in (`OnPlayerFinishLogin`)

>TODO: add new events
