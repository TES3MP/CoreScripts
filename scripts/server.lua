myMod = require("myMod")
Player = require("player")

local helptext = "\nCommand list:\
/list - List all players on the server\
\
Moderators only:\
/superman - Increase acrobatics, athletics and speed\
/teleport (<pid>/all) - Teleport another player to your position (/tp)\
/teleportto <pid> - Teleport yourself to another player (/tpto)\
/getpos <pid> - Get player position and cell\
/setattr <pid> <attribute> <value> - Set a player's attribute to a certain value\
/setskill <pid> <skill> <value> - Set a player's skill to a certain value\
/kick <pid> - Kick player\
\
Admins only:\
/setmoderator <pid> - Promote player to moderator\
\n"

function OnServerInit()
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

function OnLogin(pid) -- timer-based event see myMod.OnPlayerConnect
	local pname = tes3mp.GetName(pid)
	local message = pname.." ("..pid..") ".."joined the server.\n"
	tes3mp.SendMessage(pid, message, 1)
	myMod.AuthCheck(pid)
end

function OnPlayerDisconnect(pid)
	print("Player with pid("..pid..") disconnected.")
	local pname = tes3mp.GetName(pid)
	local message = pname.." ("..pid..") ".."left the server.\n"
	tes3mp.SendMessage(pid, message, 1)
	myMod.OnPlayerDisconnect(pid)
end

function OnPlayerDeath(pid)
	local pname = tes3mp.GetName(pid)
	local message = pname.." ("..pid..") ".."died.\n"
	tes3mp.SendMessage(pid, message, 1)
	tes3mp.Resurrect(pid)
end

function OnPlayerResurrect(pid)
end

function OnPlayerChangeCell(pid)
end

function OnPlayerUpdateEquiped(pid)
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
			tes3mp.SendMessage(pid, helptext, 0)
		elseif cmd[1] == "cheat" and moderator then
			for i=0,7 do
				tes3mp.SetAttribute(pid, i, 666)
			end
			for i=0,26 do
				tes3mp.SetSkill(pid, i, 666);
			end
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
				local message = targetPlayerName.." was kicked from the server!\n"
				tes3mp.SendMessage(pid, message, 1)
				Players[tonumber(targetPlayer)]:Kick()
			end
		elseif cmd[1] == "setmoderator" and admin then
			local targetPlayer = cmd[2]
			if myMod.CheckPlayerValidity(pid, targetPlayer) then
				local targetPlayerName = Players[tonumber(targetPlayer)].name
				local message = targetPlayerName.." was promoted to Moderator!\n"
				tes3mp.SendMessage(pid, message, 1)
				Players[tonumber(targetPlayer)].data.general.admin = 1
				Players[tonumber(targetPlayer)]:Save()
			end
		elseif cmd[1] == "superman" and moderator then
			-- Set Speed to 100
			tes3mp.SetAttribute(pid, 4, 100)
			-- Set Athletics to 100
			tes3mp.SetSkill(pid, 8, 100)
			-- Set Acrobatics to 400
			tes3mp.SetSkill(pid, 20, 400)

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

					if skillid ~= -1 then
						tes3mp.SetAttribute(targetPlayer, attrid, value)
						tes3mp.SendAttributes(targetPlayer)

						local message = targetPlayerName.."'s "..tes3mp.GetAttributeName(attrid).." is now "..value.."\n"
						tes3mp.SendMessage(pid, message, 0)
						Players[tonumber(targetPlayer)]:UpdateAttributes()
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

					if skillid ~= -1 then
						tes3mp.SetSkill(targetPlayer, skillid, value)
						tes3mp.SendSkills(targetPlayer)

						local message = targetPlayerName.."'s "..tes3mp.GetSkillName(skillid).." is now "..value.."\n"
						tes3mp.SendMessage(pid, message, 0)
						Players[tonumber(targetPlayer)]:UpdateSkills()
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

function OnPlayerEndCharGen(pid)
	myMod.OnPlayerEndCharGen(pid)
end

function OnGUIAction(pid, idGui, data)
	
end
