local BaseWorld = class("BaseWorld")

function BaseWorld:__init(test)

    self.data =
    {
        general = {
            currentMpNum = 0
        }
    };
end

function BaseWorld:HasEntry()
    return self.hasEntry
end

return BaseWorld
