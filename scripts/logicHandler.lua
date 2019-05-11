tableHelper = require("tableHelper")
fileHelper = require("fileHelper")
inventoryHelper = require("inventoryHelper")
contentFixer = require("contentFixer")
menuHelper = require("menuHelper")
dataTableBuilder = require("dataTableBuilder")
packetBuilder = require("packetBuilder")
packetReader = require("packetReader")

local logicHandler = {}

Players = {}
LoadedCells = {}
RecordStores = {}
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
        WorldInstance:LoadFromDrive()
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

    if not valid then
        if sendMessage then
            local message = "That player is not logged in!\n"
            tes3mp.SendMessage(pid, message, false)
        end
    end

    return valid
end

-- Get the "Name (pid)" representation of a player used in chat
logicHandler.GetChatName = function(pid)
    if pid == nil then
        return "Unlogged player (nil)"
    end

    if Players[pid] ~= nil then
        return Players[pid].name .. " (" .. pid .. ")"
    else
        return "Unlogged player (" .. pid .. ")"
    end
end

-- Iterate through a table of pids and find the player with the
-- lowest ping in it
logicHandler.GetLowestPingPid = function(pidArray)

    local lowestPing
    local lowestPingPid

    for _, pid in pairs(pidArray) do

        local currentPing = tes3mp.GetAvgPing(pid)

        if lowestPing == nil or currentPing < lowestPing then
            lowestPing = currentPing
            lowestPingPid = pid
        end
    end

    return lowestPingPid
end

logicHandler.IsNameAllowed = function(inputName)

    if type(config.disallowedNameStrings) == "table" then
        for _, disallowedNameString in pairs(config.disallowedNameStrings) do

            if string.find(string.lower(inputName), string.lower(disallowedNameString)) ~= nil then

                return false
            end
        end
    end

    return true
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

logicHandler.IsPlayerAllowedConsole = function(pid)

    local player = Players[pid]

    if player ~= nil and player:IsLoggedIn() then

        if player:IsAdmin() or player.data.settings.consoleAllowed then
            return true
        elseif player.data.settings.consoleAllowed == "default" and config.allowConsole then
            return true
        end
    end

    return false
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
        targetPlayer:LoadFromDrive()
        return targetPlayer
    else
        return nil
    end
end

logicHandler.BanPlayer = function(pid, targetName)
    if not tableHelper.containsValue(banList.playerNames, string.lower(targetName)) then
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

logicHandler.GetLoadedRegionCount = function()

    local regionCount = 0

    for key, value in pairs(WorldInstance.storedRegions) do
        if WorldInstance:GetRegionVisitorCount(key) > 0 then
            regionCount = regionCount + 1
        end
    end

    return regionCount
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

logicHandler.AuthCheck = function(pid)
    if Players[pid]:IsLoggedIn() then
        return true
    end

    local playerName = logicHandler.GetChatName(pid)

    local message = playerName .. " failed to log in.\n"
    tes3mp.SendMessage(pid, message, true)
    Players[pid]:Kick()

    Players[pid] = nil
    return false
end

logicHandler.DoesPacketOriginRequireLoadedCell = function(packetOrigin)

    if packetOrigin == enumerations.packetOrigin.CLIENT_GAMEPLAY then
        return true
    end

    return false
end

logicHandler.IsPacketFromConsole = function(packetOrigin)

    if packetOrigin == enumerations.packetOrigin.CLIENT_CONSOLE then
        return true
    end

    return false
end

logicHandler.SendConfigCollisionOverrides = function(pid, forEveryone)

    tes3mp.ClearEnforcedCollisionRefIds()

    for _, refId in pairs(config.enforcedCollisionRefIds) do
        tes3mp.AddEnforcedCollisionRefId(refId)
    end

    tes3mp.SendWorldCollisionOverride(pid, forEveryone)
end

logicHandler.CreateObjectAtLocation = function(cellDescription, location, refId, packetType)

    local mpNum = WorldInstance:GetCurrentMpNum() + 1
    local uniqueIndex =  0 .. "-" .. mpNum

    -- Is this a generated record? If so, add a link to it in the cell it
    -- has been placed in
    if logicHandler.IsGeneratedRecord(refId) then
        local recordStore = logicHandler.GetRecordStoreByRecordId(refId)

        if recordStore ~= nil then
            LoadedCells[cellDescription]:AddLinkToRecord(recordStore.storeType, refId, uniqueIndex)

            -- Do any of the visitors to this cell lack the generated record?
            -- If so, send it to them
            for _, visitorPid in pairs(LoadedCells[cellDescription].visitors) do
                recordStore:LoadGeneratedRecords(visitorPid, recordStore.data.generatedRecords, { refId })
            end
        else
            tes3mp.LogMessage(enumerations.log.ERROR, "Attempt at creating object based on non-existent generated record")
            return
        end
    end

    WorldInstance:SetCurrentMpNum(mpNum)
    tes3mp.SetCurrentMpNum(mpNum)

    LoadedCells[cellDescription]:InitializeObjectData(uniqueIndex, refId)
    LoadedCells[cellDescription].data.objectData[uniqueIndex].location = location

    if packetType == "place" then
        table.insert(LoadedCells[cellDescription].data.packets.place, uniqueIndex)
    elseif packetType == "spawn" then
        table.insert(LoadedCells[cellDescription].data.packets.spawn, uniqueIndex)
        table.insert(LoadedCells[cellDescription].data.packets.actorList, uniqueIndex)
    end

    LoadedCells[cellDescription]:QuicksaveToDrive()

    -- Are there any players on the server? If so, initialize the object
    -- list for the first one we find and just send the corresponding packet
    -- to everyone
    if tableHelper.getCount(Players) > 0 then

        local pid = tableHelper.getAnyValue(Players).pid
        tes3mp.ClearObjectList()
        tes3mp.SetObjectListPid(pid)
        tes3mp.SetObjectListCell(cellDescription)
        tes3mp.SetObjectRefId(refId)
        tes3mp.SetObjectRefNum(0)
        tes3mp.SetObjectMpNum(mpNum)
        tes3mp.SetObjectCharge(-1)
        tes3mp.SetObjectEnchantmentCharge(-1)
        tes3mp.SetObjectPosition(location.posX, location.posY, location.posZ)
        tes3mp.SetObjectRotation(location.rotX, location.rotY, location.rotZ)
        tes3mp.AddObject()

        if packetType == "place" then
            tes3mp.SendObjectPlace(true)
        elseif packetType == "spawn" then
            tes3mp.SendObjectSpawn(true)
        end
    end

    return uniqueIndex
end

logicHandler.CreateObjectAtPlayer = function(pid, refId, packetType)

    local cell = tes3mp.GetCell(pid)
    local location = {
        posX = tes3mp.GetPosX(pid), posY = tes3mp.GetPosY(pid), posZ = tes3mp.GetPosZ(pid),
        rotX = tes3mp.GetRotX(pid), rotY = 0, rotZ = tes3mp.GetRotZ(pid)
    }

    return logicHandler.CreateObjectAtLocation(cell, location, refId, packetType)
end

logicHandler.DeleteObject = function(pid, objectCellDescription, objectUniqueIndex, forEveryone)

    tes3mp.ClearObjectList()
    tes3mp.SetObjectListPid(pid)
    tes3mp.SetObjectListCell(objectCellDescription)

    local splitIndex = objectUniqueIndex:split("-")
    tes3mp.SetObjectRefNum(splitIndex[1])
    tes3mp.SetObjectMpNum(splitIndex[2])

    tes3mp.AddObject()
    tes3mp.SendObjectDelete(forEveryone)
end

logicHandler.DeleteObjectForPlayer = function(pid, objectCellDescription, objectUniqueIndex)
    logicHandler.DeleteObject(pid, objectCellDescription, objectUniqueIndex, false)
end

logicHandler.DeleteObjectForEveryone = function(objectCellDescription, objectUniqueIndex)
    logicHandler.DeleteObject(tableHelper.getAnyValue(Players).pid, objectCellDescription, objectUniqueIndex, true)
end

logicHandler.ActivateObjectForPlayer = function(pid, objectCellDescription, objectUniqueIndex)

    tes3mp.ClearObjectList()
    tes3mp.SetObjectListPid(pid)
    tes3mp.SetObjectListCell(objectCellDescription)

    local splitIndex = objectUniqueIndex:split("-")
    tes3mp.SetObjectRefNum(splitIndex[1])
    tes3mp.SetObjectMpNum(splitIndex[2])
    tes3mp.SetObjectActivatingPid(pid)

    tes3mp.AddObject()
    tes3mp.SendObjectActivate()
end

logicHandler.RunConsoleCommandOnPlayer = function(pid, consoleCommand, forEveryone)

    tes3mp.ClearObjectList()
    tes3mp.SetObjectListPid(pid)
    tes3mp.SetObjectListCell(Players[pid].data.location.cell)
    tes3mp.SetObjectListConsoleCommand(consoleCommand)
    tes3mp.SetPlayerAsObject(pid)
    tes3mp.AddObject()

    -- Depending on what the console command is, you may or may not want to send it
    -- to all the players; experiment if you're not sure
    tes3mp.SendConsoleCommand(forEveryone)
end

logicHandler.RunConsoleCommandOnObjects = function(pid, consoleCommand, cellDescription, objectUniqueIndexes, forEveryone)

    tes3mp.LogMessage(enumerations.log.INFO, "Running " .. consoleCommand .. " in cell " .. cellDescription .. " on object(s) " ..
        tableHelper.concatenateArrayValues(objectUniqueIndexes, 1, ", "))

    tes3mp.ClearObjectList()
    tes3mp.SetObjectListPid(pid)
    tes3mp.SetObjectListCell(cellDescription)
    tes3mp.SetObjectListConsoleCommand(consoleCommand)

    -- Set the object state to deal with the oversight mentioned below
    tes3mp.SetObjectState(true)

    for _, uniqueIndex in pairs(objectUniqueIndexes) do
        local splitIndex = uniqueIndex:split("-")
        tes3mp.SetObjectRefNum(splitIndex[1])
        tes3mp.SetObjectMpNum(splitIndex[2])

        tes3mp.AddObject()
    end

    -- Due to an oversight, console command packets do not include the cell for their
    -- associated objects; as a result, the last cell received by players in an unrelated
    -- object packet is used instead, so send them a dummy packet for that sake
    tes3mp.SendObjectState(forEveryone, false)

    tes3mp.SendConsoleCommand(forEveryone, false)
end

logicHandler.RunConsoleCommandOnObject = function(pid, consoleCommand, cellDescription, objectUniqueIndex, forEveryone)
    logicHandler.RunConsoleCommandOnObjects(pid, consoleCommand, cellDescription, {objectUniqueIndex}, forEveryone)
end

logicHandler.IsGeneratedRecord = function(recordId)

    if string.find(string.lower(recordId), string.lower(config.generatedRecordIdPrefix)) ~= nil then
        return true
    end

    return false
end

logicHandler.GetRecordStoreByRecordId = function(recordId)

    local isGenerated = logicHandler.IsGeneratedRecord(recordId)

    if isGenerated then
        local recordType = string.match(recordId, "_(%a+)_")

        if RecordStores[recordType] ~= nil then
            return RecordStores[recordType]
        end
    end

    for _, storeType in pairs(config.recordStoreLoadOrder) do

        if isGenerated and RecordStores[storeType].data.generatedRecords[recordId] ~= nil then
            return RecordStores[storeType]
        elseif RecordStores[storeType].data.permanentRecords[recordId] ~= nil then
            return RecordStores[storeType]
        end
    end

    return nil
end

logicHandler.ExchangeGeneratedRecords = function(pid, otherPidsArray)

    for _, storeType in ipairs(config.recordStoreLoadOrder) do
        local recordStore = RecordStores[storeType]

        for _, otherPid in pairs(otherPidsArray) do
            if pid ~= otherPid then

                -- Load the generated records linked to other players
                if Players[otherPid].data.recordLinks[storeType] ~= nil then
                    recordStore:LoadGeneratedRecords(pid, recordStore.data.generatedRecords,
                        Players[otherPid].data.recordLinks[storeType])
                end

                -- Make the other players load the generated records linked to us too
                if Players[pid].data.recordLinks[storeType] ~= nil then
                    recordStore:LoadGeneratedRecords(otherPid, recordStore.data.generatedRecords,
                        Players[pid].data.recordLinks[storeType])
                end
            end
        end
    end
end

logicHandler.GetCellContainingActor = function(actorUniqueIndex)

    for cellDescription, cell in pairs(LoadedCells) do

        if tableHelper.containsValue(cell.data.packets.actorList, actorUniqueIndex) then
            return cell
        end
    end

    return nil
end

logicHandler.SetAIForActor = function(cell, actorUniqueIndex, action, targetPid, targetUniqueIndex,
    posX, posY, posZ, distance, duration, shouldRepeat)

    if cell ~= nil and actorUniqueIndex ~= nil then

        local aiData = dataTableBuilder.BuildAIData(targetPid, targetUniqueIndex, action,
            posX, posY, posZ, distance, duration, shouldRepeat)

        -- Save this AI package to the actor's objectData in its cell, but only if
        -- the associated action isn't ACTIVATE, because we don't want the activation
        -- to happen every time someone loads the cell
        if action ~= enumerations.ai.ACTIVATE then

            cell.data.objectData[actorUniqueIndex].ai = aiData
            tableHelper.insertValueIfMissing(cell.data.packets.ai, actorUniqueIndex)
            cell:QuicksaveToDrive()
        end

        -- Initialize the packet for the current cell authority
        local pid = cell.authority
        tes3mp.ClearActorList()
        tes3mp.SetActorListPid(pid)
        tes3mp.SetActorListCell(cell.description)

        packetBuilder.AddAIActor(actorUniqueIndex, targetPid, aiData)

        -- If the cell authority leaves, we want the new cell authority to resume
        -- this AI package, so we send the packet to all of the cell's visitors
        -- i.e. sendToOtherVisitors is true and skipAttachedPlayer is false
        tes3mp.SendActorAI(true, false)

    else
        tes3mp.LogAppend(enumerations.log.ERROR, "Invalid input for logicHandler.SetAIForActor()!")
    end
end

logicHandler.IsCellLoaded = function(cellDescription)

    return LoadedCells[cellDescription] ~= nil
end

logicHandler.SetCellAuthority = function(pid, cellDescription)
    LoadedCells[cellDescription]:SetAuthority(pid)
end

logicHandler.LoadRecordStore = function(storeType)

    if RecordStores[storeType] == nil then

        RecordStores[storeType] = RecordStore(storeType)

        -- If this record store has a data entry, load it
        if RecordStores[storeType]:HasEntry() then
            RecordStores[storeType]:LoadFromDrive()
            RecordStores[storeType]:EnsureDataStructure()
        -- Otherwise, create a data file for it
        else
            RecordStores[storeType]:CreateEntry()
        end
    end
end

logicHandler.LoadCell = function(cellDescription)

    -- If this cell isn't loaded at all, load it
    if LoadedCells[cellDescription] == nil then

        LoadedCells[cellDescription] = Cell(cellDescription)

        -- If this cell has a data entry, load it
        if LoadedCells[cellDescription]:HasEntry() then
            LoadedCells[cellDescription]:LoadFromDrive()
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
    -- Otherwise, only set this new visitor as the authority if their ping is noticeably lower
    -- than that of the current authority
    elseif tes3mp.GetAvgPing(pid) < (tes3mp.GetAvgPing(authPid) - config.pingDifferenceRequiredForAuthority) then
        tes3mp.LogMessage(enumerations.log.WARN, "Player " .. logicHandler.GetChatName(pid) ..
            " took over authority from player " .. logicHandler.GetChatName(authPid) ..
            " in " .. cellDescription .. " for latency reasons")
        LoadedCells[cellDescription]:SetAuthority(pid)
    end
end

logicHandler.UnloadCell = function(cellDescription)

    if LoadedCells[cellDescription] ~= nil then

        LoadedCells[cellDescription]:SaveToDrive()
        LoadedCells[cellDescription] = nil
    end
end

logicHandler.UnloadCellForPlayer = function(pid, cellDescription)

    if LoadedCells[cellDescription] ~= nil then

        -- No longer record that this player has the cell loaded
        LoadedCells[cellDescription]:RemoveVisitor(pid)
        LoadedCells[cellDescription]:SaveActorPositions()
        LoadedCells[cellDescription]:SaveActorStatsDynamic()
        LoadedCells[cellDescription]:QuicksaveToDrive()

        -- If this player was the cell's authority, set another player
        -- as the authority
        if LoadedCells[cellDescription]:GetAuthority() == pid then

            local visitors = LoadedCells[cellDescription].visitors

            if tableHelper.getCount(visitors) > 0 then
                local newAuthorityPid = logicHandler.GetLowestPingPid(visitors)
                LoadedCells[cellDescription]:SetAuthority(newAuthorityPid)
            end
        end
    end
end

logicHandler.LoadRegionForPlayer = function(pid, regionName, isTeleported)

    if regionName == "" then return end

    tes3mp.LogMessage(enumerations.log.INFO, "Loading region " .. regionName .. " for " ..
        logicHandler.GetChatName(pid))

    -- Record that this player has the region loaded
    WorldInstance:AddRegionVisitor(pid, regionName)
    local authPid = WorldInstance:GetRegionAuthority(regionName)

    -- Set the latest known weather for this player; if isTeleported is true, the weather
    -- will be forced, i.e. set instantly to how it is for the authority
    WorldInstance:LoadRegionWeather(regionName, pid, false, isTeleported)

    -- If the region's authority is nil, set this player as the authority
    if authPid == nil then
        WorldInstance:SetRegionAuthority(pid, regionName)
    else
        -- If the player has been teleported here, we'll be receiving an update for this weather
        -- from the region authority, so store this new visitor in the forcedUpdatePids for when
        -- that packet arrives
        if isTeleported then
            WorldInstance:AddForcedWeatherUpdatePid(pid, regionName)

        -- Only set this new visitor as the authority if they haven't been teleported here and
        -- their ping is noticeably lower than that of the current authority
        elseif not isTeleported and
            tes3mp.GetAvgPing(pid) < (tes3mp.GetAvgPing(authPid) - config.pingDifferenceRequiredForAuthority) then
            tes3mp.LogMessage(enumerations.log.WARN, "Player " .. logicHandler.GetChatName(pid) ..
                " took over authority from player " .. logicHandler.GetChatName(authPid) ..
                " in region " .. regionName .. " for latency reasons")
            WorldInstance:SetRegionAuthority(pid, regionName)
        end
    end
end

logicHandler.UnloadRegionForPlayer = function(pid, regionName)

    if regionName == "" then return end

    if WorldInstance.storedRegions[regionName] ~= nil then

        tes3mp.LogMessage(enumerations.log.INFO, "Unloading region " .. regionName .. " for " ..
            logicHandler.GetChatName(pid))

        -- No longer record that this player has the region loaded
        WorldInstance:RemoveRegionVisitor(pid, regionName)

        -- If this player was the region's authority, set another player
        -- as the authority
        if WorldInstance:GetRegionAuthority(regionName) == pid then

            local visitors = WorldInstance.storedRegions[regionName].visitors

            if tableHelper.getCount(visitors) > 0 then
                local newAuthorityPid = logicHandler.GetLowestPingPid(visitors)
                WorldInstance:SetRegionAuthority(newAuthorityPid, regionName)
            else
                WorldInstance.storedRegions[regionName].authority = nil
            end
        end
    end
end

return logicHandler
