StateHelper = class("StateHelper")

function StateHelper:SaveJournal(pid, stateObject)

    if stateObject.data.journal == nil then
        stateObject.data.journal = {}
    end

    local journalItemTypes = { ENTRY = 0, INDEX = 1 }

    for i = 0, tes3mp.GetJournalChangesSize(pid) - 1 do

        local journalItem = {
            type = tes3mp.GetJournalItemType(pid, i),
            index = tes3mp.GetJournalItemIndex(pid, i),
            quest = tes3mp.GetJournalItemQuest(pid, i)
        }

        if journalItem.type == journalItemTypes.ENTRY then
            journalItem.actorRefId = tes3mp.GetJournalItemActorRefId(pid, i)
        end

        table.insert(stateObject.data.journal, journalItem)
    end

    stateObject:Save()
end

function StateHelper:SaveFactionRanks(pid, stateObject)

    if stateObject.data.factionRanks == nil then
        stateObject.data.factionRanks = {}
    end

    for i = 0, tes3mp.GetFactionChangesSize(pid) - 1 do

        local factionId = tes3mp.GetFactionId(pid, i)
        stateObject.data.factionRanks[factionId] = tes3mp.GetFactionRank(pid, i)
    end

    stateObject:Save()
end

function StateHelper:SaveFactionExpulsion(pid, stateObject)

    if stateObject.data.factionExpulsion == nil then
        stateObject.data.factionExpulsion = {}
    end

    for i = 0, tes3mp.GetFactionChangesSize(pid) - 1 do

        local factionId = tes3mp.GetFactionId(pid, i)
        stateObject.data.factionExpulsion[factionId] = tes3mp.GetFactionExpelledState(pid, i)
    end

    stateObject:Save()
end

function StateHelper:SaveFactionReputation(pid, stateObject)

    if stateObject.data.factionReputation == nil then
        stateObject.data.factionReputation = {}
    end

    for i = 0, tes3mp.GetFactionChangesSize(pid) - 1 do

        local factionId = tes3mp.GetFactionId(pid, i)
        stateObject.data.factionReputation[factionId] = tes3mp.GetFactionReputation(pid, i)
    end

    stateObject:Save()
end

function StateHelper:LoadJournal(pid, stateObject)

    if stateObject.data.journal == nil then
        stateObject.data.journal = {}
    end

    local journalItemTypes = { ENTRY = 0, INDEX = 1 }

    tes3mp.InitializeJournalChanges(pid)

    for index, journalItem in pairs(stateObject.data.journal) do

        if journalItem.type == journalItemTypes.ENTRY then

            if journalItem.actorRefId == nil then
                journalItem.actorRefId = "player"
            end

            tes3mp.AddJournalEntry(pid, journalItem.quest, journalItem.index, journalItem.actorRefId)
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

    local actionTypes = { RANK = 0, EXPULSION = 1, REPUTATION = 2 }

    tes3mp.InitializeFactionChanges(pid)
    tes3mp.SetFactionChangesAction(pid, actionTypes.RANK)

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

    local actionTypes = { RANK = 0, EXPULSION = 1, REPUTATION = 2 }

    tes3mp.InitializeFactionChanges(pid)
    tes3mp.SetFactionChangesAction(pid, actionTypes.EXPULSION)

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

    local actionTypes = { RANK = 0, EXPULSION = 1, REPUTATION = 2 }

    tes3mp.InitializeFactionChanges(pid)
    tes3mp.SetFactionChangesAction(pid, actionTypes.REPUTATION)

    for factionId, reputation in pairs(stateObject.data.factionReputation) do

        tes3mp.SetFactionId(factionId)
        tes3mp.SetFactionReputation(reputation)
        tes3mp.AddFaction(pid)
    end

    tes3mp.SendFactionChanges(pid)
end

return StateHelper
