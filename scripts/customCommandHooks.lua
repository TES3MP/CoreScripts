local customCommandHooks = {}

local specialCharacter = "/"

customCommandHooks.commands = {}

function customCommandHooks.registerCommand(cmd, callback)
    customCommandHooks.commands[cmd] = callback 
end

function customCommandHooks.removeCommand(cmd)
    customCommandHooks.commands[cmd] = nil 
end

function customCommandHooks.getCallback(cmd)
    return customCommandHooks.commands[cmd]
end

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