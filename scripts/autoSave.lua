local autoSave = {}

local queue = {
    new = function()
        return {head = nil, tail = nil, size = 0}
    end,
    push = function(q, v)
        local el = {
            v = v
        }
        if q.size == 0 then
            el.next = nil
            q.head = el
            q.tail = el
        else
            el.next = nil
            q.tail.next = el
            q.tail = el
        end
        q.size = q.size + 1
        return q
    end,
    pop = function(q)
        if not q.head then
            return nil
        end
        local el = q.head
        q.head = el.next
        q.size = q.size - 1
        if q.size == 0 then
            q.tail = nil
        end
        return el.v
    end
}

local recordQueue = queue.new()

local types = {
    PLAYER = 1,
    CELL = 2,
    STORAGE = 3,
    RECORD_STORE = 4 -- currently unused
}

--
-- public functions
--
function autoSave.PushPlayer(pid)
    if not Players[pid] then
        return
    end
    queue.push(recordQueue, {
        type = types.PLAYER,
        id = pid,
        name = Players[pid].accountName
    })
end

function autoSave.PushCell(cellDescription)
    if not LoadedCells[cellDescription] then
        return
    end
    queue.push(recordQueue, {
        type = types.CELL,
        id = cellDescription
    })
end

function autoSave.PushStorage(key)
    queue.push(recordQueue, {
        type = types.STORAGE,
        id = key
    })
end

--
-- private functions
--
function autoSave.Pop(exit)
    local record = nil
    repeat
        record = queue.pop(recordQueue)
    until autoSave.IsValid(record) or recordQueue.size == 0
    if autoSave.IsValid(record) then
        if not exit then
            autoSave.QuicksaveToDrive(record)
            queue.push(recordQueue, record)
        else
            autoSave.SaveToDrive(record)
        end
        return true
    end
    return false
end

function autoSave.IsValid(record)
    if record == nil then
        return false
    end
    if record.type == types.PLAYER then
        return Players[record.id] ~= nil and Players[record.id].accountName == record.name
    elseif record.type == types.CELL then
        return LoadedCells[record.id] ~= nil
    elseif record.type == types.STORAGE then
        return true
    elseif record.type == types.RECORD_STORE then
        return RecordStores[record.id] ~= nil
    end
    return false
end

function autoSave.QuicksaveToDrive(record)
    if record.type == types.PLAYER then
        Players[record.id]:QuicksaveToDrive()
    elseif record.type == types.CELL then
        LoadedCells[record.id]:QuicksaveToDrive()
    elseif record.type == types.STORAGE then
        storage.Save(record.id)
    elseif record.type == types.RECORD_STORE then
        RecordStores[record.id]:QuicksaveToDrive()
    else
        return false
    end
    autoSave.Log(record)
    return true
end

function autoSave.SaveToDrive(record)
    if record.type == types.PLAYER then
        Players[record.id]:SaveToDrive()
    elseif record.type == types.CELL then
        LoadedCells[record.id]:SaveToDrive()
    elseif record.type == types.STORAGE then
        storage.Save(record.id)
    elseif record.type == types.RECORD_STORE then
        RecordStores[record.id]:SaveToDrive()
    else
        return false
    end
    autoSave.Log(record)
    return true
end

function autoSave.Log(record)
    if record.type == types.PLAYER then
        tes3mp.LogMessage(enumerations.log.INFO, "[AutoSave] Saved player with pid " .. record.id)
    elseif record.type == types.CELL then
        tes3mp.LogMessage(enumerations.log.INFO, "[AutoSave] Saved cell with description " .. record.id)
    elseif record.type == types.STORAGE then
        tes3mp.LogMessage(enumerations.log.INFO, "[AutoSave] Saved storage with key " .. record.id)
    elseif record.type == types.RECORD_STORE then
        tes3mp.LogMessage(enumerations.log.INFO, "[AutoSave] Saved record store with type " .. record.id)
    end
    return false
end

customEventHooks.registerHandler('OnServerPostInit', function(eventStatus)
    if eventStatus.validDefaultHandler then
        timers.Interval(function()
            async.Wrap(function()
                autoSave.Pop()
            end)
        end, time.seconds(config.autoSaveInterval))
    end
end)

customEventHooks.registerHandler('OnPlayerAuthentified', function(eventStatus, pid)
    if eventStatus.validDefaultHandler then
        autoSave.PushPlayer(pid)
    end
end)

customEventHooks.registerHandler('OnCellLoad', function(eventStatus, pid, cellDescription)
    if eventStatus.validDefaultHandler then
        autoSave.PushCell(cellDescription)
    end
end)

customEventHooks.registerHandler('OnStorageLoad', function(eventStatus, key)
    if eventStatus.validDefaultHandler then
        autoSave.PushStorage(key)
    end
end)

customEventHooks.registerHandler('OnServerExit', function(eventStatus)
    if eventStatus.validDefaultHandler then
        tes3mp.LogMessage(enumerations.log.INFO, "[AutoSave] Saving everything before exiting")
        local res = true
        repeat
            autoSave.Pop(true)
        until not res
        
        for storeType, recordStore in pairs(RecordStores) do
            recordStore:SaveToDrive()
        end
    end
end)

return autoSave