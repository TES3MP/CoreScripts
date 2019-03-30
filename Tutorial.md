Using the customEventHooks API:
===

Handling events:
---

To handle various events you will need to use two functions: `customEventHooks.registerValidator` and `customEventHooks.registerHandler`.
Validators are called before any default logic for the event is executed, Handlers are called after such (whether default behaviour was peformed or not). 

Both of these functions accept an event string (you can find a table below) and a callback function as their arguments.
The callback function will be called with a guaranteed argument of eventStatus and a few arguments (potentially none) depending on the particular event.

eventStatus is a table that defines the way handlers should behave. It has two fields: `validDefaultHandler` and `validCustomHandlers`. By default both of these are `true`.
First defines if default behaviour should be performed, the second signals custom handlers that they should not run.
However, their callbacks are still ran, and it is scripts' responsibility to handle `eventStatus.validCustomHandlers` being `false`.

Validators can change the current eventStatus. If your validators returns nothing, it stays the same, however if you return a non-`nil` value for either of the two fields, it will override the previous one. You can use `customEventHooks.makeEventStatus(validDefaultHandler, validCustomHandlers)` for this.

Examples:
---
Imagine you want to taunt a player whenever they die.

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
    local player = Players[pid]
    if player.data.stats.level >= maxLevel then
        player.data.stats.level = maxLevel
        player.data.stats.levelProgress = 0
        player:LoadLevel()
        --cancel the level increase on the server side
        --there have been no level up anymore, so don't run custom handlers for it either
        return customEventHooks.makeEventStatus(false,false) 
    end
end)
```

Custom events
---

You can also use this API to allow other scripts to interact with yours. For that you will need to add `customEventHooks.triggerValidators(event, args)` and `customEventHooks.triggerHandlers(event, eventStatus, args)` to your code. `event` is a string labeling the event, `eventStatus` should be whatever was returned by `triggerValidators` and `args` is a list or arguments relevant callbacks will receive.

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

Using the customCommandHooks API:
===

To add a command, simply run `customCommandHooks.registerCommand(cmd, callback)`. Here `cmd` is the word after `/` which you want to trigger your command (e.g. "help" for `/help`) and callback is a function which will be ran when someone sends a message starting with "/" and `cmd`.

Callback will receive as its arguments a player's `pid` and an array of all command parts (their message is split into parts by spaces, after removing the leading '/', same as in the old `commandHandler.lua`).

You can then perform staff rank checks by calling `Players[pid]:IsAdmin()` etc.

Event table
===

This table will follow this format: `event(args)`, where `event` and `args` are as described in *Using the customEventHooks API:*

Most of the events are the same as `eventHandler.lua` functions, with some extra arguments:

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
    `objects` and `players` container lists of activated objects and players respectively.
    
    `objects` elements have form
    `
    {
        uniqueIndex = ...,
        refId = ...
    }
    `
    
    `players` elements have form
    `
    {
        pid = ...
    }
    `
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

There are also some events not present in `eventHandler` before:

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
    
    Is triggered after a player has finished login it, whether it was by making a new character (`OnPlayerEndCharGen`) or by logging in (`OnPlayerFinishLogin`)

