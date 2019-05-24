--- World JSON
-- @classmod world-json
require("config")
tableHelper = require("tableHelper")
local BaseWorld = require("world.base")

local World = class("World", BaseWorld)

--- Init function
function World:__init()
    BaseWorld.__init(self)

    self.worldFile = "world.json"

    if self.hasEntry == nil then
        local home = tes3mp.GetDataPath() .. "/world/"
        local file = io.open(home .. self.worldFile, "r")
        if file ~= nil then
            io.close()
            self.hasEntry = true
        else
            self.hasEntry = false
        end
    end
end

--- Create entry
function World:CreateEntry()
    jsonInterface.save("world/" .. self.worldFile, self.data)
    self.hasEntry = true
end

--- Save to drive
function World:SaveToDrive()
    if self.hasEntry then
        jsonInterface.save("world/" .. self.worldFile, self.data, config.worldKeyOrder)
    end
end

--- Quick save to drive
function World:QuicksaveToDrive()
    if self.hasEntry then
        jsonInterface.quicksave("world/" .. self.worldFile, self.data)
    end
end

--- Load from drive
function World:LoadFromDrive()
    self.data = jsonInterface.load("world/" .. self.worldFile)

    -- JSON doesn't allow numerical keys, but we use them, so convert
    -- all string number keys into numerical keys
    tableHelper.fixNumericalKeys(self.data)
end


--- Deprecated functions with confusing names, kept around for backwards compatibility
function World:Save()
    self:SaveToDrive()
end

--- Deprecated functions with confusing names, kept around for backwards compatibility
function World:Load()
    self:LoadFromDrive()
end

return World
