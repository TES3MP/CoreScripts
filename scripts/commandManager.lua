local commandManager = {}

local specialCharacter = "/"

commandManager.commands = {}

function commandManager.registerCommand(cmd,callback)
    commandManager.commands[cmd] = callback 
end

function commandManager.removeCommand(cmd)
    commandManager.commands[cmd] = nil 
end

function commandManager.getCallback(cmd)
    return commandManager.commands[cmd]
end

function commandManager.validator(eventStatus,pid,message)
    if message:sub(1,1) == specialCharacter then
        local cmd = (message:sub(2,#message)):split(" ")
        local callback = commandManager.getCallback(cmd[1])
        if callback~=nil then
            callback(pid,cmd)
            return eventManager.getEventStatus(false,nil)
        end
    end
end

eventManager.registerValidator("OnPlayerSendMessage",commandManager.validator)

return commandManager