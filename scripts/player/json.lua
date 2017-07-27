require("config")
require("patterns")
local jsonInterface = require("jsonInterface")
tableHelper = require("tableHelper")
local BasePlayer = require("player.base")

local Player = class("Player", BasePlayer)

function Player:__init(pid, playerName)
    BasePlayer.__init(self, pid, playerName)

    -- Replace characters not allowed in filenames
    self.accountFile = self.accountName
    self.accountFile = string.gsub(self.accountFile, patterns.invalidFileCharacters, "_")
    self.accountFile = self.accountFile .. ".json"

    if self.hasAccount == nil then
        local home = os.getenv("MOD_DIR").."/player/"
        local file = io.open(home .. self.accountFile, "r")
        if file ~= nil then
            io.close()
            self.hasAccount = true
        else
            self.hasAccount = false
        end
    end
end

function Player:CreateAccount()
    jsonInterface.save("player/" .. self.accountFile, self.data)
    self.hasAccount = true
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
