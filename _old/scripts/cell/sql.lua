jsonInterface = require("jsonInterface")
Database = require("database")
local BaseCell = require("cell.base")

local Cell = class("Cell", BaseCell)

function Cell:__init(cellDescription)
    BaseCell.__init(self, cellDescription)

    -- Replace characters not allowed in filenames
    self.cellFile = cellDescription
    self.cellFile = string.gsub(self.cellFile, ":", ";")
    self.cellFile = self.cellFile .. ".json"

    if self.hasEntry == nil then
        local home = os.getenv("MOD_DIR").."/cell/"
        local file = io.open(home .. self.cellFile, "r")
        if file ~= nil then
            io.close()
            self.hasEntry = true
        else
            self.hasEntry = false
        end
    end
end

function Cell:CreateEntry()
    jsonInterface.save("cell/" .. self.cellFile, self.data)
    self.hasEntry = true
end

function Cell:Save()
    if self.hasEntry then
        jsonInterface.save("cell/" .. self.cellFile, self.data)
    end
end

function Cell:Load()
    self.data = jsonInterface.load("cell/" .. self.cellFile)

    -- JSON doesn't allow numerical keys, but we use them, so convert
    -- all string number keys into numerical keys
    tableHelper.fixNumericalKeys(self.data)
end

return Cell
