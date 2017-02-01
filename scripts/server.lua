require('utils')
require('config')
class = require('classy')

require('guiIds')
myMod = require("myMod")

Player = nil
Cell = nil

if (config.dbtype ~= nil or config.dbtype ~="file") and doesModuleExist("luasql."..config.dbtype) then
    dbdriver = require("luasql." .. config.dbtype)
    print(dbdriver._VERSION)
    Player = require("player.sql")
    Cell = require("cell.sql")
else
    Player = require("player.file")
    Cell = require("cell.file")
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
/removemoderator <pid> - Demote player from moderator"


function OnServerInit()

    local version = tes3mp.GetServerVersion():split(".") -- for future versions

    if tes3mp.GetServerVersion() ~= "0.4.1" then
        print("The server or script is outdated!")
        tes3mp.StopServer(1)
    end

    myMod.PushPlayerList(Players)
end

function OnServerExit(err)
    print(err)
end

function OnPlayerConnect(pid)
    tes3mp.SetConsoleAllow(pid, config.allowConsole)

    local pname = tes3mp.GetName(pid)

    if myMod.IsPlayerNameLoggedIn(pname) then
        myMod.OnPlayerDeny(pid, pname)
        return 0 -- deny player
    else
        print("New player with pid("..pid..") connected!")
        myMod.OnPlayerConnect(pid, pname)
        return 1 -- accept player
    end
end

function OnLogin(pid) -- timer-based event, see myMod.OnPlayerConnect
    myMod.AuthCheck(pid)
end

function OnPlayerDisconnect(pid)
    print("Player with pid("..pid..") disconnected.")
    local pname = tes3mp.GetName(pid)
    local message = pname.." ("..pid..") ".."left the server.\n"
    tes3mp.SendMessage(pid, message, 1)

    -- Trigger any necessary script events useful for saving state
    myMod.OnPlayerCellChange(pid)

    myMod.OnPlayerDisconnect(pid)
end

require("deathReasons")

function OnPlayerDeath(pid, reason, killerId)
    local pname = tes3mp.GetName(pid)
    local message = ("%s (%d) %s"):format(pname, pid, reasons.GetReasonName(reason))

    if reason == reasons.killed then
       message = ("%s by %s (%d)"):format(message, tes3mp.GetName(killerId), killerId)
    end

    message = message .. ".\n"
    tes3mp.SendMessage(pid, message, 1)
    tes3mp.Resurrect(pid)
end

function OnPlayerResurrect(pid)
end

function OnPlayerSendMessage(pid, message)
    local pname = tes3mp.GetName(pid)
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

            for i = 0, (tes3mp.GetAttributeCount() - 1) do
                tes3mp.SetAttributeBase(pid, i, 666)
            end

            for i = 0, (tes3mp.GetSkillCount() - 1) do
                tes3mp.SetSkillBase(pid, i, 666);
            end

            tes3mp.SendAttributes(pid)
            tes3mp.SendSkills(pid)

        elseif cmd[1] == "players" or cmd[1] == "list" then
            GUI.ShowPlayerList(pid)

        elseif cmd[1] == "cells" then
            GUI.ShowCellList(pid)

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
                    tes3mp.SendMessage(pid, message, 0)
                elseif Players[targetPlayer]:IsModerator() and not admin then
                    message = "You cannot kick a fellow Moderator from the server\n"
                    tes3mp.SendMessage(pid, message, 0)
                else
                    message = targetPlayerName .. " was kicked from the server by " .. pname .. "!\n"
                    tes3mp.SendMessage(pid, message, 1)
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
                    tes3mp.SendMessage(pid, message, 0)
                elseif Players[targetPlayer]:IsModerator() then
                    message = targetPlayerName .. " is already a Moderator\n"
                    tes3mp.SendMessage(pid, message, 0)
                else
                    message = targetPlayerName .. " was promoted to Moderator!\n"
                    tes3mp.SendMessage(pid, message, 1)
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
                    tes3mp.SendMessage(pid, message, 0)
                elseif Players[targetPlayer]:IsModerator() then
                    message = targetPlayerName .. " was demoted from Moderator!\n"
                    tes3mp.SendMessage(pid, message, 1)
                    Players[targetPlayer].data.general.admin = 0
                    Players[targetPlayer]:Save()
                else
                    message = targetPlayerName .. " is not a Moderator\n"
                    tes3mp.SendMessage(pid, message, 0)
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
                        tes3mp.SendMessage(pid, message, 1)
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
                        tes3mp.SendMessage(pid, message, 1)
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

        else
            local message = "Not a valid command. Type /help for more info.\n"
            tes3mp.SendMessage(pid, message, 0)
        end

        return 0 -- commands should be hidden
    end

    return 1 -- default behavior, chat messages should not
end

function OnPlayerAttributesChange(pid)
    myMod.OnPlayerAttributesChange(pid)
end

function OnPlayerSkillsChange(pid)
    myMod.OnPlayerSkillsChange(pid)
end

function OnPlayerLevelChange(pid)
    myMod.OnPlayerLevelChange(pid)
end

function OnPlayerCellChange(pid)
    myMod.OnPlayerCellChange(pid)
end

function OnPlayerCellState(pid, action)
    myMod.OnPlayerCellState(pid, action)
end

function OnPlayerEquipmentChange(pid)
    myMod.OnPlayerEquipmentChange(pid)
end

function OnPlayerInventoryChange(pid)
    myMod.OnPlayerInventoryChange(pid)
end

function OnPlayerSpellbookChange(pid, action)
    myMod.OnPlayerSpellbookChange(pid, action)
end

function OnPlayerEndCharGen(pid)
    myMod.OnPlayerEndCharGen(pid)
end

function OnObjectPlace(pid, cellDescription)
    myMod.OnObjectPlace(pid, cellDescription)
end

function OnObjectDelete(pid, cellDescription)
    myMod.OnObjectDelete(pid, cellDescription)
end

function OnGUIAction(pid, idGui, data)
    if myMod.OnGUIAction(pid, idGui, data) then return end -- if myMod.OnGUIAction is called
end
