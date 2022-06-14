---@class TES3MP
local api

---@param callback string
---@param msec integer
---@return integer
function api.CreateTimer(callback, msec) end

---@param callback string
---@param msec integer
---@param types string
---@param ... any
---@return integer
function api.CreateTimerEx(callback, msec, types, ...) end

---@param timerId integer
function api.StartTimer(timerId) end

---@param timerId integer
function api.StopTimer(timerId) end

---@param timerId integer
---@param msec integer
function api.RestartTimer(timerId, msec) end

---@param timerId integer
function api.FreeTimer(timerId) end

---@param timerId integer
---@return boolean
function api.IsTimerElapsed(timerId) end
