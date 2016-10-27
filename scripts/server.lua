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


function OnServerInit()
    local version = tes3mp.GetServerVersion():split(".") -- for future versions

    if tes3mp.GetServerVersion() ~= "0.3.0" then
        print("The server or script is outdated!")
        tes3mp.StopServer(1)
    end

    myMod.PushPlayerList(Players)
end

function OnServerExit(err)
    print(err)
end

function OnPlayerConnect(pid)
    print("New player with pid("..pid..") connected!")
    myMod.OnPlayerConnect(pid)
    return 1 -- accept player (0 deny)
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
    myMod.OnPlayerChangeCell(pid)

    myMod.OnPlayerDisconnect(pid)
end

require("deathReasons")

function OnPlayerDeath(pid, reason, kid)
    local pname = tes3mp.GetName(pid)
    local message = ("%s (%d) %s"):format(pname, pid, reasons.GetReasonName(reason))
    if reason == reasons.killed then
       message = ("%s by %s (%d)"):format(message, tes3mp.GetName(kid), kid)
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

        if cmd[1] == "help" then
            local text = helptext .. "\n";
            if moderator then
                text = text .. modhelptext .. "\n"
            end
            if admin then
                text = text .. adminhelptext .. "\n"
            end
            tes3mp.SendMessage(pid, text, 0)

        elseif cmd[1] == "cheat" and moderator then
            
            for i = 0, (tes3mp.GetAttributeCount() - 1) do
                tes3mp.SetAttributeBase(pid, i, 666)
            end

            for i = 0, (tes3mp.GetSkillCount() - 1) do
                tes3mp.SetSkillBase(pid, i, 666);
            end

            tes3mp.SendAttributes(pid)
            tes3mp.SendSkills(pid)

        elseif cmd[1] == "list" then
            local text
            if myMod.GetConnectedPlayerNumber() == 1 then
                text = "player"
            else
                text = "players"
            end
            local message = myMod.GetConnectedPlayerNumber() .. " connected " .. text .. ": " .. myMod.GetConnectedPlayerList() .. "\n"
            tes3mp.SendMessage(pid, message, 0)

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
            local targetPlayer = cmd[2]
            if myMod.CheckPlayerValidity(pid, targetPlayer) then           
                local targetPlayerName = Players[tonumber(targetPlayer)].name
                local message = targetPlayerName .. " was kicked from the server!\n"
                if Players[targetPlayer]:IsModerator() and not admin or Players[targetPlayer]:IsAdmin() then
                    message = "You cannot kick admin from the server"
                else
                    Players[tonumber(targetPlayer)]:Kick()
                end     
                tes3mp.SendMessage(pid, message, 1)
            end

        elseif cmd[1] == "addmoderator" and admin then
            local targetPlayer = cmd[2]
            if myMod.CheckPlayerValidity(pid, targetPlayer) then
                local targetPlayerName = Players[tonumber(targetPlayer)].name
                local message = targetPlayerName .. " was promoted to Moderator!\n"
                tes3mp.SendMessage(pid, message, 1)
                Players[tonumber(targetPlayer)].data.general.admin = 1
                Players[tonumber(targetPlayer)]:Save()
            end
        
        elseif cmd[1] == "removemoderator" and admin then
            local targetPlayer = cmd[2]
            if myMod.CheckPlayerValidity(pid, targetPlayer) then
                local targetPlayerName = Players[tonumber(targetPlayer)].name
                local message = targetPlayerName .. " was demoted from Moderator!\n"
                tes3mp.SendMessage(pid, message, 1)
                Players[tonumber(targetPlayer)].data.general.admin = 0
                Players[tonumber(targetPlayer)]:Save()
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

            local targetPlayer = cmd[2]
            if myMod.CheckPlayerValidity(pid, targetPlayer) then
                local targetPlayerName = Players[tonumber(targetPlayer)].name

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
                        tes3mp.SendMessage(pid, message, 0)
                        Players[tonumber(targetPlayer)]:SaveAttributes()
                    end
                end
            end

        elseif cmd[1] == "setskill" and moderator then

            local targetPlayer = cmd[2]
            if myMod.CheckPlayerValidity(pid, targetPlayer) then
                local targetPlayerName = Players[tonumber(targetPlayer)].name

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
                        tes3mp.SendMessage(pid, message, 0)
                        Players[tonumber(targetPlayer)]:SaveSkills()
                    end
                end
            end

        elseif cmd[1] == "help" then
            tes3mp.MessageBox(pid, 1, helptext)

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

function OnPlayerChangeAttributes(pid)
    myMod.OnPlayerChangeAttributes(pid)
end

function OnPlayerChangeSkills(pid)
    myMod.OnPlayerChangeSkills(pid)
end

function OnPlayerChangeLevel(pid)
    myMod.OnPlayerChangeLevel(pid)
end

function OnPlayerChangeCell(pid)
    myMod.OnPlayerChangeCell(pid)
end

function OnPlayerChangeEquipment(pid)
    myMod.OnPlayerChangeEquipment(pid)
end

function OnPlayerEndCharGen(pid)
    myMod.OnPlayerEndCharGen(pid)
end

function OnGUIAction(pid, idGui, data)
    
end
