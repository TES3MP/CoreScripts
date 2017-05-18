local BaseWorld = class("BaseWorld")

function BaseWorld:__init(test)

    self.data =
    {
        general = {
            currentMpNum = 0
        },
        journal = {}
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

function BaseWorld:AddJournal(pid)

    for i = 0, tes3mp.GetJournalChangesSize(pid) - 1 do

        local journalItem = {
            type = tes3mp.GetJournalItemType(pid, i),
            index = tes3mp.GetJournalItemIndex(pid, i),
            quest = tes3mp.GetJournalItemQuest(pid, i)
        }

        table.insert(self.data.journal, journalItem)
    end

    self:Save()
end

return BaseWorld
