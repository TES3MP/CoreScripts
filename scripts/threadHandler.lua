local effil = require("effil")

local threadHandler = {
    threads = {},
    threadId = 0,
    messageId = 0,
    callbacks = {},
    checkCoroutine = nil,
    timer = nil,
    interval = nil,
    ERROR = -1
}

if config then
    threadHandler.interval = config.threadHandlerInterval
end

--
-- public functions for the main thread
--

function threadHandler.CreateThread(body, ...)
    local thread = {}
    thread.input = effil.channel()
    thread.output = effil.channel()
    thread.worker = effil.thread(body)(thread.input, thread.output, ...)
    local id = threadHandler.GetThreadId()
    threadHandler.threads[id] = thread
    return id
end

function threadHandler.Send(id, message, callback)
    local thread = threadHandler.threads[id]
    if thread == nil then
        error("Thread " .. id .. " not found!")
    end
    local id = threadHandler.GetMessageId()
    threadHandler.callbacks[id] = callback
    thread.input:push(effil.table{
        id = id,
        message = message
    })
end

function threadHandler.SendAsync(id, message, sync)
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

--
-- public functions for secondary threads
--

function threadHandler.ReceiveMessages(input, output, callback)
    local fl = true
    repeat
        local inp = input:pop()
        local status, err = pcall(function()
            output:push(effil.table{
                id = inp.id,
                message = callback(inp.message)
            })
        end)
        if not status then
            output:push(effil.table{
                id = threadHandler.ERROR,
                message = err
            })
        end
    until not fl
end

--
-- private functions
--

function threadHandler.GetThreadId()
    threadHandler.threadId = threadHandler.threadId + 1
    return threadHandler.threadId
end

function threadHandler.GetMessageId()
    threadHandler.messageId = threadHandler.messageId + 1
    return threadHandler.messageId
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
                threadHandler.callbacks[res.id](res.message)
                threadHandler.callbacks[res.id] = nil
            end
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

if threadHandler.interval then
    threadHandler.Initiate()
end

return threadHandler
