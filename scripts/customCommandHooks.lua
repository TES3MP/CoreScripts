local customCommandHooks = {}

local specialCharacter = "/"

customCommandHooks.commands = {}
customCommandHooks.helpCommands = {}

function customCommandHooks.registerCommand(cmd, callback, label)
    customCommandHooks.commands[cmd] = callback 
    if label ~= nil then
        customCommandHooks.helpCommands[cmd] = label
    end
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
customEventHooks.registerHandler("OnServerPostInit", function(eventStatus)
    -- Add commmands with label
    for cmd, label in pairs(customCommandHooks.helpCommands) do
        Menus["help player"].text = Menus["help player"].text .. "\n" .. color.Yellow .."/".. cmd .."\n"..
         color.White .. label
    end
end)
return customCommandHooks
