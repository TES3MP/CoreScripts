local effil = require("effil")
local Request = require("postgres.request")

local DB = {}

DB.threads = {}

DB.currentJobs = {}

function DB.ThreadWork(input, output)
    local Run = require("postgres.thread")
    Run(input, output)
end

function DB.Initiate()
    for i = 1, config.postgresThreadCount do
        local threadId = threadHandler.CreateThread(DB.ThreadWork)
        table.insert(DB.threads, threadId)
        DB.currentJobs[threadId] = 0
    end
end

function DB.ProcessResponse(res)
    if res.error then
        tes3mp.LogMessage(enumerations.log.ERROR, "[Postgres] [[" .. res.error .. "]]")
    elseif res.log then
        tes3mp.LogMessage(enumerations.log.INFO, "[Postgres] [[" .. res.log .. "]]")
    end
    if res.id == -1 and res.error then
        tes3mp.StopServer(1)
    end
end

function DB.ChooseThread()
    local minThread = DB.threads[1]
    local min = DB.currentJobs[minThread]
    for _, thread in pairs(DB.threads) do
        if min == 0 then
            break
        end
        if DB.currentJobs[thread] < min then
            min = DB.currentJobs[thread]
            minThread = thread
        end
    end
    return minThread
end

function DB.StartJob(thread)
    DB.currentJobs[thread] = DB.currentJobs[thread] + 1
end

function DB.FinishJob(thread)
    DB.currentJobs[thread] = DB.currentJobs[thread] - 1
    if DB.currentJobs[thread] < 0 then
        DB.currentJobs[thread] = 0
    end
end

function DB.Send(thread, action, sql, parameters, callback)
    DB.StartJob(thread)
    threadHandler.Send(
        thread,
        Request.form(
            action,
            sql or "",
            parameters or {}
        ),
        function(res)
            DB.FinishJob(thread)
            DB.ProcessResponse(res)
            if callback ~= nil then
                callback(res)
            end
        end
    )
end

function DB.SendAsync(thread, action, sql, parameters)
    DB.StartJob(thread)
    local res = threadHandler.SendAsync(
        thread,
        Request.form(
            action,
            sql or "",
            parameters or {}
        )
    )
    DB.FinishJob(thread)
    DB.ProcessResponse(res)
    return res
end

function DB.Connect(connectString, callback)
    local tasks = {}
    for _, thread in pairs(DB.threads) do
        table.insert(tasks, function()
            return DB.SendAsync(thread, Request.CONNECT, connectString)
        end)
    end
    async.WaitAll(tasks, nil, callback)
end

function DB.ConnectAsync(connectString)
    local currentCoroutine = async.CurrentCoroutine()
    DB.Connect(connectString, function(results)
        coroutine.resume(currentCoroutine, results)
    end)
    return coroutine.yield()
end

function DB.Disconnect(callback)
    local tasks = {}
    for _, thread in pairs(DB.threads) do
        table.insert(tasks, function()
            return DB.SendAsync(thread, Request.DISCONNECT)
        end)
    end
    async.WaitAll(tasks, nil, callback)
end

function DB.DisconnectAsync()
    local currentCoroutine = async.CurrentCoroutine()
    DB.Disconnect(function(results)
        coroutine.resume(currentCoroutine, results)
    end)
    return coroutine.yield()
end

function DB.Query(sql, parameters, callback, numericalIndices)
    local thread = DB.ChooseThread()
    if numericalIndices then
        DB.Send(thread, Request.QUERY_NUMERICAL_INDICES, sql, parameters, callback)
    else
        DB.Send(thread, Request.QUERY, sql, parameters, callback)
    end
end

function DB.QueryAsync(sql, parameters, numericalIndices)
    local thread = DB.ChooseThread()
    if numericalIndices then
        return DB.SendAsync(thread, Request.QUERY_NUMERICAL_INDICES, sql, parameters)
    else
        return DB.SendAsync(thread, Request.QUERY, sql, parameters)
    end
end

return DB
