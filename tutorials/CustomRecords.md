# Custom Records

## Permanent records

Permanent records are quite similar in effect to adding an .esp file. However, there are significant differences as well:
* Players don't have to download an .esp file. Instead, all the permanent records are sent to them on server join.
* Custom records can be created while the server is running, and without client restarts.

Creating permanent records is very simple. You only need to assign a Lua table of particular with key `refId` to `RecordStores[storeType].data.permanentRecords`:
```Lua
customEventHooks.registerHandler('OnServerPostInit', function(eventStatus)
    if eventStatus.validCustomHandlers then
        local potionData = RecordStores.potion.data
        local refId = 'p_icarianflight'
        if not potionData.permanentRecords[refId] then
            potionData.permanentRecords[refId] = {
                name = "Potion of Icarian Flight",
                value = 119,
                weight = 1.0,
                autoCalc = 0,
                icon = "m\\tx_potion_cheap_01.dds",
                model = "m\\misc_potion_cheap_01.nif",
                script = "",
                effects = {{
                    id = 83, -- Fortify Skill
                    attribute = -1,
                    skill = 20, -- Acrobatics
                    rangeType = 0, -- Self
                    area = 0,
                    duration = 7, -- seconds
                    magnitudeMax = 1000,
                    magnitudeMin = 1000
                }]
            }
        end
    end
end)
```

Keep in mind, that if you create a permanent record mid-session, you will likely have to send the necessary information to the players by calling
```Lua
local recordStore = RecordStores[storeType]
recordStore:LoadRecords(pid, recordStore.data.permanentRecords, {refId}, true)
```

## Generated records

Generated records are mainly used for player-created objects: potions, enchanted items, custom spells. However you can also use them for other objects, if you expect them to be temporary, or have a lot of them.  
These are the main features differentiating generated records from permanent ones:
* Generated records are only stored for as long as necessary.  
  As soon as they are created, they are linked either to a player (while in their inventory / spellbook) or a cell (object dropped on the ground).  
  If a generated record is not linked to anything, it is removed.
* Generated records are only sent to players when necessary (inside a linked cell, a linked player is in the same cell, ...)
* Generated records `refId` must follow a specific pattern `$custom_<storeType>_<number>`, e.g. `$custom_potion_2`.  
  This allows other parts of CoreScripts to easily recognize that a particlar object is a generated record, and of what type it is.

Give every player a note with their name in it:
```Lua
customEventHooks.registerHandler('OnPlayerAuthentified', function(eventStatus, pid)
    local doorStore = RecordStores.door
    local refId = doorStore:GenerateRecordId()
    doorStore.generatedRecords[refId] = {
        baseId = 'sc_paper plain',
        name = 'Suspicious note',
        text = "We are watching you, %s%s%s!".format(color.DarkRed, Players[pid].accountName, color.DarkRed)
    }
    doorStore:LoadGeneratedRecords(pid, doorStore.data.generatedRecords, {refId}, false)
    doorStore:QuicksaveToDrive()
    inventoryHelper.addItem(Players[pid].data.inventory, refId, 1, -1, -1, '')
    Players[pid]:LoadItemChanges({{
      refId = refId,
      count = 1
    }}, enumerations.inventory.ADD)
end)
```

## Record format

There are a lot of different record types, mirroring the ones you might be familiar with from TES Construction Set. I will not provide a full list here, instead I suggest you look at the relevant functions [in `packetBuilder.AddRecordByType`](../scripts/packetBuilder.lua#L199).

### Common important properties

* `refId` if you aren't familiar with Morrowind modding, this is a string identifier of a record.
  Every object in the game has both a `refId` - linking it to a record - and a `uniqueIndex` - to differ it from other instances of the same `refId`.
* `baseId` is a `refId` of another record (almost always of the same type), on which this record should be based. Some records (e. g. creatures) require one.
* `effects` applies to spells, enchantments and potions, and contains effects. Check [in `packetBuilder.AddEffectToRecord`](../scripts/packetBuilder.lua#L168).
  
### Magic related identifiers

* [magical effects](https://github.com/TES3MP/openmw-tes3mp/tree/2249450b0efd523f09182087ef296bda581bfc20/components/esm/loadmgef.hpp#L107)
* [attributes](https://github.com/TES3MP/openmw-tes3mp/tree/2249450b0efd523f09182087ef296bda581bfc20/components/esm/attr.hpp#L14)
* [skills](https://github.com/TES3MP/openmw-tes3mp/tree/2249450b0efd523f09182087ef296bda581bfc20/components/esm/loadskil.hpp#L44)
* [casting range](https://github.com/TES3MP/openmw-tes3mp/tree/2249450b0efd523f09182087ef296bda581bfc20/components/esm/defs.hpp#L27) (Self, Target...)
* [spell types](https://github.com/TES3MP/openmw-tes3mp/tree/2249450b0efd523f09182087ef296bda581bfc20/components/esm/loadspel.hpp#L22) (spell, ability, disease...)
* [enchantment subtypes](https://github.com/TES3MP/openmw-tes3mp/tree/2249450b0efd523f09182087ef296bda581bfc20/components/esm/loadench.hpp#L24) (On Use, On Strike, Constant...)

### Other identifiers

* [class specialization](https://github.com/TES3MP/openmw-tes3mp/tree/2249450b0efd523f09182087ef296bda581bfc20/components/esm/defs.hpp#L28)
* [body parts](https://github.com/TES3MP/openmw-tes3mp/tree/2249450b0efd523f09182087ef296bda581bfc20/components/esm/loadbody.hpp#L18)
* [armor parts](https://github.com/TES3MP/openmw-tes3mp/tree/2249450b0efd523f09182087ef296bda581bfc20/components/esm/loadarmo.hpp#L13)
* [clothing parts](https://github.com/TES3MP/openmw-tes3mp/tree/2249450b0efd523f09182087ef296bda581bfc20/components/esm/loadclot.hpp#L24)
* [weapon types](https://github.com/TES3MP/openmw-tes3mp/tree/2249450b0efd523f09182087ef296bda581bfc20/components/esm/loadweap.hpp#L24)