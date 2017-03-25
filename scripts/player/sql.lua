require('patterns')
local LIP = require('LIP')
local Database = require('database')
local BasePlayer = require('player.base')

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
    Database:InsertRow("player_general", self.data.general)
    self.dbPid = self:GetDatabaseId()
    Database:SavePlayer(self.dbPid, self.data)
    self.hasAccount = true

    print(self.data.general.name .. " has dbPid of " .. self.dbPid)
end

function Player:Save()
    if self.hasAccount and self.loggedIn then
        LIP.save("player/" .. self.accountFile, self.data)
        Database:SavePlayer(self.dbPid, self.data)
    end
end

function Player:Load()
    self.data = LIP.load("player/" .. self.accountFile)
    self.dbPid = self:GetDatabaseId()
end

function Player:GetDatabaseId()
    return Database:GetSingleValue("player_general", "dbPid", string.format("WHERE name = '%s'", self.data.general.name))
end

return Player
