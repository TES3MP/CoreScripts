local defaultCommands = {}

local ranks = {
    MODERATOR = 1,
    ADMIN = 2,
    OWNER = 3
}

local function commandInfo(pid, text, toEveryone, chatMessage)
    chatMessage = chatMessage or text
    chatMessage = chatMessage .. "\n"
    if pid == serverCommandHooks.pid then
        tes3mp.LogMessage(enumerations.log.INFO, text)
        if toEveryone and next(Players) then
            tes3mp.SendMessage(next(Players), chatMessage, true)
        end
    else
        tes3mp.SendMessage(pid, chatMessage, toEveryone or false)
    end
end
defaultCommands.info = commandInfo

local function commandError(pid, text, toEveryone, chatMessage)
    chatMessage = chatMessage or color.Error .. text .. color.Default
    chatMessage = chatMessage .. "\n"
    commandInfo(pid, text, toEveryone, chatMessage)
end
defaultCommands.error = commandError

defaultCommands.help = function(pid)
    -- Check "scripts/menu/help.lua" if you want to change the contents of the help menus
    Players[pid].currentCustomMenu = "help player"
    menuHelper.DisplayMenu(pid, Players[pid].currentCustomMenu)
end
chatCommandHooks.registerCommand("help", defaultCommands.help)

--
-- Chat
--

defaultCommands.msg = function(pid, cmd, rawCmd)
    if pid == tonumber(rawCmd[2]) then
       commandError(pid, "You can't message yourself.")
    elseif rawCmd[3] == nil then
        commandError(pid, "You cannot send a blank message.")
    elseif logicHandler.CheckPlayerValidity(pid, rawCmd[2]) then
        local targetPid = tonumber(rawCmd[2])
        message = logicHandler.GetChatName(pid) .. " to " .. logicHandler.GetChatName(targetPid) .. ": "
        message = message .. tableHelper.concatenateFromIndex(rawCmd, 3) .. "\n"
        commandInfo(pid, message)
        tes3mp.SendMessage(targetPid, message, false)
    end
end
serverCommandHooks.registerCommand("message", defaultCommands.msg)
chatCommandHooks.registerCommand("message", defaultCommands.msg)
chatCommandHooks.registerAlias("msg", "message")

defaultCommands.me = function(pid, cmd)
    local message = logicHandler.GetChatName(pid) .. " " .. tableHelper.concatenateFromIndex(cmd, 2) .. "\n"
    tes3mp.SendMessage(pid, message, true)
end
chatCommandHooks.registerCommand("me", defaultCommands.me)

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
chatCommandHooks.registerCommand("local", defaultCommands.localMessage)
chatCommandHooks.registerAlias("l", "local")

defaultCommands.greentext = function(pid, cmd, rawCmd)
    local message = logicHandler.GetChatName(pid) .. ": " .. color.GreenText ..
            ">" .. tableHelper.concatenateFromIndex(rawCmd, 2) .. "\n"
    tes3mp.SendMessage(pid, message, true)
end
chatCommandHooks.registerCommand("greentext", defaultCommands.greentext)
chatCommandHooks.registerAlias("gt", "greentext")

--
-- Party
--

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
chatCommandHooks.registerCommand("invite", defaultCommands.inviteAlly)

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
chatCommandHooks.registerCommand("join", defaultCommands.joinTeam)

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
chatCommandHooks.registerCommand("leave", defaultCommands.leaveTeam)

--
-- Server status
--

function defaultCommands.setLogLevel(pid, cmd)
    if logicHandler.CheckPlayerValidity(pid, cmd[2]) then

        local targetPid = tonumber(cmd[2])
        local logLevel = cmd[3]

        if type(tonumber(logLevel)) == "number" then
            logLevel = tonumber(logLevel)
        end

        if logLevel == "default" or type(logLevel) == "number" then
            Players[targetPid]:SetEnforcedLogLevel(logLevel)
            Players[targetPid]:LoadSettings()
            tes3mp.SendMessage(pid, "Enforced log level for " .. Players[targetPid].name
                                   .. " is now " .. logLevel .. "\n", true)
        else
            tes3mp.SendMessage(pid, "Not a valid argument. Use /setloglevel <pid> <value>\n", false)
            return false
        end
    end
end
chatCommandHooks.registerCommand("setloglevel", defaultCommands.setLogLevel)
chatCommandHooks.registerAlias("setenforcedloglevel", "setloglevel")
chatCommandHooks.setRankRequirement("setloglevel", ranks.ADMIN)

local GetConnectedPlayerList = function()
    local lastPid = tes3mp.GetLastPlayerId()
    local list = ""
    local divider = ""

    for playerIndex = 0, lastPid do
        if playerIndex == lastPid then
            divider = ""
        else
            divider = "\n"
        end
        if Players[playerIndex] ~= nil and Players[playerIndex]:IsLoggedIn() then

            list = list .. tostring(Players[playerIndex].name) .. " (pid: " .. tostring(Players[playerIndex].pid) ..
                ", ping: " .. tostring(tes3mp.GetAvgPing(Players[playerIndex].pid)) .. ")" .. divider
        end
    end

    return list
end
defaultCommands.players = function(pid, cmd)
    local playerCount = logicHandler.GetConnectedPlayerCount()
    local label = playerCount .. " connected player"

    if playerCount ~= 1 then
        label = label .. "s"
    end

    tes3mp.ListBox(pid, guiHelper.ID.PLAYERSLIST, label, GetConnectedPlayerList())
end
chatCommandHooks.registerCommand("players", defaultCommands.players)
chatCommandHooks.registerAlias("list", "players")

local GetLoadedCellList = function()
    local list = ""
    local divider = ""

    local cellCount = logicHandler.GetLoadedCellCount()
    local cellIndex = 0

    for key, value in pairs(LoadedCells) do
        cellIndex = cellIndex + 1

        if cellIndex == cellCount then
            divider = ""
        else
            divider = "\n"
        end

        list = list .. key .. " (auth: " .. LoadedCells[key]:GetAuthority() .. ", loaded by " ..
            LoadedCells[key]:GetVisitorCount() .. ")" .. divider
    end

    return list
end
defaultCommands.cells = function(pid, cmd)
    local cellCount = logicHandler.GetLoadedCellCount()
    local label = cellCount .. " loaded cell"

    if cellCount ~= 1 then
        label = label .. "s"
    end

    tes3mp.ListBox(pid, guiHelper.ID.CELLSLIST, label, GetLoadedCellList())
end
chatCommandHooks.registerCommand("cells", defaultCommands.cells)
chatCommandHooks.setRankRequirement("cells", ranks.MODERATOR)

local GetLoadedRegionList = function()
    local list = ""
    local divider = ""

    local regionCount = logicHandler.GetLoadedRegionCount()
    local regionIndex = 0

    for key, value in pairs(WorldInstance.storedRegions) do
        local visitorCount = WorldInstance:GetRegionVisitorCount(key)

        if visitorCount > 0 then
            regionIndex = regionIndex + 1

            if regionIndex == regionCount then
                divider = ""
            else
                divider = "\n"
            end

            list = list .. key .. " (auth: " .. WorldInstance:GetRegionAuthority(key) .. ", loaded by " ..
                visitorCount .. ")" .. divider
        end
    end

    return list
end
defaultCommands.regions = function(pid, cmd)
    local regionCount = logicHandler.GetLoadedRegionCount()
    local label = regionCount .. " loaded region"

    if regionCount ~= 1 then
        label = label .. "s"
    end

    tes3mp.ListBox(pid, guiHelper.ID.CELLSLIST, label, GetLoadedRegionList())
end
chatCommandHooks.registerCommand("regions", defaultCommands.regions)
chatCommandHooks.setRankRequirement("regions", ranks.MODERATOR)

local exitWarning = function(delay)
    local message = ""
    if delay == 0 then
        message = "Stopping the server!\n"
    else
        local hours = math.floor(time.toHours(delay))
        local min = math.floor(time.toMinutes(delay % time.hours(1)))
        local sec = math.floor(time.toSeconds(delay % time.minutes(1)))
        message = table.concat({
            "Stopping the server in ",
            hours > 0 and string.format(" %s hour", hours) or "",
            hours > 1 and "s" or "",
            min > 0 and string.format(" %s minute", min) or "",
            min > 1 and "s" or "",
            sec > 0 and string.format(" %s second", sec) or "",
            sec > 1 and "s" or "",
            "!"
        })
    end
    commandInfo(serverCommandHooks.pid, message, true, color.DarkRed .. message .. color.Default)
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
serverCommandHooks.registerCommand("exit", defaultCommands.exit)
chatCommandHooks.registerCommand("exit", defaultCommands.exit)
chatCommandHooks.setRankRequirement("exit", ranks.ADMIN)

--
-- Moderation
--

local function banPlayerByName(pid, targetName)
    if logicHandler.IsBanned(targetName) then
        commandError(pid, targetName .. " was already banned.")
        return
    end
    if logicHandler.BanPlayer(targetName) then
        commandInfo(pid, "All IP addresses stored for " .. targetName .. " are now banned.")
    else
        commandError(pid, targetName .. " does not have an account on this server.")
    end
end
defaultCommands.ban = function(pid, cmd)
    if cmd[2] == "ip" and cmd[3] ~= nil then
        local ipAddress = cmd[3]

        if not tableHelper.containsValue(banList.ipAddresses, ipAddress) then
            table.insert(banList.ipAddresses, ipAddress)
            SaveBanList()

            commandInfo(pid, ipAddress .. " is now banned.\n")
            tes3mp.BanAddress(ipAddress)
        else
            commandError(pid, ipAddress .. " was already banned.")
        end
    elseif (cmd[2] == "name" or cmd[2] == "player") and cmd[3] ~= nil then
        local targetName = tableHelper.concatenateFromIndex(cmd, 3)
        banPlayerByName(pid, targetName)

    elseif type(tonumber(cmd[2])) == "number" and logicHandler.CheckPlayerValidity(pid, cmd[2]) then
        local targetPid = tonumber(cmd[2])
        local targetName = Players[targetPid].name
        banPlayerByName(pid, targetName)
    else
        commandError(pid, "Invalid input for ban.")
    end
end
serverCommandHooks.registerCommand("ban", defaultCommands.ban)
chatCommandHooks.registerCommand("ban", defaultCommands.ban)
chatCommandHooks.setRankRequirement("ban", ranks.MODERATOR)

local function unbanPlayerByName(pid, targetName)
    if not logicHandler.IsBanned(targetName) then
        commandError(pid, targetName .. " is not banned.")
        return
    end
    if logicHandler.UnbanPlayer(targetName) then
        commandInfo(pid, "All IP addresses stored for " .. targetName .. " are now unbanned.")
    else
        commandError(pid, targetName .. " does not have an account on this server, " ..
            "but has been removed from the ban list.")
    end
end
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
        unbanPlayerByName(pid, targetName)
    else
        commandError(pid, "Invalid input for unban.")
    end
end
serverCommandHooks.registerCommand("unban", defaultCommands.unban)
chatCommandHooks.registerCommand("unban", defaultCommands.unban)
chatCommandHooks.setRankRequirement("unban", ranks.MODERATOR)

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
chatCommandHooks.registerCommand("banlist", defaultCommands.banlist)
chatCommandHooks.setRankRequirement("banlist", ranks.MODERATOR)

defaultCommands.ipAddresses = function(pid, cmd)
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
chatCommandHooks.registerCommand("ipaddresses", defaultCommands.ipAddresses)
chatCommandHooks.registerAlias("ips", "ipaddresses")
chatCommandHooks.setRankRequirement("ipaddress", ranks.MODERATOR)

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
            commandInfo(pid, message, true)
            Players[targetPid]:Kick()
        end
    end
end
serverCommandHooks.registerCommand("kick", defaultCommands.kick)
chatCommandHooks.registerCommand("kick", defaultCommands.kick)
chatCommandHooks.setRankRequirement("kick", ranks.MODERATOR)

function defaultCommands.addAdmin(pid, cmd)
    tableHelper.print(cmd)
    if logicHandler.CheckPlayerValidity(pid, cmd[2]) then
        local targetPid = tonumber(cmd[2])
        local targetName = Players[targetPid].name
        if Players[targetPid]:IsAdmin() then
            commandError(pid, targetName .. " is already an Admin.")
        else
            local message = targetName .. " was promoted to Admin!\n"
            commandInfo(pid, message, true)
            Players[targetPid].data.settings.staffRank = 2
            Players[targetPid]:QuicksaveToDrive()
        end
    else
        commandError(pid, "Player with pid " .. cmd[2] .. " not found!")
    end
end
serverCommandHooks.registerCommand("addadmin", defaultCommands.addAdmin)
chatCommandHooks.registerCommand("addadmin", defaultCommands.addAdmin)
chatCommandHooks.setRankRequirement("addadmin", ranks.OWNER)

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
            commandInfo(pid, message, true)
            Players[targetPid].data.settings.staffRank = 1
            Players[targetPid]:QuicksaveToDrive()
        else
            message = targetName .. " is not an Admin."
            commandError(pid, message)
        end
    end
end
serverCommandHooks.registerCommand("removeadmin", defaultCommands.removeAdmin)
chatCommandHooks.registerCommand("removeadmin", defaultCommands.removeAdmin)
chatCommandHooks.setRankRequirement("removeadmin", ranks.OWNER)

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
            commandInfo(pid, message, true)
            Players[targetPid].data.settings.staffRank = 1
            Players[targetPid]:QuicksaveToDrive()
        end
    end
end
serverCommandHooks.registerCommand("addmoderator", defaultCommands.addModerator)
chatCommandHooks.registerCommand("addmoderator", defaultCommands.addModerator)
chatCommandHooks.setRankRequirement("addmoderator", ranks.ADMIN)

function defaultCommands.removeModerator(pid, cmd)
    if logicHandler.CheckPlayerValidity(pid, cmd[2]) then
        local targetPid = tonumber(cmd[2])
        local targetName = Players[targetPid].name
        local message

        if Players[targetPid]:IsAdmin() then
            message = "Cannot demote " .. targetName .. " because they are an Admin.\n"
            commandError(pid, message)
        elseif Players[targetPid]:IsModerator() then
            message = targetName .. " was demoted from Moderator!\n"
            commandInfo(pid, message, true)
            Players[targetPid].data.settings.staffRank = 0
            Players[targetPid]:QuicksaveToDrive()
        else
            message = targetName .. " is not a Moderator.\n"
            commandError(pid, message)
        end
    end
end
serverCommandHooks.registerCommand("removemoderator", defaultCommands.removeModerator)
chatCommandHooks.registerCommand("removemoderator", defaultCommands.removeModerator)
chatCommandHooks.setRankRequirement("removemoderator", ranks.ADMIN)

function defaultCommands.setRace(pid, cmd)
    if logicHandler.CheckPlayerValidity(pid, cmd[2]) then
        local targetPid = tonumber(cmd[2])
        local targetName = Players[targetPid].name
        local message

        if Players[targetPid]:IsAdmin() then
            message = "Cannot demote " .. targetName .. " because they are an Admin.\n"
            commandError(pid, message)
        elseif Players[targetPid]:IsModerator() then
            message = targetName .. " was demoted from Moderator!\n"
            tes3mp.SendMessage(pid, message, true)
            Players[targetPid].data.settings.staffRank = 0
            Players[targetPid]:QuicksaveToDrive()
        else
            message = targetName .. " is not a Moderator.\n"
            commandError(pid, message)
        end
    end
end
chatCommandHooks.registerCommand("setRace", defaultCommands.setRace)
chatCommandHooks.setRankRequirement("setRace", ranks.ADMIN)

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
chatCommandHooks.registerCommand("teleport", defaultCommands.teleport)
chatCommandHooks.registerAlias("tp", "teleport")
chatCommandHooks.registerAlias("tpto", "teleport")
chatCommandHooks.registerAlias("teleportto", "teleport")
chatCommandHooks.setRankRequirement("teleport", ranks.MODERATOR)

function defaultCommands.confiscate(pid, cmd)
    if logicHandler.CheckPlayerValidity(pid, cmd[2]) then

        local targetPid = tonumber(cmd[2])

        if targetPid == pid then
            tes3mp.SendMessage(pid, "You can't confiscate from yourself!\n", false)
        elseif Players[targetPid].data.customVariables.isConfiscationTarget then
            tes3mp.SendMessage(pid, "Someone is already confiscating from that player\n", false)
        else
            Players[pid].confiscationTargetName = Players[targetPid].accountName

            Players[targetPid]:SetConfiscationState(true)

            tableHelper.cleanNils(Players[targetPid].data.inventory)
            local inventoryCount = tableHelper.getCount(Players[targetPid].data.inventory)
            local label = inventoryCount .. " item"

            if inventoryCount ~= 1 then
                label = label .. "s"
            end

            local itemList = {}
            for index, item in ipairs(Players[targetPid].data.inventory) do
                table.insert(itemList, index .. ": " .. item.refId .. " (count: " .. item.count .. ")")
            end

            tes3mp.ListBox(pid, config.customMenuIds.confiscate, label, table.concat(itemList, "\n"))
        end
    end
end
chatCommandHooks.registerCommand("confiscate", defaultCommands.confiscate)
chatCommandHooks.setRankRequirement("confiscate", ranks.MODERATOR)

--
-- Player editing
--

function defaultCommands.setAttr(pid, cmd)
    if logicHandler.CheckPlayerValidity(pid, cmd[2]) then
        local targetPid = tonumber(cmd[2])
        local targetName = Players[targetPid].name

        if cmd[3] ~= nil and cmd[4] ~= nil and tonumber(cmd[4]) ~= nil then
            local attrId
            local value = tonumber(cmd[4])

            if tonumber(cmd[3]) ~= nil then
                attrId = tonumber(cmd[3])
            else
                attrId = tes3mp.GetAttributeId(cmd[3])
            end

            if attrId ~= -1 and attrId < tes3mp.GetAttributeCount() then
                tes3mp.SetAttributeBase(targetPid, attrId, value)
                tes3mp.SendAttributes(targetPid)

                local message = targetName .. "'s " .. tes3mp.GetAttributeName(attrId) ..
                    " is now " .. value .. "\n"
                tes3mp.SendMessage(pid, message, true)
                Players[targetPid]:SaveAttributes()
            end
        end
    end
end
chatCommandHooks.registerCommand("setattr", defaultCommands.setAttr)
chatCommandHooks.setRankRequirement("setattr", ranks.MODERATOR)

function defaultCommands.setSkill(pid, cmd)
    if logicHandler.CheckPlayerValidity(pid, cmd[2]) then
        local targetPid = tonumber(cmd[2])
        local targetName = Players[targetPid].name

        if cmd[3] ~= nil and cmd[4] ~= nil and tonumber(cmd[4]) ~= nil then
            local skillId
            local value = tonumber(cmd[4])

            if tonumber(cmd[3]) ~= nil then
                skillId = tonumber(cmd[3])
            else
                skillId = tes3mp.GetSkillId(cmd[3])
            end

            if skillId ~= -1 and skillId < tes3mp.GetSkillCount() then
                tes3mp.SetSkillBase(targetPid, skillId, value)
                tes3mp.SendSkills(targetPid)
  
                local message = targetName .. "'s " .. tes3mp.GetSkillName(skillId) ..
                    " is now " .. value .. "\n"
                tes3mp.SendMessage(pid, message, true)
                Players[targetPid]:SaveSkills()
            end
        end
    end
end
chatCommandHooks.registerCommand("setskill", defaultCommands.setSkill)
chatCommandHooks.setRankRequirement("setskill", ranks.MODERATOR)

function defaultCommands.setScale(pid, cmd)
    if logicHandler.CheckPlayerValidity(pid, cmd[2]) then

        local targetPid = tonumber(cmd[2])
        local targetName = ""
        local scale = cmd[3]

        if type(tonumber(scale)) == "number" then
            scale = tonumber(scale)
        else
            tes3mp.SendMessage(pid, "Not a valid argument. Use /setscale <pid> <value>.\n", false)
            return false
        end

        Players[targetPid]:SetScale(scale)
        Players[targetPid]:LoadShapeshift()
        tes3mp.SendMessage(pid, "Scale for " .. Players[targetPid].name .. " is now " .. scale .. "\n", false)
        if targetPid ~= pid then
            tes3mp.SendMessage(targetPid, "Your scale is now " .. scale .. "\n", false)
        end
    end
end
chatCommandHooks.registerCommand("setscale", defaultCommands.setScale)
chatCommandHooks.setRankRequirement("setscale", ranks.ADMIN)

function defaultCommands.setWerewolf(pid, cmd)
    if logicHandler.CheckPlayerValidity(pid, cmd[2]) then

        local targetPid = tonumber(cmd[2])
        local targetName = ""
        local state = ""

        if cmd[3] == "on" then
            Players[targetPid]:SetWerewolfState(true)
            state = " enabled.\n"
        elseif cmd[3] == "off" then
            Players[targetPid]:SetWerewolfState(false)
            state = " disabled.\n"
        else
            tes3mp.SendMessage(pid, "Not a valid argument. Use /setwerewolf <pid> on/off.\n", false)
            return false
        end

        Players[targetPid]:LoadShapeshift()
        tes3mp.SendMessage(pid, "Werewolf state for " .. Players[targetPid].name .. state, false)
        if targetPid ~= pid then
            tes3mp.SendMessage(targetPid, "Werewolf state" .. state, false)
        end
    end
end
chatCommandHooks.registerCommand("setwerewolf", defaultCommands.setWerewolf)
chatCommandHooks.setRankRequirement("setwerewolf", ranks.ADMIN)

function defaultCommands.setDisguise(pid, cmd)
    if logicHandler.CheckPlayerValidity(pid, cmd[2]) then

        local targetPid = tonumber(cmd[2])
        local creatureRefId = tableHelper.concatenateFromIndex(cmd, 3)

        Players[targetPid].data.shapeshift.creatureRefId = creatureRefId
        tes3mp.SetCreatureRefId(targetPid, creatureRefId)
        tes3mp.SendShapeshift(targetPid)

        if creatureRefId == "" then
            creatureRefId = "nothing"
        end

        tes3mp.SendMessage(pid, Players[targetPid].accountName .. " is now disguised as " ..
                               creatureRefId .. "\n", false)
        if targetPid ~= pid then
            tes3mp.SendMessage(targetPid, "You are now disguised as " .. creatureRefId .. "\n", false)
        end
    end
end
chatCommandHooks.registerCommand("setdisguise", defaultCommands.setDisguise)
chatCommandHooks.setRankRequirement("setdisguise", ranks.ADMIN)

function defaultCommands.setUseCreatureName(pid, cmd)
    if logicHandler.CheckPlayerValidity(pid, cmd[2]) then

        local targetPid = tonumber(cmd[2])
        local nameState

        if cmd[3] == "on" then
            nameState = true
        elseif cmd[3] == "off" then
            nameState = false
        else
            tes3mp.SendMessage(pid, "Not a valid argument. Use /usecreaturename <pid> on/off\n", false)
            return false
        end

        Players[targetPid].data.shapeshift.displayCreatureName = nameState
        tes3mp.SetCreatureNameDisplayState(targetPid, nameState)
        tes3mp.SendShapeshift(targetPid)
    end
end
chatCommandHooks.registerCommand("usecreaturename", defaultCommands.setUseCreatureName)
chatCommandHooks.setRankRequirement("usecreaturename", ranks.ADMIN)

function defaultCommands.setMomentum(pid, cmd)
    if logicHandler.CheckPlayerValidity(pid, cmd[2]) then

        local targetPid = tonumber(cmd[2])
        local xValue = tonumber(cmd[3])
        local yValue = tonumber(cmd[4])
        local zValue = tonumber(cmd[5])

        if type(xValue) == "number" and type(yValue) == "number" and
            type(zValue) == "number" then

            tes3mp.SetMomentum(targetPid, xValue, yValue, zValue)
            tes3mp.SendMomentum(targetPid)
        else
            tes3mp.SendMessage(pid, "Not a valid argument. Use /setmomentum <pid> <x> <y> <z>\n", false)
        end
    end
end
chatCommandHooks.registerCommand("setmomentum", defaultCommands.setMomentum)
chatCommandHooks.setRankRequirement("setmomentum", ranks.MODERATOR)

function defaultCommands.setDifficulty(pid, cmd)
    if logicHandler.CheckPlayerValidity(pid, cmd[2]) then

        local targetPid = tonumber(cmd[2])
        local difficulty = cmd[3]

        if type(tonumber(difficulty)) == "number" then
            difficulty = tonumber(difficulty)
        end

        if difficulty == "default" or type(difficulty) == "number" then
            Players[targetPid]:SetDifficulty(difficulty)
            Players[targetPid]:LoadSettings()
            tes3mp.SendMessage(pid, "Difficulty for " .. Players[targetPid].name .. " is now " ..
                difficulty .. "\n", true)
        else
            tes3mp.SendMessage(pid, "Not a valid argument. Use /setdifficulty <pid> <value>\n", false)
            return false
        end
    end
end
chatCommandHooks.registerCommand("setdifficulty", defaultCommands.setDifficulty)
chatCommandHooks.setRankRequirement("setdifficulty", ranks.MODERATOR)

function defaultCommands.setConsole(pid, cmd)
    if logicHandler.CheckPlayerValidity(pid, cmd[2]) then

        local targetPid = tonumber(cmd[2])
        local targetName = ""
        local state = ""

        if cmd[3] == "on" then
            Players[targetPid]:SetConsoleAllowed(true)
            state = " enabled.\n"
        elseif cmd[3] == "off" then
            Players[targetPid]:SetConsoleAllowed(false)
            state = " disabled.\n"
        elseif cmd[3] == "default" then
            Players[targetPid]:SetConsoleAllowed("default")
            state = " reset to default.\n"
        else
             tes3mp.SendMessage(pid, "Not a valid argument. Use /setconsole <pid> on/off/default\n", false)
             return false
        end

        Players[targetPid]:LoadSettings()
        tes3mp.SendMessage(pid, "Console for " .. Players[targetPid].name .. state, false)
        if targetPid ~= pid then
            tes3mp.SendMessage(targetPid, "Console" .. state, false)
        end
    end
end
chatCommandHooks.registerCommand("setconsole", defaultCommands.setConsole)
chatCommandHooks.setRankRequirement("setconsole", ranks.ADMIN)

function defaultCommands.setBedRest(pid, cmd)
    if logicHandler.CheckPlayerValidity(pid, cmd[2]) then

        local targetPid = tonumber(cmd[2])
        local targetName = ""
        local state = ""

        if cmd[3] == "on" then
            Players[targetPid]:SetBedRestAllowed(true)
            state = " enabled.\n"
        elseif cmd[3] == "off" then
            Players[targetPid]:SetBedRestAllowed(false)
            state = " disabled.\n"
        elseif cmd[3] == "default" then
            Players[targetPid]:SetBedRestAllowed("default")
            state = " reset to default.\n"
        else
             tes3mp.SendMessage(pid, "Not a valid argument. Use /setbedrest <pid> on/off/default\n", false)
             return false
        end

        Players[targetPid]:LoadSettings()
        tes3mp.SendMessage(pid, "Bed resting for " .. Players[targetPid].name .. state, false)
        if targetPid ~= pid then
            tes3mp.SendMessage(targetPid, "Bed resting" .. state, false)
        end
    end
end
chatCommandHooks.registerCommand("setbedrest", defaultCommands.setBedRest)
chatCommandHooks.setRankRequirement("setbedrest", ranks.ADMIN)

function defaultCommands.setWildernessRest(pid, cmd)
    if logicHandler.CheckPlayerValidity(pid, cmd[2]) then

        local targetPid = tonumber(cmd[2])
        local state = ""

        if cmd[3] == "on" then
            Players[targetPid]:SetWildernessRestAllowed(true)
            state = " enabled.\n"
        elseif cmd[3] == "off" then
            Players[targetPid]:SetWildernessRestAllowed(false)
            state = " disabled.\n"
        elseif cmd[3] == "default" then
            Players[targetPid]:SetWildernessRestAllowed("default")
            state = " reset to default.\n"
        else
             tes3mp.SendMessage(pid, "Not a valid argument. Use /setwildrest <pid> on/off/default\n", false)
             return false
        end

        Players[targetPid]:LoadSettings()
        tes3mp.SendMessage(pid, "Wilderness resting for " .. Players[targetPid].name .. state, false)
        if targetPid ~= pid then
            tes3mp.SendMessage(targetPid, "Wilderness resting" .. state, false)
        end
    end
end
chatCommandHooks.registerCommand("setwildernessrest", defaultCommands.setWildernessRest)
chatCommandHooks.setRankRequirement("setwildernessrest", ranks.ADMIN)

function defaultCommands.setWait(pid, cmd)
    if logicHandler.CheckPlayerValidity(pid, cmd[2]) then

        local targetPid = tonumber(cmd[2])
        local state = ""

        if cmd[3] == "on" then
            Players[targetPid]:SetWaitAllowed(true)
            state = " enabled.\n"
        elseif cmd[3] == "off" then
            Players[targetPid]:SetWaitAllowed(false)
            state = " disabled.\n"
        elseif cmd[3] == "default" then
            Players[targetPid]:SetWaitAllowed("default")
            state = " reset to default.\n"
        else
             tes3mp.SendMessage(pid, "Not a valid argument. Use /setwait <pid> on/off/default\n", false)
             return false
        end

        Players[targetPid]:LoadSettings()
        tes3mp.SendMessage(pid, "Waiting for " .. Players[targetPid].name .. state, false)
        if targetPid ~= pid then
            tes3mp.SendMessage(targetPid, "Waiting" .. state, false)
        end
    end
end
chatCommandHooks.registerCommand("setwait", defaultCommands.setWait)
chatCommandHooks.setRankRequirement("setwait", ranks.ADMIN)

function defaultCommands.setWait(pid, cmd)
    if logicHandler.CheckPlayerValidity(pid, cmd[2]) then

        local targetPid = tonumber(cmd[2])
        local physicsFramerate = cmd[3]

        if type(tonumber(physicsFramerate)) == "number" then
            physicsFramerate = tonumber(physicsFramerate)
        end

        if physicsFramerate == "default" or type(physicsFramerate) == "number" then
            Players[targetPid]:SetPhysicsFramerate(physicsFramerate)
            Players[targetPid]:LoadSettings()
            tes3mp.SendMessage(pid, "Physics framerate for " .. Players[targetPid].name
                .. " is now " .. physicsFramerate .. "\n", true)
        else
            tes3mp.SendMessage(pid, "Not a valid argument. Use /setphysicsfps <pid> <value>\n", false)
            return false
        end
    end
end
chatCommandHooks.registerCommand("setphysicsfps", defaultCommands.setWait)
chatCommandHooks.registerAlias("setphysicsframerate", "setphysicsfps")
chatCommandHooks.setRankRequirement("setphysicsfps", ranks.ADMIN)

function defaultCommands.setCollision(pid, cmd)
    local collisionState

    if cmd[2] ~= nil and cmd[3] == "on" then
        collisionState = true
    elseif cmd[2] ~= nil and cmd[3] == "off" then
        collisionState = false
    else
        tes3mp.SendMessage(pid, "Not a valid argument. Use /setcollision <category> on/off\n", false)
        return false
    end

    local categoryInput = string.upper(cmd[2])
    local categoryValue = enumerations.objectCategories[categoryInput]

    if categoryValue == enumerations.objectCategories.PLAYER then
        tes3mp.SetPlayerCollisionState(collisionState)
    elseif categoryValue == enumerations.objectCategories.ACTOR then
        tes3mp.SetActorCollisionState(collisionState)
    elseif categoryValue == enumerations.objectCategories.PLACED_OBJECT then
        tes3mp.SetPlacedObjectCollisionState(collisionState)

        if cmd[4] == "on" then
            tes3mp.UseActorCollisionForPlacedObjects(true)
        elseif cmd[4] == "off" then
            tes3mp.UseActorCollisionForPlacedObjects(false)
        end
    else
        tes3mp.SendMessage(pid, categoryInput .. " is not a valid object category. Valid choices are " ..
                               tableHelper.concatenateTableIndexes(enumerations.objectCategories, ", ") .. "\n", false)
        return false
    end

    tes3mp.SendWorldCollisionOverride(pid, true)
    tes3mp.SendMessage(pid, "Collision for " .. categoryInput .. " is now " .. cmd[3] ..
                       " for all newly loaded cells.\n", false)
end
chatCommandHooks.registerCommand("setcollision", defaultCommands.setCollision)
chatCommandHooks.setRankRequirement("setcollision", ranks.ADMIN)

function defaultCommands.overrideCollision(pid, cmd)
    local collisionState
    local refId = cmd[2]

    if refId ~= nil and cmd[3] == "on" then
        collisionState = true
    elseif refId ~= nil and cmd[3] == "off" then
        collisionState = false
    else
        Players[pid]:Message("Use /addcollision <refId> on/off\n")
        return false
    end

    local message = "A collision-enabling override "

    if tableHelper.containsValue(config.enforcedCollisionRefIds, refId) then
        if collisionState then
            message = message .. "is already on"
        else
            tableHelper.removeValue(config.enforcedCollisionRefIds, refId)
            message = message .. "is now off"
        end
    else
        if collisionState then
            table.insert(config.enforcedCollisionRefIds, refId)
            message = message .. "is now on"
        else
            message = message .. "is already off"
        end
    end

    logicHandler.SendConfigCollisionOverrides(pid, true)
    Players[pid]:Message(message .. " for " .. refId .. " in newly loaded cells\n")
end
chatCommandHooks.registerCommand("overridecollision", defaultCommands.overrideCollision)
chatCommandHooks.setRankRequirement("overridecollision", ranks.ADMIN)


function defaultCommands.load(pid, cmd)
    local scriptName = cmd[2]

    if scriptName == nil then
        Players[pid]:Message("Use /load <scriptName>\n")
    else
        local wasLoaded = false

        if package.loaded[scriptName] then
            Players[pid]:Message(scriptName .. " was already loaded, so it is being reloaded.\n")
            wasLoaded = true
        end

        local result

        if wasLoaded then

            -- Local objects that use functions from the script we are reloading
            -- will keep their references to the old versions of those functions if
            -- we do this:
            --
            -- package.loaded[scriptName] = nil
            -- require(scriptName)
            --
            -- To get around that, we load up the script with dofile() instead and
            -- then update the function references in package.loaded[scriptName], which
            -- in turn also changes them in the local objects
            --
            local scriptPath = package.searchpath(scriptName, package.path)
            result = dofile(scriptPath)

            for key, value in pairs(package.loaded[scriptName]) do
                if result[key] == nil then
                    package.loaded[scriptName][key] = nil
                end
            end

            for key, value in pairs(result) do
                package.loaded[scriptName][key] = value
            end
        else
            result = prequire(scriptName)
        end

        if result then
            Players[pid]:Message(scriptName .. " was successfully loaded.\n")
        else
            Players[pid]:Message(scriptName .. " could not be found.\n")
        end
    end
end
chatCommandHooks.registerCommand("load", defaultCommands.load)
chatCommandHooks.setRankRequirement("load", ranks.ADMIN)

function defaultCommands.resetKills(pid, cmd)
    -- Set all currently recorded kills to 0 for connected players
    for refId, killCount in pairs(WorldInstance.data.kills) do
        WorldInstance.data.kills[refId] = 0
    end

    WorldInstance:QuicksaveToDrive()
    WorldInstance:LoadKills(pid, true)
    tes3mp.SendMessage(pid, "All the kill counts for creatures and NPCs have been reset.\n", true)
end
chatCommandHooks.registerCommand("resetkills", defaultCommands.resetKills)
chatCommandHooks.setRankRequirement("resetkills", ranks.MODERATOR)

function defaultCommands.suicide(pid, cmd)
    if config.allowSuicideCommand == true then
        tes3mp.SetHealthCurrent(pid, 0)
        tes3mp.SendStatsDynamic(pid)
    else
        tes3mp.SendMessage(pid, "That command is disabled on this server.\n", false)
    end
end
chatCommandHooks.registerCommand("suicide", defaultCommands.suicide)

function defaultCommands.fixme(pid, cmd)
    if config.allowFixmeCommand == true then
        local currentTime = os.time()

        if not tes3mp.IsInExterior(pid) then
            local message = "Sorry! You can only use " .. color.Yellow .. "/fixme" ..
                color.White .. " in exteriors.\n"
            tes3mp.SendMessage(pid, message, false)
        elseif Players[pid].data.customVariables.lastFixMe == nil or
        currentTime >= Players[pid].data.customVariables.lastFixMe + config.fixmeInterval then

            logicHandler.RunConsoleCommandOnPlayer(pid, "fixme")
            Players[pid].data.customVariables.lastFixMe = currentTime
            tes3mp.SendMessage(pid, "You have fixed your position!\n", false)
        else
            local remainingSeconds = Players[pid].data.customVariables.lastFixMe +
                config.fixmeInterval - currentTime
            local message = "Sorry! You can't use " .. color.Yellow .. "/fixme" ..
            color.White .. " for another "

            if remainingSeconds > 1 then
                message = message .. color.Yellow .. remainingSeconds .. color.White .. " seconds"
            else
                message = message .. " second"
            end

            message = message .. "\n"
            tes3mp.SendMessage(pid, message, false)
        end
    else
        tes3mp.SendMessage(pid, "That command is disabled on this server.\n", false)
    end
end
chatCommandHooks.registerCommand("fixme", defaultCommands.fixme)

function defaultCommands.storeConsole(pid, cmd)
    if #cmd < 3 then
        commandError(pid, "/storeconsole <pid> \"cmdName\"")
        return
    end
    if logicHandler.CheckPlayerValidity(pid, cmd[2]) then

        local targetPid = tonumber(cmd[2])
        Players[targetPid].storedConsoleCommand = tableHelper.concatenateFromIndex(cmd, 3)

        tes3mp.SendMessage(pid, "That console command is now stored for player " .. targetPid .. "\n", false)
    end
end
chatCommandHooks.registerCommand("storeconsole", defaultCommands.storeConsole)
chatCommandHooks.setRankRequirement("storeconsole", ranks.ADMIN)

function defaultCommands.runConsole(pid, cmd)
    if #cmd < 4 then
        commandError(pid, "/runconsole <pid> \"cmdName\" <interval>")
        return
    end
    if logicHandler.CheckPlayerValidity(pid, cmd[2]) then

        local targetPid = tonumber(cmd[2])

        if Players[targetPid].storedConsoleCommand == nil then
            tes3mp.SendMessage(pid, "There is no console command stored for player " .. targetPid ..
                                   ". Please run /storeconsole on them first.\n", false)
        else
            local consoleCommand = Players[targetPid].storedConsoleCommand
            logicHandler.RunConsoleCommandOnPlayer(targetPid, consoleCommand)

            local count = tonumber(cmd[3])

            if count ~= nil and count > 1 then

                count = count - 1
                local interval = 1

                if tonumber(cmd[4]) ~= nil and tonumber(cmd[4]) > 1 then
                    interval = tonumber(cmd[4])
                end

                local loopIndex = tableHelper.getUnusedNumericalIndex(ObjectLoops)
                local timerId = tes3mp.CreateTimerEx("OnObjectLoopTimeExpiration", interval, "i", loopIndex)

                ObjectLoops[loopIndex] = {
                    packetType = "console",
                    timerId = timerId,
                    interval = interval,
                    count = count,
                    targetPid = targetPid,
                    targetName = Players[targetPid].accountName,
                    consoleCommand = consoleCommand
                }

                tes3mp.StartTimer(timerId)
            end
        end
    end
end
chatCommandHooks.registerCommand("runconsole", defaultCommands.runConsole)
chatCommandHooks.setRankRequirement("runconsole", ranks.ADMIN)

function defaultCommands.placeAt(pid, cmd)
    if #cmd < 2 then
        commandError(pid, "/placeat <pid> \"refId\"")
        return
    end
    if logicHandler.CheckPlayerValidity(pid, cmd[2]) then

        local targetPid = tonumber(cmd[2])
        local refId = tableHelper.concatenateFromIndex(cmd, 3)
        local packetType

        if cmd[1] == "placeat" then
            packetType = "place"
        elseif cmd[1] == "spawnat" then
            packetType = "spawn"
        end

        logicHandler.CreateObjectAtPlayer(targetPid, refId, packetType)
    end
end
chatCommandHooks.registerCommand("placeat", defaultCommands.placeAt)
chatCommandHooks.registerAlias("spawnat", "placeat")
chatCommandHooks.setRankRequirement("placeat", ranks.ADMIN)

function defaultCommands.anim(pid, cmd)
    local isValid = animHelper.PlayAnimation(pid, cmd[2])

    if not isValid then
        local validList = animHelper.GetValidList(pid)
        tes3mp.SendMessage(pid, "That is not a valid animation. Try one of the following:\n" ..
                               validList .. "\n", false)
    end
end
chatCommandHooks.registerCommand("anim", defaultCommands.anim)
chatCommandHooks.registerAlias("a", "anim")

function defaultCommands.speech(pid, cmd)
    local isValid = false

    if cmd[2] ~= nil and cmd[3] ~= nil and type(tonumber(cmd[3])) == "number" then
        isValid = speechHelper.PlaySpeech(pid, cmd[2], tonumber(cmd[3]))
    end

    if not isValid then
        local validList = speechHelper.GetPrintableValidListForPid(pid)
        tes3mp.SendMessage(pid, "That is not a valid speech. Try one of the following:\n"
                               .. validList .. "\n", false)
    end
end
chatCommandHooks.registerCommand("speech", defaultCommands.speech)
chatCommandHooks.registerAlias("s", "speech")

function defaultCommands.craft(pid, cmd)
    -- Check "scripts/menu/defaultCrafting.lua" if you want to change the example craft menu
    Players[pid].currentCustomMenu = "default crafting origin"
    menuHelper.DisplayMenu(pid, Players[pid].currentCustomMenu)
end
chatCommandHooks.registerCommand("craft", defaultCommands.craft)

--
-- World editing
--

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
chatCommandHooks.registerCommand("overridedestination", defaultCommands.overrideDestination)
chatCommandHooks.setRankRequirement("overridedestination", ranks.MODERATOR)


function defaultCommands.setAuthority(pid, cmd)
    if #cmd ~= 3 then
        commandError(pid, "/setauthority <pid> \"cellDescription\"")
        return
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
chatCommandHooks.registerCommand("setauthority", defaultCommands.setAuthority)
chatCommandHooks.registerAlias("setauth", "setauthority")
chatCommandHooks.setRankRequirement("setauthority", ranks.MODERATOR)

function defaultCommands.setHour(pid, cmd)
    local inputValue = tonumber(cmd[2])

    if type(inputValue) == "number" then

        if inputValue == 24 then
            inputValue = 0
        end

        if inputValue >= 0 and inputValue < 24 then
            WorldInstance.data.time.hour = inputValue
            WorldInstance:QuicksaveToDrive()
            WorldInstance:LoadTime(pid, true)
            hourCounter = inputValue
        else
            tes3mp.SendMessage(pid, "There aren't that many hours in a day.\n", false)
        end
    end
end
chatCommandHooks.registerCommand("sethour", defaultCommands.setHour)
chatCommandHooks.setRankRequirement("sethour", ranks.MODERATOR)

function defaultCommands.setDay(pid, cmd)
    local inputValue = tonumber(cmd[2])

    if type(inputValue) == "number" then

        local daysInMonth = WorldInstance.monthLengths[WorldInstance.data.time.month]

        if inputValue <= daysInMonth then
            WorldInstance.data.time.day = inputValue
            WorldInstance:QuicksaveToDrive()
            WorldInstance:LoadTime(pid, true)
        else
            tes3mp.SendMessage(pid, "There are only " .. daysInMonth .. " days in the current month.\n", false)
        end
    end
end
chatCommandHooks.registerCommand("setday", defaultCommands.setDay)
chatCommandHooks.setRankRequirement("setday", ranks.MODERATOR)

function defaultCommands.setMonth(pid, cmd)
    local inputValue = tonumber(cmd[2])

    if type(inputValue) == "number" then
        WorldInstance.data.time.month = inputValue
        WorldInstance:QuicksaveToDrive()
        WorldInstance:LoadTime(pid, true)
    end
end
chatCommandHooks.registerCommand("setmonth", defaultCommands.setMonth)
chatCommandHooks.setRankRequirement("setmonth", ranks.MODERATOR)

function defaultCommands.setTimeScale(pid, cmd)
    local inputPeriod = string.lower(tostring(cmd[2]))
    local inputValue = tonumber(cmd[3])

    if tableHelper.containsValue({"day", "night", "both"}, inputPeriod) and type(inputValue) == "number" then

        if inputPeriod == "day" or inputPeriod == "both" then
            WorldInstance.data.time.dayTimeScale = inputValue
        end

        if inputPeriod == "night" or inputPeriod == "both" then
            WorldInstance.data.time.nightTimeScale = inputValue
        end

        WorldInstance:QuicksaveToDrive()
        WorldInstance:UpdateFrametimeMultiplier()
        WorldInstance:LoadTime(pid, true)
    else
        tes3mp.SendMessage(pid, "Invalid input! Please use /settimescale day/night/both <value>\n", false)
    end
end
chatCommandHooks.registerCommand("settimescale", defaultCommands.setTimeScale)
chatCommandHooks.setRankRequirement("settimescale", ranks.MODERATOR)

function defaultCommands.setAi(pid, cmd)
    if #cmd ~= 6 then
        commandError(pid, "/setai <uniqueIndex> <actionInput> <posX> <posY> <posZ>")
        return
    end
    local actionInput = cmd[3]
    local actionNumericalId

    -- Allow both numerical and string input for actions (i.e. 1 or COMBAT), but
    -- convert the latter into the former
    if type(tonumber(actionInput)) == "number" then
        actionNumericalId = tonumber(actionInput)
    else
        actionNumericalId = enumerations.ai[string.upper(actionInput)]
    end

    if actionNumericalId == nil then

        Players[pid]:Message(actionInput .. " is not a valid AI action. Valid choices are " ..
                                 tableHelper.concatenateTableIndexes(enumerations.ai, ", ") .. "\n")
    else

        local uniqueIndex = cmd[2]
        local cell = logicHandler.GetCellContainingActor(uniqueIndex)

        if cell == nil then

            Players[pid]:Message("Could not find actor " .. uniqueIndex .. " in any loaded cell\n")
        else

            local actionName = tableHelper.getIndexByValue(enumerations.ai, actionNumericalId)
            local messageAction = enumerations.aiPrintableAction[actionName]
            local message = uniqueIndex .. " is now " .. messageAction

            if actionNumericalId == enumerations.ai.CANCEL then

                logicHandler.SetAIForActor(cell, uniqueIndex, actionNumericalId)
                Players[pid]:Message(message .. "\n")

            elseif actionNumericalId == enumerations.ai.TRAVEL then

                local posX, posY, posZ = tonumber(cmd[4]), tonumber(cmd[5]), tonumber(cmd[6])

                if type(posX) == "number" and type(posY) == "number" and type(posZ) == "number" then

                    logicHandler.SetAIForActor(cell, uniqueIndex, actionNumericalId, nil, nil, posX, posY, posZ)
                    Players[pid]:Message(message .. " " .. posX .. " " .. posY .. " " .. posZ .. "\n")
                else
                    Players[pid]:Message("Invalid travel coordinates! " ..
                                             "Use /setai <uniqueIndex> travel <x> <y> <z>\n")
                end

            elseif actionNumericalId == enumerations.ai.WANDER then

                local distance, duration = tonumber(cmd[4]), tonumber(cmd[5])

                if type(distance) == "number" and type(duration) == "number" then

                    if cmd[6] == "true" then
                        shouldRepeat = true
                    else
                        shouldRepeat = false
                    end

                    logicHandler.SetAIForActor(cell, uniqueIndex, actionNumericalId, nil, nil, nil, nil, nil,
                                               distance, duration, shouldRepeat)
                    Players[pid]:Message(message .. " a distance of " .. distance .. " for a duration of " ..
                                             duration .. "\n")
                else
                    Players[pid]:Message("Invalid wander parameters! " ..
                                             "Use /setai <uniqueIndex> wander <distance> <duration> true/false\n")
                end

            elseif cmd[4] ~= nil then

                local target = cmd[4]
                local hasPlayerTarget = false

                if type(tonumber(target)) == "number" and logicHandler.CheckPlayerValidity(pid, target) then
                    target = tonumber(target)
                    hasPlayerTarget = true
                end

                if hasPlayerTarget then
                    logicHandler.SetAIForActor(cell, uniqueIndex, actionNumericalId, target)
                    message = message .. " player " .. Players[target].name
                else
                    logicHandler.SetAIForActor(cell, uniqueIndex, actionNumericalId, nil, target)
                    message = message .. " actor " .. target
                end

                Players[pid]:Message(message .. "\n")
            else

                Players[pid]:Message("Invalid AI action!\n")
            end
        end
    end
end
chatCommandHooks.registerCommand("setai", defaultCommands.setAi)
chatCommandHooks.setRankRequirement("setai", ranks.ADMIN)

--
-- Testing
--

function defaultCommands.setRace(pid, cmd)
    if logicHandler.CheckPlayerValidity(pid, cmd[2]) then

        local targetPid = tonumber(cmd[2])
        local newRace = cmd[3]

        Players[targetPid].data.character.race = newRace
        tes3mp.SetRace(targetPid, newRace)
        tes3mp.SetResetStats(targetPid, false)
        tes3mp.SendBaseInfo(targetPid)
    end
end
chatCommandHooks.registerCommand("setrace", defaultCommands.setRace)
chatCommandHooks.setRankRequirement("setrace", ranks.ADMIN)

function defaultCommands.setHead(pid, cmd)
    if logicHandler.CheckPlayerValidity(pid, cmd[2]) then

        local targetPid = tonumber(cmd[2])
        local newHead = cmd[3]

        Players[targetPid].data.character.head = newHead
        tes3mp.SetHead(targetPid, newHead)
        tes3mp.SetResetStats(targetPid, false)
        tes3mp.SendBaseInfo(targetPid)
    end
end
chatCommandHooks.registerCommand("sethead", defaultCommands.setHead)
chatCommandHooks.setRankRequirement("sethead", ranks.ADMIN)

function defaultCommands.setHair(pid, cmd)
    if logicHandler.CheckPlayerValidity(pid, cmd[2]) then

        local targetPid = tonumber(cmd[2])
        local newHair = cmd[3]

        Players[targetPid].data.character.hair = newHair
        tes3mp.SetHair(targetPid, newHair)
        tes3mp.SetResetStats(targetPid, false)
        tes3mp.SendBaseInfo(targetPid)
    end
end
chatCommandHooks.registerCommand("sethair", defaultCommands.setHair)
chatCommandHooks.setRankRequirement("sethair", ranks.ADMIN)

function defaultCommands.getPos(pid, cmd)
    logicHandler.PrintPlayerPosition(pid, cmd[2])
end
chatCommandHooks.registerCommand("getpos", defaultCommands.getPos)
chatCommandHooks.setRankRequirement("getpos", ranks.ADMIN)

function defaultCommands.advancedExample(pid)
    -- Check "scripts/menu/advancedExample.lua" if you want to change the advanced menu example
    Players[pid].currentCustomMenu = "advanced example origin"
    menuHelper.DisplayMenu(pid, Players[pid].currentCustomMenu)
end
chatCommandHooks.registerCommand("advancedexample", defaultCommands.advancedExample)
chatCommandHooks.registerAlias("advex", "advancedexample")
chatCommandHooks.setRankRequirement("advancedexample", ranks.MODERATOR)

--
-- Helpers
--

function defaultCommands.storeRecord(pid, cmd)
    if #cmd < 2 then
        commandError(pid, 'Invalid inputs! TODO"')
        return
    end
    if Players[pid].data.customVariables == nil then
        Players[pid].data.customVariables = {}
    end

    if Players[pid].data.customVariables.storedRecords == nil then
        Players[pid].data.customVariables.storedRecords = {}
    end

    local inputType = string.lower(cmd[2])

    if config.validRecordSettings[inputType] == nil then
        Players[pid]:Message("Record type " .. inputType .. " is invalid. Please use one of the following " ..
            "valid types instead: " .. tableHelper.concatenateTableIndexes(config.validRecordSettings, ", ") .. "\n")
        return
    else
        if Players[pid].data.customVariables.storedRecords[inputType] == nil then
            Players[pid].data.customVariables.storedRecords[inputType] = {}
        end
    end

    local storedTable = Players[pid].data.customVariables.storedRecords[inputType]
    local inputSetting = cmd[3]

    if inputSetting == "clear" then
        Players[pid].data.customVariables.storedRecords[inputType] = {}
        Players[pid]:Message("Clearing stored " .. inputType .. " data\n")
    elseif inputSetting == "print" then
        local text = "for a record of type " .. inputType

        if tableHelper.isEmpty(storedTable) then
            text = "You have no values stored " .. text .. "."
        else
            text = "You have the current values stored " .. text .. ":\n\n"

            for index, value in pairs(storedTable) do
                text = text .. index .. ": "

                if type(value) == "table" then
                    text = text .. tableHelper.getSimplePrintableTable(value)
                else
                    text = text .. value
                end

                text = text .. "\n"
            end
        end

        tes3mp.CustomMessageBox(pid, config.customMenuIds.recordPrint, text, "Ok")
    elseif inputSetting ~= nil then

        if inputSetting == "add" then
            local inputAdditionType = cmd[4]
            local inputConcatenation
            local inputValues

            if inputAdditionType == nil or cmd[5] == nil then
                Players[pid]:Message("Please provide the minimum number of arguments required.\n")
                return
            else
                inputConcatenation = tableHelper.concatenateFromIndex(cmd, 5)
                inputValues = tableHelper.getTableFromCommaSplit(inputConcatenation)
            end

            if inputAdditionType == "effect" and (inputType == "spell" or inputType == "potion"
                or inputType == "enchantment" or inputType == "ingredient") then

                if inputType == "ingredient" and type(storedTable.effects) == "table"
                    and tableHelper.getCount(storedTable.effects) == 4 then
                    Players[pid]:Message("You have already reached the cap of 4 effects on an ingredient record.\n")
                else
                    if storedTable.effects == nil then
                        storedTable.effects = {}
                    end

                    local inputEffectId = inputValues[1]

                    if type(tonumber(inputEffectId)) == "number" then

                        local effect = { id = tonumber(inputEffectId), rangeType = tonumber(inputValues[2]),
                            duration = tonumber(inputValues[3]), area = tonumber(inputValues[4]),
                            magnitudeMin = tonumber(inputValues[5]), magnitudeMax = tonumber(inputValues[6]),
                            attribute = tonumber(inputValues[7]), skill = tonumber(inputValues[8]) }
                        table.insert(storedTable.effects, effect)
                        Players[pid]:Message("Added effect " .. inputConcatenation .. "\n")
                    else
                        Players[pid]:Message("Please use a numerical value for the effect ID.\n")
                    end
                end
            elseif inputAdditionType == "part" and (inputType == "armor" or inputType == "clothing") then

                if storedTable.parts == nil then
                    storedTable.parts = {}
                end

                local inputPartType = inputValues[1]

                if type(tonumber(inputPartType)) == "number" then

                    local part = { partType = tonumber(inputPartType), malePart = inputValues[2],
                        femalePart = inputValues[3] }
                    table.insert(storedTable.parts, part)
                    Players[pid]:Message("Added part " .. inputConcatenation .. "\n")
                else
                    Players[pid]:Message("Please use a numerical value for the part type.\n")
                end
            elseif inputAdditionType == "item" and tableHelper.containsValue({"creature", "npc", "container"}, inputType) then

                if storedTable.items == nil then
                    storedTable.items = {}
                end

                local inputItemId = inputValues[1]
                local inputItemCount = tonumber(inputValues[2])

                if type(inputItemCount) ~= "number" then
                    inputItemCount = 1
                end

                local item = { id = inputItemId, count = inputItemCount }
                table.insert(storedTable.items, item)
                Players[pid]:Message("Added item " .. inputItemId .. " with count " .. inputItemCount .. "\n")
            else
                Players[pid]:Message(tostring(inputAdditionType) .. " is not a valid addition type for " ..
                    inputType .. " records.\n")
            end

        elseif tableHelper.containsValue(config.validRecordSettings[inputType], inputSetting) then

            local inputValue = tableHelper.concatenateFromIndex(cmd, 4)

            -- Although numerical values are accepted for gender, allow "male" and "female" input
            -- as well
            if inputSetting == "gender" and type(tonumber(inputValue)) ~= "number" then
                local gender

                if inputValue == "male" then
                    gender = 1
                elseif inputValue == "female" then
                    gender = 0
                end

                if type(gender) == "number" then
                    storedTable.gender = gender
                else
                    Players[pid]:Message("Please use either 0/1 or female/male as the gender input.\n")
                    return
                end
            elseif tableHelper.containsValue(config.numericalRecordSettings, inputSetting) then
                inputValue = tonumber(inputValue)

                if type(inputValue) == "number" then
                    storedTable[inputSetting] = inputValue
                else
                    Players[pid]:Message("Please use a valid numerical value as the input for " ..
                        inputSetting .. "\n")
                    return
                end
            elseif tableHelper.containsValue(config.minMaxRecordSettings, inputSetting) then
                local minValue = tonumber(cmd[4])
                local maxValue = tonumber(cmd[5])

                if type(minValue) == "number" and type(maxValue) == "number"  then
                    storedTable[inputSetting] = { min = minValue, max = maxValue }
                else
                    Players[pid]:Message("Please use two valid numerical values as the input for " ..
                        inputSetting .. "\n")
                    return
                end
            elseif tableHelper.containsValue(config.rgbRecordSettings, inputSetting) then
                local redValue = tonumber(cmd[4])
                local greenValue = tonumber(cmd[5])
                local blueValue = tonumber(cmd[6])

                if type(redValue) == "number" and type(greenValue) == "number" and type(blueValue) == "number" and
                    redValue > -1 and redValue < 256 and greenValue > -1 and greenValue < 256 and
                    blueValue > -1 and blueValue < 256 then
                    storedTable[inputSetting] = { red = redValue, green = greenValue, blue = blueValue }
                else
                    Players[pid]:Message("Please use three valid numerical values between 0 and 255 as the input for " ..
                        inputSetting .. "\n")
                    return
                end
            elseif tableHelper.containsValue(config.booleanRecordSettings, inputSetting) then
                if inputValue == "true" or inputValue == "on" or tonumber(inputValue) == 1 then
                    storedTable[inputSetting] = true
                elseif inputValue == "false" or inputValue == "off" or tonumber(inputValue) == 0 then
                    storedTable[inputSetting] = false
                else
                    Players[pid]:Message("Please use a valid boolean as the input for " .. inputSetting .. "\n")
                    return
                end
            else
                storedTable[inputSetting] = inputValue
            end

            local message = "Storing " .. inputType .. " " .. inputSetting .. " with value " .. inputValue .. "\n"
            Players[pid]:Message(message)
        else
            local validSettingsArray = config.validRecordSettings[inputType]
            Players[pid]:Message(inputSetting .. " is not a valid setting for " .. inputType .. " records. " ..
                "Try one of these:\n" .. tableHelper.concatenateArrayValues(validSettingsArray, 1, ", ") .. "\n")
        end
    end
end
chatCommandHooks.registerCommand("storerecord", defaultCommands.storeRecord)
chatCommandHooks.setRankRequirement("storerecord", ranks.ADMIN)

function defaultCommands.createRecord(pid, cmd)
    if Players[pid].data.customVariables == nil then
        Players[pid].data.customVariables = {}
    end

    if Players[pid].data.customVariables.storedRecords == nil then
        Players[pid].data.customVariables.storedRecords = {}
    end

    if tableHelper.getCount(cmd) > 2 then
        Players[pid]:Message("This command does not take more than 1 argument. Did you mean to use " ..
                                 "/storerecord instead?\n")
        return
    end

    local inputType = string.lower(cmd[2])

    if config.validRecordSettings[inputType] == nil then
        Players[pid]:Message("Record type " .. inputType .. " is invalid. Please use one of the following " ..
                                 "valid types instead: " .. tableHelper.concatenateTableIndexes(config.validRecordSettings, ", ") .. "\n")
        return
    else
        if Players[pid].data.customVariables.storedRecords[inputType] == nil then
            Players[pid].data.customVariables.storedRecords[inputType] = {}
        end
    end

    local storedTable = Players[pid].data.customVariables.storedRecords[inputType]

    if storedTable.baseId == nil then
        if inputType == "creature" then
            Players[pid]:Message("As of now, you cannot create creatures from scratch because of how many " ..
                                 "different settings need to be implemented for them. Please use a baseId for your creature " ..
                                     "instead.\n")
            return
        end

        local missingSettings = {}

        for _, requiredSetting in pairs(config.requiredRecordSettings[inputType]) do
            if storedTable[requiredSetting] == nil then
                table.insert(missingSettings, requiredSetting)
            end
        end

        if not tableHelper.isEmpty(missingSettings) then
            Players[pid]:Message("You cannot create a record of type " .. inputType .. " because it is missing the " ..
                                     "following required settings: " .. tableHelper.concatenateArrayValues(missingSettings, 1, ", ") .. "\n")
            return
        end
    end

    if inputType == "enchantment" and (storedTable.effects == nil or tableHelper.isEmpty(storedTable.effects)) then
        Players[pid]:Message("Records of type " .. inputType .. " require at least 1 effect.\n")
        return
    end

    local id = storedTable.id
    local isGenerated = id == nil or logicHandler.IsGeneratedRecord(id)

    local enchantmentStore
    local hasGeneratedEnchantment = tableHelper.containsValue(config.enchantableRecordTypes, inputType) and
        storedTable.enchantmentId ~= nil and logicHandler.IsGeneratedRecord(storedTable.enchantmentId)

    if hasGeneratedEnchantment then
        -- Ensure the generated enchantment used by this record actually exists
        if isGenerated then
            enchantmentStore = RecordStores["enchantment"]

            if enchantmentStore.data.generatedRecords[storedTable.enchantmentId] == nil then
                Players[pid]:Message("The generated enchantment record (" .. storedTable.enchantmentId ..
                                     ") you are trying to use for this " .. inputType .. " record does not exist.\n")
                return
            end
            -- Permanent records should only use other permanent records as enchantments, so
            -- go no further if that is not the case
        else
            Players[pid]:Message("You cannot use a generated enchantment record (" .. storedTable.enchantmentId ..
                                     ") with a permanent record (" .. id .. ").\n")
            return
        end
    end

    local recordStore = RecordStores[inputType]

    if id == nil then
        id = recordStore:GenerateRecordId()
        isGenerated = true
    end

    -- We don't want to insert a direct reference to the storedTable in our record data,
    -- so create a copy of the storedTable and insert that instead
    local savedTable = tableHelper.shallowCopy(storedTable)

    -- The id and the savedTable will form a key-value pair, so there's no need to keep
    -- the id in the savedTable as well
    savedTable.id = nil

    -- Use an autoCalc of 1 by default for entirely new NPCs to avoid spawning them
    -- without any stats
    if inputType == "npc" and savedTable.baseId == nil and savedTable.autoCalc == nil then
        savedTable.autoCalc = 1
        Players[pid]:Message("autoCalc is defaulting to 1 for this record.\n")
    end

    -- Use a skillId of -1 by default for entirely new books to avoid having them
    -- increase a skill
    if inputType == "book" and savedTable.skillId == nil then
        savedTable.skillId = -1
        Players[pid]:Message("skillId is defaulting to -1 for this record.\n")
    end

    local message = "Your record has now been saved as a "

    if isGenerated then
        message = message .. "generated record that will be deleted when no longer used.\n"
        recordStore.data.generatedRecords[id] = savedTable

        -- This record will be sent to everyone on the server below, so track it
        -- as having already been received by players
        for _, player in pairs(Players) do
            if not tableHelper.containsValue(Players[pid].generatedRecordsReceived, id) then
                table.insert(player.generatedRecordsReceived, id)
            end
        end

        -- Is this an enchantable record using an enchantment from a generated record?
        -- If so, add a link to this record for that enchantment record
        if hasGeneratedEnchantment then
            enchantmentStore:AddLinkToRecord(savedTable.enchantmentId, id, inputType)
            enchantmentStore:QuicksaveToDrive()
        end
    else
        message = message .. "permanent record that you'll have to remove manually when you no longer need it.\n"
        recordStore.data.permanentRecords[id] = savedTable
    end

    recordStore:QuicksaveToDrive()

    tes3mp.ClearRecords()
    tes3mp.SetRecordType(enumerations.recordType[string.upper(inputType)])

    if inputType == "activator" then packetBuilder.AddActivatorRecord(id, savedTable)
    elseif inputType == "apparatus" then packetBuilder.AddApparatusRecord(id, savedTable)
    elseif inputType == "armor" then packetBuilder.AddArmorRecord(id, savedTable)
    elseif inputType == "book" then packetBuilder.AddBookRecord(id, savedTable)
    elseif inputType == "bodypart" then packetBuilder.AddBodyPartRecord(id, savedTable)
    elseif inputType == "cell" then packetBuilder.AddCellRecord(id, savedTable)
    elseif inputType == "clothing" then packetBuilder.AddClothingRecord(id, savedTable)
    elseif inputType == "container" then packetBuilder.AddContainerRecord(id, savedTable)
    elseif inputType == "creature" then packetBuilder.AddCreatureRecord(id, savedTable)
    elseif inputType == "door" then packetBuilder.AddDoorRecord(id, savedTable)
    elseif inputType == "enchantment" then packetBuilder.AddEnchantmentRecord(id, savedTable)
    elseif inputType == "ingredient" then packetBuilder.AddIngredientRecord(id, savedTable)
    elseif inputType == "light" then packetBuilder.AddLightRecord(id, savedTable)
    elseif inputType == "lockpick" then packetBuilder.AddLockpickRecord(id, savedTable)
    elseif inputType == "miscellaneous" then packetBuilder.AddMiscellaneousRecord(id, savedTable)
    elseif inputType == "npc" then packetBuilder.AddNpcRecord(id, savedTable)
    elseif inputType == "potion" then packetBuilder.AddPotionRecord(id, savedTable)
    elseif inputType == "probe" then packetBuilder.AddProbeRecord(id, savedTable)
    elseif inputType == "repair" then packetBuilder.AddRepairRecord(id, savedTable)
    elseif inputType == "script" then packetBuilder.AddScriptRecord(id, savedTable)
    elseif inputType == "spell" then packetBuilder.AddSpellRecord(id, savedTable)
    elseif inputType == "static" then packetBuilder.AddStaticRecord(id, savedTable)
    elseif inputType == "weapon" then packetBuilder.AddWeaponRecord(id, savedTable) end

    tes3mp.SendRecordDynamic(pid, true, false)

    if not tableHelper.containsValue({"spell", "cell", "script"}, inputType) then
        if inputType ~= "enchantment" then
            if inputType == "creature" or inputType == "npc" then
                message = message .. "You can spawn an instance of it using /spawnat "
            else
                message = message .. "You can place an instance of it using /placeat "
            end

            message = message .. "<pid> " .. id .. "\n"
        else
            message = message .. "To use it, create an armor, book, clothing or weapon record with an " ..
                "enchantmentId of " .. id .. "\n"
        end
    end

    Players[pid]:Message(message)
end
chatCommandHooks.registerCommand("createrecord", defaultCommands.createRecord)
chatCommandHooks.setRankRequirement("createrecord", ranks.ADMIN)

return defaultCommands
