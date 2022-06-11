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

---@alias OnEventCallback fun()
---@alias OnActorAICallback fun(eventStatus: EventStatus)
---@alias OnActorCellChangeCallback fun(eventStatus: EventStatus)
---@alias OnActorDeathCallback fun(eventStatus: EventStatus)
---@alias OnActorEquipmentCallback fun(eventStatus: EventStatus)
---@alias OnActorListCallback fun(eventStatus: EventStatus)
---@alias OnActorSpellsActiveCallback fun(eventStatus: EventStatus)
---@alias OnCellDeletionCallback fun(eventStatus: EventStatus)
---@alias OnCellLoadCallback fun(eventStatus: EventStatus)
---@alias OnCellUnloadCallback fun(eventStatus: EventStatus)
---@alias OnClientScriptGlobalCallback fun(eventStatus: EventStatus)
---@alias OnClientScriptLocalCallback fun(eventStatus: EventStatus, pid: integer, cellDescription: string, objects: ClientScriptLocalObjectPacket[])
---@alias OnConsoleCommandCallback fun(eventStatus: EventStatus)
---@alias OnContainerCallback fun(eventStatus: EventStatus)
---@alias OnDeathTimeExpirationCallback fun(eventStatus: EventStatus)
---@alias OnDoorStateCallback fun(eventStatus: EventStatus, pid: integer, cellDescription: string, objects: DoorStateObjectPacket[])
---@alias OnGUIActionCallback fun(eventStatus: EventStatus)
---@alias OnLoginTimeExpirationCallback fun(eventStatus: EventStatus)
---@alias OnObjectActivateCallback fun(eventStatus: EventStatus, pid: integer, cellDescription: string, objects: ObjectActivateObjectPacket[], players: ObjectActivatePlayerPacket[])
---@alias OnObjectDeleteCallback fun(eventStatus: EventStatus, pid: integer, cellDescription: string, objects: ObjectDeleteObjectPacket[])
---@alias OnObjectDialogueChoiceCallback fun(eventStatus: EventStatus, pid: integer, cellDescription: string, objects: ObjectDialogueChoiceObjectPacket[])
---@alias OnObjectHitCallback fun(eventStatus: EventStatus, pid: integer, cellDescription: string, objects: ObjectHitObjectPacket[], players: ObjectHitPlayerPacket[])
---@alias OnObjectLockCallback fun(eventStatus: EventStatus, pid: integer, cellDescription: string, objects: ObjectLockObjectPacket[])
---@alias OnObjectLoopTimeExpirationCallback fun(eventStatus: EventStatus)
---@alias OnObjectMiscellaneousCallback fun(eventStatus: EventStatus, pid: integer, cellDescription: string, objects: ObjectMiscellaneousObjectPacket[])
---@alias OnObjectPlaceCallback fun(eventStatus: EventStatus, pid: integer, cellDescription: string, objects: ObjectPlaceObjectPacket[])
---@alias OnObjectRestockCallback fun(eventStatus: EventStatus, pid: integer, cellDescription: string, objects: ObjectRestockObjectPacket[])
---@alias OnObjectScaleCallback fun(eventStatus: EventStatus, pid: integer, cellDescription: string, objects: ObjectScaleObjectPacket[])
---@alias OnObjectSoundCallback fun(eventStatus: EventStatus, pid: integer, cellDescription: string, objects: ObjectSoundObjectPacket[], players: ObjectSoundPlayerPacket[])
---@alias OnObjectSpawnCallback fun(eventStatus: EventStatus, pid: integer, cellDescription: string, objects: ObjectSpawnObjectPacket[])
---@alias OnObjectStateCallback fun(eventStatus: EventStatus, pid: integer, cellDescription: string, objects: ObjectStateObjectPacket[])
---@alias OnObjectTrapCallback fun(eventStatus: EventStatus, pid: integer, cellDescription: string, objects: ObjectTrapObjectPacket[])
---@alias OnPlayerAuthentifiedCallback fun(eventStatus: EventStatus)
---@alias OnPlayerBookCallback fun(eventStatus: EventStatus)
---@alias OnPlayerBountyCallback fun(eventStatus: EventStatus)
---@alias OnPlayerCellChangeCallback fun(eventStatus: EventStatus)
---@alias OnPlayerConnectCallback fun(eventStatus: EventStatus)
---@alias OnPlayerDeathCallback fun(eventStatus: EventStatus)
---@alias OnPlayerDisconnectCallback fun(eventStatus: EventStatus)
---@alias OnPlayerEndCharGenCallback fun(eventStatus: EventStatus)
---@alias OnPlayerFactionCallback fun(eventStatus: EventStatus)
---@alias OnPlayerItemUseCallback fun(eventStatus: EventStatus)
---@alias OnPlayerJournalCallback fun(eventStatus: EventStatus)
---@alias OnPlayerMarkLocationCallback fun(eventStatus: EventStatus)
---@alias OnPlayerReputationCallback fun(eventStatus: EventStatus)
---@alias OnPlayerSelectedSpellCallback fun(eventStatus: EventStatus)
---@alias OnPlayerSendMessageCallback fun(eventStatus: EventStatus)
---@alias OnPlayerSpellsActiveCallback fun(eventStatus: EventStatus)
---@alias OnPlayerTopicCallback fun(eventStatus: EventStatus)
---@alias OnRecordDynamicCallback fun(eventStatus: EventStatus)
---@alias OnServerInitCallback fun(eventStatus: EventStatus)
---@alias OnServerPostInitCallback fun(eventStatus: EventStatus)
---@alias OnVideoPlayCallback fun(eventStatus: EventStatus)
---@alias OnWorldKillCountCallback fun(eventStatus: EventStatus)
---@alias OnWorldMapCallback fun(eventStatus: EventStatus)
---@alias OnWorldWeatherCallback fun(eventStatus: EventStatus)

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
---@overload fun(event: "OnPlayerAuthentified", callback: OnPlayerAuthentifiedCallback)
---@overload fun(event: "OnPlayerBook", callback: OnPlayerBookCallback)
---@overload fun(event: "OnPlayerBounty", callback: OnPlayerBountyCallback)
---@overload fun(event: "OnPlayerCellChange", callback: OnPlayerCellChangeCallback)
---@overload fun(event: "OnPlayerConnect", callback: OnPlayerConnectCallback)
---@overload fun(event: "OnPlayerDeath", callback: OnPlayerDeathCallback)
---@overload fun(event: "OnPlayerDisconnect", callback: OnPlayerDisconnectCallback)
---@overload fun(event: "OnPlayerEndCharGen", callback: OnPlayerEndCharGenCallback)
---@overload fun(event: "OnPlayerFaction", callback: OnPlayerFactionCallback)
---@overload fun(event: "OnPlayerItemUse", callback: OnPlayerItemUseCallback)
---@overload fun(event: "OnPlayerJournal", callback: OnPlayerJournalCallback)
---@overload fun(event: "OnPlayerMarkLocation", callback: OnPlayerMarkLocationCallback)
---@overload fun(event: "OnPlayerReputation", callback: OnPlayerReputationCallback)
---@overload fun(event: "OnPlayerSelectedSpell", callback: OnPlayerSelectedSpellCallback)
---@overload fun(event: "OnPlayerSendMessage", callback: OnPlayerSendMessageCallback)
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
---@overload fun(event: "OnPlayerAuthentified", callback: OnPlayerAuthentifiedCallback)
---@overload fun(event: "OnPlayerBook", callback: OnPlayerBookCallback)
---@overload fun(event: "OnPlayerBounty", callback: OnPlayerBountyCallback)
---@overload fun(event: "OnPlayerCellChange", callback: OnPlayerCellChangeCallback)
---@overload fun(event: "OnPlayerConnect", callback: OnPlayerConnectCallback)
---@overload fun(event: "OnPlayerDeath", callback: OnPlayerDeathCallback)
---@overload fun(event: "OnPlayerDisconnect", callback: OnPlayerDisconnectCallback)
---@overload fun(event: "OnPlayerEndCharGen", callback: OnPlayerEndCharGenCallback)
---@overload fun(event: "OnPlayerFaction", callback: OnPlayerFactionCallback)
---@overload fun(event: "OnPlayerItemUse", callback: OnPlayerItemUseCallback)
---@overload fun(event: "OnPlayerJournal", callback: OnPlayerJournalCallback)
---@overload fun(event: "OnPlayerMarkLocation", callback: OnPlayerMarkLocationCallback)
---@overload fun(event: "OnPlayerReputation", callback: OnPlayerReputationCallback)
---@overload fun(event: "OnPlayerSelectedSpell", callback: OnPlayerSelectedSpellCallback)
---@overload fun(event: "OnPlayerSendMessage", callback: OnPlayerSendMessageCallback)
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
