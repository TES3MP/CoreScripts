--- Custom command hooks
-- @module customCommandHooks
local customCommandHooks = {}
--- special character "/"
local specialCharacter = "/"

-- commands
customCommandHooks.commands = {}

--- Register command
-- @string cmd
-- @string callback
function customCommandHooks.registerCommand(cmd, callback)
    customCommandHooks.commands[cmd] = callback 
end

--- Remove command
-- @string cmd
function customCommandHooks.removeCommand(cmd)
    customCommandHooks.commands[cmd] = nil 
end

--- Get callback
-- @string cmd
-- @return callback
function customCommandHooks.getCallback(cmd)
    return customCommandHooks.commands[cmd]
end

--- Validator
-- @param eventStatus
-- @int pid player ID
-- @string message
function customCommandHooks.validator(eventStatus, pid, message)
    if message:sub(1,1) == specialCharacter then
        local cmd = (message:sub(2, #message)):split(" ")
        local callback = customCommandHooks.getCallback(cmd[1])
        if callback~=nil then
            callback(pid, cmd)
            return customEventHooks.makeEventStatus(false, nil)
        end
    end
end

customEventHooks.registerValidator("OnPlayerSendMessage", customCommandHooks.validator)

return customCommandHooks