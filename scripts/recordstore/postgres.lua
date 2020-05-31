-- TODO: split record stores into tables records, cell_links, player_links
local BaseRecordStore = require("recordstore.base")

local RecordStore = class("RecordStore", BaseRecordStore)

function RecordStore:__init(storeType)
  BaseRecordStore.__init(self, storeType)

  local result = postgresClient.QueryAwait(
    [[SELECT type FROM record_stores WHERE type = ?]],
    { self.storeType }
  )
  if result.error then
    error("Failed to check if record store " .. self.storeType .. " exists")
  end
  if result.count > 1 then
    error("Duplicate records in the database for record store " .. self.storeType)
  end

  self.hasEntry = result.count > 0
end

function RecordStore:CreateEntry()
  self:Upsert()
end

function RecordStore:Upsert(keyOrderArray)
  return postgresClient.QueryAwait(
    [[INSERT INTO record_stores (type, data) VALUES (?, ?)
    ON CONFLICT (type) DO UPDATE SET data = EXCLUDED.data;]],
    { self.storeType, jsonInterface.encode(self.data, keyOrderArray) }
  )
end

function RecordStore:SaveToDrive()
  if self.hasEntry then
    self:Upsert()
  end
end

function RecordStore:QuicksaveToDrive()
  self:SaveToDrive()
end

function RecordStore:LoadFromDrive()
  local result = postgresClient.QueryAwait(
    [[SELECT data FROM record_stores
    WHERE type = ?;]],
    { self.storeType }
  )
  if result.error then
    error("Failed to load the record store " .. self.storeType)
  end

  if result.count > 1 then
    error("Duplicate records in the database for record store " .. self.storeType)
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
function RecordStore:Save()
  self:SaveToDrive()
end

function RecordStore:Load()
  self:LoadFromDrive()
end

return RecordStore
