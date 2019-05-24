--- JSON cell class - if opted for json storage instead of SQL
-- @classmod cell-base

require("config")
fileHelper = require("fileHelper")
tableHelper = require("tableHelper")
local BaseCell = require("cell.base")

local Cell = class("Cell", BaseCell)

--- Init function
-- @string cellDescription
function Cell:__init(cellDescription)
    BaseCell.__init(self, cellDescription)

    -- Ensure filename is valid
    self.entryName = fileHelper.fixFilename(cellDescription)

    self.entryFile = tes3mp.GetCaseInsensitiveFilename(tes3mp.GetDataPath() .. "/cell/", self.entryName .. ".json")

    if self.entryFile == "invalid" then
        self.hasEntry = false
        self.entryFile = self.entryName .. ".json"
    else
        self.hasEntry = true
    end
end

--- Create entry
function Cell:CreateEntry()
    self.hasEntry = jsonInterface.save("cell/" .. self.entryFile, self.data)

    if self.hasEntry then
        tes3mp.LogMessage(enumerations.log.INFO, "Successfully created JSON file for cell " .. self.entryName)
    else
        local message = "Failed to create JSON file for " .. self.entryName
        tes3mp.SendMessage(self.pid, message, true)
    end
end

--- Save cell to drive (removes nills)
function Cell:SaveToDrive()
    if self.hasEntry then
        tableHelper.cleanNils(self.data.packets)
        jsonInterface.save("cell/" .. self.entryFile, self.data, config.cellKeyOrder)
    end
end

--- Quick save cell to drive (doesn't remove nills)
function Cell:QuicksaveToDrive()
    if self.hasEntry then
        jsonInterface.quicksave("cell/" .. self.entryFile, self.data)
    end
end

--- Load from drive
function Cell:LoadFromDrive()
    self.data = jsonInterface.load("cell/" .. self.entryFile)

    -- JSON doesn't allow numerical keys, but we use them, so convert
    -- all string number keys into numerical keys
    tableHelper.fixNumericalKeys(self.data)
end

--- Deprecated function with confusing name, kept around for backwards compatibility
function Cell:Save()
    self:SaveToDrive()
end

--- Deprecated function with confusing name, kept around for backwards compatibility
function Cell:Load()
    self:LoadFromDrive()
end

return Cell
