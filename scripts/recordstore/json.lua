require("config")
fileHelper = require("fileHelper")
tableHelper = require("tableHelper")
local BaseRecordStore = require("recordstore.base")

local RecordStore = class("RecordStore", BaseRecordStore)

function RecordStoreSaveTimer(storeType)
    coroutine.resume(RecordStores[storeType].saveCoroutine)
end

function RecordStore:__init(storeType)
    BaseRecordStore.__init(self, storeType)

    -- Ensure filename is valid
    self.recordstoreFile = storeType .. ".json"

    if self.hasEntry == nil then
        local home = config.dataPath .. "/recordstore/"
        local file = io.open(home .. self.recordstoreFile, "r")
        if file ~= nil then
            io.close()
            self.hasEntry = true
        else
            self.hasEntry = false
        end
    end
    self.saveCoroutine = coroutine.create(function()
    while true do
        tes3mp.LogMessage(enumerations.log.INFO, "Saving recordstore " .. self.storeType)
        jsonInterface.quicksave("recordstore/" .. self.recordstoreFile, self.data)
        coroutine.yield()
    end
    end)
    self.quickSaveTimer = tes3mp.CreateTimerEx("RecordStoreSaveTimer", time.seconds(config.recordStoreSaveDelay), "s", self.storeType)
end

function RecordStore:CreateEntry()
    jsonInterface.save("recordstore/" .. self.recordstoreFile, self.data)
    self.hasEntry = true
end

function RecordStore:SaveToDrive()
    if self.hasEntry then
        jsonInterface.save("recordstore/" .. self.recordstoreFile, self.data, config.recordstoreKeyOrder)
    end
end

function RecordStore:QuicksaveToDrive()
    if self.hasEntry then
        tes3mp.StartTimer(self.quickSaveTimer)
    end
end

function RecordStore:LoadFromDrive()
    self.data = jsonInterface.load("recordstore/" .. self.recordstoreFile)

    -- JSON doesn't allow numerical keys, but we use them, so convert
    -- all string number keys into numerical keys
    tableHelper.fixNumericalKeys(self.data)
end

-- Deprecated functions with confusing names, kept around for backwards compatibility
function RecordStore:Save()
    self:SaveToDrive()
end

function RecordStore:Load()
    self:LoadFromDrive()
end

return RecordStore
