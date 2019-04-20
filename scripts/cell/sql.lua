Database = require("database")
local BaseCell = require("cell.base")

local Cell = class("Cell", BaseCell)

function Cell:__init(cellDescription)
    BaseCell.__init(self, cellDescription)

    if self.hasEntry == nil then

        -- Not implemented yet
    end
end

function Cell:CreateEntry()
    -- Not implemented yet
end

function Cell:SaveToDrive()
    -- Not implemented yet
end

function Cell:LoadFromDrive()
    -- Not implemented yet
end

return Cell
