require("config")
class = require("classy")
tableHelper = require("tableHelper")
require("utils")
require("guiIds")
require("color")
require("time")
myMod = require("myMod")

Database = nil
Player = nil
Cell = nil
World = nil

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
/list - List all players on the server"

local modhelptext = "Moderators only:\
/superman - Increase acrobatics, athletics and speed\
/teleport (<pid>/all) - Teleport another player to your position (/tp)\
/teleportto <pid> - Teleport yourself to another player (/tpto)\
/getpos <pid> - Get player position and cell\
/setattr <pid> <attribute> <value> - Set a player's attribute to a certain value\
/setskill <pid> <skill> <value> - Set a player's skill to a certain value\
/kick <pid> - Kick player"

local adminhelptext = "Admins only:\
/addmoderator <pid> - Promote player to moderator\
/removemoderator <pid> - Demote player from moderator\
/console <pid> <on/off/default> - Enable/disable in-game console for player\
/difficulty <pid> <value/default> - Set the difficulty for a particular player"

Sample = {}

function LoadPluginList()
    local Sample2 = jsonInterface.load("pluginlist.json")
    for idx, pl in pairs(Sample2) do
        idx = tonumber(idx) + 1
        for n, h in pairs(pl) do
            Sample[idx] = {n}
            io.write(("%d, {%s"):format(idx, n))
            for _, v in ipairs(h) do
                io.write((", %X"):format(tonumber(v, 16)))
                table.insert(Sample[idx], tonumber(v,16))
            end
            table.insert(Sample[idx], "")
            io.write("}\n")
        end
    end
end

do
    local counter = config.timeServerInitTime
    local tid_ut = tes3mp.CreateTimer("UpdateTime", time.seconds(1))
    function UpdateTime()
        local hour = 0
        if config.timeSyncMode == 1 then
            counter = counter + (0.0083 * config.timeServerMult)
            hour = counter
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

    local version = tes3mp.GetServerVersion():split(".") -- for future versions

    if tes3mp.GetServerVersion() ~= "0.6-alpha" then
        tes3mp.LogMessage(3, "The server or script is outdated!")
        tes3mp.StopServer(1)
    end

    myMod.InitializeWorld()
    myMod.PushPlayerList(Players)
    LoadPluginList()
end

function OnServerPostInit()
    local consoleRuleString = "allowed"
    if not config.allowConsole then
        consoleRuleString = "not " .. consoleRuleString
    end

    tes3mp.SetRuleString("console", consoleRuleString)
    tes3mp.SetRuleString("difficulty", tostring(config.difficulty))
    tes3mp.SetRuleString("spawnCell", tostring(config.defaultSpawnCell))

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
    if #Sample < id then
        return ""
    end
    return Sample[id][field]
end

function OnPlayerConnect(pid)
    tes3mp.SetConsoleAllow(pid, config.allowConsole)
    tes3mp.SetDifficulty(pid, config.difficulty)
    tes3mp.SendSettings(pid)

    local pname = tes3mp.GetName(pid)

    if myMod.IsPlayerNameLoggedIn(pname) then
        myMod.OnPlayerDeny(pid, pname)
        return false -- deny player
    else
        tes3mp.LogMessage(1, "New player with pid("..pid..") connected!")
        myMod.OnPlayerConnect(pid, pname)
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
    tes3mp.LogMessage(1, "Player with pid("..pid..") disconnected.")
    local pname = tes3mp.GetName(pid)
    local message = pname.." ("..pid..") ".."left the server.\n"
    tes3mp.SendMessage(pid, message, true)

    -- Trigger any necessary script events useful for saving state
    myMod.OnPlayerCellChange(pid)

    myMod.OnPlayerDisconnect(pid)
    DecrementAdminCounter()
end

function OnPlayerDeath(pid)

    local playerName = tes3mp.GetName(pid)
    local deathReason = tes3mp.GetDeathReason(pid)

    tes3mp.LogMessage(1, "Original death reason was " .. deathReason)

    if deathReason == "suicide" then
        deathReason = "committed suicide"
    else
        deathReason = "was killed by " .. deathReason
    end

    local message = ("%s (%d) %s"):format(playerName, pid, deathReason)

    message = message .. ".\n"
    tes3mp.SendMessage(pid, message, true)

    Players[pid].tid_resurrect = tes3mp.CreateTimerEx("OnDeathTimeExpiration", time.seconds(config.deathTime), "i", pid)
    tes3mp.StartTimer(Players[pid].tid_resurrect);
end

function OnDeathTimeExpiration(pid)

    local resurrectTypes = { REGULAR = 0, IMPERIAL_SHRINE = 1, TRIBUNAL_TEMPLE = 2}

    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then

        local currentResurrectType

        if config.respawnAtImperialShrine == true then
            if config.respawnAtTribunalTemple == true then
                if math.random() > 0.5 then
                    currentResurrectType = resurrectTypes.IMPERIAL_SHRINE
                else
                    currentResurrectType = resurrectTypes.TRIBUNAL_TEMPLE
                end
            else
                currentResurrectType = resurrectTypes.IMPERIAL_SHRINE
            end

        elseif config.respawnAtTribunalTemple == true then
            currentResurrectType = resurrectTypes.TRIBUNAL_TEMPLE

        elseif config.defaultRespawnCell ~= nil then
            currentResurrectType = resurrectTypes.REGULAR

            tes3mp.SetCell(pid, config.defaultRespawnCell)
            tes3mp.SendCell(pid)

            if config.defaultRespawnPos ~= nil and config.defaultRespawnRot ~= nil then
                tes3mp.SetPos(pid, config.defaultRespawnPos[1], config.defaultRespawnPos[2], config.defaultRespawnPos[3])
                tes3mp.SetRot(pid, config.defaultRespawnRot[1], config.defaultRespawnRot[2])
                tes3mp.SendPos(pid)
            end
        end

        local message = "You have been resurrected"

        if currentResurrectType == resurrectTypes.IMPERIAL_SHRINE then
            message = message .. " at the nearest Imperial shrine"
        elseif currentResurrectType == resurrectTypes.TRIBUNAL_TEMPLE then
            message = message .. " at the nearest Tribunal temple"
        end

        message = message .. ".\n"
        tes3mp.Resurrect(pid, currentResurrectType)
        tes3mp.SendMessage(pid, message, false)
    end
end

function OnPlayerResurrect(pid)
end

function OnPlayerSendMessage(pid, message)
    local pname = tes3mp.GetName(pid)
    tes3mp.LogMessage(1, pname.."("..pid.."): "..message)

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

        if cmd[1] == "players" or cmd[1] == "list" then
            GUI.ShowPlayerList(pid)

        elseif cmd[1] == "cells" then
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
                local cellDescription = ""

                for i = 3, #cmd do
                    cellDescription = cellDescription .. cmd[i]

                    if i ~= #cmd then
                        cellDescription = cellDescription .. " "
                    end
                end

                -- Get rid of quotation marks
                cellDescription = string.gsub(cellDescription, '"', '')

                if myMod.IsCellLoaded(cellDescription) == true then
                    local targetPlayer = tonumber(cmd[2])
                    myMod.SetCellAuthority(targetPlayer, cellDescription)
                else
                    tes3mp.SendMessage(pid, "Cell \"" .. cellDescription .. "\" isn't loaded!\n", false)
                end
            end

        elseif cmd[1] == "kick" and moderator then
            if myMod.CheckPlayerValidity(pid, cmd[2]) then
                local targetPlayer = tonumber(cmd[2])
                local targetPlayerName = Players[targetPlayer].name
                local message

                if Players[targetPlayer]:IsAdmin() then
                    message = "You cannot kick an Admin from the server\n"
                    tes3mp.SendMessage(pid, message, false)
                elseif Players[targetPlayer]:IsModerator() and not admin then
                    message = "You cannot kick a fellow Moderator from the server\n"
                    tes3mp.SendMessage(pid, message, false)
                else
                    message = targetPlayerName .. " was kicked from the server by " .. pname .. "!\n"
                    tes3mp.SendMessage(pid, message, true)
                    Players[targetPlayer]:Kick()
                end
            end

        elseif cmd[1] == "addmoderator" and admin then
            if myMod.CheckPlayerValidity(pid, cmd[2]) then
                local targetPlayer = tonumber(cmd[2])
                local targetPlayerName = Players[targetPlayer].name
                local message

                if Players[targetPlayer]:IsAdmin() then
                    message = targetPlayerName .. " is already an Admin\n"
                    tes3mp.SendMessage(pid, message, false)
                elseif Players[targetPlayer]:IsModerator() then
                    message = targetPlayerName .. " is already a Moderator\n"
                    tes3mp.SendMessage(pid, message, false)
                else
                    message = targetPlayerName .. " was promoted to Moderator!\n"
                    tes3mp.SendMessage(pid, message, true)
                    Players[targetPlayer].data.settings.admin = 1
                    Players[targetPlayer]:Save()
                end
            end

        elseif cmd[1] == "removemoderator" and admin then
            if myMod.CheckPlayerValidity(pid, cmd[2]) then
                local targetPlayer = tonumber(cmd[2])
                local targetPlayerName = Players[targetPlayer].name
                local message

                if Players[targetPlayer]:IsAdmin() then
                    message = "Cannot demote " .. targetPlayerName .. " because they are an Admin\n"
                    tes3mp.SendMessage(pid, message, false)
                elseif Players[targetPlayer]:IsModerator() then
                    message = targetPlayerName .. " was demoted from Moderator!\n"
                    tes3mp.SendMessage(pid, message, true)
                    Players[targetPlayer].data.settings.admin = 0
                    Players[targetPlayer]:Save()
                else
                    message = targetPlayerName .. " is not a Moderator\n"
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

        elseif cmd[1] == "setattr" and moderator then
            if myMod.CheckPlayerValidity(pid, cmd[2]) then
                local targetPlayer = tonumber(cmd[2])
                local targetPlayerName = Players[targetPlayer].name

                if cmd[3] ~= nil and cmd[4] ~= nil and tonumber(cmd[4]) ~= nil then
                    local attrid
                    local value = tonumber(cmd[4])

                    if tonumber(cmd[3]) ~= nil then
                        attrid = tonumber(cmd[3])
                    else
                        attrid = tes3mp.GetAttributeId(cmd[3])
                    end

                    if attrid ~= -1 and attrid < tes3mp.GetAttributeCount() then
                        tes3mp.SetAttributeBase(targetPlayer, attrid, value)
                        tes3mp.SendAttributes(targetPlayer)

                        local message = targetPlayerName.."'s "..tes3mp.GetAttributeName(attrid).." is now "..value.."\n"
                        tes3mp.SendMessage(pid, message, true)
                        Players[targetPlayer]:SaveAttributes()
                    end
                end
            end

        elseif cmd[1] == "setskill" and moderator then
            if myMod.CheckPlayerValidity(pid, cmd[2]) then
                local targetPlayer = tonumber(cmd[2])
                local targetPlayerName = Players[targetPlayer].name

                if cmd[3] ~= nil and cmd[4] ~= nil and tonumber(cmd[4]) ~= nil then
                    local skillid
                    local value = tonumber(cmd[4])

                    if tonumber(cmd[3]) ~= nil then
                        skillid = tonumber(cmd[3])
                    else
                        skillid = tes3mp.GetSkillId(cmd[3])
                    end

                    if skillid ~= -1 and skillid < tes3mp.GetSkillCount() then
                        tes3mp.SetSkillBase(targetPlayer, skillid, value)
                        tes3mp.SendSkills(targetPlayer)

                        local message = targetPlayerName.."'s "..tes3mp.GetSkillName(skillid).." is now "..value.."\n"
                        tes3mp.SendMessage(pid, message, true)
                        Players[targetPlayer]:SaveSkills()
                    end
                end
            end
        elseif cmd[1] == "help" then
            local text = helptext .. "\n";
            if moderator then
                text = text .. modhelptext .. "\n"
            end
            if admin then
                text = text .. adminhelptext .. "\n"
            end
            tes3mp.MessageBox(pid, -1, text)

        elseif cmd[1] == "setext" and admin then
            tes3mp.SetExterior(pid, cmd[2], cmd[3])

        elseif cmd[1] == "getpos" and moderator then
            myMod.PrintPlayerPosition(pid, cmd[2])

        elseif cmd[1] == "console" and admin then
            local targetPlayer = tonumber(cmd[2])
            local targetPlayerName = ""
            local state = ""

            if Players[targetPlayer] == nil then
                tes3mp.SendMessage(pid, "Player with pid ".. tostring(targetPlayer) .. " not found.\n", false)
                return false
            elseif cmd[3] == "on" then
                Players[targetPlayer]:SetConsole(true)
                state = " enabled.\n"
            elseif cmd[3] == "off" then
                Players[targetPlayer]:SetConsole(false)
                state = " disabled.\n"
            elseif cmd[3] == "default" then
                Players[targetPlayer]:SetConsole("default")
                state = " reset to default.\n"
            else
                 tes3mp.SendMessage(pid, "Not a valid argument. Use /console <pid> <on/off/default>.\n", false)
                 return false
            end

            Players[targetPlayer]:LoadSettings()
            tes3mp.SendMessage(pid, "Console for " .. Players[targetPlayer].name .. state, false)
            if targetPlayer ~= pid then
                tes3mp.SendMessage(targetPlayer, "Console" .. state, false)
            end

        elseif cmd[1] == "difficulty" and admin then
            if myMod.CheckPlayerValidity(pid, cmd[2]) then

                local targetPlayer = tonumber(cmd[2])
                local difficulty = cmd[3]

                if type(tonumber(difficulty)) == "number" then
                    difficulty = tonumber(difficulty)
                end

                if difficulty == "default" or type(difficulty) == "number" then
                    Players[targetPlayer]:SetDifficulty(difficulty)
                    Players[targetPlayer]:LoadSettings()
                    tes3mp.SendMessage(pid, "Difficulty for " .. Players[targetPlayer].name .. " is now " .. difficulty .. "\n", true)
                else
                    tes3mp.SendMessage(pid, "Not a valid argument. Use /difficulty <pid> <value>.\n", false)
                    return false
                end
            end

        else
            local message = "Not a valid command. Type /help for more info.\n"
            tes3mp.SendMessage(pid, color.Error..message..color.Default, false)
        end

        return false -- commands should be hidden
    end

    return true -- default behavior, chat messages should not
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

function OnPlayerBounty(pid)
    myMod.OnPlayerBounty(pid)
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

function OnPlayerJournal(pid)
    myMod.OnPlayerJournal(pid)
end

function OnPlayerFaction(pid)
    myMod.OnPlayerFaction(pid)
end

function OnPlayerTopic(pid)
    myMod.OnPlayerTopic(pid)
end

function OnPlayerKillCount(pid)
    myMod.OnPlayerKillCount(pid)
end

function OnPlayerBook(pid)
    myMod.OnPlayerBook(pid)
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
