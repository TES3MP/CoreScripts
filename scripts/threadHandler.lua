local effil = require("effil")

local threadHandler = {
    threads = {},
    threadId = 0,
    messageId = 0,
    callbacks = {},
    ERROR = -1
}

--
-- private
--

local function GetThreadId()
    threadHandler.threadId = threadHandler.threadId + 1
    return threadHandler.threadId
end

local function GetMessageId()
    threadHandler.messageId = threadHandler.messageId + 1
    return threadHandler.messageId
end

local function Check()
    for _, thread in pairs(threadHandler.threads) do
        local res = thread.output:pop(0)
        while res ~= nil do
            if res.id == threadHandler.ERROR then
                tes3mp.LogMessage(enumerations.log.ERROR, "[ThreadHandler] Error in thread: " .. res.message)
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

--
-- public
--

function threadHandler.CreateThread(body, ...)
    local thread = {}
    thread.input = effil.channel()
    thread.output = effil.channel()
    thread.worker = effil.thread(body)(thread.input, thread.output, ...)
    local id = GetThreadId()
    threadHandler.threads[id] = thread
    return id
end

function threadHandler.Send(id, message, callback)
    local thread = threadHandler.threads[id]
    if thread == nil then
        error("Thread " .. id .. " not found!")
    end
    local id = GetMessageId()
    if config.threadHandlerDebug then
        local checkpoint = tes3mp.GetMillisecondsSinceServerStart()
        local originalCallback = callback
        callback = function(...)
            local delta = tes3mp.GetMillisecondsSinceServerStart() - checkpoint
            tes3mp.LogMessage(enumerations.log.INFO, string.format("[ThreadHandler] Request took %s",delta))
            return originalCallback(...)
        end
    end
    threadHandler.callbacks[id] = callback
    thread.input:push(effil.table{
        id = id,
        message = message
    })
end

function threadHandler.SendAsync(id, message)
    -- replace with async.CurrentCoroutine when synchronous mode is scrapped
    local currentCoroutine = coroutine.running()
    local responseMessage = nil
    if not currentCoroutine then
        async.RunBlocking(function()
            local co = async.CurrentCoroutine()
            threadHandler.Send(id, message, function(result)
                responseMessage = result
                async.Resume(co)
            end)
            coroutine.yield()
        end)
    else
        threadHandler.Send(id, message, function(result)
            responseMessage = result
            async.Resume(currentCoroutine)
        end)
        coroutine.yield()
    end
    return responseMessage
end

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

-- we might not be in the main thread, and config might not be imported
if config and config.schedulerInterval then
    timers.Interval(config.schedulerInterval, function()
        Check()
    end)
end

return threadHandler
