require("config")
fileHelper = require("fileHelper")
tableHelper = require("tableHelper")
local BasePlayer = require("player.base")

local Player = class("Player", BasePlayer)

function Player:__init(pid, playerName)
    BasePlayer.__init(self, pid, playerName)

    -- Ensure filename is valid
    self.accountName = fileHelper.fixFilename(playerName)

    self.accountFile = tes3mp.GetCaseInsensitiveFilename(config.dataPath .. "/player/", self.accountName .. ".json")

    if self.accountFile == "invalid" then
        self.hasAccount = false
        self.accountFile = self.accountName .. ".json"
    else
        self.hasAccount = true
    end
end

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

function Player:SaveToDrive()
    if self.hasAccount then
        tes3mp.LogMessage(enumerations.log.INFO, "Saving player " .. logicHandler.GetChatName(self.pid))
        jsonInterface.save("player/" .. self.accountFile, self.data, config.playerKeyOrder)
    end
end

function Player:QuicksaveToDrive()
    if self.hasAccount then
        jsonInterface.quicksave("player/" .. self.accountFile, self.data)
    end
end

function Player:LoadFromDrive()
    self.data = jsonInterface.load("player/" .. self.accountFile)

    if self.data == nil then
        tes3mp.LogMessage(enumerations.log.ERROR, "player/" .. self.accountFile .. " cannot be read!")
        tes3mp.StopServer(2)
    else
        -- JSON doesn't allow numerical keys, but we use them, so convert
        -- all string number keys into numerical keys
        tableHelper.fixNumericalKeys(self.data)

        if self.data.login.password ~= nil and self.data.login.passwordHash == nil then
            self:ConvertPlaintextPassword()
        end
    end
end

-- Deprecated functions with confusing names, kept around for backwards compatibility
function Player:Save()
    self:SaveToDrive()
end

function Player:Load()
    self:LoadFromDrive()
end

return Player
