StateHelper = class("StateHelper")

function StateHelper:LoadJournal(pid, stateObject)

    if stateObject.data.journal == nil then
        stateObject.data.journal = {}
    end

    tes3mp.ClearJournalChanges(pid)

    for index, journalItem in pairs(stateObject.data.journal) do

        if journalItem.type == enumerations.journal.ENTRY then

            if journalItem.actorRefId == nil then
                journalItem.actorRefId = "player"
            end

            if journalItem.timestamp ~= nil then
                tes3mp.AddJournalEntryWithTimestamp(pid, journalItem.quest, journalItem.index, journalItem.actorRefId,
                    journalItem.timestamp.daysPassed, journalItem.timestamp.month, journalItem.timestamp.day)
            else
                tes3mp.AddJournalEntry(pid, journalItem.quest, journalItem.index, journalItem.actorRefId)
            end
        else
            tes3mp.AddJournalIndex(pid, journalItem.quest, journalItem.index)
        end
    end

    tes3mp.SendJournalChanges(pid)
end

function StateHelper:LoadFactionRanks(pid, stateObject)

    if stateObject.data.factionRanks == nil then
        stateObject.data.factionRanks = {}
    end

    tes3mp.ClearFactionChanges(pid)
    tes3mp.SetFactionChangesAction(pid, enumerations.faction.RANK)

    for factionId, rank in pairs(stateObject.data.factionRanks) do

        tes3mp.SetFactionId(factionId)
        tes3mp.SetFactionRank(rank)
        tes3mp.AddFaction(pid)
    end

    tes3mp.SendFactionChanges(pid)
end

function StateHelper:LoadFactionExpulsion(pid, stateObject)

    if stateObject.data.factionExpulsion == nil then
        stateObject.data.factionExpulsion = {}
    end

    tes3mp.ClearFactionChanges(pid)
    tes3mp.SetFactionChangesAction(pid, enumerations.faction.EXPULSION)

    for factionId, state in pairs(stateObject.data.factionExpulsion) do

        tes3mp.SetFactionId(factionId)
        tes3mp.SetFactionExpulsionState(state)
        tes3mp.AddFaction(pid)
    end

    tes3mp.SendFactionChanges(pid)
end

function StateHelper:LoadFactionReputation(pid, stateObject)

    if stateObject.data.factionReputation == nil then
        stateObject.data.factionReputation = {}
    end

    tes3mp.ClearFactionChanges(pid)
    tes3mp.SetFactionChangesAction(pid, enumerations.faction.REPUTATION)

    for factionId, reputation in pairs(stateObject.data.factionReputation) do

        tes3mp.SetFactionId(factionId)
        tes3mp.SetFactionReputation(reputation)
        tes3mp.AddFaction(pid)
    end

    tes3mp.SendFactionChanges(pid)
end

function StateHelper:LoadTopics(pid, stateObject)

    if stateObject.data.topics == nil then
        stateObject.data.topics = {}
    end

    tes3mp.ClearTopicChanges(pid)

    for index, topicId in pairs(stateObject.data.topics) do

        tes3mp.AddTopic(pid, topicId)
    end

    tes3mp.SendTopicChanges(pid)
end

function StateHelper:LoadBounty(pid, stateObject)

    if stateObject.data.fame == nil then
        stateObject.data.fame = { bounty = 0, reputation = 0 }
    elseif stateObject.data.fame.bounty == nil then
        stateObject.data.fame.bounty = 0
    end

    -- Update old player files to the new format
    if stateObject.data.stats ~= nil and stateObject.data.stats.bounty ~= nil then
        stateObject.data.fame.bounty = stateObject.data.stats.bounty
        stateObject.data.stats.bounty = nil
    end

    tes3mp.SetBounty(pid, stateObject.data.fame.bounty)
    tes3mp.SendBounty(pid)
end

function StateHelper:LoadReputation(pid, stateObject)

    if stateObject.data.fame == nil then
        stateObject.data.fame = { bounty = 0, reputation = 0 }
    elseif stateObject.data.fame.reputation == nil then
        stateObject.data.fame.reputation = 0
    end

    tes3mp.SetReputation(pid, stateObject.data.fame.reputation)
    tes3mp.SendReputation(pid)
end

function StateHelper:LoadClientScriptVariables(pid, stateObject)

    if stateObject.data.clientVariables == nil then
        stateObject.data.clientVariables = {}
    end

    if stateObject.data.clientVariables.globals == nil then
        stateObject.data.clientVariables.globals = {}
    end

    local variableCount = 0

    tes3mp.ClearClientGlobals()

    for variableId, variableTable in pairs(stateObject.data.clientVariables.globals) do

        if type(variableTable) == "table" then

            if variableTable.variableType == enumerations.variableType.SHORT then
                tes3mp.AddClientGlobalInteger(variableId, variableTable.intValue, enumerations.variableType.SHORT)
            elseif variableTable.variableType == enumerations.variableType.LONG then
                tes3mp.AddClientGlobalInteger(variableId, variableTable.intValue, enumerations.variableType.LONG)
            elseif variableTable.variableType == enumerations.variableType.FLOAT then
                tes3mp.AddClientGlobalFloat(variableId, variableTable.floatValue)
            end

            variableCount = variableCount + 1
        end
    end

    if variableCount > 0 then
        tes3mp.SendClientScriptGlobal(pid)
    end
end

function StateHelper:LoadDestinationOverrides(pid, stateObject)

    if stateObject.data.destinationOverrides == nil then
        stateObject.data.destinationOverrides = {}
    end

    local destinationCount = 0

    tes3mp.ClearDestinationOverrides()

    for oldCellDescription, newCellDescription in pairs(stateObject.data.destinationOverrides) do

        tes3mp.AddDestinationOverride(oldCellDescription, newCellDescription)
        destinationCount = destinationCount + 1
    end

    if destinationCount > 0 then
        tes3mp.SendWorldDestinationOverride(pid)
    end
end

function StateHelper:LoadMap(pid, stateObject)

    if stateObject.data.mapExplored == nil then
        stateObject.data.mapExplored = {}
    end

    local tileCount = 0
    tes3mp.ClearMapChanges()

    for index, cellDescription in pairs(stateObject.data.mapExplored) do

        local filePath = config.dataPath .. "/map/" .. cellDescription .. ".png"

        if tes3mp.DoesFilePathExist(filePath) then

            local cellX, cellY
            _, _, cellX, cellY = string.find(cellDescription, patterns.exteriorCell)
            cellX = tonumber(cellX)
            cellY = tonumber(cellY)

            if type(cellX) == "number" and type(cellY) == "number" then
                tes3mp.LoadMapTileImageFile(cellX, cellY, filePath)
                tileCount = tileCount + 1
            end
        end
    end

    if tileCount > 0 then
        tes3mp.SendWorldMap(pid)
    end
end

function StateHelper:SaveJournal(stateObject, playerPacket)

    if stateObject.data.journal == nil then
        stateObject.data.journal = {}
    end

    if stateObject.data.customVariables == nil then
        stateObject.data.customVariables = {}
    end

    for _, journalItem in ipairs(playerPacket.journal) do

        table.insert(stateObject.data.journal, journalItem)

        if journalItem.quest == "a1_1_findspymaster" and journalItem.index >= 14 then
            stateObject.data.customVariables.deliveredCaiusPackage = true
        end
    end

    stateObject:QuicksaveToDrive()
end

function StateHelper:SaveFactionRanks(pid, stateObject)

    if stateObject.data.factionRanks == nil then
        stateObject.data.factionRanks = {}
    end

    for i = 0, tes3mp.GetFactionChangesSize(pid) - 1 do

        local factionId = tes3mp.GetFactionId(pid, i)
        stateObject.data.factionRanks[factionId] = tes3mp.GetFactionRank(pid, i)
    end

    stateObject:QuicksaveToDrive()
end

function StateHelper:SaveFactionExpulsion(pid, stateObject)

    if stateObject.data.factionExpulsion == nil then
        stateObject.data.factionExpulsion = {}
    end

    for i = 0, tes3mp.GetFactionChangesSize(pid) - 1 do

        local factionId = tes3mp.GetFactionId(pid, i)
        stateObject.data.factionExpulsion[factionId] = tes3mp.GetFactionExpulsionState(pid, i)
    end

    stateObject:QuicksaveToDrive()
end

function StateHelper:SaveFactionReputation(pid, stateObject)

    if stateObject.data.factionReputation == nil then
        stateObject.data.factionReputation = {}
    end

    for i = 0, tes3mp.GetFactionChangesSize(pid) - 1 do

        local factionId = tes3mp.GetFactionId(pid, i)
        stateObject.data.factionReputation[factionId] = tes3mp.GetFactionReputation(pid, i)
    end

    stateObject:QuicksaveToDrive()
end

function StateHelper:SaveTopics(pid, stateObject)

    if stateObject.data.topics == nil then
        stateObject.data.topics = {}
    end

    for i = 0, tes3mp.GetTopicChangesSize(pid) - 1 do

        local topicId = tes3mp.GetTopicId(pid, i)

        if not tableHelper.containsValue(stateObject.data.topics, topicId) then
            table.insert(stateObject.data.topics, topicId)
        end
    end

    stateObject:QuicksaveToDrive()
end

function StateHelper:SaveBounty(pid, stateObject)

    if stateObject.data.fame == nil then
        stateObject.data.fame = {}
    end

    stateObject.data.fame.bounty = tes3mp.GetBounty(pid)

    stateObject:QuicksaveToDrive()
end

function StateHelper:SaveReputation(pid, stateObject)

    if stateObject.data.fame == nil then
        stateObject.data.fame = {}
    end

    stateObject.data.fame.reputation = tes3mp.GetReputation(pid)

    stateObject:QuicksaveToDrive()
end

function StateHelper:SaveClientScriptGlobal(stateObject, variables)

    if stateObject.data.clientVariables == nil then
        stateObject.data.clientVariables = {}
    end

    if stateObject.data.clientVariables.globals == nil then
        stateObject.data.clientVariables.globals = {}
    end

    for id, variable in pairs (variables) do
        stateObject.data.clientVariables.globals[id] = variable
    end

    stateObject:QuicksaveToDrive()
end

function StateHelper:SaveMapExploration(pid, stateObject)

    local cell = tes3mp.GetCell(pid)

    if tes3mp.IsInExterior(pid) == true then
        if not tableHelper.containsValue(stateObject.data.mapExplored, cell) then
            table.insert(stateObject.data.mapExplored, cell)
        end
    end
end

return StateHelper
