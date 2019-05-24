--- RecordStore JSON
-- @classmod recordstore-json
require("config")
fileHelper = require("fileHelper")
tableHelper = require("tableHelper")
--- base class
local BaseRecordStore = require("recordstore.base")

--- Base record store
local RecordStore = class("RecordStore", BaseRecordStore)

--- Init function
-- @string storeType
function RecordStore:__init(storeType)
    BaseRecordStore.__init(self, storeType)

    -- Ensure filename is valid
    self.recordstoreFile = storeType .. ".json"

    if self.hasEntry == nil then
        local home = tes3mp.GetDataPath() .. "/recordstore/"
        local file = io.open(home .. self.recordstoreFile, "r")
        if file ~= nil then
            io.close()
            self.hasEntry = true
        else
            self.hasEntry = false
        end
    end
end

--- Create entry
function RecordStore:CreateEntry()
    jsonInterface.save("recordstore/" .. self.recordstoreFile, self.data)
    self.hasEntry = true
end

--- Save to drive
function RecordStore:SaveToDrive()
    if self.hasEntry then
        jsonInterface.save("recordstore/" .. self.recordstoreFile, self.data, config.recordstoreKeyOrder)
    end
end

--- Quick save to drive
function RecordStore:QuicksaveToDrive()
    if self.hasEntry then
        jsonInterface.quicksave("recordstore/" .. self.recordstoreFile, self.data)
    end
end

--- Load from drive
function RecordStore:LoadFromDrive()
    self.data = jsonInterface.load("recordstore/" .. self.recordstoreFile)

    -- JSON doesn't allow numerical keys, but we use them, so convert
    -- all string number keys into numerical keys
    tableHelper.fixNumericalKeys(self.data)
end

--- Deprecated functions with confusing names, kept around for backwards compatibility
function RecordStore:Save()
    self:SaveToDrive()
end

--- Deprecated functions with confusing names, kept around for backwards compatibility
function RecordStore:Load()
    self:LoadFromDrive()
end

return RecordStore
