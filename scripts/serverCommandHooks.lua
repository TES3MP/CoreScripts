local serverCommandHooks = {}
serverCommandHooks.commands = {}
serverCommandHooks.aliases = {}

function serverCommandHooks.registerCommand(pattern, callback)
    cmd = string.lower(cmd)
    serverCommandHooks.commands[pattern] = callback
end

function serverCommandHooks.registerAlias(alias, cmd)
    cmd = string.lower(cmd)
    serverCommandHooks.aliases[alias] = cmd
end

function serverCommandHooks.validator(eventStatus, line)
    if eventStatus.validDefaultHandler then
        local cmd = (line:split(" "))
        cmd[1] = string.lower(cmd[1])
        local alias = serverCommandHooks.aliases[cmd[1]]
        if alias ~= nil then
            cmd[1] = alias
        end
        local callback = serverCommandHooks.commands[cmd[1]]
        if callback ~= nil then
            callback(-1, customCommandHooks.mergeQuotedArguments(cmd), cmd) -- match the chat command arguments
            return customEventHooks.makeEventStatus(false, nil)
        end
    end
end

customEventHooks.registerValidator("OnServerWindowInput", serverCommandHooks.validator)
