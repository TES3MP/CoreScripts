stateHelper = require("stateHelper")
local BaseWorld = class("BaseWorld")

function BaseWorld:__init(test)

    self.data =
    {
        general = {
            currentMpNum = 0
        },
        journal = {},
        factionRanks = {},
        factionExpulsion = {},
        topics = {},
        kills = {}
    };
end

function BaseWorld:HasEntry()
    return self.hasEntry
end

function BaseWorld:GetCurrentMpNum()
    return self.data.general.currentMpNum
end

function BaseWorld:SetCurrentMpNum(currentMpNum)
    self.data.general.currentMpNum = currentMpNum
    self:Save()
end

function BaseWorld:SaveJournal(pid)

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

        table.insert(self.data.journal, journalItem)
    end

    self:Save()
end

function BaseWorld:SaveFactionRanks(pid)
    stateHelper:SaveFactionRanks(pid, self)
end

function BaseWorld:SaveFactionExpulsion(pid)
    stateHelper:SaveFactionExpulsion(pid, self)
end

function BaseWorld:SaveTopics(pid)

    for i = 0, tes3mp.GetTopicChangesSize(pid) - 1 do

        local topicId = tes3mp.GetTopicId(pid, i)

        if tableHelper.containsValue(self.data.topics, topicId) == false then
            table.insert(self.data.topics, topicId)
        end
    end

    self:Save()
end

function BaseWorld:SaveKills(pid)

    for i = 0, tes3mp.GetKillChangesSize(pid) - 1 do

        local refId = tes3mp.GetKillRefId(pid, i)
        local number = tes3mp.GetKillNumber(pid, i)
        self.data.kills[refId] = number
    end

    self:Save()
end

function BaseWorld:LoadJournal(pid)

    local journalItemTypes = { ENTRY = 0, INDEX = 1 }

    tes3mp.InitializeJournalChanges(pid)

    for index, journalItem in pairs(self.data.journal) do

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

function BaseWorld:LoadFactionRanks(pid)
    stateHelper:LoadFactionRanks(pid, self)
end

function BaseWorld:LoadFactionExpulsion(pid)
    stateHelper:LoadFactionExpulsion(pid, self)
end

function BaseWorld:LoadTopics(pid)

    tes3mp.InitializeTopicChanges(pid)

    for index, topicId in pairs(self.data.topics) do

        tes3mp.AddTopic(pid, topicId)
    end

    tes3mp.SendTopicChanges(pid)
end

function BaseWorld:LoadKills(pid)

    tes3mp.InitializeKillChanges(pid)

    for refId, number in pairs(self.data.kills) do

        tes3mp.AddKill(pid, refId, number)
    end

    tes3mp.SendKillChanges(pid)
end

return BaseWorld
