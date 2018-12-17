Database = require("database")
local BaseRecordStore = require("recordstore.base")

local RecordStore = class("RecordStore", BaseRecordStore)

function RecordStore:__init()
    BaseRecordStore.__init(self)

    if self.hasEntry == nil then

        -- Not implemented yet
    end
end

function RecordStore:CreateEntry()
    -- Not implemented yet
end

function RecordStore:Save()
    -- Not implemented yet
end

function RecordStore:Load()
    -- Not implemented yet
end

return RecordStore
