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

local savingQueue = queue.new()

local types = {
    PLAYER = 1,
    CELL = 2,
    STORAGE = 3,
    WORLD = 4,
    RECORD_STORE = 5 -- currently unused
}

function autoSave.PushPlayer(pid)
    if not Players[pid] then
        return
    end
    queue.push(savingQueue, {
        type = types.PLAYER,
        id = pid,
        accountName = Players[pid].accountName
    })
end

function autoSave.PushCell(cellDescription)
    if not LoadedCells[cellDescription] then
        return
    end
    queue.push(savingQueue, {
        type = types.CELL,
        id = cellDescription
    })
end

function autoSave.PushStorage(key)
    queue.push(savingQueue, {
        type = types.STORAGE,
        id = key
    })
end

function autoSave.PushWorld(instance)
    queue.push(savingQueue, {
        type = types.WORLD,
        id = instance
    })
end

function autoSave.Pop(exit)
    local record = nil
    repeat
        record = queue.pop(savingQueue)
    until record == nil or autoSave.IsValid(record)
    if record ~= nil then
        if not exit then
            autoSave.QuicksaveToDrive(record)
            queue.push(savingQueue, record)
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
        return Players[record.id] ~= nil and Players[record.id].accountName == record.accountName
    elseif record.type == types.CELL then
        return LoadedCells[record.id] ~= nil
    elseif record.type == types.STORAGE then
        return true
    elseif record.type == types.WORLD then
        return true
    elseif record.type == types.RECORD_STORE then
        return RecordStores[record.id] ~= nil
    else
        return false
    end
end

function autoSave.QuicksaveToDrive(record)
    if record.type == types.PLAYER then
        Players[record.id]:SaveStatsDynamic()
        Players[record.id]:SaveCell()
        Players[record.id]:QuicksaveToDrive()
    elseif record.type == types.CELL then
        LoadedCells[record.id]:SaveActorPositions()
        LoadedCells[record.id]:SaveActorStatsDynamic()
        LoadedCells[record.id]:QuicksaveToDrive()
    elseif record.type == types.STORAGE then
        storage.Save(record.id)
    elseif record.type == types.WORLD then
        record.id:QuicksaveToDrive()
    elseif record.type == types.RECORD_STORE then
        RecordStores[record.id]:QuicksaveToDrive()
    else
        return false
    end
    autoSave.Log(record)
    return true
end

function autoSave.SaveToDrive(record)
    autoSave.Log(record)
    if record.type == types.PLAYER then
        Players[record.id]:SaveStatsDynamic()
        Players[record.id]:SaveCell()
        Players[record.id]:SaveToDrive()
    elseif record.type == types.CELL then
        LoadedCells[record.id]:SaveActorPositions()
        LoadedCells[record.id]:SaveActorStatsDynamic()
        LoadedCells[record.id]:SaveToDrive()
    elseif record.type == types.STORAGE then
        storage.Save(record.id)
    elseif record.type == types.WORLD then
        record.id:SaveToDrive()
    elseif record.type == types.RECORD_STORE then
        RecordStores[record.id]:SaveToDrive()
    else
        return false
    end
    return true
end

function autoSave.SaveAll(exit)
    local res = true
    local i = 0
    repeat
        res = autoSave.Pop(exit)
        i = i + 1
    until not res or savingQueue.size == 0 or i > savingQueue.size

    local tasks = {}
    for _, recordStore in pairs(RecordStores) do
        table.insert(tasks, function()
            recordStore:DeleteUnlinkedRecords()
            recordStore:SaveToDrive()
        end)
    end
    async.WaitAllAsync(tasks)
end

function autoSave.Log(record)
    local log = nil
    if record.type == types.PLAYER then
       log = "Saving player with pid " .. record.id .. " and name " .. record.accountName
    elseif record.type == types.CELL then
        log = "Saving cell with description " .. record.id
    elseif record.type == types.STORAGE then
        log = "Saving storage with key " .. record.id
    elseif record.type == types.WORLD then
        log = "Saving the world instance"
    elseif record.type == types.RECORD_STORE then
        log = "Saving record store with type " .. record.id
    end
    if log then
        tes3mp.LogMessage(enumerations.log.VERBOSE, "[AutoSave] " .. log)
    end
    return log
end

local exiting = false
local intervalAverage = time.seconds(config.autoSaveCompleteInterval)
local intervalWeight = 0.1 -- exponential moving average coefficient

function autoSave.Interval()
    async.Wrap(function()
        while not exiting do
            local timestamp = tes3mp.GetMillisecondsSinceServerStart()
            if not tableHelper.isEmpty(Players) then
                autoSave.Pop()
            end
            local delta = tes3mp.GetMillisecondsSinceServerStart() - timestamp
            intervalAverage = intervalWeight * delta + (1 - intervalWeight) * intervalAverage
            local delay = math.ceil(math.max(
                time.seconds(config.autoSaveCompleteInterval) / math.max(savingQueue.size, 1) - intervalAverage,
                time.seconds(config.autoSaveMinimalInterval)
            ))
            tes3mp.LogMessage(
                enumerations.log.VERBOSE,
                string.format("[AutoSave] Save interval of %ss",time.toSeconds(delay))
            )
            timers.WaitAsync(delay)
        end
    end)
end

customEventHooks.registerHandler('OnServerPostInit', function(eventStatus)
    if eventStatus.validDefaultHandler then
        autoSave.PushWorld(WorldInstance)
        autoSave.Interval()
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

-- force the OnServerExit handler to be the last
customEventHooks.registerHandler('OnServerInit', function(eventStatus)
    customEventHooks.registerHandler('OnServerExit', function(eventStatus)
        if eventStatus.validDefaultHandler then
            exiting = true

            tes3mp.LogMessage(enumerations.log.INFO, "[AutoSave] Kicking all players")
            for pid in pairs(Players) do
                tes3mp.Kick(pid)
            end

            tes3mp.LogMessage(enumerations.log.INFO, "[AutoSave] Saving everything before exiting")
            async.RunBlocking(function()
                autoSave.SaveAll(true)
            end)
        end
    end)
end)


customEventHooks.registerHandler('OnPlayerDisconnect', function(eventStatus)
    if eventStatus.validDefaultHandler and not exiting then
        if tableHelper.isEmpty(Players) then
            tes3mp.LogMessage(enumerations.log.INFO, "[AutoSave] Saving everything because the server is empty")
            autoSave.SaveAll(false)
        end
    end
end)

return autoSave