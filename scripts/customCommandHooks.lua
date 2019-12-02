--[[
    Example usage:

    customCommandHooks.registerCommand("test", function(pid, cmd)
        tes3mp.SendMessage(pid, "You can execute a normal command!\n", false)
    end)


    customCommandHooks.registerCommand("ranktest", function(pid, cmd)
        tes3mp.SendMessage(pid, "You can execute a rank-checked command!\n", false)
    end)
    customCommandHooks.setRankRequirement("ranktest", 2) -- must be at least rank 2


    customCommandHooks.registerCommand("nametest", function(pid, cmd)
        tes3mp.SendMessage(pid, "You can execute a name-checked command!\n", false)
    end)
    customCommandHooks.setNameRequirement("nametest", {"Admin", "Kneg", "Jiub"}) -- must be one of these names

]]


local customCommandHooks = {}

local specialCharacter = "/"

customCommandHooks.commands = {}
customCommandHooks.rankRequirement = {}
customCommandHooks.nameRequirement = {}

function customCommandHooks.registerCommand(cmd, callback)
    customCommandHooks.commands[cmd] = callback 
end

function customCommandHooks.removeCommand(cmd)
    customCommandHooks.commands[cmd] = nil 
    customCommandHooks.rankRequirement[cmd] = nil
    customCommandHooks.nameRequirement[cmd] = nil
end

function customCommandHooks.getCallback(cmd)
    return customCommandHooks.commands[cmd]
end

function customCommandHooks.setRankRequirement(cmd, rank)
    if customCommandHooks.commands[cmd] ~= nil then
        customCommandHooks.rankRequirement[cmd] = rank
    end
end

function customCommandHooks.removeRankRequirement(cmd)
    customCommandHooks.rankRequirement[cmd] = nil
end

function customCommandHooks.setNameRequirement(cmd, names)
    if customCommandHooks.commands[cmd] ~= nil then
        customCommandHooks.nameRequirement[cmd] = names
    end
end

function customCommandHooks.addNameRequirement(cmd, name)
    if customCommandHooks.commands[cmd] ~= nil then
        if customCommandHooks.nameRequirement[cmd] == nil then
            customCommandHooks.nameRequirement[cmd] = {}
        end
        table.insert(customCommandHooks.nameRequirement[cmd], name)
    end
end

function customCommandHooks.removeNameRequirement(cmd)
    customCommandHooks.nameRequirement[cmd] = nil
end

function customCommandHooks.validator(eventStatus, pid, message)
    if message:sub(1,1) == specialCharacter then
        local cmd = (message:sub(2, #message)):split(" ")
        local callback = customCommandHooks.getCallback(cmd[1])
        if callback ~= nil then
            if customCommandHooks.nameRequirement[cmd[1]] ~= nil then
                if tableHelper.containsValue(customCommandHooks.nameRequirement[cmd[1]], Players[pid].accountName) then
                    callback(pid, cmd)
                    return customEventHooks.makeEventStatus(false, nil)
                end
            elseif customCommandHooks.rankRequirement[cmd[1]] ~= nil then
                if Players[pid].data.settings.staffRank >= customCommandHooks.rankRequirement[cmd[1]] then
                    callback(pid, cmd)
                    return customEventHooks.makeEventStatus(false, nil)
                end
            else
                callback(pid, cmd)
                return customEventHooks.makeEventStatus(false, nil)
            end
        end
    end
end

customEventHooks.registerValidator("OnPlayerSendMessage", customCommandHooks.validator)

return customCommandHooks
