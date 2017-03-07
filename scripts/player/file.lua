local LIP = require 'LIP';
local BasePlayer = require "player.base"

local Player = class ("Player", BasePlayer)

function Player:__init(pid)
    BasePlayer.__init(self, pid)

    -- Replace characters not allowed in filenames
    self.accountFile = self.accountName
    self.accountFile = string.gsub(self.accountFile, '[<>:"/\\|*?]', "_")
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
end

return Player
