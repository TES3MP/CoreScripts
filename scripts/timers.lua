local Timers = {}

Timers.currentId = 0
Timers.timer = nil
Timers.expecting = nil
Timers.callbacks = {}

--
-- public methods
--
function Timers.Timeout(func, delay)
    local id = Timers.GetId()
    local timestamp = tes3mp.GetMillisecondsSinceServerStart() + delay
    Timers.callbacks[id] = {
        f = function(id)
            Timers.callbacks[id] = nil
            func(id)
        end,
        timestamp = timestamp
    }
    Timers.Expect(timestamp)
    return id
end

function Timers.Interval(func, delay)
    local id = Timers.GetId()
    local timestamp = tes3mp.GetMillisecondsSinceServerStart() + delay
    Timers.callbacks[id] = {
        f = function(id)
            local timestamp = tes3mp.GetMillisecondsSinceServerStart() + delay
            Timers.callbacks[id].timestamp = timestamp
            func(id)
            Timers.Expect(timestamp)
        end,
        timestamp = timestamp
    }
    Timers.Expect(timestamp)
    return id
end

function Timers.Stop(id)
    Timers.callbacks[id] = nil
end

function Timers.WaitAsync(delay)
    local co = coroutine.running()
    if not co then
        error('Must run inside a coroutine!')
    end
    Timers.Timeout(function(id)
        coroutine.resume(co)
    end, delay)
    coroutine.yield()
end

--
-- helper methods
--
function TIMERS_CALLBACK()
    local time = tes3mp.GetMillisecondsSinceServerStart()
    local minTimestamp = nil
    Timers.expecting = nil
    for id, v in pairs(Timers.callbacks) do
        if v.timestamp <= time then
            v.f(id)
        elseif minTimestamp == nil or minTimestamp > v.timestamp then
            minTimestamp = v.timestamp
        end
    end
    if minTimestamp ~= nil then
        Timers.Expect(minTimestamp)
    end
end

function Timers.GetId()
    Timers.currentId = Timers.currentId + 1
    return Timers.currentId
end

function Timers.Expect(timestamp)
    local time = tes3mp.GetMillisecondsSinceServerStart()
    if timestamp <= time then
        TIMERS_CALLBACK()
    elseif not Timers.expecting or timestamp < Timers.expecting then
        Timers.expecting = timestamp
        tes3mp.RestartTimer(Timers.timer, math.max(0, Timers.expecting - time))
    end
end

Timers.timer = tes3mp.CreateTimer("TIMERS_CALLBACK", 0)
tes3mp.StartTimer(Timers.timer)

return Timers