--- World SQL
-- @classmod world-sql
Database = require("database")
local BaseWorld = require("world.base")

local World = class("World", BaseWorld)

--- Init funtion
function World:__init()
    BaseWorld.__init(self)

    if self.hasEntry == nil then

        local test = Database:GetSingleValue("world_general", "currentMpNum", "")

        if test ~= nil then
            self.hasEntry = true
        else
            self.hasEntry = false
        end
    end
end

--- Create entry
function World:CreateEntry()
    self:SaveToDrive()
    self.hasEntry = true
end

--- Save to drive
function World:SaveToDrive()
    Database:SaveWorld(self.data)
end

--- Load from drive
function World:LoadFromDrive()
    self.data = Database:LoadWorld(self.data)
end

return World
