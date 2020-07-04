local BaseCell = require("cell.base")

local Cell = class("Cell", BaseCell)

function Cell:__init(cellDescription)
    BaseCell.__init(self, cellDescription)

    self.hasEntry = true
    self.entryName = cellDescription:trim()
end

-- no need to write default data to the database
function Cell:CreateEntry()
end

function Cell:SaveToDrive()
    if self.hasEntry then
        tableHelper.cleanNils(self.data.packets)
        local result = postgresDrive.QueryAsync(
            [[INSERT INTO cell (description, data) VALUES (?, ?)
            ON CONFLICT (description) DO
            UPDATE SET data = EXCLUDED.data;]],
            {self.entryName, jsonInterface.encode(self.data)}
        )
        if result.error then
            error("Failed to save the cell " .. self.description)
        end
    end
end

function Cell:QuicksaveToDrive()
    async.Wrap(function() self:SaveToDrive() end)
end

function Cell:LoadFromDrive()
    local result = postgresDrive.QueryAsync([[SELECT data FROM cell WHERE description = ?;]], {self.entryName})
    if result.error then
        error("Failed to load the cell " .. self.description)
    end
    if result.count > 1 then
        error("Duplicate records in the database for cell " .. self.description)
    end

    -- if no data is present, just keep the default
    if result.count == 1 then
        self.data = jsonInterface.decode(result.rows[1].data)

        -- JSON doesn't allow numerical keys, but we use them, so convert
        -- all string number keys into numerical keys
        tableHelper.fixNumericalKeys(self.data)
    end
end

-- Deprecated function with confusing name, kept around for backwards compatibility
function Cell:Save()
    self:SaveToDrive()
end

function Cell:Load()
    self:LoadFromDrive()
end

return Cell
