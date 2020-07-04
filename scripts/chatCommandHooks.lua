local chatCommandHooks = {}

local specialCharacter = "/"

chatCommandHooks.commands = {}
chatCommandHooks.aliases = {}
chatCommandHooks.rankRequirement = {}
chatCommandHooks.nameRequirement = {}

function chatCommandHooks.registerCommand(cmd, callback)
    cmd = string.lower(cmd)
    chatCommandHooks.commands[cmd] = callback
end

function chatCommandHooks.registerAlias(alias, cmd)
    cmd = string.lower(cmd)
    chatCommandHooks.aliases[alias] = cmd
end

function chatCommandHooks.removeCommand(cmd)
    chatCommandHooks.commands[cmd] = nil 
    chatCommandHooks.rankRequirement[cmd] = nil
    chatCommandHooks.nameRequirement[cmd] = nil
end

function chatCommandHooks.getCallback(cmd)
    return chatCommandHooks.commands[cmd]
end

function chatCommandHooks.setRankRequirement(cmd, rank)
    if chatCommandHooks.commands[cmd] ~= nil then
        chatCommandHooks.rankRequirement[cmd] = rank
    end
end

function chatCommandHooks.removeRankRequirement(cmd)
    chatCommandHooks.rankRequirement[cmd] = nil
end

function chatCommandHooks.setNameRequirement(cmd, names)
    if chatCommandHooks.commands[cmd] ~= nil then
        chatCommandHooks.nameRequirement[cmd] = names
    end
end

function chatCommandHooks.addNameRequirement(cmd, name)
    if chatCommandHooks.commands[cmd] ~= nil then
        if chatCommandHooks.nameRequirement[cmd] == nil then
            chatCommandHooks.nameRequirement[cmd] = {}
        end
        table.insert(chatCommandHooks.nameRequirement[cmd], name)
    end
end

function chatCommandHooks.removeNameRequirement(cmd)
    chatCommandHooks.nameRequirement[cmd] = nil
end

function chatCommandHooks.checkName(cmd, pid)
    return chatCommandHooks.nameRequirement[cmd] == nil or
        tableHelper.containsValue(chatCommandHooks.nameRequirement[cmd], Players[pid].accountName)
end

function chatCommandHooks.checkRank(cmd, pid)
    return chatCommandHooks.rankRequirement[cmd] == nil or
        Players[pid].data.settings.staffRank >= chatCommandHooks.rankRequirement[cmd]
end

function chatCommandHooks.invalidCommand(pid)
    local message = "Not a valid command. Type /help for more info.\n"
    tes3mp.SendMessage(pid, color.Error .. message .. color.Default, false)
end

function chatCommandHooks.emptyCommand(pid)
    local message = "Please use a command after the / symbol.\n"
    tes3mp.SendMessage(pid, color.Error .. message .. color.Default, false)
end

function chatCommandHooks.mergeQuotedArguments(cmd)
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

function chatCommandHooks.validator(eventStatus, pid, message)
    if eventStatus.validDefaultHandler then
        if message:sub(1,1) == specialCharacter then
            local cmd = (message:sub(2, #message)):split(" ")

            if cmd[1] == nil then
                chatCommandHooks.emptyCommand(pid)
                return customEventHooks.makeEventStatus(false, nil)
            else
                cmd[1] = string.lower(cmd[1])
                local alias = chatCommandHooks.aliases[cmd[1]]
                if alias ~= nil then
                    cmd[1] = alias
                end
                local callback = chatCommandHooks.getCallback(cmd[1])
                if callback ~= nil then
                    local passedRequirements = chatCommandHooks.checkName(cmd[1], pid) and
                        chatCommandHooks.checkRank(cmd[1], pid)
                    if passedRequirements then
                        callback(pid, chatCommandHooks.mergeQuotedArguments(cmd), cmd)
                    else
                        chatCommandHooks.invalidCommand(pid)
                    end
                else
                    chatCommandHooks.invalidCommand(pid)
                end
            end
            return customEventHooks.makeEventStatus(false, false)
        end
    end
end

customEventHooks.registerValidator("OnPlayerSendMessage", chatCommandHooks.validator)

return chatCommandHooks
