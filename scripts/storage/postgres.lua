--
-- public functions
--

function storage.Load(key, default)
    if not storage.data[key] then
        local eventStatus = customEventHooks.triggerValidators('OnStorageLoad', {key})
        if eventStatus.validDefaultHandler then
            local result =  postgresClient.QueryAsync([[SELECT data FROM data_storage WHERE key = ?;]], {key})
            if result.error then
                error("Failed to load storage " .. key)
            end
            if result.count > 1 then
                error("Duplicate records in the database for storage " .. key)
            end
            if result.count == 1 then
                local data = jsonInterface.decode(result.rows[1].data)
                tableHelper.fixNumericalKeys(data)
                storage.data[key] = data
            else
                storage.data[key] = default
            end
        end
        customEventHooks.triggerHandlers('OnStorageLoad', eventStatus, {key})
    end
    return storage.data[key]
end

--
-- private functions
--

function storage.Save(key)
    local result = postgresClient.QueryAsync(
        [[INSERT INTO data_storage (key, data) VALUES (?, ?)
        ON CONFLICT (key) DO UPDATE SET data = EXCLUDED.data;]],
        {key, jsonInterface.encode(storage.data[key])}
    )
    if result.error then
        error("Failed to save storage " .. key)
    end
end

function storage.SaveAllAsync()
    local tasks = {}
    for key in pairs(storage.data) do
        table.insert(tasks, function() storage.Save(key) end)
    end
    return async.WaitAllAsync(tasks) -- TODO: consider adding a timeout
end

function storage.SaveAll()
    for key in pairs(storage.data) do
        storage.Save(key)
    end
end

return storage
