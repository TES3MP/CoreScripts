local defaultCommands = {}

local ranks = {
    MODERATOR = 1,
    ADMIN = 2,
    OWNER = 3
}

local function commandError(pid, text)
    tes3mp.SendMessage(pid, color.Error .. message .. color.Default .. "\n")
end

-- Commands
defaultCommands.msg = function(pid, cmd, rawCmd)
    if pid == tonumber(rawCmd[2]) then
       commandError(pid, "You can't message yourself.")
    elseif rawCmd[3] == nil then
        commandError(pid, "You cannot send a blank message.")
    elseif logicHandler.CheckPlayerValidity(pid, rawCmd[2]) then
        local targetPid = tonumber(rawCmd[2])
        message = logicHandler.GetChatName(pid) .. " to " .. logicHandler.GetChatName(targetPid) .. ": "
        message = message .. tableHelper.concatenateFromIndex(rawCmd, 3) .. "\n"
        tes3mp.SendMessage(pid, message, false)
        tes3mp.SendMessage(targetPid, message, false)
    end
end

customCommandHooks.registerCommand("message", defaultCommands.msg)
customCommandHooks.registerAlias("msg", "message")

defaultCommands.inviteAlly = function(pid, cmd)
    if pid == tonumber(cmd[2]) then
        commandError(pid, "You can't invite yourself to be your own ally.")
    elseif logicHandler.CheckPlayerValidity(pid, cmd[2]) then

        local targetPid = tonumber(cmd[2])
        local senderMessage

        if Players[pid].allyInvitesSent == nil then Players[pid].allyInvitesSent = {} end
        if Players[targetPid].allyInvitesReceived == nil then Players[targetPid].allyInvitesReceived = {} end

        if tableHelper.containsValue(Players[pid].data.alliedPlayers, Players[targetPid].accountName) then
            senderMessage = "You already have " .. logicHandler.GetChatName(targetPid) .. "as your ally\n"
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
        commandError(pid, "You can't join yourself as your own ally.")
    elseif logicHandler.CheckPlayerValidity(pid, cmd[2]) then
        local targetPid = tonumber(cmd[2])
        local senderMessage

        if Players[pid].allyInvitesReceived == nil then Players[pid].allyInvitesReceived = {} end

        if tableHelper.containsValue(Players[pid].data.alliedPlayers, Players[targetPid].accountName) then
            senderMessage = "You are already have " .. logicHandler.GetChatName(targetPid) .. "as an ally\n"
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
        commandError(pid, "You can't leave an alliance with yourself.")
    elseif logicHandler.CheckPlayerValidity(pid, cmd[2]) then

        local targetPid = tonumber(cmd[2])
        local senderMessage

        if tableHelper.containsValue(Players[pid].data.alliedPlayers, Players[targetPid].accountName) then
            senderMessage = "You have stopped having " .. logicHandler.GetChatName(targetPid) .. "as your ally \n"
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

defaultCommands.localMessage = function(pid, cmd, rawCmd)
    local cellDescription = Players[pid].data.location.cell

    if logicHandler.IsCellLoaded(cellDescription) == true then
        for index, visitorPid in pairs(LoadedCells[cellDescription].visitors) do

            local message = logicHandler.GetChatName(pid) .. " to local area: "
            message = message .. tableHelper.concatenateFromIndex(rawCmd, 2) .. "\n"
            tes3mp.SendMessage(visitorPid, message, false)
        end
    end
end
customCommandHooks.registerCommand("local", defaultCommands.localMessage)
customCommandHooks.registerAlias("l", "local")

defaultCommands.greentext = function(pid, cmd, rawCmd)
    local message = logicHandler.GetChatName(pid) .. ": " .. color.GreenText ..
            ">" .. tableHelper.concatenateFromIndex(rawCmd, 2) .. "\n"
    tes3mp.SendMessage(pid, message, true)
end
customCommandHooks.registerCommand("greentext", defaultCommands.greentext)
customCommandHooks.registerAlias("gt", "greentext")

defaultCommands.ban = function(pid, cmd)
    if cmd[2] == "ip" and cmd[3] ~= nil then
        local ipAddress = cmd[3]

        if not tableHelper.containsValue(banList.ipAddresses, ipAddress) then
            table.insert(banList.ipAddresses, ipAddress)
            SaveBanList()

            tes3mp.SendMessage(pid, ipAddress .. " is now banned.\n", false)
            tes3mp.BanAddress(ipAddress)
        else
            commandError(pid, ipAddress .. " was already banned.")
        end
    elseif (cmd[2] == "name" or cmd[2] == "player") and cmd[3] ~= nil then
        local targetName = tableHelper.concatenateFromIndex(cmd, 3)
        logicHandler.BanPlayer(pid, targetName)

    elseif type(tonumber(cmd[2])) == "number" and logicHandler.CheckPlayerValidity(pid, cmd[2]) then
        local targetPid = tonumber(cmd[2])
        local targetName = Players[targetPid].name
        logicHandler.BanPlayer(pid, targetName)
    else
        commandError(pid, "Invalid input for ban.")
    end
end
customCommandHooks.registerCommand("ban", defaultCommands.ban)
customCommandHooks.setRankRequirement("ban", ranks.MODERATOR)

defaultCommands.unban = function(pid, cmd)
    if cmd[2] == "ip" then
        local ipAddress = cmd[3]

        if tableHelper.containsValue(banList.ipAddresses, ipAddress) == true then
            tableHelper.removeValue(banList.ipAddresses, ipAddress)
            SaveBanList()

            tes3mp.SendMessage(pid, ipAddress .. " is now unbanned.\n", false)
            tes3mp.UnbanAddress(ipAddress)
        else
            commandError(pid, ipAddress .. " is not banned.")
        end
    elseif cmd[2] == "name" or cmd[2] == "player" then
        local targetName = tableHelper.concatenateFromIndex(cmd, 3)
        logicHandler.UnbanPlayer(pid, targetName)
    else
        commandError(pid, "Invalid input for unban.")
    end
end
customCommandHooks.registerCommand("unban", defaultCommands.unban)
customCommandHooks.setRankRequirement("unban", ranks.MODERATOR)

defaultCommands.banlist = function(pid, cmd)
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
customCommandHooks.setRankRequirement("banlist", ranks.MODERATOR)

defaultCommands.ipaddresses = function(pid, cmd)
    local targetName = tableHelper.concatenateFromIndex(cmd, 2)
    local targetPlayer = logicHandler.GetPlayerByName(targetName)

    if targetPlayer == nil then
        commandError(pid, "Player " .. targetName .. " does not exist/")
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
customCommandHooks.registerAlias("ips", "ipaddresses")
customCommandHooks.setRankRequirement("ipaddress", ranks.MODERATOR)

defaultCommands.players = function(pid, cmd)
    guiHelper.ShowPlayerList(pid)
end
customCommandHooks.registerCommand("players", defaultCommands.players)
customCommandHooks.registerAlias("list", "players")

defaultCommands.cells = function(pid, cmd)
    guiHelper.ShowCellList(pid)
end
customCommandHooks.registerCommand("cells", defaultCommands.cells)
customCommandHooks.setRankRequirement("cells", ranks.MODERATOR)

defaultCommands.regions = function(pid, cmd)
    guiHelper.ShowRegionList(pid)
end
customCommandHooks.registerCommand("regions", defaultCommands.regions)
customCommandHooks.setRankRequirement("regions", ranks.MODERATOR)

defaultCommands.overrideDestination = function(pid, cmd)
    if #cmd < 4 then
        commandError(pid, 'Invalid inputs! Use /overridedestination all/<pid> "Old Cell Name" "New Cell Name"')
        return
    end

    if cmd[2] ~= "all" and not logicHandler.CheckPlayerValidity(pid, cmd[2]) then
        return
    end

    local cellDescriptions = { cmd[3], cmd[4] }

    local stateObject
    local targetPid

    if cmd[2] == "all" then
        stateObject = WorldInstance
    else
        targetPid = tonumber(cmd[2])
        stateObject = Players[targetPid]
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
customCommandHooks.setRankRequirement("overridedestination", ranks.MODERATOR)

local exitWarning = function(delay)
    local message = ""
    if delay == 0 then
        message = "Stopping the server!\n"
    else
        local hours = math.floor(time.toHours(delay))
        local min = math.floor(time.toMinutes(delay % time.hours(1)))
        local sec = math.floor(time.toSeconds(delay % time.minutes(1)))
        message = table.concat({
            "Stopping the server",
            hours > 0 and string.format(" %s hours", hours) or "",
            min > 0 and string.format(" %s minutes", min) or "",
            sec > 0 and string.format(" %s seconds", sec) or "",
            "!\n"
        })
    end
    for pid in pairs(Players) do
        tes3mp.SendMessage(pid, color.DarkRed .. message)
    end
end

function defaultCommands.exit(pid, cmd)
    local delay = cmd[2] and tonumber(cmd[2]) or time.minutes(1)
    delay = time.minutes(delay)

    local minTime = time.seconds(15)
    async.Wrap(function()
        if delay > 0 then
            exitWarning(delay)
        end
        if delay > minTime then
            timers.WaitAsync(delay * 0.5)
            delay = delay - delay * 0.5
            exitWarning(delay)
        end
        if delay > minTime then
            timers.WaitAsync(delay * 0.25)
            delay = delay - delay * 0.25
            exitWarning(delay)
        end
        if delay > minTime then
            timers.WaitAsync(delay - minTime)
            delay = minTime
            exitWarning(delay)
        end
        timers.WaitAsync(delay)
        exitWarning(0)
        tes3mp.StopServer(0)
    end)
end
customCommandHooks.registerCommand("exit", defaultCommands.exit)
customCommandHooks.setRankRequirement("exit", ranks.ADMIN)

function defaultCommands.teleport(pid, cmd)
    if cmd[2] ~= "all" then
        logicHandler.TeleportToPlayer(pid, cmd[2], pid)
    else
        for iteratorPid, player in pairs(Players) do
            if iteratorPid ~= pid then
                if player:IsLoggedIn() then
                    logicHandler.TeleportToPlayer(pid, iteratorPid, pid)
                end
            end
        end
    end
end
customCommandHooks.registerCommand("teleport", defaultCommands.teleport)
customCommandHooks.registerAlias("tp", "teleport")
customCommandHooks.registerAlias("tpto", "teleport")
customCommandHooks.registerAlias("teleportto", "teleport")
customCommandHooks.setRankRequirement("teleport", ranks.MODERATOR)

function defaultCommands.setAuthority(pid, cmd)
    if #cmd ~= 3 then
        commandError(pid, "/setauthority <pid> \"cellDescription\"")
    end
    if logicHandler.CheckPlayerValidity(pid, cmd[2]) then
        local cellDescription = cmd[3]
        if logicHandler.IsCellLoaded(cellDescription) == true then
            local targetPid = tonumber(cmd[2])
            logicHandler.SetCellAuthority(targetPid, cellDescription)
        else
            commandError(pid,  "Cell \"" .. cellDescription .. "\" isn't loaded!")
        end
    end
end
customCommandHooks.registerCommand("setauthority", defaultCommands.teleport)
customCommandHooks.registerAlias("setauth", "setauthority")
customCommandHooks.setRankRequirement("setauthority", ranks.MODERATOR)

function defaultCommands.kick(pid, cmd)
    if logicHandler.CheckPlayerValidity(pid, cmd[2]) then
        local targetPid = tonumber(cmd[2])

        if Players[targetPid]:IsAdmin() then
            commandError(pid, "You cannot kick an Admin from the server.")
        elseif Players[targetPid]:IsModerator() and not Players[targetPid]:IsAdmin() then
            commandError(pid, "You cannot kick a fellow Moderator from the server.")
        else
            local message = logicHandler.GetChatName(targetPid) .. " was kicked from the server by " ..
                logicHandler.GetChatName(pid) .. ".\n"
            tes3mp.SendMessage(pid, message, true)
            Players[targetPid]:Kick()
        end
    end
end
customCommandHooks.registerCommand("kick", defaultCommands.teleport)
customCommandHooks.setRankRequirement("kick", ranks.MODERATOR)

function defaultCommands.addAdmin(pid, cmd)
    if logicHandler.CheckPlayerValidity(pid, cmd[2]) then
        local targetPid = tonumber(cmd[2])
        local targetName = Players[targetPid].name
        if Players[targetPid]:IsAdmin() then
            commandError(pid, targetName .. " is already an Admin.")
        else
            local message = targetName .. " was promoted to Admin!\n"
            tes3mp.SendMessage(pid, message, true)
            Players[targetPid].data.settings.staffRank = 2
            Players[targetPid]:QuicksaveToDrive()
        end
    end
end
customCommandHooks.registerCommand("addadmin", defaultCommands.addAdmin)
customCommandHooks.setRankRequirement("addadmin", ranks.OWNER)

function defaultCommands.removeAdmin(pid, cmd)
    if logicHandler.CheckPlayerValidity(pid, cmd[2]) then
        local targetPid = tonumber(cmd[2])
        local targetName = Players[targetPid].name
        local message

        if Players[targetPid]:IsServerOwner() then
            message = "Cannot demote " .. targetName .. " because they are a Server Owner."
            commandError(pid, message)
        elseif Players[targetPid]:IsAdmin() then
            message = targetName .. " was demoted from Admin to Moderator!\n"
            tes3mp.SendMessage(pid, message)
            Players[targetPid].data.settings.staffRank = 1
            Players[targetPid]:QuicksaveToDrive()
        else
            message = targetName .. " is not an Admin."
            commandError(pid, message)
        end
    end
end
customCommandHooks.registerCommand("removeadmin", defaultCommands.addAdmin)
customCommandHooks.setRankRequirement("removeadmin", ranks.OWNER)

function defaultCommands.addModerator(pid, cmd)
    if logicHandler.CheckPlayerValidity(pid, cmd[2]) then
        local targetPid = tonumber(cmd[2])
        local targetName = Players[targetPid].name
        local message

        if Players[targetPid]:IsAdmin() then
            message = targetName .. " is already an Admin."
            commandError(pid, message)
        elseif Players[targetPid]:IsModerator() then
            message = targetName .. " is already a Moderator."
            commandError(pid, message)
        else
            message = targetName .. " was promoted to Moderator!\n"
            tes3mp.SendMessage(pid, message, true)
            Players[targetPid].data.settings.staffRank = 1
            Players[targetPid]:QuicksaveToDrive()
        end
    end
end
customCommandHooks.registerCommand("addmoderator", defaultCommands.addModerator)
customCommandHooks.setRankRequirement("addmoderator", ranks.ADMIN)

return defaultCommands
