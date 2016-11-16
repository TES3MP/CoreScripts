require('guiIds')
myMod = require("myMod")
Player = require("player")

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
/removemoderator <pid> - Demote player from moderator"


function onServerInit()
    local version = tes3mp.getServerVersion():split(".") -- for future versions

    if tes3mp.getServerVersion() ~= "0.3.0" then
        print("The server or script is outdated!")
        tes3mp.stopServer(1)
    end

    myMod.PushPlayerList(Players)
end

function onServerExit(err)
    print(err)
end

function onPlayerConnect(pid)
    print("New player with pid("..pid..") connected!")
    myMod.onPlayerConnect(pid)
    return 1 -- accept player (0 deny)
end

function OnLogin(pid) -- timer-based event, see myMod.onPlayerConnect
    myMod.AuthCheck(pid)
end

function onPlayerDisconnect(pid)
    print("Player with pid("..pid..") disconnected.")
    local pname = tes3mp.getName(pid)
    local message = pname.." ("..pid..") ".."left the server.\n"
    tes3mp.sendMessage(pid, message, 1)

    -- Trigger any necessary script events useful for saving state
    myMod.onPlayerChangeCell(pid)

    myMod.onPlayerDisconnect(pid)
end

require("deathReasons")

function onPlayerDeath(pid, reason, killerId)
    local pname = tes3mp.getName(pid)
    local message = ("%s (%d) %s"):format(pname, pid, reasons.GetReasonName(reason))

    if reason == reasons.killed then
       message = ("%s by %s (%d)"):format(message, tes3mp.getName(killerId), killerId)
    end

    message = message .. ".\n"
    tes3mp.sendMessage(pid, message, 1)
    tes3mp.resurrect(pid)
end

function onPlayerResurrect(pid)
end

function onPlayerSendMessage(pid, message)
    local pname = tes3mp.getName(pid)
    print(pname.."("..pid.."): "..message)

    if myMod.OnPlayerMessage(pid, message) == 0 then
        return 0
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

        if cmd[1] == "cheat" and moderator then

            for i = 0, (tes3mp.getAttributeCount() - 1) do
                tes3mp.setAttributeBase(pid, i, 666)
            end

            for i = 0, (tes3mp.getSkillCount() - 1) do
                tes3mp.setSkillBase(pid, i, 666);
            end

            tes3mp.sendAttributes(pid)
            tes3mp.sendSkills(pid)

        elseif cmd[1] == "list" then
            GUI.ShowPlayersList(pid)

        elseif (cmd[1] == "teleport" or cmd[1] == "tp") and moderator then
            if cmd[2] ~= "all" then
                myMod.TeleportToPlayer(pid, cmd[2], pid)
            else
                for i=0,#Players do
                    if i ~= pid then
                        if Players[i]:IsLoggedOn() then
                            myMod.TeleportToPlayer(pid, i, pid)
                        end
                    end
                end
            end

        elseif (cmd[1] == "teleportto" or cmd[1] == "tpto") and moderator then
            myMod.TeleportToPlayer(pid, pid, cmd[2])

        elseif cmd[1] == "kick" and moderator then
            if myMod.CheckPlayerValidity(pid, cmd[2]) then
                local targetPlayer = tonumber(cmd[2])
                local targetPlayerName = Players[targetPlayer].name
                local message
                
                if Players[targetPlayer]:IsAdmin() then
                    message = "You cannot kick an Admin from the server\n"
                    tes3mp.sendMessage(pid, message, 0)
                elseif Players[targetPlayer]:IsModerator() and not admin then
                    message = "You cannot kick a fellow Moderator from the server\n"
                    tes3mp.sendMessage(pid, message, 0)
                else
                    message = targetPlayerName .. " was kicked from the server by " .. pname .. "!\n"
                    tes3mp.sendMessage(pid, message, 1)
                    Players[targetPlayer]:kick()
                end
            end

        elseif cmd[1] == "addmoderator" and admin then
            if myMod.CheckPlayerValidity(pid, cmd[2]) then
                local targetPlayer = tonumber(cmd[2])
                local targetPlayerName = Players[targetPlayer].name
                local message

                if Players[targetPlayer]:IsAdmin() then
                    message = targetPlayerName .. " is already an Admin\n"
                    tes3mp.sendMessage(pid, message, 0)
                elseif Players[targetPlayer]:IsModerator() then
                    message = targetPlayerName .. " is already a Moderator\n"
                    tes3mp.sendMessage(pid, message, 0)
                else
                    message = targetPlayerName .. " was promoted to Moderator!\n"
                    tes3mp.sendMessage(pid, message, 1)
                    Players[targetPlayer].data.general.admin = 1
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
                    tes3mp.sendMessage(pid, message, 0)
                elseif Players[targetPlayer]:IsModerator() then
                    message = targetPlayerName .. " was demoted from Moderator!\n"
                    tes3mp.sendMessage(pid, message, 1)
                    Players[targetPlayer].data.general.admin = 0
                    Players[targetPlayer]:Save()
                else
                    message = targetPlayerName .. " is not a Moderator\n"
                    tes3mp.sendMessage(pid, message, 0)
                end
            end

        elseif cmd[1] == "superman" and moderator then
            -- Set Speed to 100
            tes3mp.setAttributeBase(pid, 4, 100)
            -- Set Athletics to 100
            tes3mp.setSkillBase(pid, 8, 100)
            -- Set Acrobatics to 400
            tes3mp.setSkillBase(pid, 20, 400)

            tes3mp.sendAttributes(pid)
            tes3mp.sendSkills(pid)

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
                        attrid = tes3mp.getAttributeId(cmd[3])
                    end

                    if attrid ~= -1 and attrid < tes3mp.getAttributeCount() then
                        tes3mp.setAttributeBase(targetPlayer, attrid, value)
                        tes3mp.sendAttributes(targetPlayer)

                        local message = targetPlayerName.."'s "..tes3mp.getAttributeName(attrid).." is now "..value.."\n"
                        tes3mp.sendMessage(pid, message, 1)
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
                        skillid = tes3mp.getSkillId(cmd[3])
                    end

                    if skillid ~= -1 and skillid < tes3mp.getSkillCount() then
                        tes3mp.setSkillBase(targetPlayer, skillid, value)
                        tes3mp.sendSkills(targetPlayer)

                        local message = targetPlayerName.."'s "..tes3mp.getSkillName(skillid).." is now "..value.."\n"
                        tes3mp.sendMessage(pid, message, 1)
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
            tes3mp.setExterior(pid, cmd[2], cmd[3])

        elseif cmd[1] == "getpos" and moderator then
            myMod.PrintPlayerPosition(pid, cmd[2])

        else
            local message = "Not a valid command. Type /help for more info.\n"
            tes3mp.sendMessage(pid, message, 0)
        end

        return 0 -- commands should be hidden
    end

    return 1 -- default behavior, chat messages should not
end

function onPlayerChangeAttributes(pid)
    myMod.onPlayerChangeAttributes(pid)
end

function onPlayerChangeSkills(pid)
    myMod.onPlayerChangeSkills(pid)
end

function onPlayerChangeLevel(pid)
    myMod.onPlayerChangeLevel(pid)
end

function onPlayerChangeCell(pid)
    myMod.onPlayerChangeCell(pid)
end

function onPlayerChangeEquipment(pid)
    myMod.onPlayerChangeEquipment(pid)
end

function onPlayerChangeInventory(pid)
    myMod.onPlayerChangeInventory(pid)
end

function onPlayerEndCharGen(pid)
    myMod.onPlayerEndCharGen(pid)
end

function onGuiAction(pid, idGui, data)
    if myMod.onGuiAction(pid, idGui, data) then return end -- if myMod.onGuiAction is called
end
