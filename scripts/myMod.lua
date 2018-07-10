tableHelper = require("tableHelper")
fileHelper = require("fileHelper")
inventoryHelper = require("inventoryHelper")
require("enumerations")
local time = require("time")
contentFixer = require("contentFixer")
menuHelper = require("menuHelper")

local Methods = {}

Players = {}
LoadedCells = {}
WorldInstance = nil
ObjectLoops = {}
Menus = {}

for _, menuFile in ipairs(config.menuHelperFiles) do
    require("menu/" .. menuFile)
end

Methods.InitializeWorld = function()
    WorldInstance = World()

    -- If the world has a data entry, load it
    if WorldInstance:HasEntry() then
        WorldInstance:Load()
        WorldInstance:EnsureTimeDataExists()

        -- Get the current mpNum from the loaded world
        tes3mp.SetCurrentMpNum(WorldInstance:GetCurrentMpNum())

    -- Otherwise, create a data file for it
    else
        WorldInstance:CreateEntry()
    end
end

Methods.CheckPlayerValidity = function(pid, targetPid)

    local valid = false
    local sendMessage = true

    if pid == nil then
        sendMessage = false
    end

    if targetPid == nil or type(tonumber(targetPid)) ~= "number" then

        if sendMessage then
            local message = "Please specify the player ID.\n"
            tes3mp.SendMessage(pid, message, false)
        end

        return false
    end

    targetPid = tonumber(targetPid)

    if targetPid >= 0 and Players[targetPid] ~= nil and Players[targetPid]:IsLoggedIn() then
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

-- Get the "Name (pid)" representation of a player used in chat
Methods.GetChatName = function(pid)

    if Players[pid] ~= nil then
        return Players[pid].name .. " (" .. pid .. ")"
    else
        return "Unlogged player (" .. pid .. ")"
    end
end

-- Check if there is already a player with this name on the server
Methods.IsPlayerNameLoggedIn = function(newName)

    -- Make sure we also check the account name this new player would end up having
    local newAccountName = fileHelper.fixFilename(newName)

    for pid, player in pairs(Players) do
        if player:IsLoggedIn() then
            if string.lower(player.name) == string.lower(newName) then
                return true
            elseif string.lower(player.accountName) == string.lower(newAccountName) then
                return true
            end
        end
    end

    return false
end

-- Check if the player is using a disallowed name
Methods.IsPlayerNameAllowed = function(playerName)

    for _, disallowedNameString in pairs(config.disallowedNameStrings) do
        
        if string.find(string.lower(playerName), string.lower(disallowedNameString)) ~= nil then

            return false
        end
    end

    return true
end

-- Get the Player object of either an online player or an offline one
Methods.GetPlayerByName = function(targetName)
    -- Check if the player is online
    for iteratorPid, player in pairs(Players) do

        if string.lower(targetName) == string.lower(player.accountName) then
            return player
        end
    end

    -- If they're offline, try to load their account file
    local targetPlayer = Player(nil, targetName)

    if targetPlayer:HasAccount() == true then
        targetPlayer:Load()
        return targetPlayer
    else
        return nil
    end
end

Methods.BanPlayer = function(pid, targetName)
    if tableHelper.containsValue(banList.playerNames, string.lower(targetName)) == false then
        local targetPlayer = Methods.GetPlayerByName(targetName)

        if targetPlayer ~= nil then
            table.insert(banList.playerNames, string.lower(targetName))
            SaveBanList()

            tes3mp.SendMessage(pid, "All IP addresses stored for " .. targetName .. " are now banned.\n", false)

            for index, ipAddress in pairs(targetPlayer.data.ipAddresses) do
                tes3mp.BanAddress(ipAddress)
            end
        else
            tes3mp.SendMessage(pid, targetName .. " does not have an account on this server.\n", false)
        end
    else
        tes3mp.SendMessage(pid, targetName .. " was already banned.\n", false)
    end
end

Methods.UnbanPlayer = function(pid, targetName)
    if tableHelper.containsValue(banList.playerNames, string.lower(targetName)) == true then
        tableHelper.removeValue(banList.playerNames, string.lower(targetName))
        SaveBanList()

        local targetPlayer = Methods.GetPlayerByName(targetName)

        if targetPlayer ~= nil then
            tes3mp.SendMessage(pid, "All IP addresses stored for " .. targetName .. " are now unbanned.\n", false)

            for index, ipAddress in pairs(targetPlayer.data.ipAddresses) do
                tes3mp.UnbanAddress(ipAddress)
            end
        else
            tes3mp.SendMessage(pid, targetName .. " does not have an account on this server, but has been removed from the ban list.\n", false)
        end
    else
        tes3mp.SendMessage(pid, targetName .. " is not banned.\n", false)
    end
end

Methods.TeleportToPlayer = function(pid, originPid, targetPid)
    if (not Methods.CheckPlayerValidity(pid, originPid)) or (not Methods.CheckPlayerValidity(pid, targetPid)) then
        return
    elseif tonumber(originPid) == tonumber(targetPid) then
        local message = "You can't teleport to yourself.\n"
        tes3mp.SendMessage(pid, message, false)
        return
    end

    local originPlayerName = Players[tonumber(originPid)].name
    local targetPlayerName = Players[tonumber(targetPid)].name
    local targetCell = ""
    local targetCellName
    local targetPos = {0, 0, 0}
    local targetRot = {0, 0}
    local targetGrid = {0, 0}
    targetPos[0] = tes3mp.GetPosX(targetPid)
    targetPos[1] = tes3mp.GetPosY(targetPid)
    targetPos[2] = tes3mp.GetPosZ(targetPid)
    targetRot[0] = tes3mp.GetRotX(targetPid)
    targetRot[1] = tes3mp.GetRotZ(targetPid)
    targetCell = tes3mp.GetCell(targetPid)

    tes3mp.SetCell(originPid, targetCell)
    tes3mp.SendCell(originPid)

    tes3mp.SetPos(originPid, targetPos[0], targetPos[1], targetPos[2])
    tes3mp.SetRot(originPid, targetRot[0], targetRot[1])
    tes3mp.SendPos(originPid)

    local originMessage = "You have been teleported to " .. targetPlayerName .. "'s location. (" .. targetCell .. ")\n"
    local targetMessage = "Teleporting ".. originPlayerName .." to your location.\n"
    tes3mp.SendMessage(originPid, originMessage, false)
    tes3mp.SendMessage(targetPid, targetMessage, false)
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

Methods.PrintPlayerPosition = function(pid, targetPid)
    if not Methods.CheckPlayerValidity(pid, targetPid) then
        return
    end
    local message = ""
    local targetPlayerName = Players[tonumber(targetPid)].name
    local targetCell = ""
    local targetCellName = ""
    local targetPos = {0, 0, 0}
    local targetGrid = {0, 0}
    targetPos[0] = tes3mp.GetPosX(targetPid)
    targetPos[1] = tes3mp.GetPosY(targetPid)
    targetPos[2] = tes3mp.GetPosZ(targetPid)
    targetCell = tes3mp.GetCell(targetPid)

    message = targetPlayerName.." ("..targetPid..") is in "..targetCell.." at ["..targetPos[0].." "..targetPos[1].." "..targetPos[2].."]\n"
    tes3mp.SendMessage(pid, message, false)
end

Methods.PushPlayerList = function(pls)
    Players = pls
end

Methods.TestFunction = function()
      tes3mp.LogMessage(2, "TestFunction: Test function called")
      tes3mp.LogMessage(2, Players[0])
end

Methods.OnPlayerConnect = function(pid, playerName)

    WorldInstance:LoadTime(pid, false)

    tes3mp.SetDifficulty(pid, config.difficulty)
    tes3mp.SetConsoleAllowed(pid, config.allowConsole)
    tes3mp.SetBedRestAllowed(pid, config.allowBedRest)
    tes3mp.SetWildernessRestAllowed(pid, config.allowWildernessRest)
    tes3mp.SetWaitAllowed(pid, config.allowWait)
    tes3mp.SetPhysicsFramerate(pid, config.physicsFramerate)
    tes3mp.SetEnforcedLogLevel(pid, config.enforcedLogLevel)
    tes3mp.SendSettings(pid)

    tes3mp.SetPlayerCollisionState(config.enablePlayerCollision)
    tes3mp.SetActorCollisionState(config.enableActorCollision)
    tes3mp.SetPlacedObjectCollisionState(config.enablePlacedObjectCollision)
    tes3mp.UseActorCollisionForPlacedObjects(config.useActorCollisionForPlacedObjects)

    tes3mp.ClearEnforcedCollisionRefIds()

    for _, refId in pairs(config.enforcedCollisionRefIds) do
        tes3mp.AddEnforcedCollisionRefId(refId)
    end
    
    tes3mp.SendWorldCollisionOverride(pid, false)

    Players[pid] = Player(pid, playerName)
    Players[pid].name = playerName

    local message = Methods.GetChatName(pid) .. " joined the server.\n"
    tes3mp.SendMessage(pid, message, true)

    message = "Welcome " .. playerName .. "\nYou have " .. tostring(config.loginTime) .. " seconds to"

    if Players[pid]:HasAccount() then
        message = message .. " log in.\n"
        GUI.ShowLogin(pid)
    else
        message = message .. " register.\n"
        GUI.ShowRegister(pid)
    end

    tes3mp.SendMessage(pid, message, false)

    Players[pid].loginTimerId = tes3mp.CreateTimerEx("OnLoginTimeExpiration", time.seconds(config.loginTime), "i", pid)
    tes3mp.StartTimer(Players[pid].loginTimerId)
end

Methods.OnPlayerDeny = function(pid, playerName)
    local message = playerName .. " (" .. pid .. ") " .. "joined and tried to use an existing player's name.\n"
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

        -- Is this player on the banlist? If so, store their new IP and ban them
        if tableHelper.containsValue(banList.playerNames, string.lower(Players[pid].accountName)) == true then
            Players[pid]:SaveIpAddress()

            Players[pid]:Message(Players[pid].accountName .. " is banned from this server.\n")
            tes3mp.BanAddress(tes3mp.GetIP(pid))
        else
            Players[pid]:FinishLogin()
            Players[pid]:Message("You have successfully logged in.\n")
        end
    elseif idGui == GUI.ID.REGISTER then
        if data == nil then
            Players[pid]:Message("Password can not be empty\n")
            GUI.ShowRegister(pid)
            return true
        end
        Players[pid]:Registered(data)
        Players[pid]:Message("You have successfully registered.\nUse Y by default to chat or change it from your client config.\n")

    elseif idGui == config.customMenuIds.confiscate and Players[pid].confiscationTargetName ~= nil then

        local targetName = Players[pid].confiscationTargetName
        local targetPlayer = Methods.GetPlayerByName(targetName)

        -- Because the window's item index starts from 0 while the Lua table for
        -- inventories starts from 1, adjust the former here
        local inventoryItemIndex = data + 1
        local item = targetPlayer.data.inventory[inventoryItemIndex]

        if item ~= nil then
        
            table.insert(Players[pid].data.inventory, item)
            Players[pid]:LoadInventory()
            Players[pid]:LoadEquipment()

            -- If the item is equipped by the target, unequip it first
            if inventoryHelper.containsItem(targetPlayer.data.equipment, item.refId, item.charge) then
                local equipmentItemIndex = inventoryHelper.getItemIndex(targetPlayer.data.equipment, item.refId, item.charge)
                targetPlayer.data.equipment[equipmentItemIndex] = nil
            end

            targetPlayer.data.inventory[inventoryItemIndex] = nil
            tableHelper.cleanNils(targetPlayer.data.inventory)

            Players[pid]:Message("You've confiscated " .. item.refId .. " from " .. targetName .. "\n")

            if targetPlayer:IsLoggedIn() then
                targetPlayer:LoadInventory()
                targetPlayer:LoadEquipment()
            end
        else
            Players[pid]:Message("Invalid item index\n")
        end

        targetPlayer:SetConfiscationState(false)
        targetPlayer:Save()

        Players[pid].confiscationTargetName = nil

    elseif idGui == config.customMenuIds.menuHelper and Players[pid].currentCustomMenu ~= nil then

        local buttonIndex = tonumber(data) + 1
        local buttonPressed = Players[pid].displayedMenuButtons[buttonIndex]

        local destination = menuHelper.getButtonDestination(pid, buttonPressed)

        menuHelper.processEffects(pid, destination.effects)
        menuHelper.displayMenu(pid, destination.targetMenu)

        Players[pid].previousCustomMenu = Players[pid].currentCustomMenu
        Players[pid].currentCustomMenu = destination.targetMenu
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

    local playerName = tes3mp.GetName(pid)
    local message = playerName .. " (" .. pid .. ") " .. "failed to log in.\n"
    tes3mp.SendMessage(pid, message, true)
    Players[pid]:Kick()

    Players[pid] = nil
    return false
end

Methods.CreateObjectAtLocation = function(cell, location, refId, packetType)

    local mpNum = WorldInstance:GetCurrentMpNum() + 1
    local refIndex =  0 .. "-" .. mpNum

    WorldInstance:SetCurrentMpNum(mpNum)
    tes3mp.SetCurrentMpNum(mpNum)

    LoadedCells[cell]:InitializeObjectData(refIndex, refId)
    LoadedCells[cell].data.objectData[refIndex].location = location

    if packetType == "place" then
        table.insert(LoadedCells[cell].data.packets.place, refIndex)
    elseif packetType == "spawn" then
        table.insert(LoadedCells[cell].data.packets.spawn, refIndex)
        table.insert(LoadedCells[cell].data.packets.actorList, refIndex)
    end

    LoadedCells[cell]:Save()

    -- Are there any players on the server? If so, initialize the event
    -- for the first one we find and just send the corresponding packet
    -- to everyone
    if tableHelper.getCount(Players) > 0 then

        tes3mp.InitializeObjectList(tableHelper.getAnyValue(Players).pid)
        tes3mp.SetObjectListCell(cell)
        tes3mp.SetObjectRefId(refId)
        tes3mp.SetObjectRefNumIndex(0)
        tes3mp.SetObjectMpNum(mpNum)
        tes3mp.SetObjectPosition(location.posX, location.posY, location.posZ)
        tes3mp.SetObjectRotation(location.rotX, location.rotY, location.rotZ)
        tes3mp.AddObject()

        if packetType == "place" then
            tes3mp.SendObjectPlace(true)
        elseif packetType == "spawn" then
            tes3mp.SendObjectSpawn(true)
        end
    end
end

Methods.CreateObjectAtPlayer = function(pid, refId, packetType)

    local cell = tes3mp.GetCell(pid)
    local location = {
        posX = tes3mp.GetPosX(pid), posY = tes3mp.GetPosY(pid), posZ = tes3mp.GetPosZ(pid),
        rotX = tes3mp.GetRotX(pid), rotY = 0, rotZ = tes3mp.GetRotZ(pid)
    }

    Methods.CreateObjectAtLocation(cell, location, refId, packetType)
end

Methods.DeleteObject = function(pid, refId, refNumIndex, mpNum, forEveryone)

    tes3mp.InitializeObjectList(pid)
    tes3mp.SetObjectListCell(Players[pid].data.location.cell)
    tes3mp.SetObjectRefNumIndex(refNumIndex)
    tes3mp.SetObjectMpNum(mpNum)
    tes3mp.SetObjectRefId(refId)
    tes3mp.AddObject()
    tes3mp.SendObjectDelete(forEveryone)
end

Methods.DeleteObjectForPlayer = function(pid, refId, refNumIndex, mpNum)
    Methods.DeleteObject(pid, refId, refNumIndex, mpNum, false)
end

Methods.DeleteObjectForEveryone = function(refId, refNumIndex, mpNum)
    Methods.DeleteObject(tableHelper.getAnyValue(Players).pid, refId, refNumIndex, mpNum, true)
end

Methods.RunConsoleCommandOnPlayer = function(pid, consoleCommand, forEveryone)

    tes3mp.InitializeObjectList(pid)
    tes3mp.SetObjectListCell(Players[pid].data.location.cell)
    tes3mp.SetObjectListConsoleCommand(consoleCommand)
    tes3mp.SetPlayerAsObject(pid)
    tes3mp.AddObject()

    -- Depending on what the console command is, you may or may not want to send it
    -- to all the players; experiment if you're not sure
    tes3mp.SendConsoleCommand(forEveryone)
end

Methods.RunConsoleCommandOnObject = function(consoleCommand, cellDescription, refId, refNumIndex, mpNum)

    tes3mp.InitializeObjectList(tableHelper.getAnyValue(Players).pid)
    tes3mp.SetObjectListCell(cellDescription)
    tes3mp.SetObjectListConsoleCommand(consoleCommand)
    tes3mp.SetObjectRefId(refId)
    tes3mp.SetObjectRefNumIndex(refNumIndex)
    tes3mp.SetObjectMpNum(mpNum)
    tes3mp.AddObject()
    
    -- Always send this to everyone
    tes3mp.SendConsoleCommand(true)
end

Methods.GetCellContainingActor = function(actorRefIndex)

    for cellDescription, cell in pairs(LoadedCells) do

        if tableHelper.containsValue(cell.data.packets.actorList, actorRefIndex) then
            return cell
        end
    end
    
    return nil
end

Methods.SetAIForActor = function(cell, actorRefIndex, action, targetPid, targetActorRefIndex,
    posX, posY, posZ, distance, duration)

    if cell ~= nil and actorRefIndex ~= nil then

        tes3mp.InitializeActorList(cell.authority)

        local splitIndex = actorRefIndex:split("-")
        tes3mp.SetActorRefNumIndex(splitIndex[1])
        tes3mp.SetActorMpNum(splitIndex[2])

        tes3mp.SetActorListCell(cell.description)
        tes3mp.SetActorAIAction(action)

        if targetPid ~= nil then
            tes3mp.SetActorAITargetToPlayer(targetPid)
        elseif targetActorRefIndex ~= nil then
            local targetSplitIndex = targetActorRefIndex:split("-")
            tes3mp.SetActorAITargetToObject(targetSplitIndex[1], targetSplitIndex[2])
        elseif posX ~= nil and posY ~= nil and posZ ~= nil then
            tes3mp.SetActorAICoordinates(posX, posY, posZ)
        elseif distance ~= nil then
            tes3mp.SetActorAIDistance(distance)
        elseif duration ~= nil then
            tes3mp.SetActorAIDuration(duration)
        end

        tes3mp.AddActor()
        tes3mp.SendActorAI()

    else
        tes3mp.LogAppend(3, "Invalid input for myMod.SetAIForActor()!")
    end
end

Methods.OnObjectLoopTimeExpiration = function(loopIndex)
    if ObjectLoops[loopIndex] ~= nil then

        local loop = ObjectLoops[loopIndex]
        local pid = loop.targetPid
        local loopEnded = false

        if Players[pid] ~= nil and Players[pid]:IsLoggedIn() and Players[pid].accountName == loop.targetName then
        
            if loop.packetType == "place" or loop.packetType == "spawn" then
                Methods.CreateObjectAtPlayer(pid, loop.refId, loop.packetType)
            elseif loop.packetType == "console" then
                Methods.RunConsoleCommandOnPlayer(pid, loop.consoleCommand)
            end

            loop.count = loop.count - 1

            if loop.count > 0 then
                ObjectLoops[loopIndex] = loop
                tes3mp.RestartTimer(loop.timerId, loop.interval)
            else
                loopEnded = true
            end
        else
            loopEnded = true
        end

        if loopEnded == true then
            ObjectLoops[loopIndex] = nil
        end
    end
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

Methods.OnPlayerShapeshift = function(pid)
    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
        Players[pid]:SaveShapeshift()
    end
end

Methods.OnPlayerCellChange = function(pid)
    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then

        if contentFixer.ValidateCellChange(pid) then
            Players[pid]:SaveCell()
            Players[pid]:SaveStatsDynamic()
            tes3mp.LogMessage(1, "Saving player " .. pid)
            Players[pid]:Save()

            if config.shareMapExploration == true then
                WorldInstance:SaveMapExploration(pid)
            end
        else
            Players[pid].data.location.posX = tes3mp.GetPreviousCellPosX(pid)
            Players[pid].data.location.posY = tes3mp.GetPreviousCellPosY(pid)
            Players[pid].data.location.posZ = tes3mp.GetPreviousCellPosZ(pid)
            Players[pid]:LoadCell()
        end
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
        tes3mp.LogMessage(2, "Player " .. Methods.GetChatName(pid) .. " took over authority from player " .. Methods.GetChatName(authPid) .. " in " .. cellDescription .. " for latency reasons")
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

        local action = tes3mp.GetSpellbookChangesAction(pid)

        if action == enumerations.spellbook.SET then
            Players[pid]:SetSpells()
        elseif action == enumerations.spellbook.ADD then
            Players[pid]:AddSpells()
        elseif action == enumerations.spellbook.REMOVE then
            Players[pid]:RemoveSpells()
        end
    end
end

Methods.OnPlayerQuickKeys = function(pid)
    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
        Players[pid]:SaveQuickKeys()
    end
end

Methods.OnPlayerJournal = function(pid)
    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then

        if config.shareJournal == true then
            WorldInstance:SaveJournal(pid)

            -- Send this PlayerJournal packet to other players (sendToOthersPlayers is true),
            -- but skip sending it to the player we got it from (skipAttachedPlayer is true)
            tes3mp.SendJournalChanges(pid, true, true)
        else
            Players[pid]:SaveJournal()
        end
    end
end

Methods.OnPlayerFaction = function(pid)
    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then

        local action = tes3mp.GetFactionChangesAction(pid)

        if action == enumerations.faction.RANK then
            if config.shareFactionRanks == true then

                WorldInstance:SaveFactionRanks(pid)
                -- Send this PlayerFaction packet to other players (sendToOthersPlayers is true),
                -- but skip sending it to the player we got it from (skipAttachedPlayer is true)
                tes3mp.SendFactionChanges(pid, true, true)
            else
                Players[pid]:SaveFactionRanks()
            end
        elseif action == enumerations.faction.EXPULSION then
            if config.shareFactionExpulsion == true then

                WorldInstance:SaveFactionExpulsion(pid)
                -- As above, send this to everyone other than the original sender
                tes3mp.SendFactionChanges(pid, true, true)
            else
                Players[pid]:SaveFactionExpulsion()
            end
        elseif action == enumerations.faction.REPUTATION then
            if config.shareFactionReputation == true then
                WorldInstance:SaveFactionReputation(pid)

                -- As above, send this to everyone other than the original sender
                tes3mp.SendFactionChanges(pid, true, true)
            else
                Players[pid]:SaveFactionReputation()
            end
        end
    end
end

Methods.OnPlayerTopic = function(pid)
    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then

        if config.shareTopics == true then

            WorldInstance:SaveTopics(pid)
            -- Send this PlayerTopic packet to other players (sendToOthersPlayers is true),
            -- but skip sending it to the player we got it from (skipAttachedPlayer is true)
            tes3mp.SendTopicChanges(pid, true, true)
        else
            Players[pid]:SaveTopics()
        end
    end
end

Methods.OnPlayerBounty = function(pid)
    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then

        if config.shareBounty == true then
            WorldInstance:SaveBounty(pid)

            -- Bounty packets are special in that they are always sent
            -- to all players, but only affect their target player on
            -- any given client
            --
            -- To set the same bounty for each LocalPlayer, we need
            -- to separately set each player as the target and
            -- send the packet
            local bountyValue = tes3mp.GetBounty(pid)

            for playerIndex, player in pairs(Players) do
                if player.pid ~= pid then
                    tes3mp.SetBounty(player.pid, bountyValue)
                    tes3mp.SendBounty(player.pid)
                end
            end
        else
            Players[pid]:SaveBounty()
        end
    end
end

Methods.OnPlayerReputation = function(pid)
    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then

        if config.shareReputation == true then

            WorldInstance:SaveReputation(pid)
            -- Send this PlayerReputation packet to other players (sendToOthersPlayers is true),
            -- but skip sending it to the player we got it from (skipAttachedPlayer is true)
            tes3mp.SendReputation(pid, true, true)
        else
            Players[pid]:SaveReputation()
        end
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

Methods.OnPlayerMiscellaneous = function(pid)
    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
        local changeType = tes3mp.GetMiscellaneousChangeType(pid)

        if changeType == enumerations.miscellaneous.MARK_LOCATION then
            Players[pid]:SaveMarkLocation()
        elseif changeType == enumerations.miscellaneous.SELECTED_SPELL then
            Players[pid]:SaveSelectedSpell()
        end
    end
end

Methods.OnCellLoad = function(pid, cellDescription)
    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
        Methods.LoadCellForPlayer(pid, cellDescription)
    else
        tes3mp.LogMessage(2, "Undefined behavior: invalid player " .. pid .. " loaded cell " .. cellDescription)
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
    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
        if LoadedCells[cellDescription] ~= nil then
            LoadedCells[cellDescription]:SaveActorList(pid)
        else
            tes3mp.LogMessage(2, "Undefined behavior: " .. Methods.GetChatName(pid) .. " sent ActorList for unloaded " .. cellDescription)
        end
    else
        tes3mp.Kick(pid)
    end
end

Methods.OnActorEquipment = function(pid, cellDescription)
    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
        if LoadedCells[cellDescription] ~= nil then
            LoadedCells[cellDescription]:SaveActorEquipment(pid)
        else
            tes3mp.LogMessage(2, "Undefined behavior: " .. Methods.GetChatName(pid) .. " sent ActorEquipment for unloaded " .. cellDescription)
        end
    else
        tes3mp.Kick(pid)
    end
end

Methods.OnActorDeath = function(pid, cellDescription)
    if LoadedCells[cellDescription] ~= nil then
        LoadedCells[cellDescription]:SaveActorDeath(pid)
    else
        tes3mp.LogMessage(2, "Undefined behavior: " .. Methods.GetChatName(pid) .. " sent ActorDeath for unloaded " .. cellDescription)
    end
end

Methods.OnActorCellChange = function(pid, cellDescription)
    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
        if LoadedCells[cellDescription] ~= nil then
            LoadedCells[cellDescription]:SaveActorCellChanges(pid)
        else
            tes3mp.LogMessage(2, "Undefined behavior: " .. Methods.GetChatName(pid) .. " sent ActorCellChange for unloaded " .. cellDescription)
        end
    else
        tes3mp.Kick(pid)
    end
end

Methods.OnObjectPlace = function(pid, cellDescription)
    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
        if LoadedCells[cellDescription] ~= nil then
            LoadedCells[cellDescription]:ProcessObjectsPlaced(pid)
        else
            tes3mp.LogMessage(2, "Undefined behavior: " .. Methods.GetChatName(pid) .. " sent ObjectPlace for unloaded " .. cellDescription)
        end
    else
        tes3mp.Kick(pid)
    end
end

Methods.OnObjectSpawn = function(pid, cellDescription)
    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
        if LoadedCells[cellDescription] ~= nil then
            LoadedCells[cellDescription]:ProcessObjectsSpawned(pid)
        else
            tes3mp.LogMessage(2, "Undefined behavior: " .. Methods.GetChatName(pid) .. " sent ObjectSpawn for unloaded " .. cellDescription)
        end
    else
        tes3mp.Kick(pid)
    end
end

Methods.OnObjectDelete = function(pid, cellDescription)
    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
        if LoadedCells[cellDescription] ~= nil then
            LoadedCells[cellDescription]:ProcessObjectsDeleted(pid)
        else
            tes3mp.LogMessage(2, "Undefined behavior: " .. Methods.GetChatName(pid) .. " sent ObjectDelete for unloaded " .. cellDescription)
        end
    else
        tes3mp.Kick(pid)
    end
end

Methods.OnObjectLock = function(pid, cellDescription)
    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
        if LoadedCells[cellDescription] ~= nil then
            LoadedCells[cellDescription]:ProcessObjectsLocked(pid)
        else
            tes3mp.LogMessage(2, "Undefined behavior: " .. Methods.GetChatName(pid) .. " sent ObjectLock for unloaded " .. cellDescription)
        end
    end
end

Methods.OnObjectTrap = function(pid, cellDescription)
    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
        if LoadedCells[cellDescription] ~= nil then
            LoadedCells[cellDescription]:ProcessObjectTrapsTriggered(pid)
        else
            tes3mp.LogMessage(2, "Undefined behavior: " .. Methods.GetChatName(pid) .. " sent ObjectTrap for unloaded " .. cellDescription)
        end
    else
        tes3mp.Kick(pid)
    end
end

Methods.OnObjectScale = function(pid, cellDescription)
    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
        if LoadedCells[cellDescription] ~= nil then
            LoadedCells[cellDescription]:ProcessObjectsScaled(pid)
        else
            tes3mp.LogMessage(2, "Undefined behavior: " .. Methods.GetChatName(pid) .. " sent ObjectScale for unloaded " .. cellDescription)
        end
    else
        tes3mp.Kick(pid)
    end
end

Methods.OnObjectState = function(pid, cellDescription)
    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
        local shouldUnload = false

        if LoadedCells[cellDescription] == nil then
            Methods.LoadCell(cellDescription)
            shouldUnload = true
        end

        LoadedCells[cellDescription]:ProcessObjectStates(pid)

        if shouldUnload == true then
            Methods.UnloadCell(cellDescription)
        end
    else
        tes3mp.Kick(pid)
    end
end

Methods.OnDoorState = function(pid, cellDescription)
    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
        if LoadedCells[cellDescription] ~= nil then
            LoadedCells[cellDescription]:SaveDoorStates(pid)
        else
            tes3mp.LogMessage(2, "Undefined behavior: " .. Methods.GetChatName(pid) .. " sent DoorState for unloaded " .. cellDescription)
        end
    else
        tes3mp.Kick(pid)
    end
end

Methods.OnContainer = function(pid, cellDescription)
    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
        if LoadedCells[cellDescription] ~= nil then
            LoadedCells[cellDescription]:ProcessContainers(pid)
        else
            tes3mp.LogMessage(2, "Undefined behavior: " .. Methods.GetChatName(pid) .. " sent Container for " .. cellDescription)
        end
    else
        tes3mp.Kick(pid)
    end
end

Methods.OnVideoPlay = function(pid)
    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then

        if config.shareVideos == true then
            tes3mp.LogMessage(2, "Sharing VideoPlay from " .. pid)

            tes3mp.ReadLastObjectList()

            for i = 0, tes3mp.GetObjectChangesSize() - 1 do
                local videoFilename = tes3mp.GetVideoFilename(i)
                tes3mp.LogAppend(2, "- videoFilename " .. videoFilename)
            end

            tes3mp.CopyLastObjectListToStore()

            -- Send this VideoPlay packet to other players (sendToOthersPlayers is true),
            -- but skip sending it to the player we got it from (skipAttachedPlayer is true)
            tes3mp.SendVideoPlay(true, true)
        end
    end
end

Methods.OnWorldMap = function(pid)
    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
        WorldInstance:SaveMapTiles(pid)

        if config.shareMapExploration == true then
            tes3mp.CopyLastWorldstateToStore()

            -- Send this WorldMap packet to other players (sendToOthersPlayers is true),
            -- but skip sending it to the player we got it from (skipAttachedPlayer is true)
            tes3mp.SendWorldMap(pid, true, true)
        end
    end
end

Methods.OnMpNumIncrement = function(currentMpNum)
    WorldInstance:SetCurrentMpNum(currentMpNum)
end

return Methods
