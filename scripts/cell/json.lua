require("config")
fileHelper = require("fileHelper")
tableHelper = require("tableHelper")
local BaseCell = require("cell.base")

local Cell = class("Cell", BaseCell)

function Cell:__init(cellDescription)
    BaseCell.__init(self, cellDescription)

    -- Ensure filename is valid
    self.entryName = fileHelper.fixFilename(cellDescription)

    self.entryFile = tes3mp.GetCaseInsensitiveFilename(tes3mp.GetModDir() .. "/cell/", self.entryName .. ".json")

    if self.entryFile == "invalid" then
        self.hasEntry = false
        self.entryFile = self.entryName .. ".json"
    else
        self.hasEntry = true
    end
end

function Cell:CreateEntry()
    self.hasEntry = jsonInterface.save("cell/" .. self.entryFile, self.data)

    if self.hasEntry then
        tes3mp.LogMessage(enumerations.log.WARN, "Successfully created JSON file for cell " .. self.entryName)
    else
        local message = "Failed to create JSON file for " .. self.entryName
        tes3mp.SendMessage(self.pid, message, true)
    end
end

function Cell:Save()
    if self.hasEntry then
        tableHelper.cleanNils(self.data.packets)
        jsonInterface.save("cell/" .. self.entryFile, self.data, config.cellKeyOrder)
    end
end

function Cell:Load()
    self.data = jsonInterface.load("cell/" .. self.entryFile)

    -- JSON doesn't allow numerical keys, but we use them, so convert
    -- all string number keys into numerical keys
    tableHelper.fixNumericalKeys(self.data)
end

return Cell
