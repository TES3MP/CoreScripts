require("config")
class = require("classy")
tableHelper = require("tableHelper")
require("utils")
require("guiIds")
require("color")
require("time")

myMod = require("myMod")
animHelper = require("animHelper")
speechHelper = require("speechHelper")
menuHelper = require("menuHelper")

Database = nil
Player = nil
Cell = nil
World = nil

banList = {}
pluginList = {}
timeCounter = config.timeServerInitTime

if (config.databaseType ~= nil and config.databaseType ~= "json") and doesModuleExist("luasql." .. config.databaseType) then

    Database = require("database")
    Database:LoadDriver(config.databaseType)

    tes3mp.LogMessage(1, "Using " .. Database.driver._VERSION .. " with " .. config.databaseType .. " driver")

    Database:Connect(config.databasePath)

    -- Make sure we enable foreign keys
    Database:Execute("PRAGMA foreign_keys = ON;")

    Database:CreatePlayerTables()
    Database:CreateWorldTables()

    Player = require("player.sql")
    Cell = require("cell.sql")
    World = require("world.sql")
else
    Player = require("player.json")
    Cell = require("cell.json")
    World = require("world.json")
end

local helptext = "\nCommand list:\
/message <pid> <text> - Send a private message to a player (/msg)\
/me <text> - Send a message written in the third person\
/local <text> - Send a message that only players in your area can read (/l)\
/list - List all players on the server\
/anim <animation> - Play an animation on yourself, with a list of valid inputs being provided if you use an invalid one (/a)\
/speech <type> <index> - Play a certain speech on yourself, with a list of valid inputs being provided if you use invalid ones (/s)\
/craft - Open up a small crafting menu used as a scripting example\
/help - Get the list of commands available to regular users\
/help moderator/admin - Get the list of commands available to moderators or admins, if you are one"

local modhelptext = "Moderators only:\
/kick <pid> - Kick player\
/ban ip <ip> - Ban an IP address\
/ban name <name> - Ban a player and all IP addresses stored for them\
/ban <pid> - Same as above, but using a pid as the argument\
/unban ip <ip> - Unban an IP address\
/unban name <name> - Unban a player name and all IP addresses stored for them\
/banlist ips/names - Print all banned IPs or all banned player names\
/ipaddresses <name> - Print all the IP addresses used by a player (/ips)\
/confiscate <pid> - Open up a window where you can confiscate an item from a player\
/time <value> - Set the server's time counter\
/teleport <pid>/all - Teleport another player to your position (/tp)\
/teleportto <pid> - Teleport yourself to another player (/tpto)\
/cells - List all loaded cells on the server\
/getpos <pid> - Get player position and cell\
/setattr <pid> <attribute> <value> - Set a player's attribute to a certain value\
/setskill <pid> <skill> <value> - Set a player's skill to a certain value\
/superman - Increase your acrobatics, athletics and speed\
/setauthority <pid> <cell> - Forcibly set a certain player as the authority of a cell (/setauth)"

local adminhelptext = "Admins only:\
/setrace <pid> <race> - Change a player's race\
/addmoderator <pid> - Promote player to moderator\
/removemoderator <pid> - Demote player from moderator\
/setdifficulty <pid> <value>/default - Set the difficulty for a particular player\
/setconsole <pid> on/off/default - Enable/disable in-game console for player\
/setbedrest <pid> on/off/default - Enable/disable bed resting for player\
/setwildrest <pid> on/off/default - Enable/disable wilderness resting for player\
/setwait <pid> on/off/default - Enable/disable waiting for player\
/setscale <pid> <value> - Sets a player's scale\
/setwerewolf <pid> on/off - Set the werewolf state of a particular player\
/storeconsole <pid> <command> - Store a certain console command for a player\
/runconsole <pid> (<count>) (<interval>) - Run a stored console command on a player, with optional count and interval\
/placeat <pid> <refId> (<count>) (<interval>) - Place a certain object at a player's location, with optional count and interval\
/spawnat <pid> <refId> (<count>) (<interval>) - Spawn a certain creature or NPC at a player's location, with optional count and interval\
/setloglevel <pid> <value>/default - Set the enforced log level for a particular player\
/setphysicsfps <pid> <value>/default - Set the physics framerate for a particular player"

-- Handle commands that only exist based on config options
if config.allowSuicideCommand == true then
    helptext = helptext .. "\n/suicide - Commit suicide"
end

function LoadBanList()
    tes3mp.LogMessage(2, "Reading banlist.json")
    banList = jsonInterface.load("banlist.json")

    if banList.playerNames == nil then
        banList.playerNames = {}
    elseif banList.ipAddresses == nil then
        banList.ipAddresses = {}
    end

    if #banList.ipAddresses > 0 then
        local message = "- Banning manually-added IP addresses:\n"

        for index, ipAddress in pairs(banList.ipAddresses) do
            message = message .. ipAddress

            if index < #banList.ipAddresses then
                message = message .. ", "
            end

            tes3mp.BanAddress(ipAddress)
        end

        tes3mp.LogAppend(2, message)
    end

    if #banList.playerNames > 0 then
        local message = "- Banning all IP addresses stored for players:\n"

        for index, targetName in pairs(banList.playerNames) do
            message = message .. targetName

            if index < #banList.playerNames then
                message = message .. ", "
            end

            local targetPlayer = myMod.GetPlayerByName(targetName)

            if targetPlayer ~= nil then

                for index, ipAddress in pairs(targetPlayer.data.ipAddresses) do
                    tes3mp.BanAddress(ipAddress)
                end
            end
        end

        tes3mp.LogAppend(2, message)
    end
end

function SaveBanList()
    jsonInterface.save("banlist.json", banList)
end

function LoadPluginList()
    tes3mp.LogMessage(2, "Reading pluginlist.json")

    local jsonPluginList = jsonInterface.load("pluginlist.json")

    -- Fix numerical keys to print plugins in the correct order
    tableHelper.fixNumericalKeys(jsonPluginList, true)

    for listIndex, pluginEntry in ipairs(jsonPluginList) do
        for entryIndex, hashArray in pairs(pluginEntry) do
            pluginList[listIndex] = {entryIndex}
            io.write(("%d, {%s"):format(listIndex, entryIndex))
            for _, hash in ipairs(hashArray) do
                io.write((", %X"):format(tonumber(hash, 16)))
                table.insert(pluginList[listIndex], tonumber(hash, 16))
            end
            table.insert(pluginList[listIndex], "")
            io.write("}\n")
        end
    end
end

do
    local tid_ut = tes3mp.CreateTimer("UpdateTime", time.seconds(1))
    function UpdateTime()
        local hour = 0
        if config.timeSyncMode == 1 then
            timeCounter = timeCounter + (0.0083 * config.timeServerMult)
            hour = timeCounter
        elseif config.timeSyncMode == 2 then
            -- ToDo: implement like this
            -- local pid = GetFirstPlayer()
            -- hour = tes3mp.GetHours(pid)
        end
        local day = hour/24
        hour = math.fmod(hour, 24)
        for pid,_ in pairs(Players) do
            tes3mp.SetHour(pid, hour)
            tes3mp.SetDay(pid, day)
        end

        tes3mp.RestartTimer(tid_ut, time.seconds(1));
    end
    if config.timeSyncMode ~= 0 then
        tes3mp.StartTimer(tid_ut);
    end
end

do
    local adminsCounter = 0
    function IncrementAdminCounter()
        adminsCounter = adminsCounter + 1
        tes3mp.SetRuleValue("adminsOnline", adminsCounter)
    end
    function DecrementAdminCounter()
        adminsCounter = adminsCounter - 1
        tes3mp.SetRuleValue("adminsOnline", adminsCounter)
    end
    function ResetAdminCounter()
        adminsCounter = 0
        tes3mp.SetRuleValue("adminsOnline", adminsCounter)
    end
end

function OnServerInit()

    local expectedVersionPrefix = "0.6.3"
    local serverVersion = tes3mp.GetServerVersion()

    if string.sub(serverVersion, 1, string.len(expectedVersionPrefix)) ~= expectedVersionPrefix then
        tes3mp.LogMessage(3, "Version mismatch between server and Core scripts!")
        tes3mp.LogAppend(3, "- The Core scripts require a server version that starts with " .. expectedVersionPrefix)
        tes3mp.StopServer(1)
    end

    myMod.InitializeWorld()
    myMod.PushPlayerList(Players)

    LoadBanList()
    LoadPluginList()

    tes3mp.SetPluginEnforcementState(config.enforcePlugins)
end

function OnServerPostInit()

    local consoleRuleString = "allowed"
    if not config.allowConsole then
        consoleRuleString = "not " .. consoleRuleString
    end

    local bedRestRuleString = "allowed"
    if not config.allowBedRest then
        bedRestRuleString = "not " .. bedRestRuleString
    end

    local wildRestRuleString = "allowed"
    if not config.allowWildernessRest then
        wildRestRuleString = "not " .. wildRestRuleString
    end

    local waitRuleString = "allowed"
    if not config.allowWait then
        waitRuleString = "not " .. waitRuleString
    end

    tes3mp.SetRuleString("enforcePlugins", tostring(config.enforcePlugins))
    tes3mp.SetRuleString("difficulty", tostring(config.difficulty))
    tes3mp.SetRuleString("deathPenaltyJailDays", tostring(config.deathPenaltyJailDays))
    tes3mp.SetRuleString("console", consoleRuleString)
    tes3mp.SetRuleString("bedResting", bedRestRuleString)
    tes3mp.SetRuleString("wildernessResting", wildRestRuleString)
    tes3mp.SetRuleString("waiting", waitRuleString)
    tes3mp.SetRuleString("enforcedLogLevel", tostring(config.enforcedLogLevel))
    tes3mp.SetRuleString("physicsFramerate", tostring(config.physicsFramerate))
    tes3mp.SetRuleString("spawnCell", tostring(config.defaultSpawnCell))
    tes3mp.SetRuleString("shareJournal", tostring(config.shareJournal))
    tes3mp.SetRuleString("shareFactionRanks", tostring(config.shareFactionRanks))
    tes3mp.SetRuleString("shareFactionExpulsion", tostring(config.shareFactionExpulsion))
    tes3mp.SetRuleString("shareFactionReputation", tostring(config.shareFactionReputation))

    local respawnCell

    if config.respawnAtImperialShrine == true then
        respawnCell = "nearest Imperial shrine"

        if config.respawnAtTribunalTemple == true then
            respawnCell = respawnCell .. " or Tribunal temple"
        end
    elseif config.respawnAtTribunalTemple == true then
        respawnCell = "nearest Tribunal temple"
    else
        respawnCell = tostring(config.defaultRespawnCell)
    end

    tes3mp.SetRuleString("respawnCell", respawnCell)
    ResetAdminCounter()
end

function OnServerExit(error)
    tes3mp.LogMessage(3, tostring(error))
end

function OnRequestPluginList(id, field)
    id = id + 1
    field = field + 1
    if #pluginList < id then
        return ""
    end
    return pluginList[id][field]
end

function OnPlayerConnect(pid)
    tes3mp.SetDifficulty(pid, config.difficulty)
    tes3mp.SetConsoleAllowed(pid, config.allowConsole)
    tes3mp.SetBedRestAllowed(pid, config.allowBedRest)
    tes3mp.SetWildernessRestAllowed(pid, config.allowWildernessRest)
    tes3mp.SetWaitAllowed(pid, config.allowWait)
    tes3mp.SetPhysicsFramerate(pid, config.physicsFramerate)
    tes3mp.SetEnforcedLogLevel(pid, config.enforcedLogLevel)
    tes3mp.SendSettings(pid)

    local playerName = tes3mp.GetName(pid)

    if string.len(playerName) > 35 then
        playerName = string.sub(playerName, 0, 35)
    end

    if myMod.IsPlayerNameLoggedIn(playerName) then
        myMod.OnPlayerDeny(pid, playerName)
        return false -- deny player
    else
        tes3mp.LogMessage(1, "New player with pid("..pid..") connected!")
        myMod.OnPlayerConnect(pid, playerName)
        return true -- accept player
    end
end

function OnLoginTimeExpiration(pid) -- timer-based event, see myMod.OnPlayerConnect
    if myMod.AuthCheck(pid) then
        if Players[pid]:IsModerator() then
            IncrementAdminCounter()
        end
    end
end

function OnPlayerDisconnect(pid)
    tes3mp.LogMessage(1, "Player with pid " .. pid .. " disconnected.")
    local message = myMod.GetChatName(pid) .. " left the server.\n"

    tes3mp.SendMessage(pid, message, true)

    -- Was this player confiscating from someone? If so, clear that
    if Players[pid] ~= nil and Players[pid].confiscationTargetName ~= nil then
        local targetName = Players[pid].confiscationTargetName
        local targetPlayer = myMod.GetPlayerByName(targetName)
        targetPlayer:SetConfiscationState(false)
    end

    -- Trigger any necessary script events useful for saving state
    myMod.OnPlayerCellChange(pid)

    myMod.OnPlayerDisconnect(pid)
    DecrementAdminCounter()
end

function OnPlayerResurrect(pid)
end

function OnPlayerSendMessage(pid, message)
    local playerName = tes3mp.GetName(pid)
    tes3mp.LogMessage(1, myMod.GetChatName(pid) .. ": " .. message)

    if myMod.OnPlayerMessage(pid, message) == false then
        return false
    end

    local admin = false
    local moderator = false
    if Players[pid]:IsAdmin() then
        admin = true
        moderator = true
    elseif Players[pid]:IsModerator() then
        moderator = true
    end

    if message:sub(1,1) == '/' then
        local cmd = (message:sub(2, #message)):split(" ")

        if cmd[1] == "message" or cmd[1] == "msg" then
            if pid == tonumber(cmd[2]) then
                tes3mp.SendMessage(pid, "You can't message yourself.\n")
            elseif cmd[3] == nil then
                tes3mp.SendMessage(pid, "You cannot send a blank message.\n")
            elseif myMod.CheckPlayerValidity(pid, cmd[2]) then
                local targetPid = tonumber(cmd[2])
                local targetName = Players[targetPid].name
                message = myMod.GetChatName(pid) .. " to " .. myMod.GetChatName(targetPid) .. ": "
                message = message .. tableHelper.concatenateFromIndex(cmd, 3) .. "\n"
                tes3mp.SendMessage(pid, message, false)
                tes3mp.SendMessage(targetPid, message, false)
            end

        elseif cmd[1] == "me" and cmd[2] ~= nil then
            local message = myMod.GetChatName(pid) .. " " .. tableHelper.concatenateFromIndex(cmd, 2) .. "\n"
            tes3mp.SendMessage(pid, message, true)

        elseif (cmd[1] == "local" or cmd[1] == "l") and cmd[2] ~= nil then
            local cellDescription = Players[pid].data.location.cell

            if myMod.IsCellLoaded(cellDescription) == true then
                for index, visitorPid in pairs(LoadedCells[cellDescription].visitors) do

                    local message = myMod.GetChatName(pid) .. " to local area: "
                    message = message .. tableHelper.concatenateFromIndex(cmd, 2) .. "\n"
                    tes3mp.SendMessage(visitorPid, message, false)
                end
            end

        elseif cmd[1] == "ban" and moderator then

            if cmd[2] == "ip" and cmd[3] ~= nil then
                local ipAddress = cmd[3]

                if tableHelper.containsValue(banList.ipAddresses, ipAddress) == false then
                    table.insert(banList.ipAddresses, ipAddress)
                    SaveBanList()

                    tes3mp.SendMessage(pid, ipAddress .. " is now banned.\n", false)
                    tes3mp.BanAddress(ipAddress)
                else
                    tes3mp.SendMessage(pid, ipAddress .. " was already banned.\n", false)
                end
            elseif (cmd[2] == "name" or cmd[2] == "player") and cmd[3] ~= nil then
                local targetName = tableHelper.concatenateFromIndex(cmd, 3)
                myMod.BanPlayer(pid, targetName)

            elseif type(tonumber(cmd[2])) == "number" and myMod.CheckPlayerValidity(pid, cmd[2]) then
                local targetPid = tonumber(cmd[2])
                local targetName = Players[targetPid].name
                myMod.BanPlayer(pid, targetName)
            else
                tes3mp.SendMessage(pid, "Invalid input for ban.\n", false)
            end

        elseif cmd[1] == "unban" and moderator and cmd[3] ~= nil then

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
                myMod.UnbanPlayer(pid, targetName)
            else
                tes3mp.SendMessage(pid, "Invalid input for unban.\n", false)
            end

        elseif cmd[1] == "banlist" and moderator then

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

        elseif (cmd[1] == "ipaddresses" or cmd[1] == "ips") and moderator and cmd[2] ~= nil then
            local targetName = tableHelper.concatenateFromIndex(cmd, 2)
            local targetPlayer = myMod.GetPlayerByName(targetName)

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

        elseif cmd[1] == "players" or cmd[1] == "list" then
            GUI.ShowPlayerList(pid)

        elseif cmd[1] == "cells" and moderator then
            GUI.ShowCellList(pid)

        elseif (cmd[1] == "teleport" or cmd[1] == "tp") and moderator then
            if cmd[2] ~= "all" then
                myMod.TeleportToPlayer(pid, cmd[2], pid)
            else
                for iteratorPid, player in pairs(Players) do
                    if iteratorPid ~= pid then
                        if player:IsLoggedIn() then
                            myMod.TeleportToPlayer(pid, iteratorPid, pid)
                        end
                    end
                end
            end

        elseif (cmd[1] == "teleportto" or cmd[1] == "tpto") and moderator then
            myMod.TeleportToPlayer(pid, pid, cmd[2])

        elseif (cmd[1] == "setauthority" or cmd[1] == "setauth") and moderator and #cmd > 2 then
            if myMod.CheckPlayerValidity(pid, cmd[2]) then
                local cellDescription = tableHelper.concatenateFromIndex(cmd, 3)

                -- Get rid of quotation marks
                cellDescription = string.gsub(cellDescription, '"', '')

                if myMod.IsCellLoaded(cellDescription) == true then
                    local targetPid = tonumber(cmd[2])
                    myMod.SetCellAuthority(targetPid, cellDescription)
                else
                    tes3mp.SendMessage(pid, "Cell \"" .. cellDescription .. "\" isn't loaded!\n", false)
                end
            end

        elseif cmd[1] == "kick" and moderator then
            if myMod.CheckPlayerValidity(pid, cmd[2]) then
                local targetPid = tonumber(cmd[2])
                local targetName = Players[targetPid].name
                local message

                if Players[targetPid]:IsAdmin() then
                    message = "You cannot kick an Admin from the server.\n"
                    tes3mp.SendMessage(pid, message, false)
                elseif Players[targetPid]:IsModerator() and not admin then
                    message = "You cannot kick a fellow Moderator from the server.\n"
                    tes3mp.SendMessage(pid, message, false)
                else
                    message = targetName .. " was kicked from the server by " .. playerName .. "!\n"
                    tes3mp.SendMessage(pid, message, true)
                    Players[targetPid]:Kick()
                end
            end

        elseif cmd[1] == "addmoderator" and admin then
            if myMod.CheckPlayerValidity(pid, cmd[2]) then
                local targetPid = tonumber(cmd[2])
                local targetName = Players[targetPid].name
                local message

                if Players[targetPid]:IsAdmin() then
                    message = targetName .. " is already an Admin.\n"
                    tes3mp.SendMessage(pid, message, false)
                elseif Players[targetPid]:IsModerator() then
                    message = targetName .. " is already a Moderator.\n"
                    tes3mp.SendMessage(pid, message, false)
                else
                    message = targetName .. " was promoted to Moderator!\n"
                    tes3mp.SendMessage(pid, message, true)
                    Players[targetPid].data.settings.admin = 1
                    Players[targetPid]:Save()
                end
            end

        elseif cmd[1] == "removemoderator" and admin then
            if myMod.CheckPlayerValidity(pid, cmd[2]) then
                local targetPid = tonumber(cmd[2])
                local targetName = Players[targetPid].name
                local message

                if Players[targetPid]:IsAdmin() then
                    message = "Cannot demote " .. targetName .. " because they are an Admin.\n"
                    tes3mp.SendMessage(pid, message, false)
                elseif Players[targetPid]:IsModerator() then
                    message = targetName .. " was demoted from Moderator!\n"
                    tes3mp.SendMessage(pid, message, true)
                    Players[targetPid].data.settings.admin = 0
                    Players[targetPid]:Save()
                else
                    message = targetName .. " is not a Moderator.\n"
                    tes3mp.SendMessage(pid, message, false)
                end
            end

        elseif cmd[1] == "superman" and moderator then
            -- Set Speed to 100
            tes3mp.SetAttributeBase(pid, 4, 100)
            -- Set Athletics to 100
            tes3mp.SetSkillBase(pid, 8, 100)
            -- Set Acrobatics to 400
            tes3mp.SetSkillBase(pid, 20, 400)

            tes3mp.SendAttributes(pid)
            tes3mp.SendSkills(pid)

        elseif cmd[1] == "setrace" and admin then

            if myMod.CheckPlayerValidity(pid, cmd[2]) then

                local targetPid = tonumber(cmd[2])
                local newRace = tableHelper.concatenateFromIndex(cmd, 3)

                Players[targetPid].data.character.race = newRace
                tes3mp.SetRace(targetPid, newRace)
                tes3mp.SetResetStats(targetPid, false)
                tes3mp.SendBaseInfo(targetPid)
            end

        elseif cmd[1] == "setattr" and moderator then
            if myMod.CheckPlayerValidity(pid, cmd[2]) then
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

                        local message = targetName.."'s "..tes3mp.GetAttributeName(attrId).." is now "..value.."\n"
                        tes3mp.SendMessage(pid, message, true)
                        Players[targetPid]:SaveAttributes()
                    end
                end
            end

        elseif cmd[1] == "setskill" and moderator then
            if myMod.CheckPlayerValidity(pid, cmd[2]) then
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

                        local message = targetName.."'s "..tes3mp.GetSkillName(skillId).." is now "..value.."\n"
                        tes3mp.SendMessage(pid, message, true)
                        Players[targetPid]:SaveSkills()
                    end
                end
            end
        elseif cmd[1] == "help" then
            if (cmd[2] == "moderator" or cmd[2] == "mod") then

                if moderator then
                    tes3mp.CustomMessageBox(pid, -1, modhelptext .. "\n", "Ok")
                else
                    tes3mp.SendMessage(pid, "Only Moderators and higher can see those commands.", false)
                end
            elseif cmd[2] == "admin" then

                if admin then
                    tes3mp.CustomMessageBox(pid, -1, adminhelptext .. "\n", "Ok")
                else
                    tes3mp.SendMessage(pid, "Only Admins can see those commands.", false)
                end
            else
                tes3mp.CustomMessageBox(pid, -1, helptext .. "\n", "Ok")
            end

        elseif cmd[1] == "setext" and admin then
            tes3mp.SetExterior(pid, cmd[2], cmd[3])

        elseif cmd[1] == "getpos" and moderator then
            myMod.PrintPlayerPosition(pid, cmd[2])

        elseif (cmd[1] == "setdifficulty" or cmd[1] == "setdiff") and admin then
            if myMod.CheckPlayerValidity(pid, cmd[2]) then

                local targetPid = tonumber(cmd[2])
                local difficulty = cmd[3]

                if type(tonumber(difficulty)) == "number" then
                    difficulty = tonumber(difficulty)
                end

                if difficulty == "default" or type(difficulty) == "number" then
                    Players[targetPid]:SetDifficulty(difficulty)
                    Players[targetPid]:LoadSettings()
                    tes3mp.SendMessage(pid, "Difficulty for " .. Players[targetPid].name .. " is now " .. difficulty .. "\n", true)
                else
                    tes3mp.SendMessage(pid, "Not a valid argument. Use /setdifficulty <pid> <value>\n", false)
                    return false
                end
            end

        elseif cmd[1] == "setconsole" and admin then
            if myMod.CheckPlayerValidity(pid, cmd[2]) then

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
                     tes3mp.SendMessage(pid, "Not a valid argument. Use /setconsole <pid> <on/off/default>\n", false)
                     return false
                end

                Players[targetPid]:LoadSettings()
                tes3mp.SendMessage(pid, "Console for " .. Players[targetPid].name .. state, false)
                if targetPid ~= pid then
                    tes3mp.SendMessage(targetPid, "Console" .. state, false)
                end
            end

        elseif cmd[1] == "setbedrest" and admin then
            if myMod.CheckPlayerValidity(pid, cmd[2]) then

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
                     tes3mp.SendMessage(pid, "Not a valid argument. Use /setbedrest <pid> <on/off/default>\n", false)
                     return false
                end

                Players[targetPid]:LoadSettings()
                tes3mp.SendMessage(pid, "Bed resting for " .. Players[targetPid].name .. state, false)
                if targetPid ~= pid then
                    tes3mp.SendMessage(targetPid, "Bed resting" .. state, false)
                end
            end

        elseif (cmd[1] == "setwildernessrest" or cmd[1] == "setwildrest") and admin then
            if myMod.CheckPlayerValidity(pid, cmd[2]) then

                local targetPid = tonumber(cmd[2])
                local targetName = ""
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
                     tes3mp.SendMessage(pid, "Not a valid argument. Use /setwildrest <pid> <on/off/default>\n", false)
                     return false
                end

                Players[targetPid]:LoadSettings()
                tes3mp.SendMessage(pid, "Wilderness resting for " .. Players[targetPid].name .. state, false)
                if targetPid ~= pid then
                    tes3mp.SendMessage(targetPid, "Wilderness resting" .. state, false)
                end
            end

        elseif cmd[1] == "setwait" and admin then
            if myMod.CheckPlayerValidity(pid, cmd[2]) then

                local targetPid = tonumber(cmd[2])
                local targetName = ""
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
                     tes3mp.SendMessage(pid, "Not a valid argument. Use /setwait <pid> <on/off/default>\n", false)
                     return false
                end

                Players[targetPid]:LoadSettings()
                tes3mp.SendMessage(pid, "Waiting for " .. Players[targetPid].name .. state, false)
                if targetPid ~= pid then
                    tes3mp.SendMessage(targetPid, "Waiting" .. state, false)
                end
            end

        elseif (cmd[1] == "setphysicsfps" or cmd[1] == "setphysicsframerate") and admin then
            if myMod.CheckPlayerValidity(pid, cmd[2]) then

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

        elseif (cmd[1] == "setloglevel" or cmd[1] == "setenforcedloglevel") and admin then
            if myMod.CheckPlayerValidity(pid, cmd[2]) then

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

        elseif cmd[1] == "setscale" and admin then
            if myMod.CheckPlayerValidity(pid, cmd[2]) then

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

        elseif cmd[1] == "setwerewolf" and admin then
            if myMod.CheckPlayerValidity(pid, cmd[2]) then

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
                     tes3mp.SendMessage(pid, "Not a valid argument. Use /setwerewolf <pid> <on/off>.\n", false)
                     return false
                end

                Players[targetPid]:LoadShapeshift()
                tes3mp.SendMessage(pid, "Werewolf state for " .. Players[targetPid].name .. state, false)
                if targetPid ~= pid then
                    tes3mp.SendMessage(targetPid, "Werewolf state" .. state, false)
                end
            end

        elseif cmd[1] == "time" and moderator then
            if type(tonumber(cmd[2])) == "number" then
                timeCounter = tonumber(cmd[2])
            end

        elseif cmd[1] == "suicide" then
            if config.allowSuicideCommand == true then
                tes3mp.SetHealthCurrent(pid, 0)
                tes3mp.SendStatsDynamic(pid)
            else
                tes3mp.SendMessage(pid, "That command is disabled on this server.\n", false)
            end

        elseif cmd[1] == "storeconsole" and cmd[2] ~= nil and cmd[3] ~= nil and admin then
            if myMod.CheckPlayerValidity(pid, cmd[2]) then

                local targetPid = tonumber(cmd[2])
                Players[targetPid].storedConsoleCommand = tableHelper.concatenateFromIndex(cmd, 3)

                tes3mp.SendMessage(pid, "That console command is now stored for player " .. targetPid .. "\n", false)
            end

        elseif cmd[1] == "runconsole" and cmd[2] ~= nil and admin then
            if myMod.CheckPlayerValidity(pid, cmd[2]) then

                local targetPid = tonumber(cmd[2])

                if Players[targetPid].storedConsoleCommand == nil then
                    tes3mp.SendMessage(pid, "There is no console command stored for player " .. targetPid .. ". Please run /storeconsole on them first.\n", false)
                else
                    local consoleCommand = Players[targetPid].storedConsoleCommand
                    myMod.RunConsoleCommandOnPlayer(targetPid, consoleCommand)

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

        elseif (cmd[1] == "placeat" or cmd[1] == "spawnat") and cmd[2] ~= nil and cmd[3] ~= nil and admin then
            if myMod.CheckPlayerValidity(pid, cmd[2]) then

                local targetPid = tonumber(cmd[2])
                local refId = cmd[3]
                local packetType

                if cmd[1] == "placeat" then
                    packetType = "place"
                elseif cmd[1] == "spawnat" then
                    packetType = "spawn"
                end

                myMod.CreateObjectAtPlayer(targetPid, refId, packetType)

                local count = tonumber(cmd[4])

                if count ~= nil and count > 1 then

                    -- We've already placed the first object above, so lower the count
                    -- for the object loop
                    count = count - 1
                    local interval = 1

                    if tonumber(cmd[5]) ~= nil and tonumber(cmd[5]) > 1 then
                        interval = tonumber(cmd[5])
                    end

                    local loopIndex = tableHelper.getUnusedNumericalIndex(ObjectLoops)
                    local timerId = tes3mp.CreateTimerEx("OnObjectLoopTimeExpiration", interval, "i", loopIndex)

                    ObjectLoops[loopIndex] = {
                        packetType = packetType,
                        timerId = timerId,
                        interval = interval,
                        count = count,
                        targetPid = targetPid,
                        targetName = Players[targetPid].accountName,
                        refId = refId
                    }

                    tes3mp.StartTimer(timerId)
                end
            end

        elseif (cmd[1] == "greentext" or cmd[1] == "gt") and cmd[2] ~= nil then
            local message = myMod.GetChatName(pid) .. ": " .. color.GreenText .. ">" .. tableHelper.concatenateFromIndex(cmd, 2) .. "\n"
            tes3mp.SendMessage(pid, message, true)

        elseif (cmd[1] == "anim" or cmd[1] == "a") and cmd[2] ~= nil then
            local isValid = animHelper.playAnimation(pid, cmd[2])
                
            if isValid == false then
                local validList = animHelper.getValidList(pid)
                tes3mp.SendMessage(pid, "That is not a valid animation. Try one of the following:\n" .. validList .. "\n", false)
            end

        elseif (cmd[1] == "speech" or cmd[1] == "s") and cmd[2] ~= nil and cmd[3] ~= nil and type(tonumber(cmd[3])) == "number" then
            local isValid = speechHelper.playSpeech(pid, cmd[2], tonumber(cmd[3]))
                
            if isValid == false then
                local validList = speechHelper.getValidList(pid)
                tes3mp.SendMessage(pid, "That is not a valid speech. Try one of the following:\n" .. validList .. "\n", false)
            end

        elseif cmd[1] == "confiscate" and moderator then

            if myMod.CheckPlayerValidity(pid, cmd[2]) then

                local targetPid = tonumber(cmd[2])

                if targetPid == pid then
                    tes3mp.SendMessage(pid, "You can't confiscate from yourself!\n", false)
                elseif Players[targetPid].data.customVariables.isConfiscationTarget then
                    tes3mp.SendMessage(pid, "Someone is already confiscating from that player\n", false)
                else
                    Players[pid].confiscationTargetName = Players[targetPid].accountName

                    Players[targetPid]:SetConfiscationState(true)

                    tableHelper.cleanNils(Players[targetPid].data.inventory)
                    GUI.ShowInventoryList(config.customMenuIds.confiscate, pid, targetPid)
                end
            end

        elseif cmd[1] == "craft" then

            Players[pid].currentCustomMenu = "default crafting origin"
            menuHelper.displayMenu(pid, Players[pid].currentCustomMenu)

        else
            local message = "Not a valid command. Type /help for more info.\n"
            tes3mp.SendMessage(pid, color.Error..message..color.Default, false)
        end

        return false -- commands should be hidden
    end

    return true -- default behavior, chat messages should not
end

function OnObjectLoopTimeExpiration(loopIndex)
    myMod.OnObjectLoopTimeExpiration(loopIndex)
end

function OnPlayerDeath(pid)
    myMod.OnPlayerDeath(pid)
end

function OnDeathTimeExpiration(pid)
    myMod.OnDeathTimeExpiration(pid)
end

function OnPlayerAttribute(pid)
    myMod.OnPlayerAttribute(pid)
end

function OnPlayerSkill(pid)
    myMod.OnPlayerSkill(pid)
end

function OnPlayerLevel(pid)
    myMod.OnPlayerLevel(pid)
end

function OnPlayerShapeshift(pid)
    myMod.OnPlayerShapeshift(pid)
end

function OnPlayerCellChange(pid)
    myMod.OnPlayerCellChange(pid)
end

function OnPlayerEquipment(pid)
    myMod.OnPlayerEquipment(pid)
end

function OnPlayerInventory(pid)
    myMod.OnPlayerInventory(pid)
end

function OnPlayerSpellbook(pid)
    myMod.OnPlayerSpellbook(pid)
end

function OnPlayerQuickKeys(pid)
    myMod.OnPlayerQuickKeys(pid)
end

function OnPlayerJournal(pid)
    myMod.OnPlayerJournal(pid)
end

function OnPlayerFaction(pid)
    myMod.OnPlayerFaction(pid)
end

function OnPlayerTopic(pid)
    myMod.OnPlayerTopic(pid)
end

function OnPlayerBounty(pid)
    myMod.OnPlayerBounty(pid)
end

function OnPlayerReputation(pid)
    myMod.OnPlayerReputation(pid)
end

function OnPlayerKillCount(pid)
    myMod.OnPlayerKillCount(pid)
end

function OnPlayerBook(pid)
    myMod.OnPlayerBook(pid)
end

function OnPlayerMiscellaneous(pid)
    myMod.OnPlayerMiscellaneous(pid)
end

function OnPlayerEndCharGen(pid)
    myMod.OnPlayerEndCharGen(pid)
end

function OnCellLoad(pid, cellDescription)
    myMod.OnCellLoad(pid, cellDescription)
end

function OnCellUnload(pid, cellDescription)
    myMod.OnCellUnload(pid, cellDescription)
end

function OnCellDeletion(cellDescription)
    myMod.OnCellDeletion(cellDescription)
end

function OnActorList(pid, cellDescription)
    myMod.OnActorList(pid, cellDescription)
end

function OnActorEquipment(pid, cellDescription)
    myMod.OnActorEquipment(pid, cellDescription)
end

function OnActorCellChange(pid, cellDescription)
    myMod.OnActorCellChange(pid, cellDescription)
end

function OnObjectPlace(pid, cellDescription)
    myMod.OnObjectPlace(pid, cellDescription)
end

function OnObjectSpawn(pid, cellDescription)
    myMod.OnObjectSpawn(pid, cellDescription)
end

function OnObjectDelete(pid, cellDescription)
    myMod.OnObjectDelete(pid, cellDescription)
end

function OnObjectLock(pid, cellDescription)
    myMod.OnObjectLock(pid, cellDescription)
end

function OnObjectTrap(pid, cellDescription)
    myMod.OnObjectTrap(pid, cellDescription)
end

function OnObjectScale(pid, cellDescription)
    myMod.OnObjectScale(pid, cellDescription)
end

function OnObjectState(pid, cellDescription)
    myMod.OnObjectState(pid, cellDescription)
end

function OnDoorState(pid, cellDescription)
    myMod.OnDoorState(pid, cellDescription)
end

function OnContainer(pid, cellDescription)
    myMod.OnContainer(pid, cellDescription)
end

function OnGUIAction(pid, idGui, data)
    if myMod.OnGUIAction(pid, idGui, data) then return end -- if myMod.OnGUIAction is called
end

function OnMpNumIncrement(currentMpNum)
    myMod.OnMpNumIncrement(currentMpNum)
end
