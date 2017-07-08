StateHelper = class("StateHelper")

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

function StateHelper:LoadFactionRanks(pid, stateObject)

    if stateObject.data.factionRanks == nil then
        stateObject.data.factionRanks = {}
    end

    local actionTypes = { RANK = 0, EXPULSION = 1 }

    tes3mp.InitializeFactionChanges(pid)
    tes3mp.SetFactionChangesAction(pid, actionTypes.RANK)

    for factionId, rank in pairs(stateObject.data.factionRanks) do

        tes3mp.AddFaction(pid, factionId, rank, false)
    end

    tes3mp.SendFactionChanges(pid)
end

function StateHelper:LoadFactionExpulsion(pid, stateObject)

    if stateObject.data.factionExpulsion == nil then
        stateObject.data.factionExpulsion = {}
    end

    local actionTypes = { RANK = 0, EXPULSION = 1 }

    tes3mp.InitializeFactionChanges(pid)
    tes3mp.SetFactionChangesAction(pid, actionTypes.EXPULSION)

    for factionId, state in pairs(stateObject.data.factionExpulsion) do

        tes3mp.AddFaction(pid, factionId, -1, state)
    end

    tes3mp.SendFactionChanges(pid)
end

return StateHelper
