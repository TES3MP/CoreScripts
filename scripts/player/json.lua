require("config")
jsonInterface = require("jsonInterface")
fileHelper = require("fileHelper")
tableHelper = require("tableHelper")
local BasePlayer = require("player.base")

local Player = class("Player", BasePlayer)

function Player:__init(pid, playerName)
    BasePlayer.__init(self, pid, playerName)

    -- Ensure filename is valid
    self.accountName = fileHelper.fixFilename(playerName)

    self.accountFile = tes3mp.GetCaseInsensitiveFilename(os.getenv("MOD_DIR") .. "/player/", self.accountName .. ".json")

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
        tes3mp.LogMessage(2, "Successfully created account for " .. self.accountName)
    else
        local message = "Failed to create account for " .. self.accountName
        tes3mp.SendMessage(self.pid, message, true)
        tes3mp.Kick(self.pid)
    end
end

function Player:Save()
    if self.hasAccount and self.loggedIn then
        jsonInterface.save("player/" .. self.accountFile, self.data, config.playerKeyOrder)
    end
end

function Player:Load()
    self.data = jsonInterface.load("player/" .. self.accountFile)

    -- JSON doesn't allow numerical keys, but we use them, so convert
    -- all string number keys into numerical keys
    tableHelper.fixNumericalKeys(self.data)
end

return Player
