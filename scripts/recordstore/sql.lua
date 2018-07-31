Database = require("database")
local BaseRecordStore = require("recordstore.base")

local RecordStore = class("RecordStore", BaseRecordStore)

function RecordStore:__init()
    BaseRecordStore.__init(self)

    if self.hasEntry == nil then

        -- Fill in later
    end
end

function RecordStore:CreateEntry()
    self:Save()
    self.hasEntry = true
end

function RecordStore:Save()
    Database:SaveRecordStore(self.data)
end

function RecordStore:Load()
    self.data = Database:LoadRecordStore(self.data)
end

return RecordStore
