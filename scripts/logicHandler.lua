tableHelper = require("tableHelper")
fileHelper = require("fileHelper")
inventoryHelper = require("inventoryHelper")
require("enumerations")
local time = require("time")
contentFixer = require("contentFixer")
menuHelper = require("menuHelper")

local logicHandler = {}

Players = {}
LoadedCells = {}
WorldInstance = nil
ObjectLoops = {}
Menus = {}

for _, menuFile in ipairs(config.menuHelperFiles) do
    require("menu/" .. menuFile)
end

logicHandler.InitializeWorld = function()
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

logicHandler.CheckPlayerValidity = function(pid, targetPid)

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
logicHandler.GetChatName = function(pid)

    if Players[pid] ~= nil then
        return Players[pid].name .. " (" .. pid .. ")"
    else
        return "Unlogged player (" .. pid .. ")"
    end
end

-- Check if there is already a player with this name on the server
logicHandler.IsPlayerNameLoggedIn = function(newName)

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
logicHandler.IsPlayerNameAllowed = function(playerName)

    for _, disallowedNameString in pairs(config.disallowedNameStrings) do
        
        if string.find(string.lower(playerName), string.lower(disallowedNameString)) ~= nil then

            return false
        end
    end

    return true
end

-- Get the Player object of either an online player or an offline one
logicHandler.GetPlayerByName = function(targetName)
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

logicHandler.BanPlayer = function(pid, targetName)
    if tableHelper.containsValue(banList.playerNames, string.lower(targetName)) == false then
        local targetPlayer = logicHandler.GetPlayerByName(targetName)

        if targetPlayer ~= nil then
            table.insert(banList.playerNames, string.lower(targetName))
            SaveBanList()

            tes3mp.SendMessage(pid, "All IP addresses stored for " .. targetName ..
                " are now banned.\n", false)

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

logicHandler.UnbanPlayer = function(pid, targetName)
    if tableHelper.containsValue(banList.playerNames, string.lower(targetName)) == true then
        tableHelper.removeValue(banList.playerNames, string.lower(targetName))
        SaveBanList()

        local targetPlayer = logicHandler.GetPlayerByName(targetName)

        if targetPlayer ~= nil then
            tes3mp.SendMessage(pid, "All IP addresses stored for " .. targetName ..
                " are now unbanned.\n", false)

            for index, ipAddress in pairs(targetPlayer.data.ipAddresses) do
                tes3mp.UnbanAddress(ipAddress)
            end
        else
            tes3mp.SendMessage(pid, targetName .. " does not have an account on this server, " ..
                "but has been removed from the ban list.\n", false)
        end
    else
        tes3mp.SendMessage(pid, targetName .. " is not banned.\n", false)
    end
end

logicHandler.TeleportToPlayer = function(pid, originPid, targetPid)
    if (not logicHandler.CheckPlayerValidity(pid, originPid)) or
        (not logicHandler.CheckPlayerValidity(pid, targetPid)) then
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

    local originMessage = "You have been teleported to " .. targetPlayerName ..
        "'s location. (" .. targetCell .. ")\n"
    local targetMessage = "Teleporting ".. originPlayerName .." to your location.\n"
    tes3mp.SendMessage(originPid, originMessage, false)
    tes3mp.SendMessage(targetPid, targetMessage, false)
end

logicHandler.GetConnectedPlayerCount = function()

    local playerCount = 0

    for pid, player in pairs(Players) do
        if player:IsLoggedIn() then
            playerCount = playerCount + 1
        end
    end

    return playerCount
end

logicHandler.GetLoadedCellCount = function()

    return tableHelper.getCount(LoadedCells)
end

logicHandler.PrintPlayerPosition = function(pid, targetPid)
    if not logicHandler.CheckPlayerValidity(pid, targetPid) then
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

    message = targetPlayerName .. " (" .. targetPid .. ") is in " .. targetCell .. " at [" .. targetPos[0] ..
        " " .. targetPos[1] .. " " .. targetPos[2] .. "]\n"
    tes3mp.SendMessage(pid, message, false)
end

logicHandler.PushPlayerList = function(pls)
    Players = pls
end

logicHandler.TestFunction = function()
      tes3mp.LogMessage(2, "TestFunction: Test function called")
      tes3mp.LogMessage(2, Players[0])
end

logicHandler.AuthCheck = function(pid)
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

logicHandler.SendConfigCollisionOverrides = function(pid, forEveryone)

    tes3mp.ClearEnforcedCollisionRefIds()

    for _, refId in pairs(config.enforcedCollisionRefIds) do
        tes3mp.AddEnforcedCollisionRefId(refId)
    end
    
    tes3mp.SendWorldCollisionOverride(pid, forEveryone)
end

logicHandler.CreateObjectAtLocation = function(cell, location, refId, packetType)

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

logicHandler.CreateObjectAtPlayer = function(pid, refId, packetType)

    local cell = tes3mp.GetCell(pid)
    local location = {
        posX = tes3mp.GetPosX(pid), posY = tes3mp.GetPosY(pid), posZ = tes3mp.GetPosZ(pid),
        rotX = tes3mp.GetRotX(pid), rotY = 0, rotZ = tes3mp.GetRotZ(pid)
    }

    logicHandler.CreateObjectAtLocation(cell, location, refId, packetType)
end

logicHandler.DeleteObject = function(pid, refId, refNumIndex, mpNum, forEveryone)

    tes3mp.InitializeObjectList(pid)
    tes3mp.SetObjectListCell(Players[pid].data.location.cell)
    tes3mp.SetObjectRefNumIndex(refNumIndex)
    tes3mp.SetObjectMpNum(mpNum)
    tes3mp.SetObjectRefId(refId)
    tes3mp.AddObject()
    tes3mp.SendObjectDelete(forEveryone)
end

logicHandler.DeleteObjectForPlayer = function(pid, refId, refNumIndex, mpNum)
    logicHandler.DeleteObject(pid, refId, refNumIndex, mpNum, false)
end

logicHandler.DeleteObjectForEveryone = function(refId, refNumIndex, mpNum)
    logicHandler.DeleteObject(tableHelper.getAnyValue(Players).pid, refId, refNumIndex, mpNum, true)
end

logicHandler.RunConsoleCommandOnPlayer = function(pid, consoleCommand, forEveryone)

    tes3mp.InitializeObjectList(pid)
    tes3mp.SetObjectListCell(Players[pid].data.location.cell)
    tes3mp.SetObjectListConsoleCommand(consoleCommand)
    tes3mp.SetPlayerAsObject(pid)
    tes3mp.AddObject()

    -- Depending on what the console command is, you may or may not want to send it
    -- to all the players; experiment if you're not sure
    tes3mp.SendConsoleCommand(forEveryone)
end

logicHandler.RunConsoleCommandOnObject = function(consoleCommand, cellDescription, refId, refNumIndex, mpNum)

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

logicHandler.GetCellContainingActor = function(actorRefIndex)

    for cellDescription, cell in pairs(LoadedCells) do

        if tableHelper.containsValue(cell.data.packets.actorList, actorRefIndex) then
            return cell
        end
    end
    
    return nil
end

logicHandler.SetAIForActor = function(cell, actorRefIndex, action, targetPid, targetActorRefIndex,
    posX, posY, posZ, distance, duration, shouldRepeat)

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

        if shouldRepeat == "true" then
            shouldRepeat = true
        else
            shouldRepeat = false
        end

        tes3mp.SetActorAIRepetition(shouldRepeat)

        tes3mp.AddActor()
        tes3mp.SendActorAI()

    else
        tes3mp.LogAppend(3, "Invalid input for logicHandler.SetAIForActor()!")
    end
end

logicHandler.IsCellLoaded = function(cellDescription)

    return LoadedCells[cellDescription] ~= nil
end

logicHandler.SetCellAuthority = function(pid, cellDescription)
    LoadedCells[cellDescription]:SetAuthority(pid)
end

logicHandler.LoadCell = function(cellDescription)

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

logicHandler.LoadCellForPlayer = function(pid, cellDescription)

    logicHandler.LoadCell(cellDescription)

    -- Record that this player has the cell loaded
    LoadedCells[cellDescription]:AddVisitor(pid)

    local authPid = LoadedCells[cellDescription]:GetAuthority()

    -- If the cell's authority is nil, set this player as the authority
    if authPid == nil then
        LoadedCells[cellDescription]:SetAuthority(pid)
    -- Otherwise, only set this player as the authority if their ping is noticeably lower
    -- than that of the current authority
    elseif tes3mp.GetAvgPing(pid) < (tes3mp.GetAvgPing(authPid) - 40) then
        tes3mp.LogMessage(2, "Player " .. logicHandler.GetChatName(pid) ..
            " took over authority from player " .. logicHandler.GetChatName(authPid) ..
            " in " .. cellDescription .. " for latency reasons")
        LoadedCells[cellDescription]:SetAuthority(pid)
    end
end

logicHandler.UnloadCell = function(cellDescription)

    if LoadedCells[cellDescription] ~= nil then

        LoadedCells[cellDescription]:Save()
        LoadedCells[cellDescription] = nil
    end
end

logicHandler.UnloadCellForPlayer = function(pid, cellDescription)

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

return logicHandler
