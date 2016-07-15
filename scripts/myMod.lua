local time =require('time')
function string:split(sep)
        local sep, fields = sep or ":", {}
        local pattern = string.format("([^%s]+)", sep)
        self:gsub(pattern, function(c) fields[#fields+1] = c end)
        return fields
end
local Methods = {}

local Players

Methods.TeleportToPlayer = function(pid, originPlayer, targetPlayer)
	if originPlayer ~= nil and targetPlayer ~= nil and type(tonumber(originPlayer)) == "number" and type(tonumber(targetPlayer)) == "number" then
		if tonumber(originPlayer) >= 0 and tonumber(originPlayer) <= #Players and tonumber(targetPlayer) >= 0 and tonumber(targetPlayer) <= #Players then
			if Players[tonumber(originPlayer)]:IsLoggedOn() and Players[tonumber(targetPlayer)]:IsLoggedOn() then
				local originPlayerName = tes3mp.GetName(originPlayer)
				local targetPlayerName = tes3mp.GetName(targetPlayer)
				local targetCell
				if tes3mp.IsInInterior(targetPlayer) then
					targetCell = tes3mp.GetCell(targetPlayer)
				else
					targetCell = tes3mp.GetCell(targetPlayer) -- Placeholder
				end
				if targetCell == nil then
					targetCell = "ToddTest"
				end
				local originMessage = "You have been teleported to " .. targetPlayerName .. "'s location. (" .. targetCell .. ")\n"
				local targetMessage = "Teleporting ".. originPlayerName .." to your location.\n"
				tes3mp.SendMessage(originPlayer, originMessage, 0)
				tes3mp.SendMessage(targetPlayer, targetMessage, 0)
				tes3mp.SetCell(originPlayer,targetCell)
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
end

Methods.GetConnectedPlayerNumber = function()
	return #Players+1
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
		list = list .. tostring(Players[i].name) .. " (" .. tostring(Players[i].pid) .. ")" .. divider
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
    Players[pid] = nil
end

Methods.OnPlayerMessage = function(pid, message)
	if message:sub(1,1) ~= '/' then return 1 end
	
	local cmd = (message:sub(2, #message)):split(" ")
	
	if cmd[1] == "register" or cmd[1] == "reg" then
		if Players[pid]:IsLoggedOn() then
			Players[pid]:Message("You are already logged in.")
			return 0
		elseif Players[pid]:HasAccount() then
			Players[pid]:Message("You already have an account. Try \"/login password\".")
			return 0
		elseif cmd[2] == nil then
			Players[pid]:Message("Incorrect password!")
			return 0 
		end
		Players[pid]:Registered(cmd[2])
		return 0
	elseif cmd[1] == "login" then
		if Players[pid]:IsLoggedOn() then
			Players[pid]:Message("You are already logged in.")
			return 0
		elseif not Players[pid]:HasAccount() then
			Players[pid]:Message("You do not have an account. Try \"/register password\".")
			return 0
		elseif cmd[2] == nil then
			Players[pid]:Message("Password can not be empty")
			return 0 
		end
		Players[pid]:Load()
		if Players[pid].data.general.password ~= cmd[2] then
			Players[pid]:Message("Incorrect password!")
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
