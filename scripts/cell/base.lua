require("patterns")

contentFixer = require("contentFixer")
tableHelper = require("tableHelper")
inventoryHelper = require("inventoryHelper")
packetBuilder = require("packetBuilder")

local BaseCell = class("BaseCell")

function BaseCell:__init(cellDescription)

    self.data =
    {
        entry = {
            description = cellDescription,
            creationTime = os.time()
        },
        loadState = {
            hasFullActorList = false,
            hasFullContainerData = false
        },
        lastVisit = {},
        objectData = {},
        packets = {},
        recordLinks = {}
    }

    self:EnsurePacketTables()

    self.description = cellDescription
    self.visitors = {}
    self.authority = nil

    self.isRequestingContainerData = false
    self.containerRequestPid = nil

    self.isRequestingActorList = false
    self.actorListRequestPid = nil

    self.isResetting = false

    self.unusableContainerUniqueIndexes = {}

    self.isExterior = false

    if string.match(cellDescription, patterns.exteriorCell) then
        self.isExterior = true

        local _, _, gridX, gridY = string.find(cellDescription, patterns.exteriorCell)

        self.gridX = tonumber(gridX)
        self.gridY = tonumber(gridY)
    end
end

function BaseCell:ContainsPosition(posX, posY)

    local cellSize = 8192

    if self.isExterior then
        local correctGridX = math.floor(posX / cellSize)
        local correctGridY = math.floor(posY / cellSize)

        if self.gridX ~= correctGridX or self.gridY ~= correctGridY then
            return false
        end
    end

    return true
end

function BaseCell:HasEntry()
    return self.hasEntry
end

-- Iterate through the packets table and ensure all packet types are included in it
function BaseCell:EnsurePacketTables()

    if self.data.packets == nil then self.data.packets = {} end

    for _, packetType in pairs(config.cellPacketTypes) do
        if self.data.packets[packetType] == nil then
            self.data.packets[packetType] = {}
        end
    end
end

-- Iterate through saved packets and ensure the object uniqueIndexes they refer to
-- actually exist
function BaseCell:EnsurePacketValidity()

    for packetType, packetArray in pairs(self.data.packets) do
        for arrayIndex, uniqueIndex in pairs(self.data.packets[packetType]) do
            if self.data.objectData[uniqueIndex] == nil then
                tableHelper.removeValue(self.data.packets[packetType], uniqueIndex)
            end
        end
    end
end

-- Adding record links to cells is special because we'll keep track of the uniqueIndex
-- of every object that uses a particular generated record
function BaseCell:AddLinkToRecord(storeType, recordId, uniqueIndex)

    if self.data.recordLinks == nil then self.data.recordLinks = {} end

    local recordStore = RecordStores[storeType]

    if recordStore ~= nil then

        local recordLinks = self.data.recordLinks

        if recordLinks[storeType] == nil then recordLinks[storeType] = {} end
        if recordLinks[storeType][recordId] == nil then recordLinks[storeType][recordId] = {} end

        if not tableHelper.containsValue(self.data.recordLinks[storeType][recordId], uniqueIndex) then
            table.insert(self.data.recordLinks[storeType][recordId], uniqueIndex)
        end

        recordStore:AddLinkToCell(recordId, self)
        recordStore:QuicksaveToDrive()
    end
end

function BaseCell:RemoveLinkToRecord(storeType, recordId, uniqueIndex)

    local recordStore = RecordStores[storeType]

    if recordStore ~= nil then

        local recordLinks = self.data.recordLinks

        if recordLinks ~= nil and recordLinks[storeType] ~= nil and recordLinks[storeType][recordId] ~= nil then

            local linkIndex = tableHelper.getIndexByValue(recordLinks[storeType][recordId], uniqueIndex)

            if linkIndex ~= nil then
                recordLinks[storeType][recordId][linkIndex] = nil
            end

            local remainingIndexCount = tableHelper.getCount(recordLinks[storeType][recordId])

            if remainingIndexCount == 0 then
                recordLinks[storeType][recordId] = nil

                recordStore:RemoveLinkToCell(recordId, self)
                recordStore:QuicksaveToDrive()
            end
        end
    end
end

function BaseCell:ClearRecordLinks()

    for storeType, storeLinksTable in pairs(self.data.recordLinks) do
        
        local recordStore = RecordStores[storeType]

        if recordStore ~= nil then

            for recordId, uniqueIndexes in pairs(storeLinksTable) do

                for _, uniqueIndex in pairs(uniqueIndexes) do

                    self:RemoveLinkToRecord(storeType, recordId, uniqueIndex)
                end
            end
        end
    end
end

function BaseCell:GetVisitorCount()
    return tableHelper.getCount(self.visitors)
end

function BaseCell:AddVisitor(pid)

    -- Only add new visitor if we don't already have them
    if not tableHelper.containsValue(self.visitors, pid) then
        table.insert(self.visitors, pid)

        -- Also add a record to the player's list of loaded cells
        Players[pid]:AddCellLoaded(self.description)

        self:LoadGeneratedRecords(pid)

        local shouldSendInfo = false
        local lastVisitTimestamp = self.data.lastVisit[Players[pid].accountName]

        -- If this player has never been in this cell, they should be
        -- sent its cell data
        if lastVisitTimestamp == nil then
            shouldSendInfo = true
        -- Otherwise, send them the cell data only if they haven't
        -- visited since last connecting to the server
        elseif Players[pid].data.timestamps.lastLogin > lastVisitTimestamp then
            shouldSendInfo = true
        end

        if shouldSendInfo == true then
            -- First, fix whatever quest problems exist in this cell
            contentFixer.FixCell(pid, self.description)

            self:LoadInitialCellData(pid)
        end

        self:LoadMomentaryCellData(pid)

        if not self:HasFullContainerData() and not self.isRequestingContainerData then
            tes3mp.LogAppend(enumerations.log.INFO, "- Requesting containers")
            self:RequestContainers(pid)
        end

        if not self:HasFullActorList() and not self.isRequestingActorList then
            tes3mp.LogAppend(enumerations.log.INFO, "- Requesting actor list")
            self:RequestActorList(pid)
        end
    end
end

function BaseCell:RemoveVisitor(pid)

    -- Only remove visitor if they are actually recorded as one
    if tableHelper.containsValue(self.visitors, pid) then

        tableHelper.removeValue(self.visitors, pid)

        -- Also remove the record from the player's list of loaded cells
        Players[pid]:RemoveCellLoaded(self.description)

        -- Remember when this visitor left
        self:SaveLastVisit(Players[pid].accountName)

        -- Were we waiting on a container request from this pid?
        if self.isRequestingContainerData == true and self.containerRequestPid == pid then
            self.isRequestingContainerData = false
            self.containerRequestPid = nil
        end

        -- Were we waiting on an actorList request from this pid?
        if self.isRequestingActorList == true and self.actorListRequestPid == pid then
            self.isRequestingActorList = false
            self.actorListRequestPid = nil
        end
    end
end

function BaseCell:GetAuthority()
    return self.authority
end

function BaseCell:SetAuthority(pid)
    self.authority = pid
    tes3mp.LogMessage(enumerations.log.INFO, "Authority of cell " .. self.data.entry.description ..
        " is now " .. logicHandler.GetChatName(pid))

    self:LoadActorAuthority(pid)
end

-- Check whether an object is in this cell
function BaseCell:ContainsObject(uniqueIndex)
    if self.data.objectData[uniqueIndex] ~= nil and self.data.objectData[uniqueIndex].refId ~= nil then
        return true
    end

    return false
end

function BaseCell:HasFullContainerData()

    if self.data.loadState.hasFullContainerData == true then
        return true
    end

    return false
end

function BaseCell:HasFullActorList()

    if self.data.loadState.hasFullActorList == true then
        return true
    end

    return false
end

function BaseCell:InitializeObjectData(uniqueIndex, refId)

    if uniqueIndex ~= nil and refId ~= nil and self.data.objectData[uniqueIndex] == nil then
        self.data.objectData[uniqueIndex] = {}
        self.data.objectData[uniqueIndex].refId = refId
    end
end

function BaseCell:DeleteObjectData(uniqueIndex)

    if self.data.objectData[uniqueIndex] == nil then
        return
    end

    -- Is this a player's summon? If so, remove it from the summons tracked
    -- for the player
    local summon = self.data.objectData[uniqueIndex].summon

    if summon ~= nil then
        if summon.summoner.playerName ~= nil and logicHandler.IsPlayerNameLoggedIn(summon.summoner.playerName) then
            logicHandler.GetPlayerByName(summon.summoner.playerName).summons[uniqueIndex] = nil
        end
    end

    -- Delete all packets associated with an object
    for packetIndex, packetType in pairs(self.data.packets) do
        tableHelper.removeValue(self.data.packets[packetIndex], uniqueIndex)
    end

    -- Delete all object data
    self.data.objectData[uniqueIndex] = nil
end

function BaseCell:MoveObjectData(uniqueIndex, newCell)

    -- Ensure we're not trying to move the object to the cell it's already in
    if self.description == newCell.description then return end

    -- Move all packets about this uniqueIndex from the old cell to the new cell
    for packetIndex, packetType in pairs(self.data.packets) do

        if tableHelper.containsValue(self.data.packets[packetIndex], uniqueIndex) then

            table.insert(newCell.data.packets[packetIndex], uniqueIndex)
            tableHelper.removeValue(self.data.packets[packetIndex], uniqueIndex)
        end
    end

    newCell.data.objectData[uniqueIndex] = self.data.objectData[uniqueIndex]
    self.data.objectData[uniqueIndex] = nil
end

function BaseCell:SaveLastVisit(playerName)
    self.data.lastVisit[playerName] = os.time()
end

function BaseCell:SaveObjectsDeleted(objects)

    local temporaryLoadedCells = {}

    for uniqueIndex, object in pairs(objects) do

        local refId = object.refId

        -- Check whether this object was moved to this cell from another one
        local wasMovedHere = tableHelper.containsValue(self.data.packets.cellChangeFrom, uniqueIndex)

        if wasMovedHere == true then

            local originalCellDescription = self.data.objectData[uniqueIndex].cellChangeFrom

            -- If the new cell is not loaded, load it temporarily
            if LoadedCells[originalCellDescription] == nil then
                logicHandler.LoadCell(originalCellDescription)
                table.insert(temporaryLoadedCells, originalCellDescription)
            end

            local originalCell = LoadedCells[originalCellDescription]

            originalCell:DeleteObjectData(uniqueIndex)
            table.insert(originalCell.data.packets.delete, uniqueIndex)
            originalCell:InitializeObjectData(uniqueIndex, refId)

            self:DeleteObjectData(uniqueIndex)

        else
            -- Check whether this is a placed or spawned object
            local wasPlacedHere = tableHelper.containsValue(self.data.packets.place, uniqueIndex) or
                tableHelper.containsValue(self.data.packets.spawn, uniqueIndex)

            self:DeleteObjectData(uniqueIndex)

            -- If this is an object from the game's data files, we should keep sending ObjectDelete
            -- packets for it to visitors
            if not wasPlacedHere then

                table.insert(self.data.packets.delete, uniqueIndex)
                self:InitializeObjectData(uniqueIndex, refId)

            -- If this is an object based on a generated record, we need to remove the link to it
            elseif logicHandler.IsGeneratedRecord(refId) then
                local recordStore = logicHandler.GetRecordStoreByRecordId(refId)

                if recordStore ~= nil then
                    self:RemoveLinkToRecord(recordStore.storeType, refId, uniqueIndex)
                end
            end
        end
    end

    -- Go through every temporary loaded cell and unload it
    for arrayIndex, originalCellDescription in pairs(temporaryLoadedCells) do
        logicHandler.UnloadCell(originalCellDescription)
    end
end

function BaseCell:SaveObjectsPlaced(objects)

    for uniqueIndex, object in pairs(objects) do

        local location = object.location

        -- Ensure data integrity before proceeeding
        if tableHelper.getCount(location) == 6 and tableHelper.usesNumericalValues(location) and
            self:ContainsPosition(location.posX, location.posY) then

            local refId = object.refId
            self:InitializeObjectData(uniqueIndex, refId)

            local count = object.count
            local charge = object.charge
            local enchantmentCharge = object.enchantmentCharge
            local soul = object.soul
            local goldValue = object.goldValue

            -- Only save count if it isn't the default value of 1
            if count ~= 1 then
                self.data.objectData[uniqueIndex].count = count
            end

            -- Only save charge if it isn't the default value of -1
            if charge ~= -1 then
                self.data.objectData[uniqueIndex].charge = charge
            end

            -- Only save enchantment charge if it isn't the default value of -1
            if enchantmentCharge ~= -1 then
                self.data.objectData[uniqueIndex].enchantmentCharge = enchantmentCharge
            end

            if soul ~= "" then
               self.data.objectData[uniqueIndex].soul = soul
            end

            -- Only save goldValue if it isn't the default value of 1
            if goldValue ~= 1 then
                self.data.objectData[uniqueIndex].goldValue = goldValue
            end

            self.data.objectData[uniqueIndex].location = location

            tes3mp.LogAppend(enumerations.log.INFO, "- " .. uniqueIndex .. ", refId: " .. refId ..
                ", count: " .. count .. ", charge: " .. charge .. ", enchantmentCharge: " .. enchantmentCharge ..
                ", soul: " .. soul .. ", goldValue: " .. goldValue)

            table.insert(self.data.packets.place, uniqueIndex)

            if logicHandler.IsGeneratedRecord(refId) then
                local recordStore = logicHandler.GetRecordStoreByRecordId(refId)

                if recordStore ~= nil then
                    self:AddLinkToRecord(recordStore.storeType, refId, uniqueIndex)
                end
            end
        end
    end

    self:QuicksaveToDrive()
end

function BaseCell:SaveObjectsSpawned(objects)

    for uniqueIndex, object in pairs(objects) do

        local location = object.location

        -- Ensure data integrity before proceeeding
        if tableHelper.getCount(location) == 6 and tableHelper.usesNumericalValues(location) and
            self:ContainsPosition(location.posX, location.posY) then

            local refId = object.refId
            self:InitializeObjectData(uniqueIndex, refId)

            tes3mp.LogAppend(enumerations.log.INFO, "- " .. uniqueIndex .. ", refId: " .. refId)

            self.data.objectData[uniqueIndex].location = location

            if object.summon ~= nil then
                local summonDuration = object.summon.duration

                if summonDuration > 0 then
                    local summon = {}
                    summon.duration = object.summon.duration
                    summon.effectId = object.summon.effectId
                    summon.spellId = object.summon.spellId
                    summon.startTime = object.summon.startTime
                    summon.summoner = {}

                    local hasPlayerSummoner = object.summon.hasPlayerSummoner

                    if hasPlayerSummoner then
                        local summonerPid = object.summon.summoner.pid
                        tes3mp.LogAppend(enumerations.log.INFO, "- summoned by player " ..
                            logicHandler.GetChatName(summonerPid))

                        -- Track the player and the summon for each other
                        summon.summoner.playerName = object.summon.summoner.playerName

                        Players[summonerPid].summons[uniqueIndex] = refId
                    else
                        summon.summoner.refId = object.summon.summoner.refId
                        summon.summoner.uniqueIndex = object.summon.summoner.uniqueIndex
                        tes3mp.LogAppend(enumerations.log.INFO, "- summoned by actor " .. summon.summoner.uniqueIndex ..
                            ", refId: " .. summon.summoner.refId)
                    end

                    self.data.objectData[uniqueIndex].summon = summon
                end
            end

            table.insert(self.data.packets.spawn, uniqueIndex)
            table.insert(self.data.packets.actorList, uniqueIndex)

            if logicHandler.IsGeneratedRecord(refId) then
                local recordStore = logicHandler.GetRecordStoreByRecordId(refId)

                if recordStore ~= nil then
                    self:AddLinkToRecord(recordStore.storeType, refId, uniqueIndex)
                end
            end
        end
    end
end

function BaseCell:SaveObjectsLocked(objects)

    for uniqueIndex, object in pairs(objects) do

        local refId = object.refId
        local lockLevel = object.lockLevel

        self:InitializeObjectData(uniqueIndex, refId)
        self.data.objectData[uniqueIndex].lockLevel = lockLevel

        tes3mp.LogAppend(enumerations.log.INFO, "- " .. uniqueIndex .. ", refId: " .. refId ..
            ", lockLevel: " .. lockLevel)

        tableHelper.insertValueIfMissing(self.data.packets.lock, uniqueIndex)
    end
end

function BaseCell:SaveObjectsMiscellaneous(objects)

    for uniqueIndex, object in pairs(objects) do

        local refId = object.refId

        self:InitializeObjectData(uniqueIndex, refId)
        self.data.objectData[uniqueIndex].goldPool = object.goldPool
        self.data.objectData[uniqueIndex].lastGoldRestockHour = object.lastGoldRestockHour
        self.data.objectData[uniqueIndex].lastGoldRestockDay = object.lastGoldRestockDay

        tes3mp.LogAppend(enumerations.log.INFO, "- " .. uniqueIndex .. ", refId: " .. refId ..
            ", goldPool: " .. object.goldPool .. ", lastGoldRestockHour: " .. object.lastGoldRestockHour ..
            ", lastGoldRestockDay: " .. object.lastGoldRestockDay)

        tableHelper.insertValueIfMissing(self.data.packets.miscellaneous, uniqueIndex)
    end
end

function BaseCell:SaveObjectTrapsTriggered(objects)

    for uniqueIndex, object in pairs(objects) do

        local refId = object.refId

        self:InitializeObjectData(uniqueIndex, refId)

        tes3mp.LogAppend(enumerations.log.INFO, "- " .. uniqueIndex .. ", refId: " .. refId)

        tableHelper.insertValueIfMissing(self.data.packets.trap, uniqueIndex)
    end
end

function BaseCell:SaveObjectsScaled(objects)

    for uniqueIndex, object in pairs(objects) do

        local refId = object.refId
        local scale = object.scale

        self:InitializeObjectData(uniqueIndex, refId)
        self.data.objectData[uniqueIndex].scale = scale

        tes3mp.LogAppend(enumerations.log.INFO, "- " .. uniqueIndex .. ", refId: " .. refId ..
            ", scale: " .. scale)

        tableHelper.insertValueIfMissing(self.data.packets.scale, uniqueIndex)
    end
end

function BaseCell:SaveObjectStates(objects)

    for uniqueIndex, object in pairs(objects) do

        local refId = object.refId
        local state = object.state

        self:InitializeObjectData(uniqueIndex, refId)
        self.data.objectData[uniqueIndex].state = state

        tes3mp.LogAppend(enumerations.log.INFO, "- " .. uniqueIndex .. ", refId: " .. refId ..
            ", state: " .. tostring(state))

        tableHelper.insertValueIfMissing(self.data.packets.state, uniqueIndex)
    end
end

function BaseCell:SaveDoorStates(objects)

    for uniqueIndex, object in pairs(objects) do

        local refId = object.refId
        local doorState = object.doorState

        self:InitializeObjectData(uniqueIndex, refId)
        self.data.objectData[uniqueIndex].doorState = doorState

        tableHelper.insertValueIfMissing(self.data.packets.doorState, uniqueIndex)
    end
end

function BaseCell:SaveClientScriptLocals(objects)

    for uniqueIndex, object in pairs(objects) do

        local refId = object.refId
        local variables = object.variables

        self:InitializeObjectData(uniqueIndex, refId)

        if self.data.objectData[uniqueIndex].variables == nil then
            self.data.objectData[uniqueIndex].variables = {}
        end

        for variableType, variableTable in pairs(object.variables) do
            if self.data.objectData[uniqueIndex].variables[variableType] == nil then
                self.data.objectData[uniqueIndex].variables[variableType] = {}
            end

            for internalIndex, value in pairs(variableTable) do
                self.data.objectData[uniqueIndex].variables[variableType][internalIndex] = value
            end
        end

        tableHelper.insertValueIfMissing(self.data.packets.clientScriptLocal, uniqueIndex)
    end
end

function BaseCell:SaveContainers(pid)

    tes3mp.ReadReceivedObjectList()
    tes3mp.CopyReceivedObjectListToStore()

    tes3mp.LogMessage(enumerations.log.INFO, "Saving Container from " .. logicHandler.GetChatName(pid) ..
        " about " .. self.description)

    local packetOrigin = tes3mp.GetObjectListOrigin()
    local action = tes3mp.GetObjectListAction()
    local subAction = tes3mp.GetObjectListContainerSubAction()

    for objectIndex = 0, tes3mp.GetObjectListSize() - 1 do

        local uniqueIndex = tes3mp.GetObjectRefNum(objectIndex) .. "-" .. tes3mp.GetObjectMpNum(objectIndex)
        local refId = tes3mp.GetObjectRefId(objectIndex)

        tes3mp.LogAppend(enumerations.log.INFO, "- " .. uniqueIndex .. ", refId: " .. refId)

        self:InitializeObjectData(uniqueIndex, refId)

        tableHelper.insertValueIfMissing(self.data.packets.container, uniqueIndex)

        local inventory = self.data.objectData[uniqueIndex].inventory

        -- If this object's inventory is nil, or if the action is SET,
        -- change the inventory to an empty table
        if inventory == nil or action == enumerations.container.SET then
            inventory = {}
        end

        for itemIndex = 0, tes3mp.GetContainerChangesSize(objectIndex) - 1 do

            local itemRefId = tes3mp.GetContainerItemRefId(objectIndex, itemIndex)
            local itemCount = tes3mp.GetContainerItemCount(objectIndex, itemIndex)
            local itemCharge = tes3mp.GetContainerItemCharge(objectIndex, itemIndex)
            local itemEnchantmentCharge = tes3mp.GetContainerItemEnchantmentCharge(objectIndex, itemIndex)
            local itemSoul = tes3mp.GetContainerItemSoul(objectIndex, itemIndex)
            local actionCount = tes3mp.GetContainerItemActionCount(objectIndex, itemIndex)

            -- Check if the object's stored inventory contains this item already
            if inventoryHelper.containsItem(inventory, itemRefId, itemCharge, itemEnchantmentCharge, itemSoul) then
                local foundIndex = inventoryHelper.getItemIndex(inventory, itemRefId, itemCharge,
                    itemEnchantmentCharge, itemSoul)
                local item = inventory[foundIndex]

                if action == enumerations.container.ADD then
                    tes3mp.LogAppend(enumerations.log.VERBOSE, "- Adding count of " .. itemCount .. " to existing item " ..
                        item.refId .. " with current count of " .. item.count)
                    item.count = item.count + itemCount

                elseif action == enumerations.container.REMOVE then
                    local newCount = item.count - actionCount

                    -- The item will still exist in the container with a lower count
                    if newCount > 0 then
                        tes3mp.LogAppend(enumerations.log.VERBOSE, "- Removed count of " .. actionCount .. " from item " ..
                            item.refId .. " that had count of " .. item.count .. ", resulting in remaining count of " .. newCount)
                        item.count = newCount
                    -- The item is to be completely removed
                    elseif newCount == 0 then
                        inventory[foundIndex] = nil
                    else
                        actionCount = item.count
                        tes3mp.LogAppend(enumerations.log.WARN, "- Attempt to remove count of " .. actionCount ..
                            " from item" .. item.refId .. " that only had count of " .. item.count)
                        tes3mp.LogAppend(enumerations.log.WARN, "- Removed just " .. actionCount .. " instead")
                        tes3mp.SetContainerItemActionCountByIndex(objectIndex, itemIndex, actionCount)
                        inventory[foundIndex] = nil
                    end

                    -- Is this a generated record? If so, remove the link to it
                    if inventory[foundIndex] == nil and logicHandler.IsGeneratedRecord(itemRefId) then
                        local recordStore = logicHandler.GetRecordStoreByRecordId(itemRefId)

                        if recordStore ~= nil then
                            self:RemoveLinkToRecord(recordStore.storeType, itemRefId, uniqueIndex)
                        end
                    end
                end
            else
                if action == enumerations.container.REMOVE then
                    tes3mp.LogAppend(enumerations.log.WARN, "- Attempt to remove count of " .. actionCount .. 
                        " from non-existent item " .. itemRefId)
                    tes3mp.SetContainerItemActionCountByIndex(objectIndex, itemIndex, 0)
                else
                    tes3mp.LogAppend(enumerations.log.VERBOSE, "- Added new item " .. itemRefId .. " with count of " ..
                        itemCount)
                    inventoryHelper.addItem(inventory, itemRefId, itemCount,
                        itemCharge, itemEnchantmentCharge, itemSoul)

                    -- Is this a generated record? If so, add a link to it
                    if logicHandler.IsGeneratedRecord(itemRefId) then
                        local recordStore = logicHandler.GetRecordStoreByRecordId(itemRefId)

                        if recordStore ~= nil then
                            self:AddLinkToRecord(recordStore.storeType, itemRefId, uniqueIndex)
                        end
                    end
                end
            end
        end

        tableHelper.cleanNils(inventory)
        self.data.objectData[uniqueIndex].inventory = inventory
    end

    -- Is this a player replying to our request for container contents?
    -- If so, only send the reply to other players
    -- i.e. sendToOtherPlayers is true and skipAttachedPlayer is true
    if subAction == enumerations.containerSub.REPLY_TO_REQUEST then
        tes3mp.SendContainer(true, true)
    -- Is this a container packet originating from a client script or
    -- dialogue? If so, its effects have already taken place on the
    -- sending client, so only send it to other players
    elseif packetOrigin == enumerations.packetOrigin.CLIENT_SCRIPT_LOCAL or
        packetOrigin == enumerations.packetOrigin.CLIENT_SCRIPT_GLOBAL or
        packetOrigin == enumerations.packetOrigin.CLIENT_DIALOGUE then
        tes3mp.SendContainer(true, true)
    -- Otherwise, send the received packet to everyone, including the
    -- player who sent it (because no clientside changes will be made
    -- to the related container otherwise)
    -- i.e. sendToOtherPlayers is true and skipAttachedPlayer is false
    else
        tes3mp.SendContainer(true, false)
    end

    self:QuicksaveToDrive()

    -- Were we waiting on a full container data request from this pid?
    if self.isRequestingContainerData == true and self.containerRequestPid == pid and
        subAction == enumerations.containerSub.REPLY_TO_REQUEST then
        self.isRequestingContainerData = false
        self.data.loadState.hasFullContainerData = true

        tes3mp.LogAppend(enumerations.log.INFO, "- " .. self.description ..
            " is now recorded as having full container data")
    end
end

function BaseCell:SaveActorsByPacketType(packetType, actors)

    if packetType == "ActorList" then
        self:SaveActorList(actors)
    elseif packetType == "ActorEquipment" then
        self:SaveActorEquipment(actors)
    elseif packetType == "ActorSpellsActive" then
        self:SaveActorSpellsActive(actors)
    elseif packetType == "ActorDeath" then
        self:SaveActorDeath(actors)
    end    
end

function BaseCell:SaveObjectsByPacketType(packetType, objects)

    if packetType == "ObjectPlace" then
        self:SaveObjectsPlaced(objects)
    elseif packetType == "ObjectSpawn" then
        self:SaveObjectsSpawned(objects)
    elseif packetType == "ObjectDelete" then
        self:SaveObjectsDeleted(objects)
    elseif packetType == "ObjectLock" then
        self:SaveObjectsLocked(objects)
    elseif packetType == "ObjectMiscellaneous" then
        self:SaveObjectsMiscellaneous(objects)
    elseif packetType == "ObjectTrap" then
        self:SaveObjectTrapsTriggered(objects)
    elseif packetType == "ObjectScale" then
        self:SaveObjectsScaled(objects)
    elseif packetType == "ObjectState" then
        self:SaveObjectStates(objects)
    elseif packetType == "DoorState" then
        self:SaveDoorStates(objects)
    elseif packetType == "ClientScriptLocal" then
        self:SaveClientScriptLocals(objects)
    end
end

function BaseCell:SaveActorList(actors)

    for uniqueIndex, actor in pairs(actors) do

        self:InitializeObjectData(uniqueIndex, actor.refId)
        tes3mp.LogAppend(enumerations.log.INFO, "- " .. uniqueIndex .. ", refId: " .. actor.refId)

        tableHelper.insertValueIfMissing(self.data.packets.actorList, uniqueIndex)
    end

    self:QuicksaveToDrive()

    -- Were we waiting on an actor list request from this pid?
    if self.isRequestingActorList == true then
        self.isRequestingActorList = false
        self.data.loadState.hasFullActorList = true

        tes3mp.LogAppend(enumerations.log.INFO, "- " .. self.description ..
            " is now recorded as having a full actor list")
    end
end

function BaseCell:SaveActorPositions()

    tes3mp.ReadCellActorList(self.description)
    local actorListSize = tes3mp.GetActorListSize()

    if actorListSize == 0 then
        return
    end

    for objectIndex = 0, actorListSize - 1 do

        local uniqueIndex = tes3mp.GetActorRefNum(objectIndex) .. "-" .. tes3mp.GetActorMpNum(objectIndex)

        if tes3mp.DoesActorHavePosition(objectIndex) == true and self:ContainsObject(uniqueIndex) then

            self.data.objectData[uniqueIndex].location = {
                posX = tes3mp.GetActorPosX(objectIndex),
                posY = tes3mp.GetActorPosY(objectIndex),
                posZ = tes3mp.GetActorPosZ(objectIndex),
                rotX = tes3mp.GetActorRotX(objectIndex),
                rotY = tes3mp.GetActorRotY(objectIndex),
                rotZ = tes3mp.GetActorRotZ(objectIndex)
            }

            tableHelper.insertValueIfMissing(self.data.packets.position, uniqueIndex)
        end
    end
end

function BaseCell:SaveActorStatsDynamic()

    tes3mp.ReadCellActorList(self.description)
    local actorListSize = tes3mp.GetActorListSize()

    if actorListSize == 0 then
        return
    end

    for objectIndex = 0, actorListSize - 1 do

        local uniqueIndex = tes3mp.GetActorRefNum(objectIndex) .. "-" .. tes3mp.GetActorMpNum(objectIndex)

        if tes3mp.DoesActorHaveStatsDynamic(objectIndex) == true and self:ContainsObject(uniqueIndex) then

            self.data.objectData[uniqueIndex].stats = {
                healthBase = tes3mp.GetActorHealthBase(objectIndex),
                healthCurrent = tes3mp.GetActorHealthCurrent(objectIndex),
                healthModified = tes3mp.GetActorHealthModified(objectIndex),
                magickaBase = tes3mp.GetActorMagickaBase(objectIndex),
                magickaCurrent = tes3mp.GetActorMagickaCurrent(objectIndex),
                magickaModified = tes3mp.GetActorMagickaModified(objectIndex),
                fatigueBase = tes3mp.GetActorFatigueBase(objectIndex),
                fatigueCurrent = tes3mp.GetActorFatigueCurrent(objectIndex),
                fatigueModified = tes3mp.GetActorFatigueModified(objectIndex)
            }

            tableHelper.insertValueIfMissing(self.data.packets.statsDynamic, uniqueIndex)
        end
    end
end

function BaseCell:SaveActorEquipment(actors)

    for uniqueIndex, actor in pairs(actors) do

        tes3mp.LogAppend(enumerations.log.INFO, "- " .. uniqueIndex)

        if self:ContainsObject(uniqueIndex) then
            self.data.objectData[uniqueIndex].equipment = {}

            for equipmentIndex, item in pairs(actor.equipment) do
                self.data.objectData[uniqueIndex].equipment[equipmentIndex] = item
            end

            tableHelper.insertValueIfMissing(self.data.packets.equipment, uniqueIndex)
        end
    end

    self:QuicksaveToDrive()
end

function BaseCell:SaveActorSpellsActive(actors)

    for uniqueIndex, actor in pairs(actors) do

        tes3mp.LogAppend(enumerations.log.INFO, "- " .. uniqueIndex)

        if self:ContainsObject(uniqueIndex) then

            local action = actor.spellActiveChangesAction

            if action == enumerations.spellbook.SET or self.data.objectData[uniqueIndex].spellsActive == nil then
                self.data.objectData[uniqueIndex].spellsActive = {}
            end

            for spellId, spellInstances in pairs(actor.spellsActive) do

                if action == enumerations.spellbook.SET or action == enumerations.spellbook.ADD then
                    if self.data.objectData[uniqueIndex].spellsActive[spellId] == nil then
                        self.data.objectData[uniqueIndex].spellsActive[spellId] = {}
                    end

                    for _, spellInstanceValues in pairs(spellInstances) do

                        local spellInstanceIndex

                        -- Get an unused spellInstanceIndex if this is a spell with stacking effects
                        if spellInstanceValues.stackingState then
                            spellInstanceIndex = tableHelper.getUnusedNumericalIndex(
                                self.data.objectData[uniqueIndex].spellsActive[spellId])
                        -- Otherwise, replace what's under index 1
                        else
                            spellInstanceIndex = 1
                        end

                        self.data.objectData[uniqueIndex].spellsActive[spellId][spellInstanceIndex] = {
                            displayName = spellInstanceValues.displayName,
                            stackingState = spellInstanceValues.stackingState,
                            effects = tableHelper.deepCopy(spellInstanceValues.effects),
                            startTime = os.time()
                        }

                        if spellInstanceValues.caster ~= nil then
                            self.data.objectData[uniqueIndex].spellsActive[spellId][spellInstanceIndex].caster = {
                                playerName = spellInstanceValues.caster.playerName,
                                refId = spellInstanceValues.caster.refId,
                                uniqueIndex = spellInstanceValues.caster.uniqueIndex
                            }
                        end
                    end
                elseif action == enumerations.spellbook.REMOVE then
                    if self.data.objectData[uniqueIndex].spellsActive[spellId] ~= nil then
                        self.data.objectData[uniqueIndex].spellsActive[spellId][1] = nil

                        if tableHelper.getCount(self.data.objectData[uniqueIndex].spellsActive[spellId]) == 0 then
                            self.data.objectData[uniqueIndex].spellsActive[spellId] = nil
                        end
                    end
                end
            end

            if action == enumerations.spellbook.REMOVE then
                tableHelper.cleanNils(self.data.objectData[uniqueIndex].spellsActive)
            end

            if tableHelper.getCount(self.data.objectData[uniqueIndex].spellsActive) > 0 then
                tableHelper.insertValueIfMissing(self.data.packets.spellsActive, uniqueIndex)
            else
                tableHelper.removeValue(self.data.packets.spellsActive, uniqueIndex)
            end
        end
    end

    self:QuicksaveToDrive()
end

function BaseCell:SaveActorDeath(actors)

    if self.data.packets.death == nil then
        self.data.packets.death = {}
    end

    for uniqueIndex, actor in pairs(actors) do

        if self:ContainsObject(uniqueIndex) then

            self.data.objectData[uniqueIndex].deathState = actor.deathState

            if actor.killer.pid ~= nil then
                self.data.objectData[uniqueIndex].killer = {
                    playerName = actor.killer.playerName
                }
            elseif actor.killerName ~= "" then
                self.data.objectData[uniqueIndex].killer = {
                    refId = actor.killer.refId,
                    uniqueIndex = actor.killer.uniqueIndex
                }
            end

            tableHelper.insertValueIfMissing(self.data.packets.death, uniqueIndex)
        end
    end

    self:QuicksaveToDrive()
end

function BaseCell:SaveActorCellChanges(pid)

    local temporaryLoadedCells = {}

    tes3mp.ReadReceivedActorList()
    tes3mp.LogMessage(enumerations.log.INFO, "Saving ActorCellChange from " .. logicHandler.GetChatName(pid) ..
        " about " .. self.description)

    for actorIndex = 0, tes3mp.GetActorListSize() - 1 do

        local uniqueIndex = tes3mp.GetActorRefNum(actorIndex) .. "-" .. tes3mp.GetActorMpNum(actorIndex)
        local newCellDescription = tes3mp.GetActorCell(actorIndex)

        if newCellDescription == self.description then
            tes3mp.LogAppend(enumerations.log.INFO, "- Ignored invalid cell change that was moving " .. uniqueIndex .. " to " ..
                self.description .. " despite that actor already being in that cell")
        else
            tes3mp.LogAppend(enumerations.log.INFO, "- " .. uniqueIndex .. " moved to " .. newCellDescription)

            -- If the new cell is not loaded, load it temporarily
            if LoadedCells[newCellDescription] == nil then
                logicHandler.LoadCell(newCellDescription)
                table.insert(temporaryLoadedCells, newCellDescription)
            end

            local newCell = LoadedCells[newCellDescription]

            -- Only proceed if this Actor is actually supposed to exist in this cell
            if self.data.objectData[uniqueIndex] ~= nil then

                -- Was this actor spawned in the old cell, instead of being a pre-existing actor?
                -- If so, delete it entirely from the old cell and make it get spawned in the new cell
                if tableHelper.containsValue(self.data.packets.spawn, uniqueIndex) == true then
                    tes3mp.LogAppend(enumerations.log.INFO, "-- As a server-only object, it was moved entirely")

                    -- If this object is based on a generated record, move its record link
                    -- to the new cell
                    local refId = self.data.objectData[uniqueIndex].refId

                    if logicHandler.IsGeneratedRecord(refId) then

                        local recordStore = logicHandler.GetRecordStoreByRecordId(refId)

                        if recordStore ~= nil then
                            newCell:AddLinkToRecord(recordStore.storeType, refId, uniqueIndex)
                            self:RemoveLinkToRecord(recordStore.storeType, refId, uniqueIndex)
                        end

                        -- Send this generated record to every visitor in the new cell
                        for _, visitorPid in pairs(newCell.visitors) do
                            if pid ~= visitorPid then
                                recordStore:LoadGeneratedRecords(visitorPid, recordStore.data.generatedRecords, { refId })
                            end
                        end
                    end

                    -- This actor won't exist at all for players who have not loaded the actor's original
                    -- cell and were not online when it was first spawned, so send all of its details to them
                    for _, player in pairs(Players) do
                        if pid ~= player.pid and not tableHelper.containsValue(self.visitors, player.pid) then
                            self:LoadActorPackets(player.pid, self.data.objectData, { uniqueIndex })
                        end
                    end

                    self:MoveObjectData(uniqueIndex, newCell)

                -- Was this actor moved to the old cell from another cell?
                elseif tableHelper.containsValue(self.data.packets.cellChangeFrom, uniqueIndex) == true then

                    local originalCellDescription = self.data.objectData[uniqueIndex].cellChangeFrom

                    -- Is the new cell actually this actor's original cell?
                    -- If so, move its data back and remove all of its cell change data
                    if originalCellDescription == newCellDescription then
                        tes3mp.LogAppend(enumerations.log.INFO, "-- It is now back in its original cell " .. originalCellDescription)
                        self:MoveObjectData(uniqueIndex, newCell)

                        tableHelper.removeValue(newCell.data.packets.cellChangeTo, uniqueIndex)
                        tableHelper.removeValue(newCell.data.packets.cellChangeFrom, uniqueIndex)

                        newCell.data.objectData[uniqueIndex].cellChangeTo = nil
                        newCell.data.objectData[uniqueIndex].cellChangeFrom = nil
                    -- Otherwise, move its data to the new cell, delete it from the old cell, and update its
                    -- information in its original cell
                    else
                        self:MoveObjectData(uniqueIndex, newCell)

                        -- If the original cell is not loaded, load it temporarily
                        if LoadedCells[originalCellDescription] == nil then
                            logicHandler.LoadCell(originalCellDescription)
                            table.insert(temporaryLoadedCells, originalCellDescription)
                        end

                        local originalCell = LoadedCells[originalCellDescription]

                        if originalCell.data.objectData[uniqueIndex] ~= nil then
                            tes3mp.LogAppend(enumerations.log.INFO, "-- This is now referenced in its original cell " ..
                                originalCellDescription)
                            originalCell.data.objectData[uniqueIndex].cellChangeTo = newCellDescription
                        else
                            tes3mp.LogAppend(enumerations.log.ERROR, "-- It does not exist in its original cell " ..
                                originalCellDescription .. "! Please report this to a developer")
                        end
                    end

                -- Otherwise, simply move this actor's data to the new cell and mark it as being moved there
                -- in its old cell, as long as it's not supposed to already be in the new cell
                elseif self.data.objectData[uniqueIndex].cellChangeTo ~= newCellDescription then

                    tes3mp.LogAppend(enumerations.log.INFO, "-- This was its first move away from its original cell")

                    self:MoveObjectData(uniqueIndex, newCell)

                    table.insert(self.data.packets.cellChangeTo, uniqueIndex)

                    if self.data.objectData[uniqueIndex] == nil then
                        self.data.objectData[uniqueIndex] = {}
                    end

                    self.data.objectData[uniqueIndex].cellChangeTo = newCellDescription

                    table.insert(newCell.data.packets.cellChangeFrom, uniqueIndex)

                    newCell.data.objectData[uniqueIndex].cellChangeFrom = self.description
                end

                if newCell.data.objectData[uniqueIndex] ~= nil then
                    newCell.data.objectData[uniqueIndex].location = {
                        posX = tes3mp.GetActorPosX(actorIndex),
                        posY = tes3mp.GetActorPosY(actorIndex),
                        posZ = tes3mp.GetActorPosZ(actorIndex),
                        rotX = tes3mp.GetActorRotX(actorIndex),
                        rotY = tes3mp.GetActorRotY(actorIndex),
                        rotZ = tes3mp.GetActorRotZ(actorIndex)
                    }
                end
            else
                tes3mp.LogAppend(enumerations.log.ERROR, "-- Invalid cell change was attempted! Please report " ..
                    "this to a developer")
            end
        end
    end

    -- Go through every temporary loaded cell and unload it
    for arrayIndex, newCellDescription in pairs(temporaryLoadedCells) do
        logicHandler.UnloadCell(newCellDescription)
    end

    self:QuicksaveToDrive()
end

function BaseCell:LoadActorPackets(pid, objectData, uniqueIndexArray)

    local packets = self.data.packets

    self:LoadObjectsDeleted(pid, objectData, tableHelper.getValueOverlap(uniqueIndexArray, packets.delete))
    self:LoadObjectsSpawned(pid, objectData, tableHelper.getValueOverlap(uniqueIndexArray, packets.spawn))
    self:LoadObjectsScaled(pid, objectData, tableHelper.getValueOverlap(uniqueIndexArray, packets.scale))

    self:LoadContainers(pid, objectData, tableHelper.getValueOverlap(uniqueIndexArray, packets.container))

    self:LoadActorPositions(pid, objectData, tableHelper.getValueOverlap(uniqueIndexArray, packets.position))
    self:LoadActorDeath(pid, objectData, tableHelper.getValueOverlap(uniqueIndexArray, packets.statsDynamic))
    self:LoadActorStatsDynamic(pid, objectData, tableHelper.getValueOverlap(uniqueIndexArray, packets.statsDynamic))
    self:LoadActorEquipment(pid, objectData, tableHelper.getValueOverlap(uniqueIndexArray, packets.equipment))
    self:LoadActorAI(pid, objectData, tableHelper.getValueOverlap(uniqueIndexArray, packets.ai))
end

function BaseCell:LoadObjectsDeleted(pid, objectData, uniqueIndexArray, forEveryone)

    local objectCount = 0

    tes3mp.ClearObjectList()
    tes3mp.SetObjectListPid(pid)
    tes3mp.SetObjectListCell(self.description)

    for arrayIndex, uniqueIndex in pairs(uniqueIndexArray) do

        packetBuilder.AddObjectDelete(uniqueIndex, objectData[uniqueIndex])
        objectCount = objectCount + 1
    end

    if objectCount > 0 then
        tes3mp.SendObjectDelete(forEveryone)
    end
end

function BaseCell:LoadObjectsPlaced(pid, objectData, uniqueIndexArray, forEveryone)

    local objectCount = 0

    tes3mp.ClearObjectList()
    tes3mp.SetObjectListPid(pid)
    tes3mp.SetObjectListCell(self.description)

    for arrayIndex, uniqueIndex in pairs(uniqueIndexArray) do

        if objectData[uniqueIndex] ~= nil then

            local location = objectData[uniqueIndex].location

            -- Ensure data integrity before proceeeding
            if type(location) == "table" and tableHelper.getCount(location) == 6 and
                tableHelper.usesNumericalValues(location) and
                self:ContainsPosition(location.posX, location.posY) then

                packetBuilder.AddObjectPlace(uniqueIndex, objectData[uniqueIndex])
                objectCount = objectCount + 1
            else
                objectData[uniqueIndex] = nil
                tableHelper.removeValue(uniqueIndexArray, uniqueIndex)
            end

            -- If we're about to exceed the maximum number of objects in a single packet,
            -- start a new packet
            if objectCount >= 3000 then
                tes3mp.SendObjectPlace()    
                tes3mp.ClearObjectList()
                tes3mp.SetObjectListPid(pid)
                tes3mp.SetObjectListCell(self.description)
                objectCount = 0
            end
        end
    end

    if objectCount > 0 then
        tes3mp.SendObjectPlace(forEveryone)
    end
end

function BaseCell:LoadObjectsSpawned(pid, objectData, uniqueIndexArray, forEveryone)

    local objectCount = 0

    tes3mp.ClearObjectList()
    tes3mp.SetObjectListPid(pid)
    tes3mp.SetObjectListCell(self.description)

    for arrayIndex, uniqueIndex in pairs(uniqueIndexArray) do

        if objectData[uniqueIndex] ~= nil then

            local location = objectData[uniqueIndex].location

            -- Ensure data integrity before proceeeding
            if type(location) == "table" and tableHelper.getCount(location) == 6 and
                tableHelper.usesNumericalValues(location) and
                self:ContainsPosition(location.posX, location.posY) then

                local shouldSkip = false
                local summon = objectData[uniqueIndex].summon

                if summon ~= nil then
                    local currentTime = os.time()
                    local finishTime = summon.startTime + summon.duration

                    -- Don't spawn this summoned creature if its summoning duration is over..
                    if currentTime >= finishTime then
                        self:DeleteObjectData(uniqueIndex)
                        shouldSkip = true
                    -- ...or if its player is offline
                    elseif summon.summoner.playerName ~= nil then
                        if not logicHandler.IsPlayerNameLoggedIn(summon.summoner.playerName) then
                            shouldSkip = true
                        end
                    -- ...or if it doesn't have an actor stored as its summoner
                    elseif summon.summoner.uniqueIndex == nil then
                        shouldSkip = true
                    end
                end

                if not shouldSkip then
                    packetBuilder.AddObjectSpawn(uniqueIndex, objectData[uniqueIndex])
                    objectCount = objectCount + 1
                end
            else
                objectData[uniqueIndex] = nil
                tableHelper.removeValue(uniqueIndexArray, uniqueIndex)
            end
        end
    end

    if objectCount > 0 then
        tes3mp.SendObjectSpawn(forEveryone)
    end
end

function BaseCell:LoadObjectsLocked(pid, objectData, uniqueIndexArray, forEveryone)

    local objectCount = 0

    tes3mp.ClearObjectList()
    tes3mp.SetObjectListPid(pid)
    tes3mp.SetObjectListCell(self.description)

    for arrayIndex, uniqueIndex in pairs(uniqueIndexArray) do

        if objectData[uniqueIndex] ~= nil and objectData[uniqueIndex].refId ~= nil and
            objectData[uniqueIndex].lockLevel ~= nil then

            packetBuilder.AddObjectLock(uniqueIndex, objectData[uniqueIndex])
            objectCount = objectCount + 1
        else
            tableHelper.removeValue(uniqueIndexArray, uniqueIndex)
        end
    end

    if objectCount > 0 then
        tes3mp.SendObjectLock(forEveryone)
    end
end

function BaseCell:LoadObjectsMiscellaneous(pid, objectData, uniqueIndexArray, forEveryone)

    local objectCount = 0

    tes3mp.ClearObjectList()
    tes3mp.SetObjectListPid(pid)
    tes3mp.SetObjectListCell(self.description)

    for arrayIndex, uniqueIndex in pairs(uniqueIndexArray) do

        if objectData[uniqueIndex] ~= nil and objectData[uniqueIndex].refId ~= nil and
            objectData[uniqueIndex].goldPool ~= nil then

            local lastGoldRestockHour = objectData[uniqueIndex].lastGoldRestockHour
            local lastGoldRestockDay = objectData[uniqueIndex].lastGoldRestockDay

            if lastGoldRestockHour == nil or lastGoldRestockDay == nil then
                objectData[uniqueIndex].lastGoldRestockHour = 0
                objectData[uniqueIndex].lastGoldRestockDay = 0
            end

            packetBuilder.AddObjectMiscellaneous(uniqueIndex, objectData[uniqueIndex])
            objectCount = objectCount + 1
        else
            tableHelper.removeValue(uniqueIndexArray, uniqueIndex)
        end
    end

    if objectCount > 0 then
        tes3mp.SendObjectMiscellaneous(forEveryone)
    end
end

function BaseCell:LoadObjectTrapsTriggered(pid, objectData, uniqueIndexArray, forEveryone)

    local objectCount = 0

    tes3mp.ClearObjectList()
    tes3mp.SetObjectListPid(pid)
    tes3mp.SetObjectListCell(self.description)

    for arrayIndex, uniqueIndex in pairs(uniqueIndexArray) do

        if objectData[uniqueIndex] ~= nil then
            packetBuilder.AddObjectTrap(uniqueIndex, objectData[uniqueIndex])
            objectCount = objectCount + 1
        else
            tableHelper.removeValue(uniqueIndexArray, uniqueIndex)
        end
    end

    if objectCount > 0 then
        tes3mp.SendObjectTrap(forEveryone)
    end
end

function BaseCell:LoadObjectsScaled(pid, objectData, uniqueIndexArray, forEveryone)

    local objectCount = 0

    tes3mp.ClearObjectList()
    tes3mp.SetObjectListPid(pid)
    tes3mp.SetObjectListCell(self.description)

    for arrayIndex, uniqueIndex in pairs(uniqueIndexArray) do

        if objectData[uniqueIndex] ~= nil and objectData[uniqueIndex].refId ~= nil and
            objectData[uniqueIndex].scale ~= nil then

            packetBuilder.AddObjectScale(uniqueIndex, objectData[uniqueIndex])
            objectCount = objectCount + 1
        else
            tableHelper.removeValue(uniqueIndexArray, uniqueIndex)
        end
    end

    if objectCount > 0 then
        tes3mp.SendObjectScale(forEveryone)
    end
end

function BaseCell:LoadObjectStates(pid, objectData, uniqueIndexArray, forEveryone)

    local objectCount = 0

    tes3mp.ClearObjectList()
    tes3mp.SetObjectListPid(pid)
    tes3mp.SetObjectListCell(self.description)

    for arrayIndex, uniqueIndex in pairs(uniqueIndexArray) do

        if objectData[uniqueIndex] ~= nil and objectData[uniqueIndex].refId ~= nil and
            objectData[uniqueIndex].state ~= nil then

            packetBuilder.AddObjectState(uniqueIndex, objectData[uniqueIndex])
            objectCount = objectCount + 1
        else
            tableHelper.removeValue(uniqueIndexArray, uniqueIndex)
        end
    end

    if objectCount > 0 then
        tes3mp.SendObjectState(forEveryone)
    end
end

function BaseCell:LoadDoorStates(pid, objectData, uniqueIndexArray, forEveryone)

    local objectCount = 0

    tes3mp.ClearObjectList()
    tes3mp.SetObjectListPid(pid)
    tes3mp.SetObjectListCell(self.description)

    for arrayIndex, uniqueIndex in pairs(uniqueIndexArray) do

        if objectData[uniqueIndex] ~= nil then
            packetBuilder.AddDoorState(uniqueIndex, objectData[uniqueIndex])
            objectCount = objectCount + 1
        else
            tableHelper.removeValue(uniqueIndexArray, uniqueIndex)
        end
    end

    if objectCount > 0 then
        tes3mp.SendDoorState(forEveryone)
    end
end

function BaseCell:LoadClientScriptLocals(pid, objectData, uniqueIndexArray, forEveryone)

    local objectCount = 0

    tes3mp.ClearObjectList()
    tes3mp.SetObjectListPid(pid)
    tes3mp.SetObjectListCell(self.description)

    for arrayIndex, uniqueIndex in pairs(uniqueIndexArray) do
        packetBuilder.AddClientScriptLocal(uniqueIndex, objectData[uniqueIndex])
        objectCount = objectCount + 1
    end

    if objectCount > 0 then
        tes3mp.SendClientScriptLocal(forEveryone)
    end
end

function BaseCell:LoadContainers(pid, objectData, uniqueIndexArray)

    local objectCount = 0

    tes3mp.ClearObjectList()
    tes3mp.SetObjectListPid(pid)
    tes3mp.SetObjectListCell(self.description)

    for arrayIndex, uniqueIndex in pairs(uniqueIndexArray) do

        local splitIndex = uniqueIndex:split("-")
        tes3mp.SetObjectRefNum(splitIndex[1])
        tes3mp.SetObjectMpNum(splitIndex[2])

        if self:ContainsObject(uniqueIndex) and objectData[uniqueIndex].inventory ~= nil then
            tes3mp.SetObjectRefId(objectData[uniqueIndex].refId)

            for itemIndex, item in pairs(objectData[uniqueIndex].inventory) do

                if item.enchantmentCharge == nil then
                    item.enchantmentCharge = -1
                end

                if item.soul == nil then
                    item.soul = ""
                end

                tes3mp.SetContainerItemRefId(item.refId)
                tes3mp.SetContainerItemCount(item.count)
                tes3mp.SetContainerItemCharge(item.charge)
                tes3mp.SetContainerItemEnchantmentCharge(item.enchantmentCharge)
                tes3mp.SetContainerItemSoul(item.soul)

                tes3mp.AddContainerItem()
            end

            tes3mp.AddObject()

            objectCount = objectCount + 1
        else
            tes3mp.LogAppend(enumerations.log.ERROR, "- Had container packet recorded for " .. uniqueIndex ..
                ", but no matching object data! Please report this to a developer")
            tableHelper.removeValue(uniqueIndexArray, uniqueIndex)
        end
    end

    if objectCount > 0 then

        -- Set the action to SET
        tes3mp.SetObjectListAction(0)

        tes3mp.SendContainer()
    end
end

function BaseCell:LoadObjectsByPacketType(packetType, pid, objectData, uniqueIndexArray, forEveryone)

    if packetType == "ObjectPlace" then
        self:LoadObjectsPlaced(pid, objectData, uniqueIndexArray, forEveryone)
    elseif packetType == "ObjectSpawn" then
        self:LoadObjectsSpawned(pid, objectData, uniqueIndexArray, forEveryone)
    elseif packetType == "ObjectDelete" then
        self:LoadObjectsDeleted(pid, objectData, uniqueIndexArray, forEveryone)
    elseif packetType == "ObjectLock" then
        self:LoadObjectsLocked(pid, objectData, uniqueIndexArray, forEveryone)
    elseif packetType == "ObjectMiscellaneous" then
        self:LoadObjectsMiscellaneous(pid, objectData, uniqueIndexArray, forEveryone)
    elseif packetType == "ObjectTrap" then
        self:LoadObjectTrapsTriggered(pid, objectData, uniqueIndexArray, forEveryone)
    elseif packetType == "ObjectScale" then
        self:LoadObjectsScaled(pid, objectData, uniqueIndexArray, forEveryone)
    elseif packetType == "ObjectState" then
        self:LoadObjectStates(pid, objectData, uniqueIndexArray, forEveryone)
    elseif packetType == "DoorState" then
        self:LoadDoorStates(pid, objectData, uniqueIndexArray, forEveryone)
    elseif packetType == "ClientScriptLocal" then
        self:LoadClientScriptLocals(pid, objectData, uniqueIndexArray, forEveryone)
    end
end

function BaseCell:LoadActorList(pid, objectData, uniqueIndexArray)

    local actorCount = 0

    tes3mp.ClearActorList()
    tes3mp.SetActorListPid(pid)
    tes3mp.SetActorListCell(self.description)

    for arrayIndex, uniqueIndex in pairs(uniqueIndexArray) do

        local splitIndex = uniqueIndex:split("-")
        tes3mp.SetActorRefNum(splitIndex[1])
        tes3mp.SetActorMpNum(splitIndex[2])

        if self:ContainsObject(uniqueIndex) then
            tes3mp.SetActorRefId(objectData[uniqueIndex].refId)

            actorCount = actorCount + 1
        else
            tes3mp.LogAppend(enumerations.log.ERROR, "- Had actorList packet recorded for " .. uniqueIndex ..
                ", but no matching object data! Please report this to a developer")
            tableHelper.removeValue(uniqueIndexArray, uniqueIndex)
        end
    end

    if actorCount > 0 then

        -- Set the action to SET
        tes3mp.SetActorListAction(0)

        tes3mp.SendActorList()
    end
end

function BaseCell:LoadActorAuthority(pid)

    tes3mp.ClearActorList()
    tes3mp.SetActorListPid(pid)
    tes3mp.SetActorListCell(self.description)

    tes3mp.SendActorAuthority()
end

function BaseCell:LoadActorPositions(pid, objectData, uniqueIndexArray)

    local actorCount = 0

    tes3mp.ClearActorList()
    tes3mp.SetActorListPid(pid)
    tes3mp.SetActorListCell(self.description)

    for arrayIndex, uniqueIndex in pairs(uniqueIndexArray) do

        local splitIndex = uniqueIndex:split("-")
        tes3mp.SetActorRefNum(splitIndex[1])
        tes3mp.SetActorMpNum(splitIndex[2])

        if self:ContainsObject(uniqueIndex) then
            local location = objectData[uniqueIndex].location

            -- Ensure data integrity before proceeeding
            if tableHelper.getCount(location) == 6 and tableHelper.usesNumericalValues(location) and
                self:ContainsPosition(location.posX, location.posY) then

                tes3mp.SetActorPosition(location.posX, location.posY, location.posZ)
                tes3mp.SetActorRotation(location.rotX, location.rotY, location.rotZ)

                tes3mp.AddActor()

                actorCount = actorCount + 1
            end
        else
            tes3mp.LogAppend(enumerations.log.ERROR, "- Had position packet recorded for " .. uniqueIndex ..
                ", but no matching object data! Please report this to a developer")
            tableHelper.removeValue(uniqueIndexArray, uniqueIndex)
        end
    end

    if actorCount > 0 then
        tes3mp.SendActorPosition()
    end
end

function BaseCell:LoadActorStatsDynamic(pid, objectData, uniqueIndexArray)

    local actorCount = 0

    tes3mp.ClearActorList()
    tes3mp.SetActorListPid(pid)
    tes3mp.SetActorListCell(self.description)

    for arrayIndex, uniqueIndex in pairs(uniqueIndexArray) do

        local splitIndex = uniqueIndex:split("-")
        tes3mp.SetActorRefNum(splitIndex[1])
        tes3mp.SetActorMpNum(splitIndex[2])

        if self:ContainsObject(uniqueIndex) and objectData[uniqueIndex].stats ~= nil then
            local stats = objectData[uniqueIndex].stats

            tes3mp.SetActorHealthBase(stats.healthBase)
            tes3mp.SetActorHealthCurrent(stats.healthCurrent)
            tes3mp.SetActorHealthModified(stats.healthModified)
            tes3mp.SetActorMagickaBase(stats.magickaBase)
            tes3mp.SetActorMagickaCurrent(stats.magickaCurrent)
            tes3mp.SetActorMagickaModified(stats.magickaModified)
            tes3mp.SetActorFatigueBase(stats.fatigueBase)
            tes3mp.SetActorFatigueCurrent(stats.fatigueCurrent)
            tes3mp.SetActorFatigueModified(stats.fatigueModified)

            tes3mp.AddActor()

            actorCount = actorCount + 1
        else
            tes3mp.LogAppend(enumerations.log.ERROR, "- Had statsDynamic packet recorded for " .. uniqueIndex ..
                ", but no matching object data! Please report this to a developer")
            tableHelper.removeValue(uniqueIndexArray, uniqueIndex)
        end
    end

    if actorCount > 0 then
        tes3mp.SendActorStatsDynamic()
    end
end

function BaseCell:LoadActorEquipment(pid, objectData, uniqueIndexArray)

    local actorCount = 0

    tes3mp.ClearActorList()
    tes3mp.SetActorListPid(pid)
    tes3mp.SetActorListCell(self.description)

    for arrayIndex, uniqueIndex in pairs(uniqueIndexArray) do

        local splitIndex = uniqueIndex:split("-")
        tes3mp.SetActorRefNum(splitIndex[1])
        tes3mp.SetActorMpNum(splitIndex[2])

        if self:ContainsObject(uniqueIndex) and objectData[uniqueIndex].equipment ~= nil then
            local equipment = objectData[uniqueIndex].equipment

            for itemIndex = 0, tes3mp.GetEquipmentSize() - 1 do

                local currentItem = equipment[itemIndex]

                if currentItem ~= nil then
                    if currentItem.enchantmentCharge == nil then
                        currentItem.enchantmentCharge = -1
                    end

                    tes3mp.EquipActorItem(itemIndex, currentItem.refId, currentItem.count,
                        currentItem.charge, currentItem.enchantmentCharge)
                else
                    tes3mp.UnequipActorItem(itemIndex)
                end
            end

            tes3mp.AddActor()

            actorCount = actorCount + 1
        else
            tes3mp.LogAppend(enumerations.log.ERROR, "- Had equipment packet recorded for " .. uniqueIndex ..
                ", but no matching object data! Please report this to a developer")
            tableHelper.removeValue(uniqueIndexArray, uniqueIndex)
        end
    end

    if actorCount > 0 then
        tes3mp.SendActorEquipment()
    end
end

function BaseCell:LoadActorSpellsActive(pid, objectData, uniqueIndexArray)

    local actorCount = 0

    tes3mp.ClearActorList()
    tes3mp.SetActorListPid(pid)
    tes3mp.SetActorListCell(self.description)

    for arrayIndex, uniqueIndex in pairs(uniqueIndexArray) do

        local splitIndex = uniqueIndex:split("-")
        tes3mp.SetActorRefNum(splitIndex[1])
        tes3mp.SetActorMpNum(splitIndex[2])

        if self:ContainsObject(uniqueIndex) and objectData[uniqueIndex].spellsActive ~= nil then

            packetBuilder.AddActorSpellsActive(uniqueIndex, objectData[uniqueIndex].spellsActive,
                enumerations.spellbook.SET)

            actorCount = actorCount + 1
        else
            tes3mp.LogAppend(enumerations.log.ERROR, "- Had spellsActive packet recorded for " .. uniqueIndex ..
                ", but no matching object data! Please report this to a developer")
            tableHelper.removeValue(uniqueIndexArray, uniqueIndex)
        end
    end

    if actorCount > 0 then
        tes3mp.SendActorSpellsActiveChanges()
    end
end

function BaseCell:LoadActorDeath(pid, objectData, uniqueIndexArray)

    local actorCount = 0

    tes3mp.ClearActorList()
    tes3mp.SetActorListPid(pid)
    tes3mp.SetActorListCell(self.description)

    for arrayIndex, uniqueIndex in pairs(uniqueIndexArray) do

        local splitIndex = uniqueIndex:split("-")
        tes3mp.SetActorRefNum(splitIndex[1])
        tes3mp.SetActorMpNum(splitIndex[2])

        if self:ContainsObject(uniqueIndex) and objectData[uniqueIndex].deathState ~= nil then
            if objectData[uniqueIndex].stats == nil or objectData[uniqueIndex].stats.healthCurrent < 1 then
                tes3mp.SetActorDeathState(objectData[uniqueIndex].deathState)
                tes3mp.SetActorDeathInstant(true)
                tes3mp.AddActor()

                actorCount = actorCount + 1
            else
                tes3mp.LogAppend(enumerations.log.ERROR, "- Had death packet recorded for " .. uniqueIndex ..
                ", but its health is above 0! Please report this to a developer")
                tableHelper.removeValue(uniqueIndexArray, uniqueIndex)
            end
        else
            tes3mp.LogAppend(enumerations.log.ERROR, "- Had death packet recorded for " .. uniqueIndex ..
                ", but no matching object data! Please report this to a developer")
            tableHelper.removeValue(uniqueIndexArray, uniqueIndex)
        end
    end

    if actorCount > 0 then
        tes3mp.SendActorDeath()
    end    
end

function BaseCell:LoadActorAI(pid, objectData, uniqueIndexArray)

    local actorCount = 0

    -- These packets only need to be sent to the new visitor, unless the
    -- new visitor is the target of some of them, in which case those
    -- need to be tracked and sent separately to all the cell's visitors
    local sharedPacketUniqueIndexes = {}

    tes3mp.ClearActorList()
    tes3mp.SetActorListPid(pid)
    tes3mp.SetActorListCell(self.description)

    for arrayIndex, uniqueIndex in pairs(uniqueIndexArray) do

        local splitIndex = uniqueIndex:split("-")
        tes3mp.SetActorRefNum(splitIndex[1])
        tes3mp.SetActorMpNum(splitIndex[2])

        if self:ContainsObject(uniqueIndex) and objectData[uniqueIndex].ai ~= nil then
            local ai = objectData[uniqueIndex].ai
            local targetPid

            if ai.targetPlayer ~= nil then
                if logicHandler.IsPlayerNameLoggedIn(ai.targetPlayer) then
                    targetPid = logicHandler.GetPlayerByName(ai.targetPlayer).pid
                end
            end

            local isValid = true

            -- Don't allow untargeted packets that require targets
            if targetPid == nil and ai.targetUniqueIndex == nil then
                if ai.action == enumerations.ai.ACTIVATE or ai.action == enumerations.ai.COMBAT or
                    ai.action == enumerations.ai.ESCORT or ai.action == enumerations.ai.FOLLOW then

                    isValid = false
                    tes3mp.LogAppend(enumerations.log.WARN, "- Could not find valid AI target for actor " ..
                        uniqueIndex)
                end
            end

            if isValid then
                -- Is this new visitor the target of one of the actors? If so, we'll
                -- send a separate packet to every cell visitor with just that at
                -- the end
                if pid == targetPid then
                    table.insert(sharedPacketUniqueIndexes, uniqueIndex)
                else
                    packetBuilder.AddAIActor(uniqueIndex, targetPid, ai)

                    actorCount = actorCount + 1
                end
            end
        else
            tes3mp.LogAppend(enumerations.log.ERROR, "- Had AI packet recorded for " .. uniqueIndex ..
                ", but no matching object data! Please report this to a developer")
            tableHelper.removeValue(uniqueIndexArray, uniqueIndex)
        end
    end

    -- Send the packets meant for just this new visitor
    if actorCount > 0 then
        tes3mp.SendActorAI(false)
    end

    -- Send the packets targeting this visitor that all the visitors
    -- need to have
    if tableHelper.getCount(sharedPacketUniqueIndexes) > 0 then

        tes3mp.ClearActorList()
        tes3mp.SetActorListPid(pid)
        tes3mp.SetActorListCell(self.description)

        for arrayIndex, uniqueIndex in pairs(sharedPacketUniqueIndexes) do

            local splitIndex = uniqueIndex:split("-")
            tes3mp.SetActorRefNum(splitIndex[1])
            tes3mp.SetActorMpNum(splitIndex[2])
            local ai = objectData[uniqueIndex].ai
            packetBuilder.AddAIActor(uniqueIndex, pid, ai)
        end

        tes3mp.SendActorAI(true)
    end
end

function BaseCell:LoadActorCellChanges(pid, objectData)

    local temporaryLoadedCells = {}
    local actorCount = 0

    -- Move actors originally from this cell to other cells
    tes3mp.ClearActorList()
    tes3mp.SetActorListPid(pid)
    tes3mp.SetActorListCell(self.description)

    for arrayIndex, uniqueIndex in pairs(self.data.packets.cellChangeTo) do

        if objectData[uniqueIndex] ~= nil and objectData[uniqueIndex].cellChangeTo ~= nil then

            local newCellDescription = objectData[uniqueIndex].cellChangeTo

            tes3mp.SetActorCell(newCellDescription)

            local splitIndex = uniqueIndex:split("-")
            tes3mp.SetActorRefNum(splitIndex[1])
            tes3mp.SetActorMpNum(splitIndex[2])

            -- If the new cell is not loaded, load it temporarily
            if LoadedCells[newCellDescription] == nil then
                logicHandler.LoadCell(newCellDescription)
                table.insert(temporaryLoadedCells, newCellDescription)
            end

            if LoadedCells[newCellDescription].data.objectData[uniqueIndex] ~= nil then

                local location = LoadedCells[newCellDescription].data.objectData[uniqueIndex].location

                -- Ensure data integrity before proceeeding
                if tableHelper.getCount(location) == 6 and tableHelper.usesNumericalValues(location) and
                    LoadedCells[newCellDescription]:ContainsPosition(location.posX, location.posY) then

                    tes3mp.SetActorPosition(location.posX, location.posY, location.posZ)
                    tes3mp.SetActorRotation(location.rotX, location.rotY, location.rotZ)

                    tes3mp.AddActor()

                    actorCount = actorCount + 1
                end
            else
                tes3mp.LogAppend(enumerations.log.ERROR, "- Tried to move " .. uniqueIndex .. " from " ..
                    self.description .. " to  " .. newCellDescription .. " with no position data!")
                objectData[uniqueIndex] = nil
                tableHelper.removeValue(self.data.packets.cellChangeTo, uniqueIndex)
            end
        else
            tes3mp.LogAppend(enumerations.log.ERROR, "- Had cellChangeTo packet recorded for " .. uniqueIndex ..
                ", but no matching cell description! Please report this to a developer")
            tableHelper.removeValue(self.data.packets.cellChangeTo, uniqueIndex)
        end
    end

    if actorCount > 0 then
        tes3mp.SendActorCellChange()
    end

    -- Go through every temporary loaded cell and unload it
    for arrayIndex, newCellDescription in pairs(temporaryLoadedCells) do
        logicHandler.UnloadCell(newCellDescription)
    end

    -- Make a table of every cell that has sent actors to this cell
    local cellChangesFrom = {}

    for arrayIndex, uniqueIndex in pairs(self.data.packets.cellChangeFrom) do

        if objectData[uniqueIndex] ~= nil and objectData[uniqueIndex].cellChangeFrom ~= nil then

            local originalCellDescription = objectData[uniqueIndex].cellChangeFrom

            if cellChangesFrom[originalCellDescription] == nil then
                cellChangesFrom[originalCellDescription] = {}
            end

            table.insert(cellChangesFrom[originalCellDescription], uniqueIndex)
        else
            tes3mp.LogAppend(enumerations.log.ERROR, "- Had cellChangeFrom packet recorded for " .. uniqueIndex ..
                ", but no matching cell description! Please report this to a developer")
            tableHelper.removeValue(self.data.packets.cellChangeFrom, uniqueIndex)
        end
    end

    local actorCount = 0

    -- Send a cell change packet for every cell that has sent actors to this cell
    for originalCellDescription, actorArray in pairs(cellChangesFrom) do

        tes3mp.ClearActorList()
        tes3mp.SetActorListPid(pid)
        tes3mp.SetActorListCell(originalCellDescription)

        for arrayIndex, uniqueIndex in pairs(actorArray) do

            local splitIndex = uniqueIndex:split("-")
            tes3mp.SetActorRefNum(splitIndex[1])
            tes3mp.SetActorMpNum(splitIndex[2])

            tes3mp.SetActorCell(self.description)

            local location = objectData[uniqueIndex].location

            -- Ensure data integrity before proceeeding
            if tableHelper.getCount(location) == 6 and tableHelper.usesNumericalValues(location) and
                self:ContainsPosition(location.posX, location.posY) then

                tes3mp.SetActorPosition(location.posX, location.posY, location.posZ)
                tes3mp.SetActorRotation(location.rotX, location.rotY, location.rotZ)

                tes3mp.AddActor()

                actorCount = actorCount + 1
            end
        end

        if actorCount > 0 then
            tes3mp.SendActorCellChange()
        end
    end
end

function BaseCell:RequestContainers(pid, requestUniqueIndexes)

    self.isRequestingContainerData = true
    self.containerRequestPid = pid

    tes3mp.ClearObjectList()
    tes3mp.SetObjectListPid(pid)
    tes3mp.SetObjectListCell(self.description)

    -- Set the action to REQUEST
    tes3mp.SetObjectListAction(enumerations.container.REQUEST)
    tes3mp.SetObjectListContainerSubAction(enumerations.containerSub.NONE)

    -- If certain uniqueIndexes are specified, iterate through them and
    -- add them as world objects
    --
    -- Otherwise, the client will simply reply with the contents of all
    -- the containers in this cell
    if requestUniqueIndexes ~= nil and type(requestUniqueIndexes) == "table" then
        for arrayIndex, uniqueIndex in pairs(requestUniqueIndexes) do

            local splitIndex = uniqueIndex:split("-")
            tes3mp.SetObjectRefNum(splitIndex[1])
            tes3mp.SetObjectMpNum(splitIndex[2])

            if self.data.objectData[uniqueIndex] ~= nil and self.data.objectData[uniqueIndex].refId ~= nil then
                tes3mp.SetObjectRefId(self.data.objectData[uniqueIndex].refId)
            end
            tes3mp.AddObject()
        end
    end

    tes3mp.SendContainer()
end

function BaseCell:RequestActorList(pid)

    self.isRequestingActorList = true
    self.actorListRequestPid = pid

    tes3mp.ClearActorList()
    tes3mp.SetActorListPid(pid)
    tes3mp.SetActorListCell(self.description)

    -- Set the action to REQUEST
    tes3mp.SetActorListAction(3)

    tes3mp.SendActorList()
end

function BaseCell:LoadInitialCellData(pid)

    self:EnsurePacketTables()
    self:EnsurePacketValidity()

    if self.data.loadState == nil then
        self.data.loadState = {
            hasFullActorList = false,
            hasFullContainerData = false
        }
    end

    tes3mp.LogMessage(enumerations.log.INFO, "Loading data of cell " .. self.description .. " for " ..
        logicHandler.GetChatName(pid))

    local objectData = self.data.objectData
    local packets = self.data.packets

    self:LoadObjectsDeleted(pid, objectData, packets.delete)
    self:LoadObjectsPlaced(pid, objectData, packets.place)
    self:LoadObjectsSpawned(pid, objectData, packets.spawn)
    self:LoadObjectsLocked(pid, objectData, packets.lock)
    self:LoadObjectTrapsTriggered(pid, objectData, packets.trap)
    self:LoadObjectsScaled(pid, objectData, packets.scale)
    self:LoadObjectsMiscellaneous(pid, objectData, packets.miscellaneous)
    self:LoadObjectStates(pid, objectData, packets.state)
    self:LoadDoorStates(pid, objectData, packets.doorState)
    self:LoadClientScriptLocals(pid, objectData, packets.clientScriptLocal)

    self:LoadContainers(pid, objectData, packets.container)

    self:LoadActorCellChanges(pid, objectData)
    self:LoadActorDeath(pid, objectData, packets.death)
    self:LoadActorEquipment(pid, objectData, packets.equipment)
    self:LoadActorSpellsActive(pid, objectData, packets.spellsActive)
    self:LoadActorAI(pid, objectData, packets.ai)
end

function BaseCell:LoadMomentaryCellData(pid)

    local objectData = self.data.objectData
    local packets = self.data.packets

    self:LoadActorPositions(pid, objectData, packets.position)
    self:LoadActorStatsDynamic(pid, objectData, packets.statsDynamic)
end

function BaseCell:LoadGeneratedRecords(pid)

    if self.data.recordLinks == nil then self.data.recordLinks = {} end

    local recordLinks = self.data.recordLinks

    for storeType, recordList in pairs(recordLinks) do

        local recordStore = RecordStores[storeType]

        if recordStore ~= nil then
            recordStore:LoadGeneratedRecords(pid, recordStore.data.generatedRecords,
                tableHelper.getArrayFromIndexes(recordList))
        end
    end
end

return BaseCell
