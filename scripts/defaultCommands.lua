local defaultCommands = {}

local ranks = {
    MODERATOR = 1,
    ADMIN = 2,
    OWNER = 3
}

local function commandError(pid, text)
    tes3mp.SendMessage(pid, color.Error .. message .. color.Default .. "\n")
end

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
        tes3mp.SendMessage(pid, message, false)
        tes3mp.SendMessage(targetPid, message, false)
    end
end

customCommandHooks.registerCommand("message", defaultCommands.msg)
customCommandHooks.registerAlias("msg", "message")

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

--
-- Server status
--

defaultCommands.players = function(pid, cmd)
    guiHelper.ShowPlayerList(pid)
end
customCommandHooks.registerCommand("players", defaultCommands.players)
customCommandHooks.registerAlias("list", "players")

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
customCommandHooks.registerCommand("cells", defaultCommands.cells)
customCommandHooks.setRankRequirement("cells", ranks.MODERATOR)

defaultCommands.regions = function(pid, cmd)
    guiHelper.ShowRegionList(pid)
end
customCommandHooks.registerCommand("regions", defaultCommands.regions)
customCommandHooks.setRankRequirement("regions", ranks.MODERATOR)

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

--
-- Moderation
--

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
customCommandHooks.registerCommand("ipaddresses", defaultCommands.ipAddresses)
customCommandHooks.registerAlias("ips", "ipaddresses")
customCommandHooks.setRankRequirement("ipaddress", ranks.MODERATOR)

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
            tes3mp.SendMessage(pid, message, true)
            Players[targetPid].data.settings.staffRank = 0
            Players[targetPid]:QuicksaveToDrive()
        else
            message = targetName .. " is not a Moderator.\n"
            commandError(pid, message)
        end
    end
end
customCommandHooks.registerCommand("removemoderator", defaultCommands.removeModerator)
customCommandHooks.setRankRequirement("removemoderator", ranks.ADMIN)

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
customCommandHooks.registerCommand("removemoderator", defaultCommands.addModerator)
customCommandHooks.setRankRequirement("removemoderator", ranks.ADMIN)

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
customCommandHooks.registerCommand("setattr", defaultCommands.setAttr)
customCommandHooks.setRankRequirement("setattr", ranks.MODERATOR)

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
customCommandHooks.registerCommand("setskill", defaultCommands.setSkill)
customCommandHooks.setRankRequirement("setskill", ranks.MODERATOR)

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
customCommandHooks.registerCommand("setmomentum", defaultCommands.setMomentum)
customCommandHooks.setRankRequirement("setmomentum", ranks.MODERATOR)

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
customCommandHooks.registerCommand("setdifficulty", defaultCommands.setDifficulty)
customCommandHooks.setRankRequirement("setdifficulty", ranks.MODERATOR)

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
customCommandHooks.registerCommand("setconsole", defaultCommands.setDifficulty)
customCommandHooks.setRankRequirement("setconsole", ranks.ADMIN)

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
customCommandHooks.registerCommand("setbedrest", defaultCommands.setBedRest)
customCommandHooks.setRankRequirement("setbedrest", ranks.ADMIN)

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
customCommandHooks.registerCommand("setwildernessrest", defaultCommands.setWildernessRest)
customCommandHooks.setRankRequirement("setwildernessrest", ranks.ADMIN)

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
customCommandHooks.registerCommand("setwait", defaultCommands.setWait)
customCommandHooks.setRankRequirement("setwait", ranks.ADMIN)

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
customCommandHooks.registerCommand("setphysicsfps", defaultCommands.setWait)
customCommandHooks.registerAlias("setphysicsframerate", "setphysicsfps")
customCommandHooks.setRankRequirement("setphysicsfps", ranks.ADMIN)

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
customCommandHooks.registerCommand("overridedestination", defaultCommands.overrideDestination)
customCommandHooks.setRankRequirement("overridedestination", ranks.MODERATOR)


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
customCommandHooks.registerCommand("setauthority", defaultCommands.setAuthority)
customCommandHooks.registerAlias("setauth", "setauthority")
customCommandHooks.setRankRequirement("setauthority", ranks.MODERATOR)

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
customCommandHooks.registerCommand("setrace", defaultCommands.setRace)
customCommandHooks.setRankRequirement("setrace", ranks.ADMIN)

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
customCommandHooks.registerCommand("sethead", defaultCommands.setHead)
customCommandHooks.setRankRequirement("sethead", ranks.ADMIN)

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
customCommandHooks.registerCommand("sethair", defaultCommands.setHair)
customCommandHooks.setRankRequirement("sethair", ranks.ADMIN)

function defaultCommands.getPos(pid, cmd)
    logicHandler.PrintPlayerPosition(pid, cmd[2])
end
customCommandHooks.registerCommand("getpos", defaultCommands.setHair)
customCommandHooks.setRankRequirement("getpos", ranks.ADMIN)

return defaultCommands
