local request = require("drive.postgres.request")

local postgresDrive = {
    threads = {},
    currentJobs = {}
}

--
-- private
--

local function ThreadWork(input, output)
    local Run = require("drive.postgres.thread")
    Run(input, output)
end

local function Initiate()
    for _ = 1, config.postgres.threadCount do
        local threadId = threadHandler.CreateThread(ThreadWork)
        table.insert(postgresDrive.threads, threadId)
        postgresDrive.currentJobs[threadId] = 0
    end
    local fl = true
    local results = postgresDrive.Connect(config.postgres.connectionString)
    for _, res in pairs(results) do
        if not res then
            fl = false
        end
    end
    if fl then
        tes3mp.LogMessage(enumerations.log.INFO, "[Postgres] Successfully connected all threads!")
    end

    local function ProcessMigration(id, path)
        tes3mp.LogMessage(enumerations.log.INFO, "[Postgres] Applying migration " .. path)
        local status = require("drive.postgres.migrations." .. path)(postgresDrive)
        if status ~= 0 then
            error("[Postgres] Fatal migration error!")
        end
        postgresDrive.Query([[INSERT INTO migrations(id) VALUES(?)]], {id})
    end

    local migrations = require("drive.postgres.migrations")
    local doneMigrations = postgresDrive.QueryAsync([[SELECT * FROM migrations]])
    local doneTable = {}
    if doneMigrations.error then
        tes3mp.LogMessage(
            enumerations.log.INFO,
            "[Postgres] Seeding database for the first time, ignore the SQL error above!"
        )
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

local function ProcessResponse(res)
    if res.error then
        tes3mp.LogMessage(enumerations.log.ERROR, "[Postgres] [[" .. res.error .. "]]")
    elseif res.log then
        tes3mp.LogMessage(enumerations.log.VERBOSE, "[Postgres] [[" .. res.log .. "]]")
    end
end

local function ChooseThread()
    local minThread = postgresDrive.threads[1]
    local min = postgresDrive.currentJobs[minThread]
    for _, thread in pairs(postgresDrive.threads) do
        if min == 0 then
            break
        end
        if postgresDrive.currentJobs[thread] < min then
            min = postgresDrive.currentJobs[thread]
            minThread = thread
        end
    end
    return minThread
end

local function StartJob(thread)
    postgresDrive.currentJobs[thread] = postgresDrive.currentJobs[thread] + 1
end

local function FinishJob(thread)
    postgresDrive.currentJobs[thread] = postgresDrive.currentJobs[thread] - 1
    if postgresDrive.currentJobs[thread] < 0 then
        postgresDrive.currentJobs[thread] = 0
    end
end

local function Send(thread, req, callback)
    StartJob(thread)
    threadHandler.Send(
        thread,
        req,
        function(res)
            FinishJob(thread)
            ProcessResponse(res)
            if callback ~= nil then
                callback(res)
            end
        end
    )
end

local function SendAsync(thread, req)
    StartJob(thread)
    local res = threadHandler.SendAsync(
        thread,
        req
    )
    FinishJob(thread)
    ProcessResponse(res)
    return res
end

--
-- public
--

function postgresDrive.Connect(connectString)
    local results = {}
    for _, thread in pairs(postgresDrive.threads) do
        table.insert(
            results,
            SendAsync(thread, request.Connect(connectString))
        )
    end
    return results
end

function postgresDrive.ConnectAsync(connectString, timeout)
    local tasks = {}
    for _, thread in pairs(postgresDrive.threads) do
        table.insert(tasks, function()
            return SendAsync(thread, request.Connect(connectString))
        end)
    end
    return async.WaitAll(tasks, timeout)
end

function postgresDrive.Disconnect()
    local results = {}
    for _, thread in pairs(postgresDrive.threads) do
        table.insert(
            results,
            SendAsync(thread, request.Disconnect())
        )
    end
    return results
end

function postgresDrive.DisconnectAsync()
    local tasks = {}
    for _, thread in pairs(postgresDrive.threads) do
        table.insert(tasks, function()
            return SendAsync(thread, request.Disconnect())
        end)
    end
    return async.WaitAll(tasks)
end

function postgresDrive.Query(sql, parameters, callback, numericalIndices)
    local thread = ChooseThread()
    if numericalIndices then
        Send(thread, request.QueryNumerical(sql, parameters), callback)
    else
        Send(thread, request.Query(sql, parameters), callback)
    end
end

function postgresDrive.QueryAsync(sql, parameters, numericalIndices)
    local thread = ChooseThread()
    if numericalIndices then
        return SendAsync(thread, request.QueryNumerical(sql, parameters))
    else
        return SendAsync(thread, request.Query(sql, parameters))
    end
end

Initiate()

-- make sure the disconnect handler is the every last
customEventHooks.registerHandler("OnServerPostInit", function(eventStatus)
    if eventStatus.validDefaultHandler then
        customEventHooks.registerHandler("OnServerExit", function(eventStatus)
            if eventStatus.validDefaultHandler then
                async.Wrap(function() postgresDrive.DisconnectAsync() end)
            end
        end)
    end
end)

return postgresDrive
