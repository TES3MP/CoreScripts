require("config")
fileHelper = require("fileHelper")
tableHelper = require("tableHelper")
local BaseRecordStore = require("recordstore.base")

local RecordStore = class("RecordStore", BaseRecordStore)

function RecordStore:__init(storeType)
    BaseRecordStore.__init(self, storeType)

    -- Ensure filename is valid
    self.recordstoreFile = storeType .. ".json"

    if self.hasEntry == nil then
        local home = tes3mp.GetModDir().."/recordstore/"
        local file = io.open(home .. self.recordstoreFile, "r")
        if file ~= nil then
            io.close()
            self.hasEntry = true
        else
            self.hasEntry = false
        end
    end
end

function RecordStore:CreateEntry()
    jsonInterface.save("recordstore/" .. self.recordstoreFile, self.data)
    self.hasEntry = true
end

function RecordStore:Save()
    if self.hasEntry then
        jsonInterface.save("recordstore/" .. self.recordstoreFile, self.data, config.recordstoreKeyOrder)
    end
end

function RecordStore:Load()
    self.data = jsonInterface.load("recordstore/" .. self.recordstoreFile)

    -- JSON doesn't allow numerical keys, but we use them, so convert
    -- all string number keys into numerical keys
    tableHelper.fixNumericalKeys(self.data)
end

return RecordStore
