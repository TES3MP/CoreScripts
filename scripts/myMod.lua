local time =require('time')
function string:split(sep)
        local sep, fields = sep or ":", {}
        local pattern = string.format("([^%s]+)", sep)
        self:gsub(pattern, function(c) fields[#fields+1] = c end)
        return fields
end
local Methods = {}

Players = {}

Methods.CheckPlayerValidity = function(pid, targetPlayer)
	local valid = false
	if targetPlayer ~= nil and type(tonumber(targetPlayer)) == "number" then
		if tonumber(targetPlayer) >=0 and tonumber(targetPlayer) <= #Players then
			if Players[tonumber(targetPlayer)]:IsLoggedOn() then
				valid = true
			else
				local message = "That player is not logged on!\n"
				tes3mp.SendMessage(pid, message, 0)
			end
		else
			local message = "That player is not logged on!\n"
			tes3mp.SendMessage(pid, message, 0)
		end
	else
		local message = "Please specify the player ID.\n"
		tes3mp.SendMessage(pid, message, 0)
	end
	return valid
end

Methods.TeleportToPlayer = function(pid, originPlayer, targetPlayer)
	if Methods.CheckPlayerValidity(pid, originPlayer) and Methods.CheckPlayerValidity(pid, targetPlayer) then
		if tonumber(originPlayer) ~= tonumber(targetPlayer) then
			local originPlayerName = Players[tonumber(originPlayer)].name
			local targetPlayerName = Players[tonumber(targetPlayer)].name
			local targetCell = ""
			local targetCellName
			local targetPos = {0, 0, 0}
			targetPos[0] = tes3mp.GetPosX(targetPlayer)
			targetPos[1] = tes3mp.GetPosY(targetPlayer)
			targetPos[2] = tes3mp.GetPosZ(targetPlayer)
			targetCell = tes3mp.GetCell(targetPlayer)
			if targetCell ~= "" then
				targetCellName = targetCell
			else
				targetCellName = "Exterior"
				if tes3mp.IsInInterior(originPlayer) then
					-- We need a SetCell like function that brings people to the exterior, like "coc Balmora" does
				end
			end
			local originMessage = "You have been teleported to " .. targetPlayerName .. "'s location. (" .. targetCellName .. ")\n"
			local targetMessage = "Teleporting ".. originPlayerName .." to your location.\n"
			tes3mp.SendMessage(originPlayer, originMessage, 0)
			tes3mp.SendMessage(targetPlayer, targetMessage, 0)
			tes3mp.SetCell(originPlayer,targetCell)
			tes3mp.SetPos(originPlayer, targetPos[0], targetPos[1], targetPos[2])
		else
			local message = "You can't teleport to yourself.\n"
			tes3mp.SendMessage(pid, message, 0)
		end
	end
end

Methods.GetConnectedPlayerNumber = function()
	local playernumber = 0
	for i=0,#Players do
		if Players[i]:IsLoggedOn() then
			playernumber = playernumber + 1
		end
	end
	return playernumber
end

Methods.GetConnectedPlayerList = function()
	local list = ""
	local divider = ""
	for i=0,#Players do
		if i == #Players then
			divider = ""
		else
			divider = ", "
		end
		if Players[i]:IsLoggedOn() then
			list = list .. tostring(Players[i].name) .. " (" .. tostring(Players[i].pid) .. ")" .. divider
		end
	end
	return list
end

Methods.PushPlayerList = function(pls)
	Players = pls
end

Methods.testFunction = function()
      print("testFunction: Test function called")
      print(Players[0])
end

Methods.OnPlayerConnect = function(pid)
	Players[pid] = Player.new(pid)
	local login_time = 10
	local pname = tes3mp.GetName(pid)
	Players[pid].name = pname
	local message = "Welcome "..pname.."\nYou have "..tostring(login_time).." seconds to register (/reg) or login (/login).\n"
	tes3mp.SendMessage(pid, message, 0)
	Players[pid].tid_login = tes3mp.CreateTimerEx("OnLogin", time.seconds(login_time), "i", pid)
	tes3mp.StartTimer(Players[pid].tid_login);
end

Methods.OnPlayerDisconnect = function(pid)
	Players[pid]:Destroy()
end

Methods.OnPlayerMessage = function(pid, message)
	if message:sub(1,1) ~= '/' then return 1 end
	
	local cmd = (message:sub(2, #message)):split(" ")
	
	if cmd[1] == "register" or cmd[1] == "reg" then
		if Players[pid]:IsLoggedOn() then
			Players[pid]:Message("You are already logged in.\n")
			return 0
		elseif Players[pid]:HasAccount() then
			Players[pid]:Message("You already have an account. Try \"/login password\".\n")
			return 0
		elseif cmd[2] == nil then
			Players[pid]:Message("Incorrect password!\n")
			return 0 
		end
		Players[pid]:Registered(cmd[2])
		return 0
	elseif cmd[1] == "login" then
		if Players[pid]:IsLoggedOn() then
			Players[pid]:Message("You are already logged in.\n")
			return 0
		elseif not Players[pid]:HasAccount() then
			Players[pid]:Message("You do not have an account. Try \"/register password\".\n")
			return 0
		elseif cmd[2] == nil then
			Players[pid]:Message("Password can not be empty\n")
			return 0 
		end
		Players[pid]:Load()
		if Players[pid].data.general.password ~= cmd[2] then
			Players[pid]:Message("Incorrect password!\n")
            return 0
		end
		Players[pid]:LoggedOn()
		return 0
	end
	
	return 1
end

Methods.AuthCheck = function(pid)
	if Players[pid]:IsLoggedOn() then
		return
	end
	
	tes3mp.SendMessage(pid, "You are not authorized!\n", 0)
	Players[pid]:Kick()
	Players[pid] = nil
end

Methods.OnPlayerEndCharGen = function(pid)
	Players[pid]:UpdateGeneral()
	Players[pid]:UpdateSkills()
	Players[pid]:UpdateAttributes()
	Players[pid]:UpdateCharacter()
	Players[pid]:CreateAccount()
end

return Methods
