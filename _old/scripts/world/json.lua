require("config")
jsonInterface = require("jsonInterface")
tableHelper = require("tableHelper")
local BaseWorld = require("world.base")

local World = class("World", BaseWorld)

function World:__init()
    BaseWorld.__init(self)

    self.worldFile = "world.json"

    if self.hasEntry == nil then
        local home = os.getenv("MOD_DIR").."/world/"
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
    jsonInterface.save("world/" .. self.worldFile, self.data)
    self.hasEntry = true
end

function World:Save()
    if self.hasEntry then
        jsonInterface.save("world/" .. self.worldFile, self.data, config.worldKeyOrder)
    end
end

function World:Load()
    self.data = jsonInterface.load("world/" .. self.worldFile)

    -- JSON doesn't allow numerical keys, but we use them, so convert
    -- all string number keys into numerical keys
    tableHelper.fixNumericalKeys(self.data)
end

return World
