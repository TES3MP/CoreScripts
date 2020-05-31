local BasePlayer = require("player.base")

local Player = class("Player", BasePlayer)

function Player:__init(pid, playerName)
  BasePlayer.__init(self, pid, playerName)

  -- Ensure filename is valid
  self.accountName = playerName:trim()

  local result = postgresClient.QueryAwait([[SELECT id FROM players WHERE name = ?]], { self.accountName })
  if result.error then
    error("Failed to check if account " .. self.accountName .. " exists")
  end
  if result.count > 1 then
    error("Duplicate records in the database for player " .. self.accountName)
  end

  self.hasAccount = result.count > 0
end

function Player:Upsert(keyOrderArray)
  return postgresClient.QueryAwait(
    [[INSERT INTO players (name, data) VALUES (?, ?)
    ON CONFLICT (name) DO
    UPDATE SET data = EXCLUDED.data;]],
    { self.accountName, jsonInterface.encode(self.data, keyOrderArray) }
  )
end

function Player:CreateAccount()
  local result = self:Upsert()
  self.hasAccount = result.error == nil

  if self.hasAccount then
    tes3mp.LogMessage(enumerations.log.INFO, "Successfully created database record for player " .. self.accountName)
  else
    local message = "Failed to create database record for " .. self.accountName
    tes3mp.SendMessage(self.pid, message, true)
    tes3mp.Kick(self.pid)
  end
end

function Player:SaveToDrive()
  if self.hasAccount then
    tes3mp.LogMessage(enumerations.log.INFO, "Saving player " .. logicHandler.GetChatName(self.pid))
    local result = self:Upsert()
    if result.error then
      error("Failed to save the player " .. self.accountName)
    end
  end
end

function Player:QuicksaveToDrive()
  if self.hasAccount then
    local result = self:Upsert()
    if result.error then
      error("Failed to save the player " .. self.accountName)
    end
  end
end

function Player:LoadFromDrive()
  local result = postgresClient.QueryAwait(
    [[SELECT data FROM players
    WHERE name = ?;]],
    { self.accountName }
  )
  if result.error then
    error("Failed to load the player " .. self.accountName)
  end

  if result.count > 1 then
    error("Duplicate records in the database for player " .. self.accountName)
  end

  -- if no data is present, just keep the default
  if result.count == 1 then
    self.data = jsonInterface.decode(result.rows[1].data)

    -- JSON doesn't allow numerical keys, but we use them, so convert
    -- all string number keys into numerical keys
    tableHelper.fixNumericalKeys(self.data)
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
