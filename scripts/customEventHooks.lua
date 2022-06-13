local customEventHooks = {}

---@type table<string, EventValidator>
customEventHooks.validators = {}

---@type table<string, EventHandler>
customEventHooks.handlers = {}

---@param validDefaultHandler boolean
---@param validCustomHandlers boolean|nil
---@return EventStatus
function customEventHooks.makeEventStatus(validDefaultHandler, validCustomHandlers)
    return {
        validDefaultHandler = validDefaultHandler,
        validCustomHandlers = validCustomHandlers
    }
end

---@param oldStatus EventStatus
---@param newStatus EventStatus
---@return EventStatus
function customEventHooks.updateEventStatus(oldStatus, newStatus)
    if newStatus == nil then
        return oldStatus
    end
    local result = {}
    if newStatus.validDefaultHandler ~= nil then
        result.validDefaultHandler = newStatus.validDefaultHandler
    else
        result.validDefaultHandler = oldStatus.validDefaultHandler
    end
    
    if newStatus.validCustomHandlers ~= nil then
        result.validCustomHandlers = newStatus.validCustomHandlers
    else
        result.validCustomHandlers = oldStatus.validCustomHandlers
    end
    
    return result
end

---@alias OnEventCallback fun(eventStatus: EventStatus)
---@alias OnActorAICallback fun(eventStatus: EventStatus, pid: integer, cellDescription: string)
---@alias OnActorCellChangeCallback fun(eventStatus: EventStatus, pid: integer, cellDescription: string)
---@alias OnActorDeathCallback fun(eventStatus: EventStatus, pid: integer, cellDescription: string, actors: table<string, ActorDeathActorPacket>)
---@alias OnActorEquipmentCallback fun(eventStatus: EventStatus, pid: integer, cellDescription: string, actors: table<string, ActorEquipmentActorPacket>)
---@alias OnActorListCallback fun(eventStatus: EventStatus, pid: integer, cellDescription: string, actors: table<string, ActorPacket>)
---@alias OnActorSpellsActiveCallback fun(eventStatus: EventStatus, pid: integer, cellDescription: string, actors: table<string, ActorSpellsActiveActorPacket>)
---@alias OnCellDeletionCallback fun(eventStatus: EventStatus, cellDescription: string)
---@alias OnCellLoadCallback fun(eventStatus: EventStatus, pid: integer, cellDescription: string)
---@alias OnCellUnloadCallback fun(eventStatus: EventStatus, pid: integer, cellDescription: string)
---@alias OnClientScriptGlobalCallback fun(eventStatus: EventStatus, pid: integer, variables: VariablePacket[])
---@alias OnClientScriptLocalCallback fun(eventStatus: EventStatus, pid: integer, cellDescription: string, objects: table<string, ClientScriptLocalObjectPacket>)
---@alias OnConsoleCommandCallback fun(eventStatus: EventStatus, pid: integer, cellDescription: string, objects: table<string, ObjectObjectPacket>, targetPlayers: table<integer, ObjectPlayerPacket>)
---@alias OnContainerCallback fun(eventStatus: EventStatus, pid: integer, cellDescription: string, objects: table<string, ObjectObjectPacket>)
---@alias OnDeathTimeExpirationCallback fun(eventStatus: EventStatus, pid: integer)
---@alias OnDoorStateCallback fun(eventStatus: EventStatus, pid: integer, cellDescription: string, objects: table<string, DoorStateObjectPacket>)
---@alias OnGUIActionCallback fun(eventStatus: EventStatus, pid: integer, idGui: integer, data: string)
---@alias OnLoginTimeExpirationCallback fun(eventStatus: EventStatus, pid: integer)
---@alias OnObjectActivateCallback fun(eventStatus: EventStatus, pid: integer, cellDescription: string, objects: table<string, ObjectActivateObjectPacket>, players: table<integer, ObjectActivatePlayerPacket>)
---@alias OnObjectDeleteCallback fun(eventStatus: EventStatus, pid: integer, cellDescription: string, objects: table<string, ObjectDeleteObjectPacket>)
---@alias OnObjectDialogueChoiceCallback fun(eventStatus: EventStatus, pid: integer, cellDescription: string, objects: table<string, ObjectDialogueChoiceObjectPacket>)
---@alias OnObjectHitCallback fun(eventStatus: EventStatus, pid: integer, cellDescription: string, objects: table<string, ObjectHitObjectPacket>, players: table<integer, ObjectHitPlayerPacket>)
---@alias OnObjectLockCallback fun(eventStatus: EventStatus, pid: integer, cellDescription: string, objects: table<string, ObjectLockObjectPacket>)
---@alias OnObjectLoopTimeExpirationCallback fun(eventStatus: EventStatus, pid: integer, loopIndex: integer)
---@alias OnObjectMiscellaneousCallback fun(eventStatus: EventStatus, pid: integer, cellDescription: string, objects: table<string, ObjectMiscellaneousObjectPacket>)
---@alias OnObjectPlaceCallback fun(eventStatus: EventStatus, pid: integer, cellDescription: string, objects: table<string, ObjectPlaceObjectPacket>)
---@alias OnObjectRestockCallback fun(eventStatus: EventStatus, pid: integer, cellDescription: string, objects: table<string, ObjectRestockObjectPacket>)
---@alias OnObjectScaleCallback fun(eventStatus: EventStatus, pid: integer, cellDescription: string, objects: table<string, ObjectScaleObjectPacket>)
---@alias OnObjectSoundCallback fun(eventStatus: EventStatus, pid: integer, cellDescription: string, objects: table<string, ObjectSoundObjectPacket>, players: table<integer, ObjectSoundPlayerPacket>)
---@alias OnObjectSpawnCallback fun(eventStatus: EventStatus, pid: integer, cellDescription: string, objects: table<string, ObjectSpawnObjectPacket>)
---@alias OnObjectStateCallback fun(eventStatus: EventStatus, pid: integer, cellDescription: string, objects: table<string, ObjectStateObjectPacket>)
---@alias OnObjectTrapCallback fun(eventStatus: EventStatus, pid: integer, cellDescription: string, objects: table<string, ObjectTrapObjectPacket>)
---@alias OnPlayerAttributeCallback fun(eventStatus: EventStatus, pid: integer, playerPacket: PlayerAttributePacket)
---@alias OnPlayerAuthentifiedCallback fun(eventStatus: EventStatus, pid: integer)
---@alias OnPlayerBookCallback fun(eventStatus: EventStatus, pid: integer)
---@alias OnPlayerBountyCallback fun(eventStatus: EventStatus, pid: integer)
---@alias OnPlayerCellChangeCallback fun(eventStatus: EventStatus, pid: integer, playerPacket: PlayerCellChangePacket)
---@alias OnPlayerConnectCallback fun(eventStatus: EventStatus, pid: integer)
---@alias OnPlayerCooldownsCallback fun(eventStatus: EventStatus, pid: integer, playerPacket: PlayerCooldownsPacket)
---@alias OnPlayerDeathCallback fun(eventStatus: EventStatus, pid: integer)
---@alias OnPlayerDisconnectCallback fun(eventStatus: EventStatus, pid: integer)
---@alias OnPlayerEndCharGenCallback fun(eventStatus: EventStatus, pid: integer)
---@alias OnPlayerEquipmentCallback fun(eventStatus: EventStatus, pid: integer, playerPacket: PlayerEquipmentPacket)
---@alias OnPlayerFactionCallback fun(eventStatus: EventStatus, pid: integer, action: integer)
---@alias OnPlayerInventoryCallback fun(eventStatus: EventStatus, pid: integer, playerPacket: PlayerInventoryPacket)
---@alias OnPlayerItemUseCallback fun(eventStatus: EventStatus, pid: integer, itemRefId: string)
---@alias OnPlayerJournalCallback fun(eventStatus: EventStatus, pid: integer, playerPacket: PlayerJournalPacket)
---@alias OnPlayerLevelCallback fun(eventStatus: EventStatus, pid: integer, playerPacket: PlayerLevelPacket)
---@alias OnPlayerMarkLocationCallback fun(eventStatus: EventStatus, pid: integer)
---@alias OnPlayerQuickKeysCallback fun(eventStatus: EventStatus, pid: integer, playerPacket: PlayerQuickKeysPacket)
---@alias OnPlayerReputationCallback fun(eventStatus: EventStatus, pid: integer)
---@alias OnPlayerSelectedSpellCallback fun(eventStatus: EventStatus, pid: integer)
---@alias OnPlayerSendMessageCallback fun(eventStatus: EventStatus, pid: integer, message: string)
---@alias OnPlayerShapeshiftCallback fun(eventStatus: EventStatus, pid: integer, playerPacket: PlayerShapeshiftPacket)
---@alias OnPlayerSkillCallback fun(eventStatus: EventStatus, pid: integer, playerPacket: PlayerSkillPacket)
---@alias OnPlayerSpellbookCallback fun(eventStatus: EventStatus, pid: integer, playerPacket: PlayerSpellbookPacket)
---@alias OnPlayerSpellsActiveCallback fun(eventStatus: EventStatus, pid: integer, playerPacket: PlayerSpellsActivePacket)
---@alias OnPlayerTopicCallback fun(eventStatus: EventStatus, pid: integer)
---@alias OnRecordDynamicCallback fun(eventStatus: EventStatus, pid: integer, recordArray: RecordDynamicPacket[], storeType: string)
---@alias OnServerInitCallback fun(eventStatus: EventStatus)
---@alias OnServerPostInitCallback fun(eventStatus: EventStatus)
---@alias OnVideoPlayCallback fun(eventStatus: EventStatus, pid: integer, videos: string[])
---@alias OnWorldKillCountCallback fun(eventStatus: EventStatus, pid: integer)
---@alias OnWorldMapCallback fun(eventStatus: EventStatus, pid: integer, mapTileArray: MapTilePacket[])
---@alias OnWorldWeatherCallback fun(eventStatus: EventStatus, pid: integer)

---@overload fun(event: "OnActorAI", callback: OnActorAICallback)
---@overload fun(event: "OnActorCellChange", callback: OnActorCellChangeCallback)
---@overload fun(event: "OnActorDeath", callback: OnActorDeathCallback)
---@overload fun(event: "OnActorEquipment", callback: OnActorEquipmentCallback)
---@overload fun(event: "OnActorList", callback: OnActorListCallback)
---@overload fun(event: "OnActorSpellsActive", callback: OnActorSpellsActiveCallback)
---@overload fun(event: "OnCellDeletion", callback: OnCellDeletionCallback)
---@overload fun(event: "OnCellLoad", callback: OnCellLoadCallback)
---@overload fun(event: "OnCellUnload", callback: OnCellUnloadCallback)
---@overload fun(event: "OnClientScriptGlobal", callback: OnClientScriptGlobalCallback)
---@overload fun(event: "OnClientScriptLocal", callback: OnClientScriptLocalCallback)
---@overload fun(event: "OnConsoleCommand", callback: OnConsoleCommandCallback)
---@overload fun(event: "OnContainer", callback: OnContainerCallback)
---@overload fun(event: "OnDeathTimeExpiration", callback: OnDeathTimeExpirationCallback)
---@overload fun(event: "OnDoorState", callback: OnDoorStateCallback)
---@overload fun(event: "OnGUIAction", callback: OnGUIActionCallback)
---@overload fun(event: "OnLoginTimeExpiration", callback: OnLoginTimeExpirationCallback)
---@overload fun(event: "OnObjectActivate", callback: OnObjectActivateCallback)
---@overload fun(event: "OnObjectDelete", callback: OnObjectDeleteCallback)
---@overload fun(event: "OnObjectDialogueChoice", callback: OnObjectDialogueChoiceCallback)
---@overload fun(event: "OnObjectHit", callback: OnObjectHitCallback)
---@overload fun(event: "OnObjectLock", callback: OnObjectLockCallback)
---@overload fun(event: "OnObjectLoopTimeExpiration", callback: OnObjectLoopTimeExpirationCallback)
---@overload fun(event: "OnObjectMiscellaneous", callback: OnObjectMiscellaneousCallback)
---@overload fun(event: "OnObjectPlace", callback: OnObjectPlaceCallback)
---@overload fun(event: "OnObjectRestock", callback: OnObjectRestockCallback)
---@overload fun(event: "OnObjectScale", callback: OnObjectScaleCallback)
---@overload fun(event: "OnObjectSound", callback: OnObjectSoundCallback)
---@overload fun(event: "OnObjectSpawn", callback: OnObjectSpawnCallback)
---@overload fun(event: "OnObjectState", callback: OnObjectStateCallback)
---@overload fun(event: "OnObjectTrap", callback: OnObjectTrapCallback)
---@overload fun(event: "OnPlayerAttribute", callback: OnPlayerAttributeCallback)
---@overload fun(event: "OnPlayerAuthentified", callback: OnPlayerAuthentifiedCallback)
---@overload fun(event: "OnPlayerBook", callback: OnPlayerBookCallback)
---@overload fun(event: "OnPlayerBounty", callback: OnPlayerBountyCallback)
---@overload fun(event: "OnPlayerCellChange", callback: OnPlayerCellChangeCallback)
---@overload fun(event: "OnPlayerConnect", callback: OnPlayerConnectCallback)
---@overload fun(event: "OnPlayerCooldowns", callback: OnPlayerCooldownsCallback)
---@overload fun(event: "OnPlayerDeath", callback: OnPlayerDeathCallback)
---@overload fun(event: "OnPlayerDisconnect", callback: OnPlayerDisconnectCallback)
---@overload fun(event: "OnPlayerEndCharGen", callback: OnPlayerEndCharGenCallback)
---@overload fun(event: "OnPlayerEquipment", callback: OnPlayerEquipmentCallback)
---@overload fun(event: "OnPlayerFaction", callback: OnPlayerFactionCallback)
---@overload fun(event: "OnPlayerInventory", callback: OnPlayerInventoryCallback)
---@overload fun(event: "OnPlayerItemUse", callback: OnPlayerItemUseCallback)
---@overload fun(event: "OnPlayerJournal", callback: OnPlayerJournalCallback)
---@overload fun(event: "OnPlayerLevel", callback: OnPlayerLevelCallback)
---@overload fun(event: "OnPlayerMarkLocation", callback: OnPlayerMarkLocationCallback)
---@overload fun(event: "OnPlayerQuickKeys", callback: OnPlayerQuickKeysCallback)
---@overload fun(event: "OnPlayerReputation", callback: OnPlayerReputationCallback)
---@overload fun(event: "OnPlayerSelectedSpell", callback: OnPlayerSelectedSpellCallback)
---@overload fun(event: "OnPlayerSendMessage", callback: OnPlayerSendMessageCallback)
---@overload fun(event: "OnPlayerShapeshift", callback: OnPlayerShapeshiftCallback)
---@overload fun(event: "OnPlayerSkill", callback: OnPlayerSkillCallback)
---@overload fun(event: "OnPlayerSpellbook", callback: OnPlayerSpellbookCallback)
---@overload fun(event: "OnPlayerSpellsActive", callback: OnPlayerSpellsActiveCallback)
---@overload fun(event: "OnPlayerTopic", callback: OnPlayerTopicCallback)
---@overload fun(event: "OnRecordDynamic", callback: OnRecordDynamicCallback)
---@overload fun(event: "OnServerInit", callback: OnServerInitCallback)
---@overload fun(event: "OnServerPostInit", callback: OnServerPostInitCallback)
---@overload fun(event: "OnVideoPlay", callback: OnVideoPlayCallback)
---@overload fun(event: "OnWorldKillCount", callback: OnWorldKillCountCallback)
---@overload fun(event: "OnWorldMap", callback: OnWorldMapCallback)
---@overload fun(event: "OnWorldWeather", callback: OnWorldWeatherCallback)
---@param event string
---@param callback OnEventCallback
function customEventHooks.registerValidator(event, callback)
    if customEventHooks.validators[event] == nil then
        customEventHooks.validators[event] = {}
    end
    table.insert(customEventHooks.validators[event], callback)
end

---@overload fun(event: "OnActorAI", callback: OnActorAICallback)
---@overload fun(event: "OnActorCellChange", callback: OnActorCellChangeCallback)
---@overload fun(event: "OnActorDeath", callback: OnActorDeathCallback)
---@overload fun(event: "OnActorEquipment", callback: OnActorEquipmentCallback)
---@overload fun(event: "OnActorList", callback: OnActorListCallback)
---@overload fun(event: "OnActorSpellsActive", callback: OnActorSpellsActiveCallback)
---@overload fun(event: "OnCellDeletion", callback: OnCellDeletionCallback)
---@overload fun(event: "OnCellLoad", callback: OnCellLoadCallback)
---@overload fun(event: "OnCellUnload", callback: OnCellUnloadCallback)
---@overload fun(event: "OnClientScriptGlobal", callback: OnClientScriptGlobalCallback)
---@overload fun(event: "OnClientScriptLocal", callback: OnClientScriptLocalCallback)
---@overload fun(event: "OnConsoleCommand", callback: OnConsoleCommandCallback)
---@overload fun(event: "OnContainer", callback: OnContainerCallback)
---@overload fun(event: "OnDeathTimeExpiration", callback: OnDeathTimeExpirationCallback)
---@overload fun(event: "OnDoorState", callback: OnDoorStateCallback)
---@overload fun(event: "OnGUIAction", callback: OnGUIActionCallback)
---@overload fun(event: "OnLoginTimeExpiration", callback: OnLoginTimeExpirationCallback)
---@overload fun(event: "OnObjectActivate", callback: OnObjectActivateCallback)
---@overload fun(event: "OnObjectDelete", callback: OnObjectDeleteCallback)
---@overload fun(event: "OnObjectDialogueChoice", callback: OnObjectDialogueChoiceCallback)
---@overload fun(event: "OnObjectHit", callback: OnObjectHitCallback)
---@overload fun(event: "OnObjectLock", callback: OnObjectLockCallback)
---@overload fun(event: "OnObjectLoopTimeExpiration", callback: OnObjectLoopTimeExpirationCallback)
---@overload fun(event: "OnObjectMiscellaneous", callback: OnObjectMiscellaneousCallback)
---@overload fun(event: "OnObjectPlace", callback: OnObjectPlaceCallback)
---@overload fun(event: "OnObjectRestock", callback: OnObjectRestockCallback)
---@overload fun(event: "OnObjectScale", callback: OnObjectScaleCallback)
---@overload fun(event: "OnObjectSound", callback: OnObjectSoundCallback)
---@overload fun(event: "OnObjectSpawn", callback: OnObjectSpawnCallback)
---@overload fun(event: "OnObjectState", callback: OnObjectStateCallback)
---@overload fun(event: "OnObjectTrap", callback: OnObjectTrapCallback)
---@overload fun(event: "OnPlayerAttribute", callback: OnPlayerAttributeCallback)
---@overload fun(event: "OnPlayerAuthentified", callback: OnPlayerAuthentifiedCallback)
---@overload fun(event: "OnPlayerBook", callback: OnPlayerBookCallback)
---@overload fun(event: "OnPlayerBounty", callback: OnPlayerBountyCallback)
---@overload fun(event: "OnPlayerCellChange", callback: OnPlayerCellChangeCallback)
---@overload fun(event: "OnPlayerConnect", callback: OnPlayerConnectCallback)
---@overload fun(event: "OnPlayerCooldowns", callback: OnPlayerCooldownsCallback)
---@overload fun(event: "OnPlayerDeath", callback: OnPlayerDeathCallback)
---@overload fun(event: "OnPlayerDisconnect", callback: OnPlayerDisconnectCallback)
---@overload fun(event: "OnPlayerEndCharGen", callback: OnPlayerEndCharGenCallback)
---@overload fun(event: "OnPlayerEquipment", callback: OnPlayerEquipmentCallback)
---@overload fun(event: "OnPlayerFaction", callback: OnPlayerFactionCallback)
---@overload fun(event: "OnPlayerInventory", callback: OnPlayerInventoryCallback)
---@overload fun(event: "OnPlayerItemUse", callback: OnPlayerItemUseCallback)
---@overload fun(event: "OnPlayerJournal", callback: OnPlayerJournalCallback)
---@overload fun(event: "OnPlayerLevel", callback: OnPlayerLevelCallback)
---@overload fun(event: "OnPlayerMarkLocation", callback: OnPlayerMarkLocationCallback)
---@overload fun(event: "OnPlayerQuickKeys", callback: OnPlayerQuickKeysCallback)
---@overload fun(event: "OnPlayerReputation", callback: OnPlayerReputationCallback)
---@overload fun(event: "OnPlayerSelectedSpell", callback: OnPlayerSelectedSpellCallback)
---@overload fun(event: "OnPlayerSendMessage", callback: OnPlayerSendMessageCallback)
---@overload fun(event: "OnPlayerShapeshift", callback: OnPlayerShapeshiftCallback)
---@overload fun(event: "OnPlayerSkill", callback: OnPlayerSkillCallback)
---@overload fun(event: "OnPlayerSpellbook", callback: OnPlayerSpellbookCallback)
---@overload fun(event: "OnPlayerSpellsActive", callback: OnPlayerSpellsActiveCallback)
---@overload fun(event: "OnPlayerTopic", callback: OnPlayerTopicCallback)
---@overload fun(event: "OnRecordDynamic", callback: OnRecordDynamicCallback)
---@overload fun(event: "OnServerInit", callback: OnServerInitCallback)
---@overload fun(event: "OnServerPostInit", callback: OnServerPostInitCallback)
---@overload fun(event: "OnVideoPlay", callback: OnVideoPlayCallback)
---@overload fun(event: "OnWorldKillCount", callback: OnWorldKillCountCallback)
---@overload fun(event: "OnWorldMap", callback: OnWorldMapCallback)
---@overload fun(event: "OnWorldWeather", callback: OnWorldWeatherCallback)
---@param event string
---@param callback OnEventCallback
function customEventHooks.registerHandler(event, callback)
    if customEventHooks.handlers[event] == nil then
        customEventHooks.handlers[event] = {}
    end
    table.insert(customEventHooks.handlers[event], callback)
end

---@param event string
---@param args any
---@return EventStatus
function customEventHooks.triggerValidators(event, args)
    local eventStatus = customEventHooks.makeEventStatus(true, true)
    if customEventHooks.validators[event] ~= nil then
        for _, callback in ipairs(customEventHooks.validators[event]) do
            eventStatus = customEventHooks.updateEventStatus(eventStatus, callback(eventStatus, unpack(args)))
        end
    end
    return eventStatus
end

---@param event string
---@param eventStatus EventStatus
---@param args any
function customEventHooks.triggerHandlers(event, eventStatus, args)
    if customEventHooks.handlers[event] ~= nil then
        for _, callback in ipairs(customEventHooks.handlers[event]) do
             eventStatus = customEventHooks.updateEventStatus(eventStatus, callback(eventStatus, unpack(args)))
        end
    end
end

return customEventHooks
