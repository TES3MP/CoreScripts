--- SQL cell class - if opted for SQL storage instead of JSON
-- @classmod cell-sql
Database = require("database")
local BaseCell = require("cell.base")

local Cell = class("Cell", BaseCell)

--- Init function
-- @string cellDescription
function Cell:__init(cellDescription)
    BaseCell.__init(self, cellDescription)

    if self.hasEntry == nil then

        -- Not implemented yet
    end
end

--- Ceate entry <bold> Not implemented yet </bold>
function Cell:CreateEntry()
    -- Not implemented yet
end

--- Save to drive <bold> Not implemented yet </bold>
function Cell:SaveToDrive()
    -- Not implemented yet
end

--- Load from drive <bold> Not implemented yet </bold>
function Cell:LoadFromDrive()
    -- Not implemented yet
end

return Cell
