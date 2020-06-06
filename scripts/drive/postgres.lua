local Request = require("drive.postgres.request")

local postgresClient = {}

postgresClient.threads = {}

postgresClient.currentJobs = {}

function postgresClient.ThreadWork(input, output)
    local Run = require("drive.postgres.thread")
    Run(input, output)
end

function postgresClient.Initiate()
    for i = 1, config.postgresThreadCount do
        local threadId = threadHandler.CreateThread(postgresClient.ThreadWork)
        table.insert(postgresClient.threads, threadId)
        postgresClient.currentJobs[threadId] = 0
    end

    postgresClient.ConnectAsync(config.postgresConnectionString)

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
        tes3mp.LogMessage(enumerations.log.INFO, "[Postgres] [[" .. res.log .. "]]")
    end
    if res.id == -1 and res.error then
        tes3mp.StopServer(1)
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

function postgresClient.Send(thread, action, sql, parameters, callback)
    postgresClient.StartJob(thread)
    threadHandler.Send(
        thread,
        Request.form(
            action,
            sql or "",
            parameters or {}
        ),
        function(res)
            postgresClient.FinishJob(thread)
            postgresClient.ProcessResponse(res)
            if callback ~= nil then
                callback(res)
            end
        end
    )
end

function postgresClient.SendAsync(thread, action, sql, parameters)
    postgresClient.StartJob(thread)
    local res = threadHandler.SendAsync(
        thread,
        Request.form(
            action,
            sql or "",
            parameters or {}
        )
    )
    postgresClient.FinishJob(thread)
    postgresClient.ProcessResponse(res)
    return res
end

function postgresClient.Connect(connectString, callback)
    local tasks = {}
    for _, thread in pairs(postgresClient.threads) do
        table.insert(tasks, function()
            return postgresClient.SendAsync(thread, Request.CONNECT, connectString)
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
            return postgresClient.SendAsync(thread, Request.DISCONNECT)
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
        postgresClient.Send(thread, Request.QUERY_NUMERICAL_INDICES, sql, parameters, callback)
    else
        postgresClient.Send(thread, Request.QUERY, sql, parameters, callback)
    end
end

function postgresClient.QueryAsync(sql, parameters, numericalIndices)
    local thread = postgresClient.ChooseThread()
    if numericalIndices then
        return postgresClient.SendAsync(thread, Request.QUERY_NUMERICAL_INDICES, sql, parameters)
    else
        return postgresClient.SendAsync(thread, Request.QUERY, sql, parameters)
    end
end

async.Wrap(function()
    postgresClient.Initiate()
end)

customEventHooks.registerHandler("OnServerExit", function()
    async.Wrap(function() postgresClient.DisconnectAsync() end)
end)

return postgresClient
