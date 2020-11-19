require("config")
tableHelper = require("tableHelper")
local BaseWorld = require("world.base")

local World = class("World", BaseWorld)

function World:__init()
    BaseWorld.__init(self)

    self.coreVariablesFile = "coreVariables.json"
    self.worldFile = "world.json"

    if self.hasEntry == nil then
        local home = config.dataPath .. "/world/"
        local file = io.open(home .. self.worldFile, "r")
        if file ~= nil then
            io.close()
            self.hasEntry = true
        else
            self.hasEntry = false
        end
    end
end

function World:CreateEntry()
    jsonInterface.save("world/" .. self.coreVariablesFile, self.coreVariables)
    jsonInterface.save("world/" .. self.worldFile, self.data)
    self.hasEntry = true
end

function World:SaveToDrive()
    if self.hasEntry then
        jsonInterface.save("world/" .. self.coreVariablesFile, self.coreVariables)
        jsonInterface.save("world/" .. self.worldFile, self.data, config.worldKeyOrder)
    end
end

function World:QuicksaveToDrive()
    if self.hasEntry then
        jsonInterface.quicksave("world/" .. self.coreVariablesFile, self.coreVariables)
        jsonInterface.quicksave("world/" .. self.worldFile, self.data)
    end
end

function World:QuicksaveCoreVariablesToDrive()
    if self.hasEntry then
        jsonInterface.quicksave("world/" .. self.coreVariablesFile, self.coreVariables)
    end
end

function World:LoadFromDrive()
    self.coreVariables = jsonInterface.load("world/" .. self.coreVariablesFile)
    self.data = jsonInterface.load("world/" .. self.worldFile)

    if self.data == nil then
        tes3mp.LogMessage(enumerations.log.ERROR, "world/" .. self.worldFile .. " cannot be read!")
        tes3mp.StopServer(2)
    else
        -- JSON doesn't allow numerical keys, but we use them, so convert
        -- all string number keys into numerical keys
        tableHelper.fixNumericalKeys(self.data)
    end
end


-- Deprecated functions with confusing names, kept around for backwards compatibility
function World:Save()
    self:SaveToDrive()
end

function World:Load()
    self:LoadFromDrive()
end

return World
