local time = require("time")
local Methods = {}

Players = {}
LoadedCells = {}

Methods.CheckPlayerValidity = function(pid, targetPlayer)

    local valid = false
    local sendMessage = true

    if pid == nil then
        sendMessage = false
    end

    if targetPlayer == nil or type(tonumber(targetPlayer)) ~= "number" then

        if sendMessage then
            local message = "Please specify the player ID.\n"
            tes3mp.SendMessage(pid, message, false)
        end

        return false
    end

    targetPlayer = tonumber(targetPlayer)

    if targetPlayer >= 0 and Players[targetPlayer] ~= nil and Players[targetPlayer]:IsLoggedIn() then
        valid = true
    end

    if valid == false then
        if sendMessage then
            local message = "That player is not logged in!\n"
            tes3mp.SendMessage(pid, message, false)
        end
    end
    
    return valid
end

-- Check if there is already a player with this name on the server
Methods.IsPlayerNameLoggedIn = function(newName)

    for pid, player in pairs(Players) do
        if player:IsLoggedIn() then
            if player.name == newName then
                return true
            end
        end
    end

    return false
end

Methods.TeleportToPlayer = function(pid, originPlayer, targetPlayer)
    if (not Methods.CheckPlayerValidity(pid, originPlayer)) or (not Methods.CheckPlayerValidity(pid, targetPlayer)) then
        return
    elseif tonumber(originPlayer) == tonumber(targetPlayer) then
        local message = "You can't teleport to yourself.\n"
        tes3mp.SendMessage(pid, message, false)
        return
    end

    local originPlayerName = Players[tonumber(originPlayer)].name
    local targetPlayerName = Players[tonumber(targetPlayer)].name
    local targetCell = ""
    local targetCellName
    local targetPos = {0, 0, 0}
    local targetRot = {0, 0, 0}
    local targetGrid = {0, 0}
    targetPos[0] = tes3mp.GetPosX(targetPlayer)
    targetPos[1] = tes3mp.GetPosY(targetPlayer)
    targetPos[2] = tes3mp.GetPosZ(targetPlayer)
    targetRot[0] = tes3mp.GetAngleX(targetPlayer)
    targetRot[1] = tes3mp.GetAngleY(targetPlayer)
    targetRot[2] = tes3mp.GetAngleZ(targetPlayer)
    targetGrid[0] = tes3mp.GetExteriorX(targetPlayer)
    targetGrid[1] = tes3mp.GetExteriorY(targetPlayer)
    targetCell = tes3mp.GetCell(targetPlayer)

    if tes3mp.IsInExterior(targetPlayer) == true then
        targetCellName = "Exterior "..targetGrid[0]..", "..targetGrid[1]..""
        tes3mp.SetExterior(originPlayer, targetGrid[0], targetGrid[1])
    else
        targetCellName = targetCell
        tes3mp.SetCell(originPlayer, targetCell)
    end

    tes3mp.SetPos(originPlayer, targetPos[0], targetPos[1], targetPos[2])
    tes3mp.SetAngle(originPlayer, targetRot[0], targetRot[1], targetRot[2])

    tes3mp.SendCell(originPlayer)
    tes3mp.SendPos(originPlayer)

    local originMessage = "You have been teleported to " .. targetPlayerName .. "'s location. (" .. targetCellName .. ")\n"
    local targetMessage = "Teleporting ".. originPlayerName .." to your location.\n"
    tes3mp.SendMessage(originPlayer, originMessage, false)
    tes3mp.SendMessage(targetPlayer, targetMessage, false)
end

Methods.GetConnectedPlayerCount = function()

    local playerCount = 0
    
    for pid, player in pairs(Players) do
        if player:IsLoggedIn() then
            playerCount = playerCount + 1
        end
    end

    return playerCount
end

Methods.GetLoadedCellCount = function()

    local cellCount = 0
    for cell in pairs(LoadedCells) do cellCount = cellCount + 1 end
    return cellCount
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
    tes3mp.SendMessage(pid, message, false)
end

Methods.PushPlayerList = function(pls)
    Players = pls
end

Methods.testFunction = function()
      print("testFunction: Test function called")
      print(Players[0])
end

Methods.OnPlayerConnect = function(pid, pname)
    Players[pid] = Player(pid)
    -- pname = pname:gsub('%W','') -- Remove all non alphanumeric characters
    -- pname = pname:gsub("^%s*(.-)%s*$", "%1") -- Remove leading and trailing whitespaces
    Players[pid].name = pname

    local message = pname.." ("..pid..") ".."joined the server.\n"
    tes3mp.SendMessage(pid, message, true)

    message = "Welcome " .. pname .. "\nYou have "..tostring(config.loginTime).." seconds to"

    if Players[pid]:HasAccount() then
        message = message .. " log in.\n"
        GUI.ShowLogin(pid)
    else
        message = message .. " register.\n"
        GUI.ShowRegister(pid)
    end

    tes3mp.SendMessage(pid, message, false)

    Players[pid].tid_login = tes3mp.CreateTimerEx("OnLoginTimeExpiration", time.seconds(config.loginTime), "i", pid)
    tes3mp.StartTimer(Players[pid].tid_login);
end

Methods.OnPlayerDeny = function(pid, pname)
    local message = pname.." ("..pid..") " .. "joined and tried to use an existing player's name.\n"
    tes3mp.SendMessage(pid, message, true)
end

Methods.OnPlayerDisconnect = function(pid)

    if Players[pid] ~= nil then

        -- Unload every cell for this player
        for index, loadedCellDescription in pairs(Players[pid].cellsLoaded) do

            Methods.UnloadCell(pid, loadedCellDescription)
        end

        Players[pid]:Destroy()
        Players[pid] = nil
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
        if tostring(Players[pid].data.login.password) ~= data then
            Players[pid]:Message("Incorrect password!\n")
            GUI.ShowLogin(pid)
            return true
        end
        Players[pid]:FinishLogin()
        Players[pid]:Message("You have successfully logged in.\n")
    elseif idGui == GUI.ID.REGISTER then
        if data == nil then
            Players[pid]:Message("Password can not be empty\n")
            GUI.ShowRegister(pid)
            return true
        end
        Players[pid]:Registered(data)
        Players[pid]:Message("You have successfully registered.\nUse Y by default to chat or change it from your client config.\n")
    end
    return false
end

Methods.OnPlayerMessage = function(pid, message)
    if message:sub(1,1) ~= '/' then return 1 end

    local cmd = (message:sub(2, #message)):split(" ")

    if cmd[1] == "register" or cmd[1] == "reg" then
        if Players[pid]:IsLoggedIn() then
            Players[pid]:Message("You are already logged in.\n")
            return false
        elseif Players[pid]:HasAccount() then
            Players[pid]:Message("You already have an account. Try \"/login password\".\n")
            return false
        elseif cmd[2] == nil then
            Players[pid]:Message("Incorrect password!\n")
            return false
        end
        Players[pid]:Registered(cmd[2])
        return false
    elseif cmd[1] == "login" then
        if Players[pid]:IsLoggedIn() then
            Players[pid]:Message("You are already logged in.\n")
            return false
        elseif not Players[pid]:HasAccount() then
            Players[pid]:Message("You do not have an account. Try \"/register password\".\n")
            return 0
        elseif cmd[2] == nil then
            Players[pid]:Message("Password cannot be empty\n")
            return false
        end
        Players[pid]:Load()
        -- Just in case the password from the data file is a number, make sure to turn it into a string
        if tostring(Players[pid].data.login.password) ~= cmd[2] then
            Players[pid]:Message("Incorrect password!\n")
            return false
        end
        Players[pid]:FinishLogin()
        return false
    end

    return true
end

Methods.AuthCheck = function(pid)
    if Players[pid]:IsLoggedIn() then
        return
    end

    local pname = tes3mp.GetName(pid)
    local message = pname.." ("..pid..") ".."failed to log in.\n"
    tes3mp.SendMessage(pid, message, true)
    Players[pid]:Kick()

    Players[pid] = nil
end

Methods.OnPlayerAttributesChange = function(pid)
    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
        Players[pid]:SaveAttributes()
    end
end

Methods.OnPlayerSkillsChange = function(pid)
    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
        Players[pid]:SaveSkills()
    end
end

Methods.OnPlayerLevelChange = function(pid)
    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
        Players[pid]:SaveLevel()
        Players[pid]:SaveDynamicStats()
    end
end

Methods.OnPlayerCellChange = function(pid)
    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
        Players[pid]:SaveCell()
        Players[pid]:SaveDynamicStats()
        print("Saving player " .. pid)
        Players[pid]:Save()
    end
end

Methods.LoadCell = function(pid, cellDescription)

    -- If this cell isn't loaded at all, load it
    if LoadedCells[cellDescription] == nil then

        LoadedCells[cellDescription] = Cell(cellDescription)
        LoadedCells[cellDescription].description = cellDescription

        -- If this cell has a data file, load it
        if LoadedCells[cellDescription]:HasFile() then
            LoadedCells[cellDescription]:Load()

            -- It's possible this file uses an older cell structure,
            -- so update to the current one
            if LoadedCells[cellDescription]:HasCurrentStructure() == false then
                LoadedCells[cellDescription]:UpdateStructure()
            end

        -- Otherwise, create a data file for it
        else
            LoadedCells[cellDescription]:CreateFile()
        end
    end

    -- Record that this player has the cell loaded
    LoadedCells[cellDescription]:AddVisitor(pid)
end

Methods.UnloadCell = function(pid, cellDescription)

    if LoadedCells[cellDescription] ~= nil then

        -- No longer record that this player has the cell loaded
        LoadedCells[cellDescription]:RemoveVisitor(pid)
        LoadedCells[cellDescription]:Save()

        -- If there are no visitors left, delete the cell
        if #LoadedCells[cellDescription].visitors == 0 then
            LoadedCells[cellDescription] = nil
        end
    end
end

Methods.OnPlayerCellState = function(pid)
    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then

        for i = 0, tes3mp.GetCellStateChangesSize(pid) - 1 do

            local cellDescription = tes3mp.GetCellStateDescription(pid, i)
            local stateType = tes3mp.GetCellStateType(pid, i)

            if stateType == 0 then
                Methods.LoadCell(pid, cellDescription)
            elseif stateType == 1 then
                Methods.UnloadCell(pid, cellDescription)
            end
        end
    end
end

Methods.OnPlayerEquipmentChange = function(pid)
    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
        Players[pid]:SaveEquipment()
    end
end

Methods.OnPlayerInventoryChange = function(pid)
    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
        Players[pid]:SaveInventory()
    end
end

Methods.OnPlayerSpellbookChange = function(pid)
    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then

        local action = tes3mp.GetSpellbookAction(pid)

        if action == 0 then
            Players[pid]:SetSpells()
        elseif action == 1 then
            Players[pid]:AddSpells()
        elseif action == 2 then
            Players[pid]:RemoveSpells()
        end
    end
end

Methods.OnObjectPlace = function(pid, cellDescription)
    if LoadedCells[cellDescription] ~= nil then
        LoadedCells[cellDescription]:SaveObjectsPlaced()
    else
        print("Undefined behavior: trying to place object in unloaded " .. cellDescription)
    end
end

Methods.OnObjectDelete = function(pid, cellDescription)
    if LoadedCells[cellDescription] ~= nil then
        LoadedCells[cellDescription]:SaveObjectsDeleted()
    else
        print("Undefined behavior: trying to delete object in unloaded " .. cellDescription)
    end
end

Methods.OnObjectScale = function(pid, cellDescription)
    if LoadedCells[cellDescription] ~= nil then
        LoadedCells[cellDescription]:SaveObjectsScaled()
    else
        print("Undefined behavior: trying to scale object in unloaded " .. cellDescription)
    end
end

Methods.OnObjectLock = function(pid, cellDescription)
    if LoadedCells[cellDescription] ~= nil then
        LoadedCells[cellDescription]:SaveObjectsLocked()
    else
        print("Undefined behavior: trying to lock object in unloaded " .. cellDescription)
    end
end

Methods.OnObjectUnlock = function(pid, cellDescription)
    if LoadedCells[cellDescription] ~= nil then
        LoadedCells[cellDescription]:SaveObjectsUnlocked()
    else
        print("Undefined behavior: trying to unlock object in unloaded " .. cellDescription)
    end
end

Methods.OnDoorState = function(pid, cellDescription)
    if LoadedCells[cellDescription] ~= nil then
        LoadedCells[cellDescription]:SaveDoorStates()
    else
        print("Undefined behavior: trying to set door state in unloaded " .. cellDescription)
    end
end

Methods.OnContainer = function(pid, cellDescription)
    if LoadedCells[cellDescription] ~= nil then
        LoadedCells[cellDescription]:SaveContainers()
    else
        print("Undefined behavior: trying to set containers in unloaded " .. cellDescription)
    end
end

Methods.OnPlayerEndCharGen = function(pid)
    Players[pid]:SaveLogin()
    Players[pid]:SaveCharacter()
    Players[pid]:SaveClass()
    Players[pid]:SaveDynamicStats()
    Players[pid]:SaveEquipment()
    Players[pid]:CreateAccount()
end

return Methods
