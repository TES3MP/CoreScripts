---@diagnostic disable: unused-local

---@class TES3MP
local api

---Write a log message with its own timestamp.
---
---It will have “[Script]:” prepended to it so as to mark it as a script-generated log message.
---@param level number @The logging level used (0 for LOG_VERBOSE, 1 for LOG_INFO, 2 for LOG_WARN, 3 for LOG_ERROR, 4 for LOG_FATAL).
---@param message string @The message logged.
function api.LogMessage(level, message) end

---@type TES3MP
tes3mp = tes3mp
