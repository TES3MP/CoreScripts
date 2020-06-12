-- TODO: split record stores into tables records, cell_links, player_links
local BaseRecordStore = require("recordstore.base")

local RecordStore = class("RecordStore", BaseRecordStore)

function RecordStoreSaveTimer(storeType)
    coroutine.resume(RecordStores[storeType].saveCoroutine)
end

function RecordStore:__init(storeType)
    BaseRecordStore.__init(self, storeType)
    
    local result = postgresDrive.QueryAsync(
        [[SELECT type FROM record_stores WHERE type = ?]],
        {self.storeType}
    )
    if result.error then
        error("Failed to check if record store " .. self.storeType .. " exists")
    end
    if result.count > 1 then
        error("Duplicate records in the database for record store " .. self.storeType)
    end
    
    self.hasEntry = result.count > 0
    self.saveCoroutine = coroutine.create(function()
        while true do
            tes3mp.LogMessage(enumerations.log.INFO, "Saving recordstore " .. self.storeType)
            self:SaveToDrive()
            coroutine.yield()
        end
    end)
    self.quickSaveTimer = tes3mp.CreateTimerEx("RecordStoreSaveTimer", time.seconds(config.recordStoreSaveDelay), "s", self.storeType)
end

function RecordStore:CreateEntry()
    self:Upsert()
end

function RecordStore:Upsert(keyOrderArray)
    return postgresDrive.QueryAsync(
        [[INSERT INTO record_stores (type, data) VALUES (?, ?)
        ON CONFLICT (type) DO UPDATE SET data = EXCLUDED.data;]],
        {self.storeType, jsonInterface.encode(self.data, keyOrderArray)}
    )
end

function RecordStore:SaveToDrive()
    if self.hasEntry then
        self:Upsert()
    end
end

function RecordStore:QuicksaveToDrive()
    tes3mp.StartTimer(self.quickSaveTimer)
end

function RecordStore:LoadFromDrive()
    local result = postgresDrive.QueryAsync([[SELECT data FROM record_stores WHERE type = ?;]], {self.storeType})
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
    self:QuicksaveToDrive()
end

function RecordStore:Load()
    self:LoadFromDrive()
end

return RecordStore
