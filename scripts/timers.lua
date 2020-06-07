local timers = {}

timers.currentId = 0
timers.timer = nil
timers.expecting = nil
timers.callbacks = {}

--
-- public methods
--
function timers.Timeout(func, delay)
    local id = timers.GetId()
    local timestamp = tes3mp.GetMillisecondsSinceServerStart() + delay
    timers.callbacks[id] = {
        f = function(id)
            timers.callbacks[id] = nil
            func(id)
        end,
        timestamp = timestamp
    }
    timers.Expect(timestamp)
    return id
end

function timers.Interval(func, delay)
    local id = timers.GetId()
    local timestamp = tes3mp.GetMillisecondsSinceServerStart() + delay
    timers.callbacks[id] = {
        f = function(id)
            local timestamp = tes3mp.GetMillisecondsSinceServerStart() + delay
            timers.callbacks[id].timestamp = timestamp
            func(id)
            timers.Expect(timestamp)
        end,
        timestamp = timestamp
    }
    timers.Expect(timestamp)
    return id
end

function timers.Stop(id)
    timers.callbacks[id] = nil
end

function timers.WaitAsync(delay)
    local currentCoroutine = async.CurrentCoroutine()
    timers.Timeout(function(id)
        coroutine.resume(currentCoroutine)
    end, delay)
    coroutine.yield()
end

--
-- helper methods
--
function TIMERS_CALLBACK()
    local time = tes3mp.GetMillisecondsSinceServerStart()
    local minTimestamp = nil
    timers.expecting = nil
    for id, v in pairs(timers.callbacks) do
        if v.timestamp <= time then
            v.f(id)
        elseif minTimestamp == nil or minTimestamp > v.timestamp then
            minTimestamp = v.timestamp
        end
    end
    if minTimestamp ~= nil then
        timers.Expect(minTimestamp)
    end
end

function timers.GetId()
    timers.currentId = timers.currentId + 1
    return timers.currentId
end

function timers.Expect(timestamp)
    local time = tes3mp.GetMillisecondsSinceServerStart()
    if timestamp <= time then
        TIMERS_CALLBACK()
    elseif not timers.expecting or timestamp < timers.expecting then
        timers.expecting = timestamp
        tes3mp.RestartTimer(timers.timer, math.max(0, timers.expecting - time))
    end
end

timers.timer = tes3mp.CreateTimer("TIMERS_CALLBACK", 0)
tes3mp.StartTimer(timers.timer)

return timers