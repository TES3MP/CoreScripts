local request = require("drive.postgres.request")

local postgresClient = {}

postgresClient.threads = {}

postgresClient.currentJobs = {}

function postgresClient.ThreadWork(input, output)
    local Run = require("drive.postgres.thread")
    Run(input, output)
end

function postgresClient.Initiate()
    for i = 1, config.postgres.threadCount do
        local threadId = threadHandler.CreateThread(postgresClient.ThreadWork)
        table.insert(postgresClient.threads, threadId)
        postgresClient.currentJobs[threadId] = 0
    end

    local fl = true
    local results = postgresClient.ConnectAsync(config.postgres.connectionString)
    for thread, result in pairs(results) do
        if not result then
            error('[Postgres] Failed to connect in thread ' .. thread)
        end
        if result.error then
            fl = false
        end
    end
    if fl then
        tes3mp.LogMessage(enumerations.log.INFO, "[Postgres] Successfully connected all threads!")
    end

    local function ProcessMigration(id, path)
        tes3mp.LogMessage(enumerations.log.INFO, "[Postgres] Applying migration " .. path)
        local status = require("postgres.migrations." .. path)
        if status ~= 0 then
            error("[Postgres] Fatal migration error!")
        end
        postgresClient.Query([[INSERT INTO migrations(id, processed_at) VALUES(?, TO_TIMESTAMP(?))]], {id, os.time()})
    end

    local migrations = require("postgres.migrations")
    local doneMigrations = postgresClient.QueryAsync([[SELECT * FROM migrations]])
    local doneTable = {}
    if doneMigrations.error then
        tes3mp.LogMessage(enumerations.log.INFO, "[Postgres] Seeding database for the first time, ignore the SQL error above!")
        ProcessMigration(0, "0000_migrations")
    else
        for i = 1, doneMigrations.count do
            local row = doneMigrations.rows[i]
            doneTable[tonumber(row.id)] = true
        end
    end

    for i, path in ipairs(migrations) do
        if not doneTable[i] then
            ProcessMigration(i, path)
        end
    end
end

function postgresClient.ProcessResponse(res)
    if res.error then
        tes3mp.LogMessage(enumerations.log.ERROR, "[Postgres] [[" .. res.error .. "]]")
    elseif res.log then
        tes3mp.LogMessage(enumerations.log.VERBOSE, "[Postgres] [[" .. res.log .. "]]")
    end
end

function postgresClient.ChooseThread()
    local minThread = postgresClient.threads[1]
    local min = postgresClient.currentJobs[minThread]
    for _, thread in pairs(postgresClient.threads) do
        if min == 0 then
            break
        end
        if postgresClient.currentJobs[thread] < min then
            min = postgresClient.currentJobs[thread]
            minThread = thread
        end
    end
    return minThread
end

function postgresClient.StartJob(thread)
    postgresClient.currentJobs[thread] = postgresClient.currentJobs[thread] + 1
end

function postgresClient.FinishJob(thread)
    postgresClient.currentJobs[thread] = postgresClient.currentJobs[thread] - 1
    if postgresClient.currentJobs[thread] < 0 then
        postgresClient.currentJobs[thread] = 0
    end
end

function postgresClient.Send(thread, req, callback)
    postgresClient.StartJob(thread)
    threadHandler.Send(
        thread,
        req,
        function(res)
            postgresClient.FinishJob(thread)
            postgresClient.ProcessResponse(res)
            if callback ~= nil then
                callback(res)
            end
        end
    )
end

function postgresClient.SendAsync(thread, req)
    postgresClient.StartJob(thread)
    local res = threadHandler.SendAsync(
        thread,
        req
    )
    postgresClient.FinishJob(thread)
    postgresClient.ProcessResponse(res)
    return res
end

function postgresClient.Connect(connectString, callback)
    local tasks = {}
    for _, thread in pairs(postgresClient.threads) do
        table.insert(tasks, function()
            return postgresClient.SendAsync(thread, request.Connect(connectString))
        end)
    end
    async.WaitAll(tasks, nil, callback)
end

function postgresClient.ConnectAsync(connectString)
    local currentCoroutine = async.CurrentCoroutine()
    postgresClient.Connect(connectString, function(results)
        coroutine.resume(currentCoroutine, results)
    end)
    return coroutine.yield()
end

function postgresClient.Disconnect(callback)
    local tasks = {}
    for _, thread in pairs(postgresClient.threads) do
        table.insert(tasks, function()
            return postgresClient.SendAsync(thread, request.Disconnect())
        end)
    end
    async.WaitAll(tasks, nil, callback)
end

function postgresClient.DisconnectAsync()
    local currentCoroutine = async.CurrentCoroutine()
    postgresClient.Disconnect(function(results)
        coroutine.resume(currentCoroutine, results)
    end)
    return coroutine.yield()
end

function postgresClient.Query(sql, parameters, callback, numericalIndices)
    local thread = postgresClient.ChooseThread()
    if numericalIndices then
        postgresClient.Send(thread, request.QueryNumerical(sql, parameters), callback)
    else
        postgresClient.Send(thread, request.Query(sql, parameters), callback)
    end
end

function postgresClient.QueryAsync(sql, parameters, numericalIndices)
    local thread = postgresClient.ChooseThread()
    if numericalIndices then
        return postgresClient.SendAsync(thread, request.QueryNumerical(sql, parameters))
    else
        return postgresClient.SendAsync(thread, request.Query(sql, parameters))
    end
end

async.Wrap(function() postgresClient.Initiate() end)

customEventHooks.registerHandler("OnServerInit", function(eventStatus)
    if eventStatus.validDefaultHandler then
        customEventHooks.registerHandler("OnServerExit", function(eventStatus)
            if eventStatus.validDefaultHandler then
                async.Wrap(function() postgresClient.DisconnectAsync() end)
            end
        end)
    end
end)

return postgresClient
