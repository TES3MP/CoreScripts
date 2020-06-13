local commandHandler = {}

function commandHandler.ProcessCommand(pid, cmd)

    if cmd[1] == nil then
        local message = "Please use a command after the / symbol.\n"
        tes3mp.SendMessage(pid, color.Error .. message .. color.Default, false)
        return false
    else
        -- The command itself should always be lowercase
        cmd[1] = string.lower(cmd[1])
    end

    local serverOwner = false
    local admin = false
    local moderator = false

    if Players[pid]:IsServerOwner() then
        serverOwner = true
        admin = true
        moderator = true
    elseif Players[pid]:IsAdmin() then
        admin = true
        moderator = true
    elseif Players[pid]:IsModerator() then
        moderator = true
    end

    if false then
    else
        local message = "Not a valid command. Type /help for more info.\n"
        tes3mp.SendMessage(pid, color.Error .. message .. color.Default, false)
    end
end

return commandHandler
