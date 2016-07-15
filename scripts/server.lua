myMod = require("myMod")
Player = require("player")

Players = {}


function OnServerInit()
	myMod.PushPlayerList(Players)
end

function OnServerExit(err)

end

function OnPlayerConnect(pid)
	print("New player with pid("..pid..") connected!")
	myMod.OnPlayerConnect(pid)
	return 1 -- accept player (0 deny)
end

function OnLogin(pid) -- timer-based event see myMod.OnPlayerConnect
	myMod.AuthCheck(pid)
end

function OnPlayerDisconnect(pid)
end

function OnPlayerDeath(pid)
    tes3mp.Resurrect(pid)
end

function OnPlayerResurrect(pid)
end

function OnPlayerChangeCell(pid)
	local curCell = tes3mp.GetCell(pid);
	if curCell ~= "ToddTest" or not tes3mp.IsInInterior(pid) then
		--tes3mp.SetCell(pid, "ToddTest")
	end
end

function OnPlayerUpdateEquiped(pid)
end

function OnPlayerSendMessage(pid, message)
	local pname = tes3mp.GetName(pid)
	print(pname.."("..pid.."): "..message)
	
	if myMod.OnPlayerMessage(pid, message) == 0 then
		return 0
	end
	
	if message:sub(1,1) == '/' then
		local cmd = (message:sub(2, #message)):split(" ")
		if cmd[1] == "cheat" then
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
		elseif cmd[1] == "teleport" or cmd[1] == "tp" then
			myMod.TeleportToPlayer(pid, cmd[2], pid)
		elseif cmd[1] == "teleportto" or cmd[1] == "tpto" then
			myMod.TeleportToPlayer(pid, pid, cmd[2])
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

