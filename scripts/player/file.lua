require('patterns')
local LIP = require 'LIP'
local BasePlayer = require "player.base"

local Player = class ("Player", BasePlayer)

function Player:__init(pid)
    BasePlayer.__init(self, pid)

    -- Replace characters not allowed in filenames
    self.accountFile = self.accountName
    self.accountFile = string.gsub(self.accountFile, patterns.invalidFileCharacters, "_")
    self.accountFile = self.accountFile .. ".txt"


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
    LIP.save("player/" .. self.accountFile, self.data)
    self.hasAccount = true
end

function Player:Save()
    if self.hasAccount and self.loggedIn then
        LIP.save("player/" .. self.accountFile, self.data)
    end
end

function Player:Load()
    self.data = LIP.load("player/" .. self.accountFile)

    -- Temporary: data.general has been split off into data.login and data.settings,
    -- but maintain backwards compatibility for a while
    if self.data.login == nil then
        self.data.login = {}
        self.data.login.password = self.data.general.password
        self.data.login.name = self.data.general.name
        self.data.settings = {}
        self.data.settings.admin = self.data.general.admin
        self.data.settings.consoleAllowed = self.data.general.consoleAllowed
        self.data.general = nil
    end
end

return Player
