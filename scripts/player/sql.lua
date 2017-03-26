require('patterns')
local LIP = require('LIP')
local Database = require('database')
local BasePlayer = require('player.base')

local Player = class ("Player", BasePlayer)

function Player:__init(pid)
    BasePlayer.__init(self, pid)

    if self.hasAccount == nil then
        
        self.dbPid = self:GetDatabaseId()

        if self.dbPid ~= nil then
            self.hasAccount = true
        else
            self.hasAccount = false
        end
    end
end

function Player:CreateAccount()
    LIP.save("player/" .. self.accountFile, self.data)
    Database:InsertRow("player_login", self.data.login)
    self.dbPid = self:GetDatabaseId()
    Database:SavePlayer(self.dbPid, self.data)
    self.hasAccount = true

    print(self.data.login.name .. " has dbPid of " .. self.dbPid)
end

function Player:Save()
    if self.hasAccount and self.loggedIn then
        LIP.save("player/" .. self.accountFile, self.data)
        Database:SavePlayer(self.dbPid, self.data)
    end
end

function Player:Load()
    self.data = LIP.load("player/" .. self.accountFile)
end

function Player:GetDatabaseId()
    local escapedName = Database:Escape(self.data.login.name)
    return Database:GetSingleValue("player_login", "dbPid", string.format("WHERE name = '%s'", escapedName))
end

return Player
