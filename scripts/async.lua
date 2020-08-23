local async = {}
local sleep = require('effil').sleep
local currentTimestamp = tes3mp.GetMillisecondsSinceServerStart
local blockingInterval = time.toSeconds(config.schedulerInterval)

function async.Wrap(func, ...)
    local co = coroutine.create(func)
    return async.Resume(co, ...)
end

function async.Resume(co, ...)
    local status, res = coroutine.resume(co, ...)
    if not status then
        error(res)
    end
    return res
end

function async.CurrentCoroutine()
    local currentCoroutine = coroutine.running()
    if not currentCoroutine then
        error("Must run inside a coroutine!\n" .. debug.traceback())
    end
    return currentCoroutine
end

function async.WaitAll(funcs, timeout, callback)
    local total = #funcs
    local counter = 0
    local results = {}
    local returned = false
    if timeout then
        timers.Timeout(timeout, function(id)
            if counter < total then
                if callback then callback(results) end
                returned = true
            end
        end)
    end
    for i, func in pairs(funcs) do
        async.Wrap(function()
            local result = func()
            results[i] = result
            counter = counter + 1
            if not returned and counter == total then
                if callback then callback(results) end
                returned = true
            end
        end)
    end
end

function async.WaitAllAsync(funcs, timeout)
    local currentCoroutine = async.CurrentCoroutine()
    async.WaitAll(funcs, timeout, function(results)
        async.Resume(currentCoroutine, results)
    end)
    return coroutine.yield()
end

function async.RunBlocking(func, timeout)
    local done = false
    local res = nil
    local start = currentTimestamp()
    async.Wrap(function()
        res = func()
        done = true
    end)
    while not done do
        local now = currentTimestamp()
        if timeout and (timeout + start) < now then
            error("async.RunBlocking timed out after " .. (now - start))
        end
        customEventHooks.triggerHandlers("OnBlockingTick", customEventHooks.makeEventStatus(true, true), {})
        sleep(blockingInterval)
    end
    return res
end

return async
