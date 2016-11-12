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
    local sendMessage = true
    if pid == nil then
        sendMessage = false
    end
    if targetPlayer ~= nil and type(tonumber(targetPlayer)) == "number" then
        if tonumber(targetPlayer) >=0 and tonumber(targetPlayer) <= #Players then
            if Players[tonumber(targetPlayer)]:IsLoggedOn() then
                valid = true
            else
                if sendMessage then
                    local message = "That player is not logged on!\n"
                    tes3mp.SendMessage(pid, message, 0)
                end
            end
        else
            if sendMessage then
                local message = "That player is not logged on!\n"
                tes3mp.SendMessage(pid, message, 0)
            end
        end
    else
        if sendMessage then
            local message = "Please specify the player ID.\n"
            tes3mp.SendMessage(pid, message, 0)
        end
    end
    return valid
end

Methods.TeleportToPlayer = function(pid, originPlayer, targetPlayer)
    if (not Methods.CheckPlayerValidity(pid, originPlayer)) or (not Methods.CheckPlayerValidity(pid, targetPlayer)) then
        return
    elseif tonumber(originPlayer) == tonumber(targetPlayer) then
        local message = "You can't teleport to yourself.\n"
        tes3mp.SendMessage(pid, message, 0)
        return
    end

    local originPlayerName = Players[tonumber(originPlayer)].name
    local targetPlayerName = Players[tonumber(targetPlayer)].name
    local targetCell = ""
    local targetCellName
    local targetPos = {0, 0, 0}
    local targetAngle = {0, 0, 0}
    local targetGrid = {0, 0}
    targetPos[0] = tes3mp.GetPosX(targetPlayer)
    targetPos[1] = tes3mp.GetPosY(targetPlayer)
    targetPos[2] = tes3mp.GetPosZ(targetPlayer)
    targetAngle[0] = tes3mp.GetAngleX(targetPlayer)
    targetAngle[1] = tes3mp.GetAngleY(targetPlayer)
    targetAngle[2] = tes3mp.GetAngleZ(targetPlayer)
    targetGrid[0] = tes3mp.GetExteriorX(targetPlayer)
    targetGrid[1] = tes3mp.GetExteriorY(targetPlayer)
    targetCell = tes3mp.GetCell(targetPlayer)

    if tes3mp.IsInExterior(targetPlayer) == 1 then
        targetCellName = "Exterior "..targetGrid[0]..", "..targetGrid[1]..""
        tes3mp.SetExterior(originPlayer, targetGrid[0], targetGrid[1])
    else
        targetCellName = targetCell
        tes3mp.SetCell(originPlayer, targetCell)
    end

    tes3mp.SetPos(originPlayer, targetPos[0], targetPos[1], targetPos[2])
    tes3mp.SetAngle(originPlayer, targetAngle[0], targetAngle[1], targetAngle[2])
    
    tes3mp.SendCell(originPlayer)
    tes3mp.SendPos(originPlayer)

    local originMessage = "You have been teleported to " .. targetPlayerName .. "'s location. (" .. targetCellName .. ")\n"
    local targetMessage = "Teleporting ".. originPlayerName .." to your location.\n"
    tes3mp.SendMessage(originPlayer, originMessage, 0)
    tes3mp.SendMessage(targetPlayer, targetMessage, 0)
end

Methods.GetConnectedPlayerNumber = function()
    local playerNumber = 0
    for i=0,#Players do
        if Players[i]:IsLoggedOn() then
            playerNumber = playerNumber + 1
        end
    end
    return playerNumber
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

Methods.PrintPlayerPosition = function(pid, targetPlayer)
    if not Methods.CheckPlayerValidity(pid, targetPlayer) then
        return
    end
    local message = ""
    local targetPlayerName = Players[tonumber(targetPlayer)].name
    local targetCell = ""
    local targetCellName = ""
    local targetPos = {0, 0, 0}
    local targetGrid = {0, 0}
    targetPos[0] = tes3mp.GetPosX(targetPlayer)
    targetPos[1] = tes3mp.GetPosY(targetPlayer)
    targetPos[2] = tes3mp.GetPosZ(targetPlayer)
    targetCell = tes3mp.GetCell(targetPlayer)
    if targetCell ~= "" then
        targetCellName = targetCell
    else
        targetGrid[0] = tes3mp.GetExteriorX(targetPlayer)
        targetGrid[1] = tes3mp.GetExteriorY(targetPlayer)
        targetCellName = "Exterior ("..targetGrid[0]..", "..targetGrid[1]..")"
    end
    message = targetPlayerName.." ("..targetPlayer..") is in "..targetCellName.." at ["..targetPos[0].." "..targetPos[1].." "..targetPos[2].."]\n"
    tes3mp.SendMessage(pid, message, 0)
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
    local login_time = 60
    local pname = tes3mp.GetName(pid)
    -- pname = pname:gsub('%W','') -- Remove all non alphanumeric characters
    -- pname = pname:gsub("^%s*(.-)%s*$", "%1") -- Remove leading and trailing whitespaces
    Players[pid].name = pname

    local message = pname.." ("..pid..") ".."joined the server.\n"
    tes3mp.SendMessage(pid, message, 1)

    message = "Welcome " .. pname .. "\nYou have "..tostring(login_time).." seconds to"

    if Players[pid]:HasAccount() then
        message = message .. " login.\n"
        GUI.ShowLogin(pid)
    else
        message = message .. " register.\n"
        GUI.ShowRegister(pid)
    end

    tes3mp.SendMessage(pid, message, 0)

    Players[pid].tid_login = tes3mp.CreateTimerEx("OnLogin", time.seconds(login_time), "i", pid)
    tes3mp.StartTimer(Players[pid].tid_login);
end

Methods.OnPlayerDisconnect = function(pid)

    if Players[pid] ~= nil then
        Players[pid]:Destroy()
    end
end

Methods.OnGUIAction = function(pid, idGui, data)
    data = tostring(data) -- data can be numeric, but we should convert this to string
    if idGui == GUI.ID.LOGIN then
        if data == nil then
            Players[pid]:Message("Incorrect password!\n")
            GUI.ShowLogin(pid)
            return true
        end

        Players[pid]:Load()

        -- Just in case the password from the data file is a number, make sure to turn it into a string
        if tostring(Players[pid].data.general.password) ~= data then
            Players[pid]:Message("Incorrect password!\n")
            GUI.ShowLogin(pid)
            return true
        end
        Players[pid]:LoggedOn()
    elseif idGui == GUI.ID.REGISTER then
        if data == nil then
            Players[pid]:Message("Password can not be empty\n")
            GUI.ShowRegister(pid)
            return true
        end
        Players[pid]:Registered(data)
    end
    return false
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
            Players[pid]:Message("Password cannot be empty\n")
            return 0
        end
        Players[pid]:Load()
        -- Just in case the password from the data file is a number, make sure to turn it into a string
        if tostring(Players[pid].data.general.password) ~= cmd[2] then
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

    local pname = tes3mp.GetName(pid)
    local message = pname.." ("..pid..") ".."failed to log in.\n"
    tes3mp.SendMessage(pid, message, 1)
    Players[pid]:Kick()

    Players[pid] = nil
end

Methods.OnPlayerChangeAttributes = function(pid)
    if Players[pid] ~= nil and Players[pid]:IsLoggedOn() then
        Players[pid]:SaveAttributes()
    end
end

Methods.OnPlayerChangeSkills = function(pid)
    if Players[pid] ~= nil and Players[pid]:IsLoggedOn() then
        Players[pid]:SaveSkills()
    end
end

Methods.OnPlayerChangeLevel = function(pid)
    if Players[pid] ~= nil and Players[pid]:IsLoggedOn() then
        Players[pid]:SaveLevel()
        Players[pid]:SaveDynamicStats()
    end
end

Methods.OnPlayerChangeCell = function(pid)
    if Players[pid] ~= nil and Players[pid]:IsLoggedOn() then
        Players[pid]:SaveCell()
        Players[pid]:SaveDynamicStats()
        print("Saving player " .. pid)
        Players[pid]:Save()
    end
end

Methods.OnPlayerChangeEquipment = function(pid)
    if Players[pid] ~= nil and Players[pid]:IsLoggedOn() then
        Players[pid]:SaveEquipment()
    end
end

Methods.OnPlayerEndCharGen = function(pid)
    Players[pid]:SaveGeneral()
    Players[pid]:SaveCharacter()
    Players[pid]:SaveClass()
    Players[pid]:SaveDynamicStats()
    Players[pid]:SaveEquipment()
    Players[pid]:CreateAccount()
end

return Methods
