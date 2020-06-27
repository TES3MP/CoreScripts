local serverCommandHooks = {}
serverCommandHooks.commands = {}
serverCommandHooks.aliases = {}

serverCommandHooks.pid = -1

function serverCommandHooks.registerCommand(cmd, callback)
    cmd = string.lower(cmd)
    serverCommandHooks.commands[cmd] = callback
end

function serverCommandHooks.registerAlias(alias, cmd)
    cmd = string.lower(cmd)
    serverCommandHooks.aliases[alias] = cmd
end

function serverCommandHooks.validator(eventStatus, line)
    if eventStatus.validDefaultHandler then
        local cmd = (line:split(" "))
        if not cmd[1] then return nil end
        cmd[1] = string.lower(cmd[1])
        local alias = serverCommandHooks.aliases[cmd[1]]
        if alias ~= nil then
            cmd[1] = alias
        end
        local callback = serverCommandHooks.commands[cmd[1]]
        if callback ~= nil then
            callback(
                serverCommandHooks.pid, -- match the chat command arguments
                chatCommandHooks.mergeQuotedArguments(cmd),
                cmd
            )
            return customEventHooks.makeEventStatus(false, nil)
        end
    end
end

customEventHooks.registerValidator("OnServerWindowInput", serverCommandHooks.validator)

return serverCommandHooks
