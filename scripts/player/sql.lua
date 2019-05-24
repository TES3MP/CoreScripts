--- player-sql
-- @classmod player-sql
Database = require("database")
local BasePlayer = require("player.base")

local Player = class("Player", BasePlayer)

--- Init function
-- @int pid
-- @string playerName
function Player:__init(pid, playerName)
    BasePlayer.__init(self, pid, playerName)

    if self.hasAccount == nil then

        self.dbPid = self:GetDatabaseId()

        if self.dbPid ~= nil then
            self.hasAccount = true
        else
            self.hasAccount = false
        end
    end
end

--- Create account
function Player:CreateAccount()
    Database:InsertRow("player_login", self.data.login)
    self.dbPid = self:GetDatabaseId()
    Database:SavePlayer(self.dbPid, self.data)
    self.hasAccount = true
end

--- Save to drive
function Player:SaveToDrive()
    if self.hasAccount and self.loggedIn then
        Database:SavePlayer(self.dbPid, self.data)
    end
end

--- Load from drive
function Player:LoadFromDrive()
    self.data = Database:LoadPlayer(self.dbPid, self.data)
end

--- Get database Id
-- @return int database player ID
function Player:GetDatabaseId()
    local escapedName = Database:Escape(self.accountName)
    return Database:GetSingleValue("player_login", "dbPid", string.format("WHERE name = '%s'", escapedName))
end

return Player
