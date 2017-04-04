local BaseWorld = class("BaseWorld")

function BaseWorld:__init(test)

    self.data =
    {
        general = {
            currentMpNum = 0
        }
    };
end

function BaseWorld:GetCurrentMpNum()
    return self.data.general.currentMpNum
end

function BaseWorld:SetCurrentMpNum(currentMpNum)
    self.data.general.currentMpNum = currentMpNum
    self:Save()
end

function BaseWorld:HasEntry()
    return self.hasEntry
end

return BaseWorld
