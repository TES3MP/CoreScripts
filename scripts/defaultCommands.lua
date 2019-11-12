-- Helper functions
local getRanks = function(pid)
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
    
    return moderator, admin, serverOwner
end

local invalidCommand = function(pid)
    local message = "Not a valid command. Type /help for more info.\n"
    tes3mp.SendMessage(pid, color.Error .. message .. color.Default, false)
end

defaultCommands = {}

-- Commands
defaultCommands.msg = function(pid, cmd)
    if pid == tonumber(cmd[2]) then
        tes3mp.SendMessage(pid, "You can't message yourself.\n")
    elseif cmd[3] == nil then
        tes3mp.SendMessage(pid, "You cannot send a blank message.\n")
    elseif logicHandler.CheckPlayerValidity(pid, cmd[2]) then
        local targetPid = tonumber(cmd[2])
        local targetName = Players[targetPid].name
        message = logicHandler.GetChatName(pid) .. " to " .. logicHandler.GetChatName(targetPid) .. ": "
        message = message .. tableHelper.concatenateFromIndex(cmd, 3) .. "\n"
        tes3mp.SendMessage(pid, message, false)
        tes3mp.SendMessage(targetPid, message, false)
    end
end

customCommandHooks.registerCommand("msg", defaultCommands.msg)
customCommandHooks.registerCommand("message", defaultCommands.msg)

defaultCommands.me = function(pid, cmd)
    local message = logicHandler.GetChatName(pid) .. " " .. tableHelper.concatenateFromIndex(cmd, 2) .. "\n"
    tes3mp.SendMessage(pid, message, true)
end

customCommandHooks.registerCommand("me", defaultCommands.me)

--damn can't name it local
defaultCommands.loc = function(pid, cmd)
    local cellDescription = Players[pid].data.location.cell

    if logicHandler.IsCellLoaded(cellDescription) == true then
        for index, visitorPid in pairs(LoadedCells[cellDescription].visitors) do

            local message = logicHandler.GetChatName(pid) .. " to local area: "
            message = message .. tableHelper.concatenateFromIndex(cmd, 2) .. "\n"
            tes3mp.SendMessage(visitorPid, message, false)
        end
    end
end

customCommandHooks.registerCommand("local", defaultCommands.loc)
customCommandHooks.registerCommand("l", defaultCommands.loc)

defaultCommands.greentext = function(pid, cmd)
    local message = logicHandler.GetChatName(pid) .. ": " .. color.GreenText ..
            ">" .. tableHelper.concatenateFromIndex(cmd, 2) .. "\n"
    tes3mp.SendMessage(pid, message, true)
end

customCommandHooks.registerCommand("greentext", defaultCommands.greentext)
customCommandHooks.registerCommand("gt", defaultCommands.greentext)

defaultCommands.ban = function(pid, cmd)

    local moderator, admin, serverOwner = getRanks(pid)

    if not moderator then
        invalidCommand(pid)
        return
    end

    if cmd[2] == "ip" and cmd[3] ~= nil then
        local ipAddress = cmd[3]

        if not tableHelper.containsValue(banList.ipAddresses, ipAddress) then
            table.insert(banList.ipAddresses, ipAddress)
            SaveBanList()

            tes3mp.SendMessage(pid, ipAddress .. " is now banned.\n", false)
            tes3mp.BanAddress(ipAddress)
        else
            tes3mp.SendMessage(pid, ipAddress .. " was already banned.\n", false)
        end
    elseif (cmd[2] == "name" or cmd[2] == "player") and cmd[3] ~= nil then
        local targetName = tableHelper.concatenateFromIndex(cmd, 3)
        logicHandler.BanPlayer(pid, targetName)

    elseif type(tonumber(cmd[2])) == "number" and logicHandler.CheckPlayerValidity(pid, cmd[2]) then
        local targetPid = tonumber(cmd[2])
        local targetName = Players[targetPid].name
        logicHandler.BanPlayer(pid, targetName)
    else
        tes3mp.SendMessage(pid, "Invalid input for ban.\n", false)
    end
end

customCommandHooks.registerCommand("ban", defaultCommands.ban)

defaultCommands.unban = function(pid, cmd)
    local moderator, admin, serverOwner = getRanks(pid)

    if moderator == false or cmd[3] == nil then
        invalidCommand(pid)
        return
    end

    if cmd[2] == "ip" then
        local ipAddress = cmd[3]

        if tableHelper.containsValue(banList.ipAddresses, ipAddress) == true then
            tableHelper.removeValue(banList.ipAddresses, ipAddress)
            SaveBanList()

            tes3mp.SendMessage(pid, ipAddress .. " is now unbanned.\n", false)
            tes3mp.UnbanAddress(ipAddress)
        else
            tes3mp.SendMessage(pid, ipAddress .. " is not banned.\n", false)
        end
    elseif cmd[2] == "name" or cmd[2] == "player" then
        local targetName = tableHelper.concatenateFromIndex(cmd, 3)
        logicHandler.UnbanPlayer(pid, targetName)
    else
        tes3mp.SendMessage(pid, "Invalid input for unban.\n", false)
    end
end

customCommandHooks.registerCommand("unban", defaultCommands.unban)

defaultCommands.banlist = function(pid, cmd)
    local moderator, admin, serverOwner = getRanks(pid)

    if not moderator then
        invalidCommand(pid)
        return
    end

    local message

    if cmd[2] == "names" or cmd[2] == "name" or cmd[2] == "players" then
        if #banList.playerNames == 0 then
            message = "No player names have been banned.\n"
        else
            message = "The following player names are banned:\n"

            for index, targetName in pairs(banList.playerNames) do
                message = message .. targetName

                if index < #banList.playerNames then
                    message = message .. ", "
                end
            end

            message = message .. "\n"
        end
    elseif cmd[2] ~= nil and (string.lower(cmd[2]) == "ips" or string.lower(cmd[2]) == "ip") then
        if #banList.ipAddresses == 0 then
            message = "No IP addresses have been banned.\n"
        else
            message = "The following IP addresses unattached to players are banned:\n"

            for index, ipAddress in pairs(banList.ipAddresses) do
                message = message .. ipAddress

                if index < #banList.ipAddresses then
                    message = message .. ", "
                end
            end

            message = message .. "\n"
        end
    end

    if message == nil then
        message = "Please specify whether you want the banlist for IPs or for names.\n"
    end

    tes3mp.SendMessage(pid, message, false)
end

customCommandHooks.registerCommand("banlist", defaultCommands.banlist)

defaultCommands.ipaddresses = function(pid, cmd)
    local moderator, admin, serverOwner = getRanks(pid)

    if moderator == false or cmd[2] == nil then
        invalidCommand(pid)
        return
    end

    local targetName = tableHelper.concatenateFromIndex(cmd, 2)
    local targetPlayer = logicHandler.GetPlayerByName(targetName)

    if targetPlayer == nil then
        tes3mp.SendMessage(pid, "Player " .. targetName .. " does not exist.\n", false)
    elseif targetPlayer.data.ipAddresses ~= nil then
        local message = "Player " .. targetPlayer.accountName .. " has used the following IP addresses:\n"

        for index, ipAddress in pairs(targetPlayer.data.ipAddresses) do
            message = message .. ipAddress

            if index < #targetPlayer.data.ipAddresses then
                message = message .. ", "
            end
        end

        message = message .. "\n"
        tes3mp.SendMessage(pid, message, false)
    end
end

customCommandHooks.registerCommand("ipaddresses", defaultCommands.ipaddresses)
customCommandHooks.registerCommand("ips", defaultCommands.ipaddresses)

defaultCommands.players = function(pid, cmd)
    guiHelper.ShowPlayerList(pid)
end

customCommandHooks.registerCommand("players", defaultCommands.players)
customCommandHooks.registerCommand("list", defaultCommands.players)

defaultCommands.cells = function(pid, cmd)
    local moderator, admin, serverOwner = getRanks(pid)

    if moderator == false then
        invalidCommand(pid)
        return
    end

    guiHelper.ShowCellList(pid)
end

customCommandHooks.registerCommand("cells", defaultCommands.cells)

defaultCommands.regions = function(pid, cmd)
    local moderator, admin, serverOwner = getRanks(pid)

    if moderator == false then
        invalidCommand(pid)
        return
    end

    guiHelper.ShowRegionList(pid)
end

customCommandHooks.registerCommand("regions", defaultCommands.regions)
