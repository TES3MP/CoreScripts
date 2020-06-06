local effil = require("effil")

local threadHandler = {
    threads = {},
    threadId = 0,
    messageId = 0,
    callbacks = {},
    args = {},
    checkCoroutine = nil,
    timer = nil,
    interval = config.threadHandlerInterval,
    ERROR = -1
}

function threadHandler.Async(func, ...)
    local co = coroutine.create(func)
    local status, res = coroutine.resume(co, ...)
    if not status then
        error(res)
    end
    return res
end

function threadHandler.GetCurrentCoroutine()
    local currentCoroutine = coroutine.running()
    if not currentCoroutine then
        error("Must run inside a coroutine!\n" .. debug.traceback())
    end
    return currentCoroutine
end

function threadHandler.WaitAll(funcs, timeout, callback)
    local total = #funcs
    local counter = 0
    local results = {}
    local returned = false
    if timeout then
        timers.Timeout(function(id)
            if counter < total then
                callback(results)
                returned = true
            end
        end, timeout)
    end
    for i, func in pairs(funcs) do
        threadHandler.Async(function()
            local result = func()
            results[i] = result
            counter = counter + 1
            if not returned and counter == total then
                callback(results)
                returned = true
            end
        end)
    end
end

function threadHandler.WaitAllAsync(funcs, timeout)
    local currentCoroutine = threadHandler.GetCurrentCoroutine()
    threadHandler.WaitAll(funcs, timeout, function(results)
        coroutine.resume(currentCoroutine, results)
    end)
    return coroutine.yield()
end

function threadHandler.CreateThread(body, ...)
    local thread = {}
    thread.input = effil.channel()
    thread.output = effil.channel()
    thread.worker = effil.thread(body)(thread.input, thread.output, threadHandler.ERROR, ...)
    local id = threadHandler.GetThreadId()
    threadHandler.threads[id] = thread
    return id
end

function threadHandler.GetThreadId()
    threadHandler.threadId = threadHandler.threadId + 1
    return threadHandler.threadId
end

function threadHandler.GetMessageId()
    threadHandler.messageId = threadHandler.messageId + 1
    return threadHandler.messageId
end

function threadHandler.Send(id, message, callback, ...)
    local thread = threadHandler.threads[id]
    if thread == nil then
        error("Thread " .. id .. " not found!")
    end
    local id = threadHandler.GetMessageId()
    threadHandler.callbacks[id] = callback
    threadHandler.args[id] = {...}
    thread.input:push(effil.table{
        id = id,
        message = message
    })
end

function threadHandler.SendAwait(id, message, sync)
    local currentCoroutine = coroutine.running()
    local responseMessage = nil
    if not currentCoroutine or sync then
        local flag = false
        threadHandler.Send(id, message, function(result)
            flag = true
            responseMessage = result
        end)
        while not flag do
            effil.sleep(threadHandler.interval, "ms")
            threadHandler.Check()
        end
    else
        threadHandler.Send(id, message, function(result)
            responseMessage = result
            coroutine.resume(currentCoroutine)
        end)
        coroutine.yield()
    end
    return responseMessage
end

function threadHandler.Check()
    for id, thread in pairs(threadHandler.threads) do
        local res = thread.output:pop(0)
        while res ~= nil do
            if res.id == threadHandler.ERROR then
                tes3mp.LogMessage(enumerations.log.ERROR, "[threadHandler] Error in thread: " .. res.message)
                tes3mp.StopServer(1)
            end
            if threadHandler.callbacks[res.id] ~= nil then
                threadHandler.callbacks[res.id](res.message, unpack(threadHandler.args[res.id]))
                threadHandler.callbacks[res.id] = nil
            end
            threadHandler.args[res.id] = nil
            res = thread.output:pop(0)
        end
    end
end

function THREADHANDLER_TIMER()
    threadHandler.Check()
    threadHandler.RestartTimer()
end

function threadHandler.Initiate()
    threadHandler.timer = tes3mp.CreateTimer("THREADHANDLER_TIMER", threadHandler.interval)
    tes3mp.StartTimer(threadHandler.timer)
end

function threadHandler.RestartTimer()
    tes3mp.RestartTimer(threadHandler.timer, threadHandler.interval)
end

threadHandler.Initiate()

return threadHandler
