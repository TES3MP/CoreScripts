local customCommandHooks = {}

local specialCharacter = "/"

customCommandHooks.commands = {}
customCommandHooks.aliases = {}
customCommandHooks.rankRequirement = {}
customCommandHooks.nameRequirement = {}

function customCommandHooks.registerCommand(cmd, callback)
    customCommandHooks.commands[cmd] = callback 
end

function customCommandHooks.registerAlias(alias, cmd)
    customCommandHooks.aliases[alias] = cmd
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

function customCommandHooks.checkName(cmd, pid)
    return customCommandHooks.nameRequirement[cmd] == nil or
        tableHelper.containsValue(customCommandHooks.nameRequirement[cmd], Players[pid].accountName)
end

function customCommandHooks.checkRank(cmd, pid)
    return customCommandHooks.rankRequirement[cmd] == nil or
        Players[pid].data.settings.staffRank >= customCommandHooks.rankRequirement[cmd]
end

function customCommandHooks.invalidCommand(pid)
    local message = "Not a valid command. Type /help for more info.\n"
    tes3mp.SendMessage(pid, color.Error .. message .. color.Default, false)
end

function customCommandHooks.emptyCommand(pid)
    local message = "Please use a command after the / symbol.\n"
    tes3mp.SendMessage(pid, color.Error .. message .. color.Default, false)
end

function customCommandHooks.mergeQuotedArguments(cmd)
    local merged = {}
    local quoted = {}
    local quotedStatus = false
    for i, chunk in ipairs(cmd) do
        if not quotedStatus and chunk:sub(1, 1) == '"' then
            quotedStatus = true
            chunk = chunk:sub(2, -1)
        end
        if quotedStatus and chunk:sub(-1, -1) == '"' then
            chunk = chunk:sub(1, -2)
            table.insert(quoted, chunk)
            table.insert(merged, table.concat(quoted))
            quoted = {}
            quotedStatus = false
        elseif quotedStatus then
            table.insert(quoted, chunk .. " ")
        else
            table.insert(merged, chunk)
        end
    end
    return merged
end

function customCommandHooks.validator(eventStatus, pid, message)
    if eventStatus.validDefaultHandler then
        if message:sub(1,1) == specialCharacter then
            local cmd = (message:sub(2, #message)):split(" ")

            if cmd[1] == nil then
                customCommandHooks.emptyCommand(pid)
                return customEventHooks.makeEventStatus(false, nil)
            else
                cmd[1] = string.lower(cmd[1])
                local alias = customCommandHooks.aliases[cmd[1]]
                if alias ~= nil then
                    cmd[1] = alias
                end
                local callback = customCommandHooks.getCallback(cmd[1])
                if callback ~= nil then
                    local passedRequirements = customCommandHooks.checkName(cmd[1], pid) and
                        customCommandHooks.checkRank(cmd[1], pid)
                    if passedRequirements then
                        callback(pid, customCommandHooks.mergeQuotedArguments(cmd), cmd)
                    else
                        customCommandHooks.invalidCommand(pid)
                    end
                    return customEventHooks.makeEventStatus(false, nil)
                else
                    customCommandHooks.invalidCommand(pid)
                end
            end
        end
    end
end

customEventHooks.registerValidator("OnPlayerSendMessage", customCommandHooks.validator)

return customCommandHooks
