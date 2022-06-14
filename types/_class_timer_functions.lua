---@class TES3MP
local api

---Create a timer that will run a script function after a certain interval.
---@param callback string @The Lua script function.
---@param msec integer @The interval in miliseconds.
---@return integer @The ID of the timer thus created.
function api.CreateTimer(callback, msec) end

---Create a timer that will run a script function after a certain interval and pass certain arguments to it.
---
---Example usage:
--- - tes3mp.CreateTimerEx("OnTimerTest1", 250, "i", 90)
--- - tes3mp.CreateTimerEx("OnTimerTest2", 500, "sif", "Test string", 60, 77.321)
---@param callback unknown @The Lua script function.
---@param msec integer @The interval in miliseconds.
---@param types string @The argument types.
---@param ... any @The arguments.
---@return integer @The ID of the timer thus created.
function api.CreateTimerEx(callback, msec, types, ...) end

---Start the timer with a certain ID.
---@param timerId integer @The timer ID.
function api.StartTimer(timerId) end

---Stop the timer with a certain ID.
---@param timerId integer @The timer ID.
function api.StopTimer(timerId) end

---Restart the timer with a certain ID for a certain interval.
---@param timerId integer @The timer ID.
---@param msec integer @The interval in miliseconds.
function api.RestartTimer(timerId, msec) end

---Free the timer with a certain ID.
---@param timerId integer @The timer ID.
function api.FreeTimer(timerId) end

---Check whether a timer is elapsed.
---@param timerId integer @The timer ID.
---@return boolean @Whether the timer is elapsed.
function api.IsTimerElapsed(timerId) end
