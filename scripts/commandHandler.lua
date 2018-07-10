local commandHandler = {}

function commandHandler.ProcessCommand(pid, cmd)

    local admin = false
    local moderator = false
    if Players[pid]:IsAdmin() then
        admin = true
        moderator = true
    elseif Players[pid]:IsModerator() then
        moderator = true
    end

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

    elseif (cmd[1] == "greentext" or cmd[1] == "gt") and cmd[2] ~= nil then
        local message = myMod.GetChatName(pid) .. ": " .. color.GreenText .. ">" .. tableHelper.concatenateFromIndex(cmd, 2) .. "\n"
        tes3mp.SendMessage(pid, message, true)

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

    elseif cmd[1] == "setrace" and admin then

        if myMod.CheckPlayerValidity(pid, cmd[2]) then

            local targetPid = tonumber(cmd[2])
            local newRace = tableHelper.concatenateFromIndex(cmd, 3)

            Players[targetPid].data.character.race = newRace
            tes3mp.SetRace(targetPid, newRace)
            tes3mp.SetResetStats(targetPid, false)
            tes3mp.SendBaseInfo(targetPid)
        end

    elseif cmd[1] == "sethead" and admin then

        if myMod.CheckPlayerValidity(pid, cmd[2]) then

            local targetPid = tonumber(cmd[2])
            local newHead = tableHelper.concatenateFromIndex(cmd, 3)

            Players[targetPid].data.character.head = newHead
            tes3mp.SetHead(targetPid, newHead)
            tes3mp.SetResetStats(targetPid, false)
            tes3mp.SendBaseInfo(targetPid)
        end

    elseif cmd[1] == "sethair" and admin then

        if myMod.CheckPlayerValidity(pid, cmd[2]) then

            local targetPid = tonumber(cmd[2])
            local newHair = tableHelper.concatenateFromIndex(cmd, 3)

            Players[targetPid].data.character.hair = newHair
            tes3mp.SetHair(targetPid, newHair)
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

    elseif cmd[1] == "setmomentum" and moderator then
        if myMod.CheckPlayerValidity(pid, cmd[2]) then

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
                 tes3mp.SendMessage(pid, "Not a valid argument. Use /setconsole <pid> on/off/default\n", false)
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
                 tes3mp.SendMessage(pid, "Not a valid argument. Use /setbedrest <pid> on/off/default\n", false)
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
                 tes3mp.SendMessage(pid, "Not a valid argument. Use /setwildrest <pid> on/off/default\n", false)
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
                 tes3mp.SendMessage(pid, "Not a valid argument. Use /setwait <pid> on/off/default\n", false)
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
                 tes3mp.SendMessage(pid, "Not a valid argument. Use /setwerewolf <pid> on/off.\n", false)
                 return false
            end

            Players[targetPid]:LoadShapeshift()
            tes3mp.SendMessage(pid, "Werewolf state for " .. Players[targetPid].name .. state, false)
            if targetPid ~= pid then
                tes3mp.SendMessage(targetPid, "Werewolf state" .. state, false)
            end
        end

    elseif cmd[1] == "disguise" and admin then

        if myMod.CheckPlayerValidity(pid, cmd[2]) then

            local targetPid = tonumber(cmd[2])
            local creatureRefId = tableHelper.concatenateFromIndex(cmd, 3)

            Players[targetPid].data.shapeshift.creatureRefId = creatureRefId
            tes3mp.SetCreatureRefId(targetPid, creatureRefId)
            tes3mp.SendShapeshift(targetPid)

            if creatureRefId == "" then
                creatureRefId = "nothing"
            end

            tes3mp.SendMessage(pid, Players[targetPid].accountName .. " is now disguised as " .. creatureRefId, false)
            if targetPid ~= pid then
                tes3mp.SendMessage(targetPid, "You are now disguised as " .. creatureRefId, false)
            end
        end

    elseif cmd[1] == "usecreaturename" and admin then

        if myMod.CheckPlayerValidity(pid, cmd[2]) then

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

    elseif cmd[1] == "sethour" and moderator then

        local inputValue = tonumber(cmd[2])

        if type(inputValue) == "number" then

            if inputValue == 24 then
                inputValue = 0
            end

            if inputValue >= 0 and inputValue < 24 then
                WorldInstance.data.time.hour = inputValue
                WorldInstance:Save()
                WorldInstance:LoadTime(pid, true)
                hourCounter = inputValue
            else
                tes3mp.SendMessage(pid, "There aren't that many hours in a day.\n", false)
            end
        end

    elseif cmd[1] == "setday" and moderator then

        local inputValue = tonumber(cmd[2])

        if type(inputValue) == "number" then

            local daysInMonth = WorldInstance.monthLengths[WorldInstance.data.time.month]

            if inputValue <= daysInMonth then
                WorldInstance.data.time.day = inputValue
                WorldInstance:Save()
                WorldInstance:LoadTime(pid, true)
            else
                tes3mp.SendMessage(pid, "There are only " .. daysInMonth .. " days in the current month.\n", false)
            end
        end

    elseif cmd[1] == "setmonth" and moderator then

        local inputValue = tonumber(cmd[2])

        if type(inputValue) == "number" then
            WorldInstance.data.time.month = inputValue
            WorldInstance:Save()
            WorldInstance:LoadTime(pid, true)
        end

    elseif cmd[1] == "settimescale" and moderator then

        local inputValue = tonumber(cmd[2])

        if type(inputValue) == "number" then
            WorldInstance.data.time.timeScale = inputValue
            WorldInstance:Save()
            WorldInstance:LoadTime(pid, true)
            frametimeMultiplier = inputValue / WorldInstance.defaultTimeScale
        end

    elseif cmd[1] == "setcollision" and cmd[2] ~= nil and cmd[3] ~= nil and admin then

        local collisionState

        if cmd[3] == "on" then
            collisionState = true
        elseif cmd[3] == "off" then
            collisionState = false
        else
             tes3mp.SendMessage(pid, "Not a valid argument. Use /setcollision <category> on/off (on/off)\n", false)
             return false
        end

        local categoryInput = string.upper(cmd[2])

        if enumerations.objectCategories[categoryInput] == 0 then
            tes3mp.SetPlayerCollisionState(collisionState)
        elseif enumerations.objectCategories[categoryInput] == 1 then
            tes3mp.SetActorCollisionState(collisionState)
        elseif enumerations.objectCategories[categoryInput] == 2 then
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

    elseif cmd[1] == "suicide" then
        if config.allowSuicideCommand == true then
            tes3mp.SetHealthCurrent(pid, 0)
            tes3mp.SendStatsDynamic(pid)
        else
            tes3mp.SendMessage(pid, "That command is disabled on this server.\n", false)
        end

    elseif cmd[1] == "fixme" then
        if config.allowFixmeCommand == true then
            local currentTime = os.time()

            if Players[pid].data.customVariables.lastFixMe == nil or
                currentTime >= Players[pid].data.customVariables.lastFixMe + config.fixmeInterval then

                myMod.RunConsoleCommandOnPlayer(pid, "fixme")
                Players[pid].data.customVariables.lastFixMe = currentTime
                tes3mp.SendMessage(pid, "You have fixed your position!\n", false)
            else
                local remainingSeconds = Players[pid].data.customVariables.lastFixMe + config.fixmeInterval - currentTime
                local message = "Sorry! You can't use /fixme for another "

                if remainingSeconds > 1 then
                    message = message .. remainingSeconds .. " seconds"
                else
                    message = message .. " second"
                end

                message = message .. "\n"
                tes3mp.SendMessage(pid, message, false)
            end
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

    elseif cmd[1] == "setai" and cmd[2] ~= nil and cmd[3] ~= nil and admin then

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

            local refIndex = cmd[2]
            local cell = myMod.GetCellContainingActor(refIndex)

            if cell == nil then

                Players[pid]:Message("Could not find actor " .. actorRefIndex .. " in any loaded cell\n")
            else

                local actionName = tableHelper.getIndexByPattern(enumerations.ai, actionNumericalId)
                local messageAction = enumerations.aiPrintableAction[actionName]
                local message = refIndex .. " is now " .. messageAction

                if actionNumericalId == enumerations.ai.CANCEL then

                    myMod.SetAIForActor(cell, refIndex, actionNumericalId)
                    Players[pid]:Message(message .. "\n")

                elseif actionNumericalId == enumerations.ai.TRAVEL then

                    local posX, posY, posZ = tonumber(cmd[4]), tonumber(cmd[5]), tonumber(cmd[6])

                    if type(posX) == "number" and type(posY) == "number" and type(posZ) == "number" then

                        myMod.SetAIForActor(cell, refIndex, actionNumericalId, nil, nil, posX, posY, posZ)
                        Players[pid]:Message(message .. posX .. " " .. posY .. " " .. posZ .. "\n")
                    else
                        Players[pid]:Message("Invalid travel coordinates! " ..
                            "Use /setai <refIndex> travel <x> <y> <z>\n")
                    end

                elseif actionNumericalId == enumerations.ai.WANDER then

                    local distance, duration = tonumber(cmd[4]), tonumber(cmd[5])

                    if type(distance) == "number" and type(duration) == "number" then

                        myMod.SetAIForActor(cell, refIndex, actionNumericalId, nil, nil, nil, nil, nil,
                            distance, duration)
                        Players[pid]:Message(message .. " a distance of " .. distance .. " for " ..
                            duration .. " seconds\n")
                    else
                        Players[pid]:Message("Invalid wander parameters! " ..
                            "Use /setai <refIndex> wander <distance> <duration>\n")
                    end

                elseif cmd[4] ~= nil then

                    local target = cmd[4]
                    local hasPlayerTarget = false

                    if type(tonumber(target)) == "number" and myMod.CheckPlayerValidity(pid, target) then
                        target = tonumber(target)
                        hasPlayerTarget = true
                    end

                    if hasPlayerTarget then
                        myMod.SetAIForActor(cell, refIndex, actionNumericalId, target)
                        message = message .. " player " .. Players[target].name
                    else
                        myMod.SetAIForActor(cell, refIndex, actionNumericalId, nil, target)
                        message = message .. " actor " .. target
                    end

                    Players[pid]:Message(message .. "\n")
                else

                    Players[pid]:Message("Invalid AI action!\n")
                end
            end
        end

    elseif cmd[1] == "help" then
        
        -- Check "scripts/menu/help.lua" if you want to change the contents of the help menus
        Players[pid].currentCustomMenu = "help player"
        menuHelper.displayMenu(pid, Players[pid].currentCustomMenu)

    elseif cmd[1] == "craft" then

        Players[pid].currentCustomMenu = "default crafting origin"
        menuHelper.displayMenu(pid, Players[pid].currentCustomMenu)

    else
        local message = "Not a valid command. Type /help for more info.\n"
        tes3mp.SendMessage(pid, color.Error..message..color.Default, false)
    end
end

return commandHandler
