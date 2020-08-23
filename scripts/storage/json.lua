--
-- private
--

local function GetFileName(key)
    return 'custom/data__' .. key .. '.json'
end

local function Save(key)
    local result = fileDrive.SaveAsync(
        GetFileName(key),
        jsonInterface.encode(storage.data[key])
    )
    if not result.content then
        error("Failed to save storage " .. key)
    end
end

--
-- public
--

function storage.SaveAllAsync()
    local tasks = {}
    for key in pairs(storage.data) do
        table.insert(tasks, function() Save(key) end)
    end
    return async.WaitAllAsync(tasks) -- TODO: consider adding a timeout
end

function storage.SaveAll()
    for key in pairs(storage.data) do
        Save(key)
    end
end

function storage.Load(key, default)
    if not storage.data[key] then
        local eventStatus = customEventHooks.triggerValidators('OnStorageLoad', {key})
        if eventStatus.validDefaultHandler then
            local result = fileDrive.LoadAsync(GetFileName(key))
            if result.content then
                local data = jsonInterface.decode(result.content)
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

return storage
