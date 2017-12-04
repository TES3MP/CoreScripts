require("actionTypes")
require("patterns")
tableHelper = require("tableHelper")
inventoryHelper = require("inventoryHelper")
require("utils")
local BaseCell = class("BaseCell")

function BaseCell:__init(cellDescription)

    self.data =
    {
        entry = {
            description = cellDescription
        },
        lastVisit = {},
        objectData = {},
        packets = {
            delete = {},
            place = {},
            spawn = {},
            lock = {},
            trap = {},
            scale = {},
            state = {},
            doorState = {},
            container = {},
            equipment = {},
            actorList = {},
            position = {},
            statsDynamic = {},
            cellChangeTo = {},
            cellChangeFrom = {}
        }
    };

    self.visitors = {}
    self.authority = nil

    self.isRequestingContainers = false
    self.containerRequestPid = nil

    self.isRequestingActorList = false
    self.actorListRequestPid = nil
end

function BaseCell:HasEntry()
    return self.hasEntry
end

function BaseCell:GetVisitorCount()

    local visitorCount = 0
    for visitor in pairs(self.visitors) do visitorCount = visitorCount + 1 end
    return visitorCount
end

function BaseCell:AddVisitor(pid)

    -- Only add new visitor if we don't already have them
    if tableHelper.containsValue(self.visitors, pid) == false then
        table.insert(self.visitors, pid)

        -- Also add a record to the player's list of loaded cells
        Players[pid]:AddCellLoaded(self.description)

        local shouldSendInfo = false
        local lastVisitTimestamp = self.data.lastVisit[Players[pid].accountName]

        -- If this player has never been in this cell, they should be
        -- sent its cell data
        if lastVisitTimestamp == nil then
            shouldSendInfo = true
        -- Otherwise, send them the cell data only if they haven't
        -- visited since last connecting to the server
        elseif Players[pid].initTimestamp > lastVisitTimestamp then
            shouldSendInfo = true
        end

        if shouldSendInfo == true then
            self:SendInitialCellData(pid)
        end

        self:SendMomentaryCellData(pid)
    end
end

function BaseCell:RemoveVisitor(pid)

    -- Only remove visitor if they are actually recorded as one
    if tableHelper.containsValue(self.visitors, pid) == true then

        tableHelper.removeValue(self.visitors, pid)

        -- Also remove the record from the player's list of loaded cells
        Players[pid]:RemoveCellLoaded(self.description)

        -- Remember when this visitor left
        self:SaveLastVisit(Players[pid].accountName)

        -- Were we waiting on a container request from this pid?
        if self.isRequestingContainers == true and self.containerRequestPid == pid then
            self.isRequestingContainers = false
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
    tes3mp.LogMessage(1, "Authority of " .. self.data.entry.description .. " is now player " .. pid)

    self:SendActorAuthority(pid)
end

-- Iterate through saved packets and ensure the object refIndexes they refer to
-- actually exist
function BaseCell:EnsurePacketValidity()

    for packetType, packetArray in pairs(self.data.packets) do
        for arrayIndex, refIndex in pairs(self.data.packets[packetType]) do
            if self.data.objectData[refIndex] == nil then
                tableHelper.removeValue(self.data.packets[packetType], refIndex)
            end
        end
    end
end

-- Check whether an object is in this cell
function BaseCell:ContainsObject(refIndex)
    if self.data.objectData[refIndex] ~= nil and self.data.objectData[refIndex].refId ~= nil then
        return true
    end

    return false
end

function BaseCell:HasContainerData()

    if tableHelper.isEmpty(self.data.packets.container) == true then
        return false
    end

    return true
end

function BaseCell:HasActorData()

    if tableHelper.isEmpty(self.data.packets.actorList) == true then
        return false
    end

    return true
end

function BaseCell:InitializeObjectData(refIndex, refId)

    if self.data.objectData[refIndex] == nil then
        self.data.objectData[refIndex] = {}
        self.data.objectData[refIndex].refId = refId
    end
end

function BaseCell:DeleteObjectData(refIndex)

    -- Delete all packets associated with an object
    for packetIndex, packetType in pairs(self.data.packets) do
        tableHelper.removeValue(self.data.packets[packetIndex], refIndex)
    end

    -- Delete all object data
    self.data.objectData[refIndex] = nil
end

function BaseCell:MoveObjectData(refIndex, newCell)

    -- Move all packets about this refIndex from the old cell to the new cell
    for packetIndex, packetType in pairs(self.data.packets) do

        if tableHelper.containsValue(self.data.packets[packetIndex], refIndex) then

            table.insert(newCell.data.packets[packetIndex], refIndex)
            tableHelper.removeValue(self.data.packets[packetIndex], refIndex)
        end
    end

    newCell.data.objectData[refIndex] = self.data.objectData[refIndex]

    self.data.objectData[refIndex] = nil
end

function BaseCell:SaveLastVisit(playerName)
    self.data.lastVisit[playerName] = os.time()
end

function BaseCell:SaveObjectsDeleted(pid)

    local temporaryLoadedCells = {}

    tes3mp.ReadLastEvent()
    tes3mp.LogMessage(1, "Saving ObjectDelete from " .. myMod.GetChatName(pid) .. " about " .. self.description)

    for i = 0, tes3mp.GetObjectChangesSize() - 1 do

        local refIndex = tes3mp.GetObjectRefNumIndex(i) .. "-" .. tes3mp.GetObjectMpNum(i)
        local refId = tes3mp.GetObjectRefId(i)

        tes3mp.LogAppend(1, "- " .. refIndex .. ", refId: " .. refId)

        -- Check whether this object was moved to this cell from another one
        local wasMovedHere = tableHelper.containsValue(self.data.packets.cellChangeFrom, refIndex)

        if wasMovedHere == true then

            local originalCellDescription = self.data.objectData[refIndex].cellChangeFrom

            -- If the new cell is not loaded, load it temporarily
            if LoadedCells[originalCellDescription] == nil then
                myMod.LoadCell(originalCellDescription)
                table.insert(temporaryLoadedCells, originalCellDescription)
            end

            local originalCell = LoadedCells[originalCellDescription]

            originalCell:DeleteObjectData(refIndex)
            table.insert(originalCell.data.packets.delete, refIndex)
            originalCell:InitializeObjectData(refIndex, refId)

            self:DeleteObjectData(refIndex)

        else
            -- Check whether this is a placed or spawned object
            local wasPlacedHere = tableHelper.containsValue(self.data.packets.place, refIndex) or tableHelper.containsValue(self.data.packets.spawn, refIndex)

            self:DeleteObjectData(refIndex)

            if wasPlacedHere == false then

                table.insert(self.data.packets.delete, refIndex)
                self:InitializeObjectData(refIndex, refId)
            end
        end
    end

    -- Go through every temporary loaded cell and unload it
    for arrayIndex, originalCellDescription in pairs(temporaryLoadedCells) do
        myMod.UnloadCell(originalCellDescription)
    end
end

function BaseCell:SaveObjectsPlaced(pid)

    tes3mp.ReadLastEvent()
    tes3mp.LogMessage(1, "Saving ObjectPlace from " .. myMod.GetChatName(pid) .. " about " .. self.description)

    for i = 0, tes3mp.GetObjectChangesSize() - 1 do

        local refIndex = tes3mp.GetObjectRefNumIndex(i) .. "-" .. tes3mp.GetObjectMpNum(i)

        local location = {
            posX = tes3mp.GetObjectPosX(i),
            posY = tes3mp.GetObjectPosY(i),
            posZ = tes3mp.GetObjectPosZ(i),
            rotX = tes3mp.GetObjectRotX(i),
            rotY = tes3mp.GetObjectRotY(i),
            rotZ = tes3mp.GetObjectRotZ(i)
        }

        -- Ensure data integrity before proceeeding
        if tableHelper.getCount(location) == 6 and tableHelper.usesNumericalValues(location) then

            local refId = tes3mp.GetObjectRefId(i)
            self:InitializeObjectData(refIndex, refId)

            local count = tes3mp.GetObjectCount(i)
            local charge = tes3mp.GetObjectCharge(i)
            local goldValue = tes3mp.GetObjectGoldValue(i)

            -- Only save count if it isn't the default value of 1
            if count ~= 1 then
                self.data.objectData[refIndex].count = count
            end

            -- Only save charge if it isn't the default value of -1
            if charge ~= -1 then
                self.data.objectData[refIndex].charge = charge
            end

            -- Only save goldValue if it isn't the default value of 1
            if goldValue ~=1 then
                self.data.objectData[refIndex].goldValue = goldValue
            end

            self.data.objectData[refIndex].location = location

            tes3mp.LogAppend(1, "- " .. refIndex .. ", refId: " .. refId .. ", count: " .. count .. ", charge: " .. charge .. ", goldValue: " .. goldValue)

            table.insert(self.data.packets.place, refIndex)
        end
    end
end

function BaseCell:SaveObjectsSpawned(pid)

    tes3mp.ReadLastEvent()
    tes3mp.LogMessage(1, "Saving ObjectSpawn from " .. myMod.GetChatName(pid) .. " about " .. self.description)

    for i = 0, tes3mp.GetObjectChangesSize() - 1 do

        local refIndex = tes3mp.GetObjectRefNumIndex(i) .. "-" .. tes3mp.GetObjectMpNum(i)

        local location = {
            posX = tes3mp.GetObjectPosX(i),
            posY = tes3mp.GetObjectPosY(i),
            posZ = tes3mp.GetObjectPosZ(i),
            rotX = tes3mp.GetObjectRotX(i),
            rotY = tes3mp.GetObjectRotY(i),
            rotZ = tes3mp.GetObjectRotZ(i)
        }

        -- Ensure data integrity before proceeeding
        if tableHelper.getCount(location) == 6 and tableHelper.usesNumericalValues(location) then

            local refId = tes3mp.GetObjectRefId(i)
            self:InitializeObjectData(refIndex, refId)

            self.data.objectData[refIndex].location = location

            tes3mp.LogAppend(1, "- " .. refIndex .. ", refId: " .. refId)

            table.insert(self.data.packets.spawn, refIndex)
            table.insert(self.data.packets.actorList, refIndex)
        end
    end
end

function BaseCell:SaveObjectsLocked(pid)

    tes3mp.ReadLastEvent()
    tes3mp.LogMessage(1, "Saving ObjectLock from " .. myMod.GetChatName(pid) .. " about " .. self.description)

    for i = 0, tes3mp.GetObjectChangesSize() - 1 do

        local refIndex = tes3mp.GetObjectRefNumIndex(i) .. "-" .. tes3mp.GetObjectMpNum(i)
        local refId = tes3mp.GetObjectRefId(i)
        local lockLevel = tes3mp.GetObjectLockLevel(i)

        self:InitializeObjectData(refIndex, refId)
        self.data.objectData[refIndex].lockLevel = lockLevel

        tes3mp.LogAppend(1, "- " .. refIndex .. ", refId: " .. refId .. ", lockLevel: " .. lockLevel)

        tableHelper.insertValueIfMissing(self.data.packets.lock, refIndex)
    end
end

function BaseCell:SaveObjectTrapsTriggered(pid)

    tes3mp.ReadLastEvent()
    tes3mp.LogMessage(1, "Saving ObjectTrap from " .. myMod.GetChatName(pid) .. " about " .. self.description)

    for i = 0, tes3mp.GetObjectChangesSize() - 1 do

        local refIndex = tes3mp.GetObjectRefNumIndex(i) .. "-" .. tes3mp.GetObjectMpNum(i)
        local refId = tes3mp.GetObjectRefId(i)

        self:InitializeObjectData(refIndex, refId)

        tes3mp.LogAppend(1, "- " .. refIndex .. ", refId: " .. refId)

        tableHelper.insertValueIfMissing(self.data.packets.trap, refIndex)
    end
end

function BaseCell:SaveObjectsScaled(pid)

    tes3mp.ReadLastEvent()
    tes3mp.LogMessage(1, "Saving ObjectScale from " .. myMod.GetChatName(pid) .. " about " .. self.description)

    for i = 0, tes3mp.GetObjectChangesSize() - 1 do

        local refIndex = tes3mp.GetObjectRefNumIndex(i) .. "-" .. tes3mp.GetObjectMpNum(i)
        local refId = tes3mp.GetObjectRefId(i)
        local scale = tes3mp.GetObjectScale(i)

        self:InitializeObjectData(refIndex, refId)
        self.data.objectData[refIndex].scale = scale

        tes3mp.LogAppend(1, "- " .. refIndex .. ", refId: " .. refId .. ", scale: " .. scale)

        tableHelper.insertValueIfMissing(self.data.packets.scale, refIndex)
    end
end

function BaseCell:SaveObjectStates(pid)

    if self.data.packets.state == nil then
        self.data.packets.state = {}
    end

    tes3mp.ReadLastEvent()
    tes3mp.LogMessage(1, "Saving ObjectState from " .. myMod.GetChatName(pid) .. " about " .. self.description)

    for i = 0, tes3mp.GetObjectChangesSize() - 1 do

        local refIndex = tes3mp.GetObjectRefNumIndex(i) .. "-" .. tes3mp.GetObjectMpNum(i)
        local refId = tes3mp.GetObjectRefId(i)
        local state = tes3mp.GetObjectState(i)

        self:InitializeObjectData(refIndex, refId)
        self.data.objectData[refIndex].state = state

        tes3mp.LogAppend(1, "- " .. refIndex .. ", refId: " .. refId .. ", state: " .. tostring(state))

        tableHelper.insertValueIfMissing(self.data.packets.state, refIndex)
    end
end

function BaseCell:SaveDoorStates(pid)

    tes3mp.ReadLastEvent()

    for i = 0, tes3mp.GetObjectChangesSize() - 1 do

        local refIndex = tes3mp.GetObjectRefNumIndex(i) .. "-" .. tes3mp.GetObjectMpNum(i)
        local refId = tes3mp.GetObjectRefId(i)
        local doorState = tes3mp.GetObjectDoorState(i)

        self:InitializeObjectData(refIndex, refId)
        self.data.objectData[refIndex].doorState = doorState

        tableHelper.insertValueIfMissing(self.data.packets.doorState, refIndex)
    end
end

function BaseCell:SaveContainers(pid)

    tes3mp.ReadLastEvent()
    tes3mp.LogMessage(1, "Saving Container from " .. myMod.GetChatName(pid) .. " about " .. self.description)

    local action = tes3mp.GetEventAction()

    for objectIndex = 0, tes3mp.GetObjectChangesSize() - 1 do

        local refIndex = tes3mp.GetObjectRefNumIndex(objectIndex) .. "-" .. tes3mp.GetObjectMpNum(objectIndex)
        local refId = tes3mp.GetObjectRefId(objectIndex)

        self:InitializeObjectData(refIndex, refId)

        tes3mp.LogAppend(1, "- " .. refIndex .. ", refId: " .. refId)

        tableHelper.insertValueIfMissing(self.data.packets.container, refIndex)

        local inventory = self.data.objectData[refIndex].inventory

        -- If this object's inventory is nil, or if the action is SET,
        -- change the inventory to an empty table
        if inventory == nil or action == actionTypes.container.SET then
            inventory = {}
        end

        for itemIndex = 0, tes3mp.GetContainerChangesSize(objectIndex) - 1 do

            local itemRefId = tes3mp.GetContainerItemRefId(objectIndex, itemIndex)
            local itemCount = tes3mp.GetContainerItemCount(objectIndex, itemIndex)
            local itemCharge = tes3mp.GetContainerItemCharge(objectIndex, itemIndex)

            -- Check if the object's stored inventory contains this item already
            if inventoryHelper.containsItem(inventory, itemRefId, itemCharge) then
                local foundIndex = inventoryHelper.getItemIndex(inventory, itemRefId, itemCharge)
                local item = inventory[foundIndex]

                if action == actionTypes.container.ADD then
                    item.count = item.count + itemCount
                elseif action == actionTypes.container.REMOVE then
                    local newCount = item.count - tes3mp.GetContainerItemActionCount(objectIndex, itemIndex)

                    -- The item will still exist in the container with a lower count
                    if newCount > 0 then
                        item.count = newCount
                    -- The item is to be completely removed
                    elseif newCount == 0 then
                        inventory[foundIndex] = nil
                    else
                        tes3mp.LogMessage(2, "Attempt to remove more than possible from item")
                    end
                end
            else
                if action == actionTypes.container.REMOVE then
                    tes3mp.LogMessage(2, "Attempt to remove non-existent item")
                else
                    local item = {
                        refId = itemRefId,
                        count = itemCount,
                        charge = itemCharge
                    }

                    table.insert(inventory, item)
                end
            end
        end

        tableHelper.cleanNils(inventory)
        self.data.objectData[refIndex].inventory = inventory
    end

    self:Save()

    if action == actionTypes.container.SET then
        self.isRequestingContainers = false
    end
end

function BaseCell:SaveActorList(pid)

    tes3mp.ReadLastActorList()
    tes3mp.LogMessage(1, "Saving ActorList from " .. myMod.GetChatName(pid) .. " about " .. self.description)

    for actorIndex = 0, tes3mp.GetActorListSize() - 1 do

        local refIndex = tes3mp.GetActorRefNumIndex(actorIndex) .. "-" .. tes3mp.GetActorMpNum(actorIndex)
        local refId = tes3mp.GetActorRefId(actorIndex)

        self:InitializeObjectData(refIndex, refId)
        tes3mp.LogAppend(1, "- " .. refIndex .. ", refId: " .. refId)

        tableHelper.insertValueIfMissing(self.data.packets.actorList, refIndex)
    end

    self:Save()

    self.isRequestingActorList = false
end

function BaseCell:SaveActorPositions()

    tes3mp.ReadCellActorList(self.description)
    local actorListSize = tes3mp.GetActorListSize()

    if actorListSize == 0 then
        return
    end

    for i = 0, actorListSize - 1 do

        local refIndex = tes3mp.GetActorRefNumIndex(i) .. "-" .. tes3mp.GetActorMpNum(i)

        if tes3mp.DoesActorHavePosition(i) == true and self:ContainsObject(refIndex) then

            self.data.objectData[refIndex].location = {
                posX = tes3mp.GetActorPosX(i),
                posY = tes3mp.GetActorPosY(i),
                posZ = tes3mp.GetActorPosZ(i),
                rotX = tes3mp.GetActorRotX(i),
                rotY = tes3mp.GetActorRotY(i),
                rotZ = tes3mp.GetActorRotZ(i)
            }

            tableHelper.insertValueIfMissing(self.data.packets.position, refIndex)
        end
    end
end

function BaseCell:SaveActorStatsDynamic()

    tes3mp.ReadCellActorList(self.description)
    local actorListSize = tes3mp.GetActorListSize()

    if actorListSize == 0 then
        return
    end

    for i = 0, actorListSize - 1 do

        local refIndex = tes3mp.GetActorRefNumIndex(i) .. "-" .. tes3mp.GetActorMpNum(i)

        if tes3mp.DoesActorHaveStatsDynamic(i) == true and self:ContainsObject(refIndex) then

            self.data.objectData[refIndex].stats = {
                healthBase = tes3mp.GetActorHealthBase(i),
                healthCurrent = tes3mp.GetActorHealthCurrent(i),
                healthModified = tes3mp.GetActorHealthModified(i),
                magickaBase = tes3mp.GetActorMagickaBase(i),
                magickaCurrent = tes3mp.GetActorMagickaCurrent(i),
                magickaModified = tes3mp.GetActorMagickaModified(i),
                fatigueBase = tes3mp.GetActorFatigueBase(i),
                fatigueCurrent = tes3mp.GetActorFatigueCurrent(i),
                fatigueModified = tes3mp.GetActorFatigueModified(i)
            }

            tableHelper.insertValueIfMissing(self.data.packets.statsDynamic, refIndex)
        end
    end
end

function BaseCell:SaveActorEquipment(pid)

    tes3mp.ReadLastActorList()
    tes3mp.LogMessage(1, "Saving ActorEquipment from " .. myMod.GetChatName(pid) .. " about " .. self.description)

    local actorListSize = tes3mp.GetActorListSize()

    if actorListSize == 0 then
        return
    end

    for actorIndex = 0, actorListSize - 1 do

        local refIndex = tes3mp.GetActorRefNumIndex(actorIndex) .. "-" .. tes3mp.GetActorMpNum(actorIndex)
        tes3mp.LogAppend(1, "- " .. refIndex)

        if self:ContainsObject(refIndex) then
            self.data.objectData[refIndex].equipment = {}

            for itemIndex = 0, tes3mp.GetEquipmentSize() - 1 do

                local itemRefId = tes3mp.GetActorEquipmentItemRefId(actorIndex, itemIndex)

                if itemRefId ~= "" then

                    self.data.objectData[refIndex].equipment[itemIndex] = {
                        refId = itemRefId,
                        count = tes3mp.GetActorEquipmentItemCount(actorIndex, itemIndex),
                        charge = tes3mp.GetActorEquipmentItemCharge(actorIndex, itemIndex)
                    }
                end
            end

            tableHelper.insertValueIfMissing(self.data.packets.equipment, refIndex)
        end
    end

    self:Save()
end

function BaseCell:SaveActorCellChanges(pid)

    local temporaryLoadedCells = {}

    tes3mp.ReadLastActorList()
    tes3mp.LogMessage(1, "Saving ActorCellChange from " .. myMod.GetChatName(pid) .. " about " .. self.description)

    for actorIndex = 0, tes3mp.GetActorListSize() - 1 do

        local refIndex = tes3mp.GetActorRefNumIndex(actorIndex) .. "-" .. tes3mp.GetActorMpNum(actorIndex)
        local newCellDescription = tes3mp.GetActorCell(actorIndex)

        tes3mp.LogAppend(1, "- " .. refIndex .. " moved to " .. newCellDescription)

        -- If the new cell is not loaded, load it temporarily
        if LoadedCells[newCellDescription] == nil then
            myMod.LoadCell(newCellDescription)
            table.insert(temporaryLoadedCells, newCellDescription)
        end

        local newCell = LoadedCells[newCellDescription]

        -- Only proceed if this Actor is actually supposed to exist in this cell
        if self.data.objectData[refIndex] ~= nil then

            -- Was this actor spawned in the old cell, instead of being a pre-existing actor?
            -- If so, delete it entirely from the old cell and make it get spawned in the new cell
            if tableHelper.containsValue(self.data.packets.spawn, refIndex) == true then
                tes3mp.LogAppend(1, "-- As a server-only object, it was moved entirely")
                self:MoveObjectData(refIndex, newCell)

            -- Was this actor moved to the old cell from another cell?
            elseif tableHelper.containsValue(self.data.packets.cellChangeFrom, refIndex) == true then

                local originalCellDescription = self.data.objectData[refIndex].cellChangeFrom

                -- Is the new cell actually this actor's original cell?
                -- If so, move its data back and remove all of its cell change data
                if originalCellDescription == newCellDescription then
                    tes3mp.LogAppend(1, "-- It is now back in its original cell " .. originalCellDescription)
                    self:MoveObjectData(refIndex, newCell)

                    tableHelper.removeValue(newCell.data.packets.cellChangeTo, refIndex)
                    tableHelper.removeValue(newCell.data.packets.cellChangeFrom, refIndex)

                    newCell.data.objectData[refIndex].cellChangeTo = nil
                    newCell.data.objectData[refIndex].cellChangeFrom = nil
                -- Otherwise, move its data to the new cell, delete it from the old cell, and update its
                -- information in its original cell
                else
                    self:MoveObjectData(refIndex, newCell)

                    -- If the original cell is not loaded, load it temporarily
                    if LoadedCells[originalCellDescription] == nil then
                        myMod.LoadCell(originalCellDescription)
                        table.insert(temporaryLoadedCells, originalCellDescription)
                    end

                    local originalCell = LoadedCells[originalCellDescription]

                    if originalCell.data.objectData[refIndex] ~= nil then
                        tes3mp.LogAppend(1, "-- This is now referenced in its original cell " .. originalCellDescription)
                        originalCell.data.objectData[refIndex].cellChangeTo = newCellDescription
                    else
                        tes3mp.LogAppend(3, "-- It does not exist in its original cell " .. originalCellDescription .. "! Please report this to a developer")
                    end
                end

            -- Otherwise, simply move this actor's data to the new cell and mark it as being moved there
            -- in its old cell, as long as it's not supposed to already be in the new cell
            elseif self.data.objectData[refIndex].cellChangeTo ~= newCellDescription then

                tes3mp.LogAppend(1, "-- This was its first move away from its original cell")

                self:MoveObjectData(refIndex, newCell)

                table.insert(self.data.packets.cellChangeTo, refIndex)

                if self.data.objectData[refIndex] == nil then
                    self.data.objectData[refIndex] = {}
                end

                self.data.objectData[refIndex].cellChangeTo = newCellDescription

                table.insert(newCell.data.packets.cellChangeFrom, refIndex)

                newCell.data.objectData[refIndex].cellChangeFrom = self.description
            end

            if newCell.data.objectData[refIndex] ~= nil then
                newCell.data.objectData[refIndex].location = {
                    posX = tes3mp.GetActorPosX(actorIndex),
                    posY = tes3mp.GetActorPosY(actorIndex),
                    posZ = tes3mp.GetActorPosZ(actorIndex),
                    rotX = tes3mp.GetActorRotX(actorIndex),
                    rotY = tes3mp.GetActorRotY(actorIndex),
                    rotZ = tes3mp.GetActorRotZ(actorIndex)
                }
            end
        else
            tes3mp.LogAppend(3, "-- Invalid or repeated cell change was attempted! Please report this to a developer")
        end
    end

    -- Go through every temporary loaded cell and unload it
    for arrayIndex, newCellDescription in pairs(temporaryLoadedCells) do
        myMod.UnloadCell(newCellDescription)
    end

    self:Save()
end

function BaseCell:SendObjectsDeleted(pid)

    local objectCount = 0

    tes3mp.InitializeEvent(pid)
    tes3mp.SetEventCell(self.description)

    -- Objects deleted
    for arrayIndex, refIndex in pairs(self.data.packets.delete) do

        local splitIndex = refIndex:split("-")
        tes3mp.SetObjectRefNumIndex(splitIndex[1])
        tes3mp.SetObjectMpNum(splitIndex[2])
        tes3mp.SetObjectRefId(self.data.objectData[refIndex].refId)
        tes3mp.AddWorldObject()

        objectCount = objectCount + 1
    end

    if objectCount > 0 then
        tes3mp.SendObjectDelete()
    end
end

function BaseCell:SendObjectsPlaced(pid)

    local objectCount = 0

    tes3mp.InitializeEvent(pid)
    tes3mp.SetEventCell(self.description)

    for arrayIndex, refIndex in pairs(self.data.packets.place) do

        local location = self.data.objectData[refIndex].location

        -- Ensure data integrity before proceeeding
        if tableHelper.getCount(location) == 6 and tableHelper.usesNumericalValues(location) then

            local splitIndex = refIndex:split("-")
            tes3mp.SetObjectRefNumIndex(splitIndex[1])
            tes3mp.SetObjectMpNum(splitIndex[2])
            tes3mp.SetObjectRefId(self.data.objectData[refIndex].refId)

            local count = self.data.objectData[refIndex].count
            local charge = self.data.objectData[refIndex].charge
            local goldValue = self.data.objectData[refIndex].goldValue

            -- Use default count of 1 when the value is missing
            if count == nil then
                count = 1
            end

            -- Use default charge of -1 when the value is missing
            if charge == nil then
                charge = -1
            end

            -- Use default goldValue of 1 when the value is missing
            if goldValue == nil then
                goldValue = 1
            end

            tes3mp.SetObjectCharge(charge)
            tes3mp.SetObjectCount(count)
            tes3mp.SetObjectGoldValue(goldValue)
            tes3mp.SetObjectPosition(location.posX, location.posY, location.posZ)
            tes3mp.SetObjectRotation(location.rotX, location.rotY, location.rotZ)

            tes3mp.AddWorldObject()

            objectCount = objectCount + 1
        else
            self.data.objectData[refIndex] = nil
            tableHelper.removeValue(self.data.packets.place, refIndex)
        end
    end

    if objectCount > 0 then
        tes3mp.SendObjectPlace()
    end
end

function BaseCell:SendObjectsSpawned(pid)

    -- Keep this around for backwards compatibility
    if self.data.packets.spawn == nil then
        self.data.packets.spawn = {}
    end

    local objectCount = 0

    tes3mp.InitializeEvent(pid)
    tes3mp.SetEventCell(self.description)

    for arrayIndex, refIndex in pairs(self.data.packets.spawn) do

        local location = self.data.objectData[refIndex].location

        -- Ensure data integrity before proceeeding
        if tableHelper.getCount(location) == 6 and tableHelper.usesNumericalValues(location) then

            local splitIndex = refIndex:split("-")
            tes3mp.SetObjectRefNumIndex(splitIndex[1])
            tes3mp.SetObjectMpNum(splitIndex[2])
            tes3mp.SetObjectRefId(self.data.objectData[refIndex].refId)

            tes3mp.SetObjectPosition(location.posX, location.posY, location.posZ)
            tes3mp.SetObjectRotation(location.rotX, location.rotY, location.rotZ)

            tes3mp.AddWorldObject()

            objectCount = objectCount + 1
        else
            self.data.objectData[refIndex] = nil
            tableHelper.removeValue(self.data.packets.spawn, refIndex)
        end
    end

    if objectCount > 0 then
        tes3mp.SendObjectSpawn()
    end
end

function BaseCell:SendObjectsLocked(pid)

    local objectCount = 0

    tes3mp.InitializeEvent(pid)
    tes3mp.SetEventCell(self.description)

    for arrayIndex, refIndex in pairs(self.data.packets.lock) do

        local splitIndex = refIndex:split("-")
        tes3mp.SetObjectRefNumIndex(splitIndex[1])
        tes3mp.SetObjectMpNum(splitIndex[2])
        tes3mp.SetObjectRefId(self.data.objectData[refIndex].refId)
        tes3mp.SetObjectLockLevel(self.data.objectData[refIndex].lockLevel)
        tes3mp.AddWorldObject()

        objectCount = objectCount + 1
    end

    if objectCount > 0 then
        tes3mp.SendObjectLock()
    end
end

function BaseCell:SendObjectTrapsTriggered(pid)

    local objectCount = 0

    tes3mp.InitializeEvent(pid)
    tes3mp.SetEventCell(self.description)

    for arrayIndex, refIndex in pairs(self.data.packets.trap) do

        local splitIndex = refIndex:split("-")
        tes3mp.SetObjectRefNumIndex(splitIndex[1])
        tes3mp.SetObjectMpNum(splitIndex[2])
        tes3mp.SetObjectRefId(self.data.objectData[refIndex].refId)
        tes3mp.SetObjectDisarmState(true)
        tes3mp.AddWorldObject()

        objectCount = objectCount + 1
    end

    if objectCount > 0 then
        tes3mp.SendObjectTrap()
    end
end

function BaseCell:SendObjectsScaled(pid)

    local objectCount = 0

    tes3mp.InitializeEvent(pid)
    tes3mp.SetEventCell(self.description)

    for arrayIndex, refIndex in pairs(self.data.packets.scale) do

        local splitIndex = refIndex:split("-")
        local refId = self.data.objectData[refIndex].refId
        local scale = self.data.objectData[refIndex].scale

        if refId ~= nil and scale ~= nil then

            tes3mp.SetObjectRefNumIndex(splitIndex[1])
            tes3mp.SetObjectMpNum(splitIndex[2])
            tes3mp.SetObjectRefId(refId)
            tes3mp.SetObjectScale(scale)
            tes3mp.AddWorldObject()

            objectCount = objectCount + 1
        end
    end

    if objectCount > 0 then
        tes3mp.SendObjectScale()
    end
end

function BaseCell:SendObjectStates(pid)

    if self.data.packets.state == nil then
        self.data.packets.state = {}
    end

    local objectCount = 0

    tes3mp.InitializeEvent(pid)
    tes3mp.SetEventCell(self.description)

    for arrayIndex, refIndex in pairs(self.data.packets.state) do

        local splitIndex = refIndex:split("-")
        local refId = self.data.objectData[refIndex].refId
        local state = self.data.objectData[refIndex].state

        if refId ~= nil and state ~= nil then

            tes3mp.SetObjectRefNumIndex(splitIndex[1])
            tes3mp.SetObjectMpNum(splitIndex[2])
            tes3mp.SetObjectRefId(refId)
            tes3mp.SetObjectState(state)
            tes3mp.AddWorldObject()

            objectCount = objectCount + 1
        end
    end

    if objectCount > 0 then
        tes3mp.SendObjectState()
    end
end

function BaseCell:SendDoorStates(pid)

    local objectCount = 0

    tes3mp.InitializeEvent(pid)
    tes3mp.SetEventCell(self.description)

    for arrayIndex, refIndex in pairs(self.data.packets.doorState) do

        local splitIndex = refIndex:split("-")
        tes3mp.SetObjectRefNumIndex(splitIndex[1])
        tes3mp.SetObjectMpNum(splitIndex[2])
        tes3mp.SetObjectRefId(self.data.objectData[refIndex].refId)
        tes3mp.SetObjectDoorState(self.data.objectData[refIndex].doorState)
        tes3mp.AddWorldObject()

        objectCount = objectCount + 1
    end

    if objectCount > 0 then
        tes3mp.SendDoorState()
    end
end

function BaseCell:SendContainers(pid)

    local objectCount = 0

    tes3mp.InitializeEvent(pid)
    tes3mp.SetEventCell(self.description)

    for arrayIndex, refIndex in pairs(self.data.packets.container) do

        local splitIndex = refIndex:split("-")
        tes3mp.SetObjectRefNumIndex(splitIndex[1])
        tes3mp.SetObjectMpNum(splitIndex[2])

        if self:ContainsObject(refIndex) and self.data.objectData[refIndex].inventory ~= nil then
            tes3mp.SetObjectRefId(self.data.objectData[refIndex].refId)

            for itemIndex, item in pairs(self.data.objectData[refIndex].inventory) do
                tes3mp.SetContainerItemRefId(item.refId)
                tes3mp.SetContainerItemCount(item.count)
                tes3mp.SetContainerItemCharge(item.charge)

                tes3mp.AddContainerItem()
            end

            tes3mp.AddWorldObject()

            objectCount = objectCount + 1
        else
            tes3mp.LogAppend(3, "- Had container packet recorded for " .. refIndex .. ", but no matching object data! Please report this to a developer")
            tableHelper.removeValue(self.data.packets.container, refIndex)
        end
    end

    if objectCount > 0 then

        -- Set the action to SET
        tes3mp.SetEventAction(0)

        tes3mp.SendContainer()
    end
end

function BaseCell:SendActorList(pid)

    local actorCount = 0

    tes3mp.InitializeActorList(pid)
    tes3mp.SetActorListCell(self.description)

    for arrayIndex, refIndex in pairs(self.data.packets.actorList) do

        local splitIndex = refIndex:split("-")
        tes3mp.SetActorRefNumIndex(splitIndex[1])
        tes3mp.SetActorMpNum(splitIndex[2])

        if self:ContainsObject(refIndex) then
            tes3mp.SetActorRefId(self.data.objectData[refIndex].refId)

            actorCount = actorCount + 1
        else
            tes3mp.LogAppend(3, "- Had actorList packet recorded for " .. refIndex .. ", but no matching object data! Please report this to a developer")
            tableHelper.removeValue(self.data.packets.actorList, refIndex)
        end
    end

    if actorCount > 0 then

        -- Set the action to SET
        tes3mp.SetActorListAction(0)

        tes3mp.SendActorList()
    end
end

function BaseCell:SendActorAuthority(pid)

    tes3mp.InitializeActorList(pid)
    tes3mp.SetActorListCell(self.description)

    tes3mp.SendActorAuthority()
end

function BaseCell:SendActorPositions(pid)

    local actorCount = 0

    tes3mp.InitializeActorList(pid)
    tes3mp.SetActorListCell(self.description)

    for arrayIndex, refIndex in pairs(self.data.packets.position) do

        local splitIndex = refIndex:split("-")
        tes3mp.SetActorRefNumIndex(splitIndex[1])
        tes3mp.SetActorMpNum(splitIndex[2])

        if self:ContainsObject(refIndex) then
            local location = self.data.objectData[refIndex].location

            -- Ensure data integrity before proceeeding
            if tableHelper.getCount(location) == 6 and tableHelper.usesNumericalValues(location) then

                tes3mp.SetActorPosition(location.posX, location.posY, location.posZ)
                tes3mp.SetActorRotation(location.rotX, location.rotY, location.rotZ)

                tes3mp.AddActor()

                actorCount = actorCount + 1
            end
        else
            tes3mp.LogAppend(3, "- Had position packet recorded for " .. refIndex .. ", but no matching object data! Please report this to a developer")
            tableHelper.removeValue(self.data.packets.position, refIndex)
        end
    end

    if actorCount > 0 then
        tes3mp.SendActorPosition()
    end
end

function BaseCell:SendActorStatsDynamic(pid)

    local actorCount = 0

    tes3mp.InitializeActorList(pid)
    tes3mp.SetActorListCell(self.description)

    for arrayIndex, refIndex in pairs(self.data.packets.statsDynamic) do

        local splitIndex = refIndex:split("-")
        tes3mp.SetActorRefNumIndex(splitIndex[1])
        tes3mp.SetActorMpNum(splitIndex[2])

        if self:ContainsObject(refIndex) and self.data.objectData[refIndex].stats ~= nil then
            local stats = self.data.objectData[refIndex].stats

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
            tes3mp.LogAppend(3, "- Had statsDynamic packet recorded for " .. refIndex .. ", but no matching object data! Please report this to a developer")
            tableHelper.removeValue(self.data.packets.statsDynamic, refIndex)
        end
    end

    if actorCount > 0 then
        tes3mp.SendActorStatsDynamic()
    end
end

function BaseCell:SendActorEquipment(pid)

    local actorCount = 0

    tes3mp.InitializeActorList(pid)
    tes3mp.SetActorListCell(self.description)

    for arrayIndex, refIndex in pairs(self.data.packets.equipment) do

        local splitIndex = refIndex:split("-")
        tes3mp.SetActorRefNumIndex(splitIndex[1])
        tes3mp.SetActorMpNum(splitIndex[2])

        if self:ContainsObject(refIndex) and self.data.objectData[refIndex].equipment ~= nil then
            local equipment = self.data.objectData[refIndex].equipment

            for itemIndex = 0, tes3mp.GetEquipmentSize() - 1 do

                local currentItem = equipment[itemIndex]

                if currentItem ~= nil then
                    tes3mp.EquipActorItem(itemIndex, currentItem.refId, currentItem.count, currentItem.charge)
                else
                    tes3mp.UnequipActorItem(itemIndex)
                end
            end

            tes3mp.AddActor()

            actorCount = actorCount + 1
        else
            tes3mp.LogAppend(3, "- Had equipment packet recorded for " .. refIndex .. ", but no matching object data! Please report this to a developer")
            tableHelper.removeValue(self.data.packets.equipment, refIndex)
        end
    end

    if actorCount > 0 then
        tes3mp.SendActorEquipment()
    end
end

function BaseCell:SendActorCellChanges(pid)

    local temporaryLoadedCells = {}
    local actorCount = 0

    -- Move actors originally from this cell to other cells
    tes3mp.InitializeActorList(pid)
    tes3mp.SetActorListCell(self.description)

    for arrayIndex, refIndex in pairs(self.data.packets.cellChangeTo) do

        local splitIndex = refIndex:split("-")
        tes3mp.SetActorRefNumIndex(splitIndex[1])
        tes3mp.SetActorMpNum(splitIndex[2])

        local newCellDescription = self.data.objectData[refIndex].cellChangeTo

        if newCellDescription ~= nil then
            tes3mp.SetActorCell(newCellDescription)

            -- If the new cell is not loaded, load it temporarily
            if LoadedCells[newCellDescription] == nil then
                myMod.LoadCell(newCellDescription)
                table.insert(temporaryLoadedCells, newCellDescription)
            end

            if LoadedCells[newCellDescription].data.objectData[refIndex] ~= nil then

                local location = LoadedCells[newCellDescription].data.objectData[refIndex].location

                -- Ensure data integrity before proceeeding
                if tableHelper.getCount(location) == 6 and tableHelper.usesNumericalValues(location) then

                    tes3mp.SetActorPosition(location.posX, location.posY, location.posZ)
                    tes3mp.SetActorRotation(location.rotX, location.rotY, location.rotZ)

                    tes3mp.AddActor()

                    actorCount = actorCount + 1
                end
            else
                tes3mp.LogAppend(3, "- Tried to move " .. refIndex .. " from " .. self.description .. " to  " .. newCellDescription .. " with no position data! Please report this to a developer")
                self.data.objectData[refIndex] = nil
                tableHelper.removeValue(self.data.packets.cellChangeTo, refIndex)
            end
        else
            tes3mp.LogAppend(3, "- Had cellChangeTo packet recorded for " .. refIndex .. ", but no matching cell description! Please report this to a developer")
            tableHelper.removeValue(self.data.packets.cellChangeTo, refIndex)
        end
    end

    if actorCount > 0 then
        tes3mp.SendActorCellChange()
    end

    -- Go through every temporary loaded cell and unload it
    for arrayIndex, newCellDescription in pairs(temporaryLoadedCells) do
        myMod.UnloadCell(newCellDescription)
    end

    -- Make a table of every cell that has sent actors to this cell
    local cellChangesFrom = {}

    for arrayIndex, refIndex in pairs(self.data.packets.cellChangeFrom) do

        if self.data.objectData[refIndex] ~= nil and self.data.objectData[refIndex].cellChangeFrom ~= nil then
            local originalCellDescription = self.data.objectData[refIndex].cellChangeFrom

            if cellChangesFrom[originalCellDescription] == nil then
                cellChangesFrom[originalCellDescription] = {}
            end

            table.insert(cellChangesFrom[originalCellDescription], refIndex)
        else
            tes3mp.LogAppend(3, "- Had cellChangeFrom packet recorded for " .. refIndex .. ", but no matching cell description! Please report this to a developer")
            tableHelper.removeValue(self.data.packets.cellChangeFrom, refIndex)
        end
    end

    local actorCount = 0

    -- Send a cell change packet for every cell that has sent actors to this cell
    for originalCellDescription, actorArray in pairs(cellChangesFrom) do

        tes3mp.InitializeActorList(pid)
        tes3mp.SetActorListCell(originalCellDescription)

        for arrayIndex, refIndex in pairs(actorArray) do

            local splitIndex = refIndex:split("-")
            tes3mp.SetActorRefNumIndex(splitIndex[1])
            tes3mp.SetActorMpNum(splitIndex[2])

            tes3mp.SetActorCell(self.description)

            local location = self.data.objectData[refIndex].location

            -- Ensure data integrity before proceeeding
            if tableHelper.getCount(location) == 6 and tableHelper.usesNumericalValues(location) then

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

function BaseCell:RequestContainers(pid)

    self.isRequestingContainers = true
    self.containerRequestPid = pid

    tes3mp.InitializeEvent(pid)
    tes3mp.SetEventCell(self.description)

    -- Set the action to REQUEST
    tes3mp.SetEventAction(3)

    tes3mp.SendContainer()
end

function BaseCell:RequestActorList(pid)

    self.isRequestingActorList = true
    self.actorListRequestPid = pid

    tes3mp.InitializeActorList(pid)
    tes3mp.SetActorListCell(self.description)

    -- Set the action to REQUEST
    tes3mp.SetActorListAction(3)

    tes3mp.SendActorList()
end

function BaseCell:SendInitialCellData(pid)

    self:EnsurePacketValidity()

    tes3mp.LogMessage(1, "Sending data of cell " .. self.description .. " to pid " .. pid)

    self:SendObjectsDeleted(pid)
    self:SendObjectsPlaced(pid)
    self:SendObjectsSpawned(pid)
    self:SendObjectsLocked(pid)
    self:SendObjectTrapsTriggered(pid)
    self:SendObjectsScaled(pid)
    self:SendObjectStates(pid)
    self:SendDoorStates(pid)

    if self:HasContainerData() == true then
        tes3mp.LogAppend(1, "- Had container data")
        self:SendContainers(pid)
    elseif self.isRequestingContainers == false then
        tes3mp.LogAppend(1, "- Requesting containers")
        self:RequestContainers(pid)
    end

    if self:HasActorData() == true then
        tes3mp.LogAppend(1, "- Had actor data")
        self:SendActorCellChanges(pid)
        self:SendActorEquipment(pid)
    elseif self.isRequestingActorList == false then
        tes3mp.LogAppend(1, "- Requesting actor list")
        self:RequestActorList(pid)
    end
end

function BaseCell:SendMomentaryCellData(pid)

    if self:HasActorData() == true then
        self:SendActorPositions(pid)
        self:SendActorStatsDynamic(pid)
    end
end

return BaseCell
