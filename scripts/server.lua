myMod = require("myMod")
Player = require("player")

local helptext = "\nCommand list:\
/list - List all players on the server\
\
Moderators only:\
/superman - Increasce acrobatics and speed\
/teleport (<pid>/all) - Teleport another player to your position (/tp)\
/teleportto <pid> - Teleport yourself to another player (/tpto)\
/gepos <pid> - Get player position and cell\
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
			tes3mp.SetAttribute(pid, 4, 400)
			tes3mp.SetSkill(pid, 20, 200);
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

function OnPlayerEndCharGen(pid)
	myMod.OnPlayerEndCharGen(pid)
end

function OnGUIAction(pid, idGui, data)
	
end
