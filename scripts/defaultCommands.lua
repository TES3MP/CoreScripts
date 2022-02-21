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
        message = logicHandler.GetChatName(pid) .. " to " .. logicHandler.GetChatName(targetPid) .. ": "
        message = message .. tableHelper.concatenateFromIndex(cmd, 3) .. "\n"
        tes3mp.SendMessage(pid, message, false)
        tes3mp.SendMessage(targetPid, message, false)
    end
end

customCommandHooks.registerCommand("msg", defaultCommands.msg)
customCommandHooks.registerCommand("message", defaultCommands.msg)

defaultCommands.inviteAlly = function(pid, cmd)
    if pid == tonumber(cmd[2]) then
        tes3mp.SendMessage(pid, "You can't invite yourself to be your own ally.\n")
    elseif logicHandler.CheckPlayerValidity(pid, cmd[2]) then

        local targetPid = tonumber(cmd[2])
        local senderMessage
        
        if Players[pid].allyInvitesSent == nil then Players[pid].allyInvitesSent = {} end
        if Players[targetPid].allyInvitesReceived == nil then Players[targetPid].allyInvitesReceived = {} end

        if tableHelper.containsValue(Players[pid].data.alliedPlayers, Players[targetPid].accountName) then
            senderMessage = "You already have " .. logicHandler.GetChatName(targetPid) .. " as your ally\n"
        elseif tableHelper.containsValue(Players[pid].allyInvitesSent, Players[targetPid].accountName) then
            senderMessage = "You have already invited " .. logicHandler.GetChatName(targetPid) .. " to be your ally.\n"
        else
            table.insert(Players[pid].allyInvitesSent, Players[targetPid].accountName)
            table.insert(Players[targetPid].allyInvitesReceived, Players[pid].accountName)

            senderMessage = "You have invited " .. logicHandler.GetChatName(targetPid) .. " to be your ally.\n"
            local receiverMessage = logicHandler.GetChatName(pid) .. " has invited you to become their ally. Write " ..
                color.Yellow .. "/join " .. pid .. color.White .. " to accept.\n"
            tes3mp.SendMessage(targetPid, receiverMessage, false)
        end

        tes3mp.SendMessage(pid, senderMessage, false)
    end
end

customCommandHooks.registerCommand("invite", defaultCommands.inviteAlly)

defaultCommands.joinTeam = function(pid, cmd)
    if pid == tonumber(cmd[2]) then
        tes3mp.SendMessage(pid, "You can't join yourself as your own ally.\n")
    elseif logicHandler.CheckPlayerValidity(pid, cmd[2]) then

        local targetPid = tonumber(cmd[2])
        local senderMessage

        if Players[pid].allyInvitesReceived == nil then Players[pid].allyInvitesReceived = {} end

        if tableHelper.containsValue(Players[pid].data.alliedPlayers, Players[targetPid].accountName) then
            senderMessage = "You already have " .. logicHandler.GetChatName(targetPid) .. " as an ally\n"
        elseif tableHelper.containsValue(Players[pid].allyInvitesReceived, Players[targetPid].accountName) then
            senderMessage = "You now have " .. logicHandler.GetChatName(targetPid) .. " as an ally. Write " ..
                color.Yellow .. "/leave " .. targetPid .. color.White .. " if you later decide to leave " ..
                "the partnership.\n"
            local receiverMessage = logicHandler.GetChatName(pid) .. " has agreed to become your ally.\n"
            tes3mp.SendMessage(targetPid, receiverMessage, false)

            table.insert(Players[pid].data.alliedPlayers, Players[targetPid].accountName)
            table.insert(Players[targetPid].data.alliedPlayers, Players[pid].accountName)
            Players[pid]:Save()
            Players[pid]:LoadAllies()
            Players[targetPid]:Save()
            Players[targetPid]:LoadAllies()
        else
            senderMessage = "You have not yet been invited to become an ally of " .. logicHandler.GetChatName(targetPid) .. "\n"
        end

        tes3mp.SendMessage(pid, senderMessage, false)
    end
end

customCommandHooks.registerCommand("join", defaultCommands.joinTeam)

defaultCommands.leaveTeam = function(pid, cmd)
    if pid == tonumber(cmd[2]) then
        tes3mp.SendMessage(pid, "You can't leave an alliance with yourself.\n")
    elseif logicHandler.CheckPlayerValidity(pid, cmd[2]) then

        local targetPid = tonumber(cmd[2])
        local senderMessage

        if tableHelper.containsValue(Players[pid].data.alliedPlayers, Players[targetPid].accountName) then
            senderMessage = "You have stopped having " .. logicHandler.GetChatName(targetPid) .. " as your ally \n"
            local receiverMessage = logicHandler.GetChatName(pid) .. " has stopped having you as an ally.\n"
            tes3mp.SendMessage(targetPid, receiverMessage, false)

            tableHelper.removeValue(Players[pid].data.alliedPlayers, Players[targetPid].accountName)
            tableHelper.cleanNils(Players[pid].data.alliedPlayers)
            tableHelper.removeValue(Players[targetPid].data.alliedPlayers, Players[pid].accountName)
            tableHelper.cleanNils(Players[targetPid].data.alliedPlayers)
            Players[pid]:Save()
            Players[pid]:LoadAllies()
            Players[targetPid]:Save()
            Players[targetPid]:LoadAllies()
        else
            senderMessage = "You are not an ally of " .. logicHandler.GetChatName(targetPid) .. "\n"
        end

        tes3mp.SendMessage(pid, senderMessage, false)
    end
end

customCommandHooks.registerCommand("leave", defaultCommands.leaveTeam)

defaultCommands.me = function(pid, cmd)
    local message = logicHandler.GetChatName(pid) .. " " .. tableHelper.concatenateFromIndex(cmd, 2) .. "\n"
    tes3mp.SendMessage(pid, message, true)
end

customCommandHooks.registerCommand("me", defaultCommands.me)

defaultCommands.localMessage = function(pid, cmd)
    local cellDescription = Players[pid].data.location.cell

    if logicHandler.IsCellLoaded(cellDescription) == true then
        for index, visitorPid in pairs(LoadedCells[cellDescription].visitors) do

            local message = logicHandler.GetChatName(pid) .. " to local area: "
            message = message .. tableHelper.concatenateFromIndex(cmd, 2) .. "\n"
            tes3mp.SendMessage(visitorPid, message, false)
        end
    end
end

customCommandHooks.registerCommand("local", defaultCommands.localMessage)
customCommandHooks.registerCommand("l", defaultCommands.localMessage)

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

defaultCommands.overrideDestination = function(pid, cmd)
    local isModerator, isAdmin, isServerOwner = getRanks(pid)

    if isModerator == false then
        invalidCommand(pid)
        return
    end

    if cmd[2] == nil or cmd[3] == nil then
        tes3mp.SendMessage(pid, 'Invalid inputs! Use /overridedestination all/<pid> "Old Cell Name" "New Cell Name"\n')
        return
    end

    if cmd[2] ~= "all" and not logicHandler.CheckPlayerValidity(pid, cmd[2]) then
        return
    end

    local inputConcatenation = tableHelper.concatenateFromIndex(cmd, 3)
    local cellDescriptions = tableHelper.getTableFromSplit(inputConcatenation, patterns.quoteSplit)

    if tableHelper.getCount(cellDescriptions) ~= 2 then
        tes3mp.SendMessage(pid, "Invalid inputs! Please specify two different cells with their names between quotation marks.\n")
        return
    end

    local stateObject
    local targetPid

    if cmd[2] == "all" then
        stateObject = WorldInstance
    else
        targetPid = tonumber(cmd[2])
        stateObject = Players[targetPid]
    end

    -- Get rid of quotation marks
    for currentIndex, cellDescription in pairs(cellDescriptions) do
        cellDescriptions[currentIndex] = string.gsub(cellDescription, '"', '')
    end

    stateObject.data.destinationOverrides[cellDescriptions[1]] = cellDescriptions[2]
    stateObject:Save()

    if cmd[2] == "all" then
        for onlinePid, player in pairs(Players) do
            if player:IsLoggedIn() then
                WorldInstance:LoadDestinationOverrides(onlinePid)
            end
        end
    else
        Players[targetPid]:LoadDestinationOverrides()
    end

    tes3mp.SendMessage(pid, "Doors and clientside commands leading to " .. cellDescriptions[1] .. " now lead to " ..
        cellDescriptions[2] .. " instead.\n")
end

customCommandHooks.registerCommand("overridedestination", defaultCommands.overrideDestination)

defaultCommands.runStartup = function(pid, cmd)
    local isModerator, isAdmin, isServerOwner = getRanks(pid)

    if isAdmin == false then
        tes3mp.SendMessage(pid, "You need to be an admin to run this command\n")
        return
    end

    for _, scriptName in pairs(config.worldStartupScripts) do
        tes3mp.SendMessage(pid, "Running " .. color.Yellow .. scriptName .. color.White .. " script.\n")
        logicHandler.RunConsoleCommandOnPlayer(pid, "startscript " .. scriptName, false)
    end

    tes3mp.SendMessage(pid, color.Red .. "Warning: " .. color.White .. "Make sure to run this command again later if you " ..
        "reset the cells on this server.\n")

    WorldInstance.coreVariables.hasRunStartupScripts = true
end

customCommandHooks.registerCommand("runstartup", defaultCommands.runStartup)

defaultCommands.resetCell = function(pid, cmd)
    local isModerator, isAdmin, isServerOwner = getRanks(pid)

    if isModerator == false then
        tes3mp.SendMessage(pid, "You need to be a moderator to run this command\n")
        return
    end

    if cmd[2] == nil then
        tes3mp.SendMessage(pid, 'Invalid inputs! Use /resetcell "Cell Name"\n')
        return
    end

    local inputConcatenation = tableHelper.concatenateFromIndex(cmd, 2)
    local cellDescription = string.gsub(inputConcatenation, '"', '')

    logicHandler.ResetCell(pid, cellDescription)
end

customCommandHooks.registerCommand("resetcell", defaultCommands.resetCell)

defaultCommands.setPlayerModel = function(pid, cmd)
    local isModerator, isAdmin, isServerOwner = getRanks(pid)

    if isAdmin == false then
        tes3mp.SendMessage(pid, "You need to be an admin to run this command\n")
        return
    end

    if logicHandler.CheckPlayerValidity(pid, cmd[2]) then
        if cmd[3] == nil then
            tes3mp.SendMessage(pid, 'Invalid inputs! Use /setmodel <pid> "Model name"\n')
            return
        end

        local targetPid = tonumber(cmd[2])
        local inputConcatenation = tableHelper.concatenateFromIndex(cmd, 3)
        local modelName = string.gsub(inputConcatenation, '"', '')

        Players[targetPid].data.character.modelOverride = modelName
        Players[targetPid]:LoadCharacter()
        Players[targetPid]:Message("Your model has been changed.\n")
    end    
end

customCommandHooks.registerCommand("setmodel", defaultCommands.setPlayerModel)
