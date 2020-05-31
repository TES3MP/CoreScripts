local BaseWorld = require("world.base")

local World = class("World", BaseWorld)

function World:__init()
  BaseWorld.__init(self)

  local result = postgresClient.QueryAwait(
    [[SELECT key FROM data_storage WHERE key = 'world']]
  )
  if result.error then
    error("Failed to check if world instance record exists")
  end
  if result.count > 1 then
    error("Duplicate records in the database for world instance")
  end

  self.hasEntry = result.count > 0
end

function World:Upsert(keyOrderArray)
  return postgresClient.QueryAwait(
    [[INSERT INTO data_storage (key, data) VALUES ('world', ?)
    ON CONFLICT (key) DO UPDATE SET data = EXCLUDED.data;]],
    { jsonInterface.encode(self.data, keyOrderArray) }
  )
end

function World:CreateEntry()
  self:Upsert()
  self.hasEntry = true
end

function World:SaveToDrive()
  if self.hasEntry then
    self:Upsert()
  end
end

function World:QuicksaveToDrive()
  self:SaveToDrive()
end

function World:LoadFromDrive()
  local result = postgresClient.QueryAwait(
    [[SELECT data FROM data_storage
    WHERE key = 'world';]]
  )
  if result.error then
    error("Failed to load the world instance")
  end

  if result.count > 1 then
    error("Duplicate records in the database for world instance")
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
function World:Save()
    self:SaveToDrive()
end

function World:Load()
    self:LoadFromDrive()
end

return World
