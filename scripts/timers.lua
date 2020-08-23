local timers = {
    currentId = 0,
    timer = nil,
    expecting = nil,
    callbacks = {}
}

--
-- private
--

local currentTimestamp = tes3mp.GetMillisecondsSinceServerStart

local function TimerId()
    timers.currentId = timers.currentId + 1
    return timers.currentId
end

local function Expect(timestamp)
    local time = currentTimestamp()
    if not timers.expecting or timestamp < timers.expecting then
        timers.expecting = timestamp
        tes3mp.RestartTimer(timers.timer, math.max(0, timers.expecting - time))
    end
end

--
-- public
--

function timers.Timeout(delay, func)
    local id = TimerId()
    local timestamp = currentTimestamp() + delay
    timers.callbacks[id] = {
        f = function(id)
            timers.callbacks[id] = nil
            func(id)
        end,
        timestamp = timestamp
    }
    Expect(timestamp)
    return id
end

function timers.Interval(delay, func)
    local id = TimerId()
    local timestamp = currentTimestamp() + delay
    timers.callbacks[id] = {
        f = function(id)
            local timestamp = currentTimestamp() + delay
            timers.callbacks[id].timestamp = timestamp
            func(id)
            Expect(timestamp)
        end,
        timestamp = timestamp
    }
    Expect(timestamp)
    return id
end

function timers.Stop(id)
    timers.callbacks[id] = nil
end

function timers.WaitAsync(delay)
    local currentCoroutine = async.CurrentCoroutine()
    if delay <= 0 then
        return
    end
    timers.Timeout(delay, function(id)
        async.Resume(currentCoroutine)
    end)
    coroutine.yield()
end

-- has to be public, since it is called in global TIMERS_CALLBACK
function timers.Tick()
    local now = currentTimestamp()
    local minTimestamp = nil
    timers.expecting = nil
    for id, v in pairs(timers.callbacks) do
        if v.timestamp <= now then
            v.f(id)
        elseif minTimestamp == nil or minTimestamp > v.timestamp then
            minTimestamp = v.timestamp
        end
    end
    if minTimestamp ~= nil then
        Expect(minTimestamp)
    end
end

-- has to be global due to how tes3mp.CreateTimer functions
function TIMERS_CALLBACK()
    timers.Tick()
end

customEventHooks.registerHandler("OnBlockingTick", TIMERS_CALLBACK)

timers.timer = tes3mp.CreateTimer("TIMERS_CALLBACK", 0)
tes3mp.StartTimer(timers.timer)

return timers