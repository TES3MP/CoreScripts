require("actionTypes")
local time = require("time")
local Methods = {}

Players = {}
LoadedCells = {}
WorldInstance = nil

Methods.InitializeWorld = function()
    WorldInstance = World()

    -- If the world has a data entry, load it
    if WorldInstance:HasEntry() then
        WorldInstance:Load()

        -- Get the current mpNum from the loaded world
        tes3mp.SetCurrentMpNum(WorldInstance:GetCurrentMpNum())

    -- Otherwise, create a data file for it
    else
        WorldInstance:CreateEntry()
    end
end

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
            if string.lower(player.name) == string.lower(newName) then
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
    local targetRot = {0, 0}
    local targetGrid = {0, 0}
    targetPos[0] = tes3mp.GetPosX(targetPlayer)
    targetPos[1] = tes3mp.GetPosY(targetPlayer)
    targetPos[2] = tes3mp.GetPosZ(targetPlayer)
    targetRot[0] = tes3mp.GetRotX(targetPlayer)
    targetRot[1] = tes3mp.GetRotZ(targetPlayer)
    targetCell = tes3mp.GetCell(targetPlayer)

    tes3mp.SetCell(originPlayer, targetCell)
    tes3mp.SendCell(originPlayer)

    tes3mp.SetPos(originPlayer, targetPos[0], targetPos[1], targetPos[2])
    tes3mp.SetRot(originPlayer, targetRot[0], targetRot[1])
    tes3mp.SendPos(originPlayer)

    local originMessage = "You have been teleported to " .. targetPlayerName .. "'s location. (" .. targetCell .. ")\n"
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

    return tableHelper.getCount(LoadedCells)
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

    message = targetPlayerName.." ("..targetPlayer..") is in "..targetCell.." at ["..targetPos[0].." "..targetPos[1].." "..targetPos[2].."]\n"
    tes3mp.SendMessage(pid, message, false)
end

Methods.PushPlayerList = function(pls)
    Players = pls
end

Methods.TestFunction = function()
      tes3mp.LogMessage(2, "TestFunction: Test function called")
      tes3mp.LogMessage(2, Players[0])
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

            Methods.UnloadCellForPlayer(pid, loadedCellDescription)
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
        return true
    end

    local pname = tes3mp.GetName(pid)
    local message = pname.." ("..pid..") ".."failed to log in.\n"
    tes3mp.SendMessage(pid, message, true)
    Players[pid]:Kick()

    Players[pid] = nil
    return false
end

Methods.OnPlayerDeath = function(pid)
    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
        Players[pid]:ProcessDeath()
    end
end

Methods.OnDeathTimeExpiration = function(pid)
    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
        Players[pid]:Resurrect()
    end
end

Methods.OnPlayerAttribute = function(pid)
    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
        Players[pid]:SaveAttributes()
    end
end

Methods.OnPlayerSkill = function(pid)
    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
        Players[pid]:SaveSkills()
    end
end

Methods.OnPlayerLevel = function(pid)
    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
        Players[pid]:SaveLevel()
        Players[pid]:SaveStatsDynamic()
    end
end

Methods.OnPlayerBounty = function(pid)
    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
        Players[pid]:SaveBounty()
    end
end

Methods.OnPlayerCellChange = function(pid)
    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
        Players[pid]:SaveCell()
        Players[pid]:SaveStatsDynamic()
        tes3mp.LogMessage(1, "Saving player " .. pid)
        Players[pid]:Save()
    end
end

Methods.IsCellLoaded = function(cellDescription)

    return LoadedCells[cellDescription] ~= nil
end

Methods.SetCellAuthority = function(pid, cellDescription)
    LoadedCells[cellDescription]:SetAuthority(pid)
end

Methods.LoadCell = function(cellDescription)

    -- If this cell isn't loaded at all, load it
    if LoadedCells[cellDescription] == nil then

        LoadedCells[cellDescription] = Cell(cellDescription)
        LoadedCells[cellDescription].description = cellDescription

        -- If this cell has a data entry, load it
        if LoadedCells[cellDescription]:HasEntry() then
            LoadedCells[cellDescription]:Load()
        -- Otherwise, create a data file for it
        else
            LoadedCells[cellDescription]:CreateEntry()
        end
    -- Otherwise, save momentary actor data so it can be sent
    -- to the cell's new loader
    else
        LoadedCells[cellDescription]:SaveActorPositions()
        LoadedCells[cellDescription]:SaveActorStatsDynamic()
    end
end

Methods.LoadCellForPlayer = function(pid, cellDescription)

    Methods.LoadCell(cellDescription)

    -- Record that this player has the cell loaded
    LoadedCells[cellDescription]:AddVisitor(pid)

    local authPid = LoadedCells[cellDescription]:GetAuthority()

    -- If the cell's authority is nil, set this player as the authority
    if authPid == nil then
        LoadedCells[cellDescription]:SetAuthority(pid)
    -- Otherwise, only set this player as the authority if their ping is noticeably lower
    -- than that of the current authority
    elseif tes3mp.GetAvgPing(pid) < (tes3mp.GetAvgPing(authPid) - 40) then
        tes3mp.LogMessage(2, "Player " .. pid .. " took over authority from player " .. authPid .. " in " .. cellDescription .. " for latency reasons")
        LoadedCells[cellDescription]:SetAuthority(pid)
    end
end

Methods.UnloadCell = function(cellDescription)

    if LoadedCells[cellDescription] ~= nil then

        LoadedCells[cellDescription]:Save()
        LoadedCells[cellDescription] = nil
    end
end

Methods.UnloadCellForPlayer = function(pid, cellDescription)

    if LoadedCells[cellDescription] ~= nil then

        -- No longer record that this player has the cell loaded
        LoadedCells[cellDescription]:RemoveVisitor(pid)
        LoadedCells[cellDescription]:SaveActorPositions()
        LoadedCells[cellDescription]:SaveActorStatsDynamic()
        LoadedCells[cellDescription]:Save()

        -- If this player was the cell's authority, set another player
        -- as the authority
        if LoadedCells[cellDescription]:GetAuthority() == pid then
            for key, otherPid in pairs(LoadedCells[cellDescription].visitors) do
                LoadedCells[cellDescription]:SetAuthority(otherPid)
                break
            end
        end
    end
end

Methods.OnPlayerEndCharGen = function(pid)
    if Players[pid] ~= nil then
        Players[pid]:EndCharGen()
    end
end

Methods.OnPlayerEquipment = function(pid)
    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
        Players[pid]:SaveEquipment()
    end
end

Methods.OnPlayerInventory = function(pid)
    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
        Players[pid]:SaveInventory()
    end
end

Methods.OnPlayerSpellbook = function(pid)
    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then

        local action = tes3mp.GetSpellbookAction(pid)

        if action == actionTypes.spellbook.SET then
            Players[pid]:SetSpells()
        elseif action == actionTypes.spellbook.ADD then
            Players[pid]:AddSpells()
        elseif action == actionTypes.spellbook.REMOVE then
            Players[pid]:RemoveSpells()
        end
    end
end

Methods.OnPlayerJournal = function(pid)
    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then

        if config.shareJournal == true then
            WorldInstance:SaveJournal(pid)
            tes3mp.SendJournalChanges(pid, true)
        else
            Players[pid]:SaveJournal()
        end
    end
end

Methods.OnPlayerFaction = function(pid)
    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then

        local action = tes3mp.GetFactionChangesAction(pid)

        if action == actionTypes.faction.RANK then
            if config.shareFactionRanks == true then
                WorldInstance:SaveFactionRanks(pid)
                tes3mp.SendFactionChanges(pid, true)
            else
                Players[pid]:SaveFactionRanks()
            end
        elseif action == actionTypes.faction.EXPULSION then
            if config.shareFactionExpulsion == true then
                WorldInstance:SaveFactionExpulsion(pid)
                tes3mp.SendFactionChanges(pid, true)
            else
                Players[pid]:SaveFactionExpulsion()
            end
        elseif action == actionTypes.faction.REPUTATION then
            if config.shareFactionReputation == true then
                WorldInstance:SaveFactionReputation(pid)
                tes3mp.SendFactionChanges(pid, true)
            else
                Players[pid]:SaveFactionReputation()
            end
        end
    end
end

Methods.OnPlayerTopic = function(pid)
    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
        WorldInstance:SaveTopics(pid)
    end
end

Methods.OnPlayerKillCount = function(pid)
    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
        WorldInstance:SaveKills(pid)
    end
end

Methods.OnPlayerBook = function(pid)
    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
        Players[pid]:AddBooks()
    end
end

Methods.OnCellLoad = function(pid, cellDescription)
    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
        Methods.LoadCellForPlayer(pid, cellDescription)
    else
        tes3mp.LogMessage(2, "Undefined behavior: trying to set actors in unloaded " .. cellDescription)
    end
end

Methods.OnCellUnload = function(pid, cellDescription)
    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
        Methods.UnloadCellForPlayer(pid, cellDescription)
    end
end

Methods.OnCellDeletion = function(cellDescription)
    Methods.UnloadCell(cellDescription)
end

Methods.OnActorList = function(pid, cellDescription)
    if LoadedCells[cellDescription] ~= nil then
        LoadedCells[cellDescription]:SaveActorList()
    else
        tes3mp.LogMessage(2, "Undefined behavior: trying to set actors in unloaded " .. cellDescription)
    end
end

Methods.OnActorEquipment = function(pid, cellDescription)
    if LoadedCells[cellDescription] ~= nil then
        LoadedCells[cellDescription]:SaveActorEquipment()
    else
        tes3mp.LogMessage(2, "Undefined behavior: trying to set equipment in unloaded " .. cellDescription)
    end
end

Methods.OnActorCellChange = function(pid, cellDescription)
    if LoadedCells[cellDescription] ~= nil then
        LoadedCells[cellDescription]:SaveActorCellChanges()
    else
        tes3mp.LogMessage(2, "Undefined behavior: trying to save actor cell change in unloaded " .. cellDescription)
    end
end

Methods.OnObjectPlace = function(pid, cellDescription)
    if LoadedCells[cellDescription] ~= nil then
        LoadedCells[cellDescription]:SaveObjectsPlaced()
    else
        tes3mp.LogMessage(2, "Undefined behavior: trying to place object in unloaded " .. cellDescription)
    end
end

Methods.OnObjectSpawn = function(pid, cellDescription)
    if LoadedCells[cellDescription] ~= nil then
        LoadedCells[cellDescription]:SaveObjectsSpawned()
    else
        tes3mp.LogMessage(2, "Undefined behavior: trying to spawn object in unloaded " .. cellDescription)
    end
end

Methods.OnObjectDelete = function(pid, cellDescription)
    if LoadedCells[cellDescription] ~= nil then
        LoadedCells[cellDescription]:SaveObjectsDeleted()
    else
        tes3mp.LogMessage(2, "Undefined behavior: trying to delete object in unloaded " .. cellDescription)
    end
end

Methods.OnObjectLock = function(pid, cellDescription)
    if LoadedCells[cellDescription] ~= nil then
        LoadedCells[cellDescription]:SaveObjectsLocked()
    else
        tes3mp.LogMessage(2, "Undefined behavior: trying to lock object in unloaded " .. cellDescription)
    end
end

Methods.OnObjectTrap = function(pid, cellDescription)
    if LoadedCells[cellDescription] ~= nil then
        LoadedCells[cellDescription]:SaveObjectTrapsTriggered()
    else
        tes3mp.LogMessage(2, "Undefined behavior: trying to trigger object traps in unloaded " .. cellDescription)
    end
end

Methods.OnObjectScale = function(pid, cellDescription)
    if LoadedCells[cellDescription] ~= nil then
        LoadedCells[cellDescription]:SaveObjectsScaled()
    else
        tes3mp.LogMessage(2, "Undefined behavior: trying to scale object in unloaded " .. cellDescription)
    end
end

Methods.OnObjectState = function(pid, cellDescription)
    if LoadedCells[cellDescription] ~= nil then
        LoadedCells[cellDescription]:SaveObjectStates()
    else
        tes3mp.LogMessage(2, "Undefined behavior: trying to set object states in unloaded " .. cellDescription)
    end
end

Methods.OnDoorState = function(pid, cellDescription)
    if LoadedCells[cellDescription] ~= nil then
        LoadedCells[cellDescription]:SaveDoorStates()
    else
        tes3mp.LogMessage(2, "Undefined behavior: trying to set door state in unloaded " .. cellDescription)
    end
end

Methods.OnContainer = function(pid, cellDescription)
    if LoadedCells[cellDescription] ~= nil then
        LoadedCells[cellDescription]:SaveContainers()
    else
        tes3mp.LogMessage(2, "Undefined behavior: trying to set containers in unloaded " .. cellDescription)
    end
end

Methods.OnMpNumIncrement = function(currentMpNum)
    WorldInstance:SetCurrentMpNum(currentMpNum)
end

return Methods
