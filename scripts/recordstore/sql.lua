--- RecordStore SQL
-- @classmod recordstore-sql
Database = require("database")
local BaseRecordStore = require("recordstore.base")
--- Base RecordStore
local RecordStore = class("RecordStore", BaseRecordStore)

--- Init function
function RecordStore:__init()
    BaseRecordStore.__init(self)

    if self.hasEntry == nil then

        -- Not implemented yet
    end
end

--- Ceate entry <bold> Not implemented yet </bold>
function RecordStore:CreateEntry()
    -- Not implemented yet
end

--- Save to drive <bold> Not implemented yet </bold>
function RecordStore:SaveToDrive()
    -- Not implemented yet
end

--- Load from drive <bold> Not implemented yet </bold>
function RecordStore:LoadFromDrive()
    -- Not implemented yet
end

return RecordStore
