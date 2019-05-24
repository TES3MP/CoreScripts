--- player-json
-- @classmod player-json
require("config")
fileHelper = require("fileHelper")
tableHelper = require("tableHelper")
local BasePlayer = require("player.base")

local Player = class("Player", BasePlayer)

--- Init function
-- @int pid
-- @string playerName
function Player:__init(pid, playerName)
    BasePlayer.__init(self, pid, playerName)

    -- Ensure filename is valid
    self.accountName = fileHelper.fixFilename(playerName)

    self.accountFile = tes3mp.GetCaseInsensitiveFilename(tes3mp.GetDataPath() .. "/player/", self.accountName .. ".json")

    if self.accountFile == "invalid" then
        self.hasAccount = false
        self.accountFile = self.accountName .. ".json"
    else
        self.hasAccount = true
    end
end

--- Create acount
function Player:CreateAccount()
    self.hasAccount = jsonInterface.save("player/" .. self.accountFile, self.data)

    if self.hasAccount then
        tes3mp.LogMessage(enumerations.log.INFO, "Successfully created JSON file for player " .. self.accountName)
    else
        local message = "Failed to create JSON file for " .. self.accountName
        tes3mp.SendMessage(self.pid, message, true)
        tes3mp.Kick(self.pid)
    end
end

--- Save to drive
function Player:SaveToDrive()
    if self.hasAccount then
        tes3mp.LogMessage(enumerations.log.INFO, "Saving player " .. logicHandler.GetChatName(self.pid))
        jsonInterface.save("player/" .. self.accountFile, self.data, config.playerKeyOrder)
    end
end

--- Quick save to drive
function Player:QuicksaveToDrive()
    if self.hasAccount then
        jsonInterface.quicksave("player/" .. self.accountFile, self.data)
    end
end

--- Load from drive
function Player:LoadFromDrive()
    self.data = jsonInterface.load("player/" .. self.accountFile)

    -- JSON doesn't allow numerical keys, but we use them, so convert
    -- all string number keys into numerical keys
    tableHelper.fixNumericalKeys(self.data)
end

--- Deprecated functions with confusing names, kept around for backwards compatibility
function Player:Save()
    self:SaveToDrive()
end

--- Deprecated functions with confusing names, kept around for backwards compatibility
function Player:Load()
    self:LoadFromDrive()
end

return Player
