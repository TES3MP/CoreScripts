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
            scale = {},
            lock = {},
            unlock = {},
            doorState = {},
            container = {},
            actorList = {},
            position = {},
            statsDynamic = {},
            cellChangeTo = {},
            cellChangeFrom = {}
        }
    };

    self.visitors = {}
    self.authority = nil
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
            self:SendCellData(pid)
        end
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

    self:DeleteObjectData(refIndex)
end

function BaseCell:SaveLastVisit(playerName)
    self.data.lastVisit[playerName] = os.time()
end

function BaseCell:SaveObjectsDeleted()

    tes3mp.ReadLastEvent()

    for i = 0, tes3mp.GetObjectChangesSize() - 1 do

        local refIndex = tes3mp.GetObjectRefNumIndex(i) .. "-" .. tes3mp.GetObjectMpNum(i)

        -- Check whether this is a placed object
        local wasPlaced = tableHelper.containsValue(self.data.packets.place, refIndex)

        -- Delete all packets for the object
        for packetIndex, packetType in pairs(self.data.packets) do
            tableHelper.removeValue(self.data.packets[packetIndex], refIndex)
        end

        -- Delete all object data
        self:DeleteObjectData(refIndex)

        -- If wasPlaced is false, this is a pre-existing object from the game's data files
        -- that should be tracked and deleted every time this cell is opened
        if wasPlaced == false then
            table.insert(self.data.packets.delete, refIndex)
            self:InitializeObjectData(refIndex, tes3mp.GetObjectRefId(i))
        end
    end
end

function BaseCell:SaveObjectsPlaced()

    tes3mp.ReadLastEvent()

    for i = 0, tes3mp.GetObjectChangesSize() - 1 do

        local refIndex = tes3mp.GetObjectRefNumIndex(i) .. "-" .. tes3mp.GetObjectMpNum(i)
        
        self:InitializeObjectData(refIndex, tes3mp.GetObjectRefId(i))

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

        self.data.objectData[refIndex].location = {
            posX = tes3mp.GetObjectPosX(i),
            posY = tes3mp.GetObjectPosY(i),
            posZ = tes3mp.GetObjectPosZ(i),
            rotX = tes3mp.GetObjectRotX(i),
            rotY = tes3mp.GetObjectRotY(i),
            rotZ = tes3mp.GetObjectRotZ(i)
        }

        table.insert(self.data.packets.place, refIndex)
    end
end

function BaseCell:SaveObjectsScaled()

    tes3mp.ReadLastEvent()

    for i = 0, tes3mp.GetObjectChangesSize() - 1 do

        local refIndex = tes3mp.GetObjectRefNumIndex(i) .. "-" .. tes3mp.GetObjectMpNum(i)

        self:InitializeObjectData(refIndex, tes3mp.GetObjectRefId(i))
        self.data.objectData[refIndex].scale = tes3mp.GetObjectScale(i)
        
        tableHelper.insertValueIfMissing(self.data.packets.scale, refIndex)
    end
end

function BaseCell:SaveObjectsLocked()

    tes3mp.ReadLastEvent()

    for i = 0, tes3mp.GetObjectChangesSize() - 1 do

        local refIndex = tes3mp.GetObjectRefNumIndex(i) .. "-" .. tes3mp.GetObjectMpNum(i)

        self:InitializeObjectData(refIndex, tes3mp.GetObjectRefId(i))
        self.data.objectData[refIndex].lockLevel = tes3mp.GetObjectLockLevel(i)

        tableHelper.insertValueIfMissing(self.data.packets.lock, refIndex)

        tableHelper.removeValue(self.data.packets.unlock, refIndex)
    end
end

function BaseCell:SaveObjectsUnlocked()

    tes3mp.ReadLastEvent()

    for i = 0, tes3mp.GetObjectChangesSize() - 1 do

        local refIndex = tes3mp.GetObjectRefNumIndex(i) .. "-" .. tes3mp.GetObjectMpNum(i)

        self:InitializeObjectData(refIndex, tes3mp.GetObjectRefId(i))
        self.data.objectData[refIndex].lockLevel = nil

        tableHelper.insertValueIfMissing(self.data.packets.unlock, refIndex)

        tableHelper.removeValue(self.data.packets.lock, refIndex)
    end
end

function BaseCell:SaveDoorStates()

    tes3mp.ReadLastEvent()

    for i = 0, tes3mp.GetObjectChangesSize() - 1 do

        local refIndex = tes3mp.GetObjectRefNumIndex(i) .. "-" .. tes3mp.GetObjectMpNum(i)

        self:InitializeObjectData(refIndex, tes3mp.GetObjectRefId(i))
        self.data.objectData[refIndex].doorState = tes3mp.GetObjectDoorState(i)

        tableHelper.insertValueIfMissing(self.data.packets.doorState, refIndex)
    end
end

function BaseCell:SaveContainers()

    tes3mp.ReadLastEvent()

    local actionTypes = { SET = 0, ADD = 1, REMOVE = 2}
    local action = tes3mp.GetEventAction()

    for objectIndex = 0, tes3mp.GetObjectChangesSize() - 1 do

        local refIndex = tes3mp.GetObjectRefNumIndex(objectIndex) .. "-" .. tes3mp.GetObjectMpNum(objectIndex)

        self:InitializeObjectData(refIndex, tes3mp.GetObjectRefId(objectIndex))

        tableHelper.insertValueIfMissing(self.data.packets.container, refIndex)

        local inventory = self.data.objectData[refIndex].inventory

        -- If this object's inventory is nil, or if the action is SET,
        -- change the inventory to an empty table
        if inventory == nil or action == actionTypes.SET then
            inventory = {}
        end

        for itemIndex = 0, tes3mp.GetContainerChangesSize(objectIndex) - 1 do

            local itemRefId = tes3mp.GetContainerItemRefId(objectIndex, itemIndex)
            local itemCount = tes3mp.GetContainerItemCount(objectIndex, itemIndex)
            local itemCharge = tes3mp.GetContainerItemCharge(objectIndex, itemIndex)

            -- Check if the object's stored inventory contains this item already
            if inventoryHelper.containsItem(inventory, itemRefId, itemCharge) then
                local item = inventoryHelper.getItem(inventory, itemRefId, itemCharge)

                if action == actionTypes.ADD then
                    item.count = item.count + itemCount
                elseif action == actionTypes.REMOVE then
                    local newCount = item.count - tes3mp.GetContainerItemActionCount(objectIndex, itemIndex)

                    -- The item will still exist in the container with a lower count
                    if newCount > 0 then
                        item.count = newCount
                    -- The item is to be completely removed
                    elseif newCount == 0 then
                        item = nil
                    else
                        tes3mp.LogMessage(2, "Attempt to remove more than possible from item")
                    end
                end
            else
                if action == actionTypes.REMOVE then
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

        self.data.objectData[refIndex].inventory = inventory
    end

    self:Save()
end

function BaseCell:SaveActorList()

    tes3mp.ReadLastActorList()

    local actionTypes = { SET = 0, ADD = 1, REMOVE = 2}
    local action = tes3mp.GetActorListAction()

    for actorIndex = 0, tes3mp.GetActorListSize() - 1 do

        local refIndex = tes3mp.GetActorRefNumIndex(actorIndex) .. "-" .. tes3mp.GetActorMpNum(actorIndex)

        self:InitializeObjectData(refIndex, tes3mp.GetActorRefId(actorIndex))

        tableHelper.insertValueIfMissing(self.data.packets.actorList, refIndex)
    end

    self:Save()
end

function BaseCell:SaveActorPositions()

    tes3mp.ReadCellActorList(self.description)
    local actorListSize = tes3mp.GetActorListSize()

    if actorListSize == 0 then
        return
    end

    for i = 0, actorListSize - 1 do

        local refIndex = tes3mp.GetActorRefNumIndex(i) .. "-" .. tes3mp.GetActorMpNum(i)

        if tes3mp.DoesActorHavePosition(i) == true and self.data.objectData[refIndex] ~= nil then

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

        if tes3mp.DoesActorHaveStatsDynamic(i) == true and self.data.objectData[refIndex] ~= nil then

            self.data.objectData[refIndex].stats = {
                healthBase = tes3mp.GetActorHealthBase(i),
                healthCurrent = tes3mp.GetActorHealthCurrent(i),
                magickaBase = tes3mp.GetActorMagickaBase(i),
                magickaCurrent = tes3mp.GetActorMagickaCurrent(i),
                fatigueBase = tes3mp.GetActorFatigueBase(i),
                fatigueCurrent = tes3mp.GetActorFatigueCurrent(i)
            }

            tableHelper.insertValueIfMissing(self.data.packets.statsDynamic, refIndex)
        end
    end
end

function BaseCell:SaveActorCellChanges()

    tes3mp.ReadLastActorList()

    local temporaryLoadedCells = {}

    for actorIndex = 0, tes3mp.GetActorListSize() - 1 do

        local refId = tes3mp.GetActorRefId(actorIndex)
        local refIndex = tes3mp.GetActorRefNumIndex(actorIndex) .. "-" .. tes3mp.GetActorMpNum(actorIndex)
        local newCellDescription = tes3mp.GetActorCell(actorIndex)

        tes3mp.LogMessage(1, "Actor " .. refId .. ", " .. refIndex .. " changed cell from " .. self.description .. " to " .. newCellDescription)

        -- If the new cell is not loaded, load it temporarily
        if LoadedCells[newCellDescription] == nil then
            myMod.LoadCell(newCellDescription)
            table.insert(temporaryLoadedCells, newCellDescription)
        end

        local newCell = LoadedCells[newCellDescription]

        -- Was this actor placed in the old cell, instead of being a pre-existing actor?
        -- If so, delete it entirely from the old cell and make it get placed in the new cell
        if tableHelper.containsValue(self.data.packets.place, refIndex) == true then
            tes3mp.LogAppend(1, "- As a server-only object, it was moved entirely")
            self:MoveObjectData(refIndex, newCell)

        -- Was this actor moved to the old cell from another cell?
        elseif tableHelper.containsValue(self.data.packets.cellChangeFrom, refIndex) == true then

            local originalCellDescription = self.data.objectData[refIndex].cellChangeFrom

            -- Is the new cell actually this actor's original cell?
            -- If so, move its data back and remove all of its cell change data
            if originalCellDescription == newCellDescription then
                tes3mp.LogAppend(1, "- It is now back in its original cell " .. originalCellDescription)
                self:MoveObjectData(refIndex, newCell)

                tableHelper.removeValue(newCell.data.packets.cellChangeTo, refIndex)
                tableHelper.removeValue(newCell.data.packets.cellChangeFrom, refIndex)

                newCell.data.objectData[refIndex].cellChangeTo = nil
                newCell.data.objectData[refIndex].cellChangeFrom = nil
            -- Otherwise, move its data to the new cell, delete it from the old cell, and update its
            -- information in its original cell
            else
                tes3mp.LogAppend(1, "- This is now referenced in its original cell " .. originalCellDescription)
                self:MoveObjectData(refIndex, newCell)

                -- If the original cell is not loaded, load it temporarily
                if LoadedCells[originalCellDescription] == nil then
                    myMod.LoadCell(originalCellDescription)
                    table.insert(temporaryLoadedCells, originalCellDescription)
                end

                local originalCell = LoadedCells[originalCellDescription]
                originalCell.data.objectData[refIndex].cellChangeTo = newCellDescription
            end

        -- Otherwise, simply move this actor's data to the new cell and mark it as being moved there
        -- in its old cell, as long as it's not supposed to already be in the new cell
        elseif self.data.objectData[refIndex].cellChangeTo ~= newCellDescription then

            tes3mp.LogAppend(1, "- This was its first move away from its original cell")

            self:MoveObjectData(refIndex, newCell)

            table.insert(self.data.packets.cellChangeTo, refIndex)
            self:InitializeObjectData(refIndex, refId)
            self.data.objectData[refIndex].cellChangeTo = newCellDescription

            table.insert(newCell.data.packets.cellChangeFrom, refIndex)

            newCell.data.objectData[refIndex].cellChangeFrom = self.description                
        end

        newCell.data.objectData[refIndex].location = {
            posX = tes3mp.GetActorPosX(actorIndex),
            posY = tes3mp.GetActorPosY(actorIndex),
            posZ = tes3mp.GetActorPosZ(actorIndex),
            rotX = tes3mp.GetActorRotX(actorIndex),
            rotY = tes3mp.GetActorRotY(actorIndex),
            rotZ = tes3mp.GetActorRotZ(actorIndex)
        }
    end

    -- Go through every temporary loaded cell and unload it
    for arrayIndex, newCellDescription in pairs(temporaryLoadedCells) do
        myMod.UnloadCell(newCellDescription)
    end

    self:Save()
end

function BaseCell:SendObjectsDeleted(pid)

    local objectCount = 0

    tes3mp.InitiateEvent(pid)
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

    tes3mp.InitiateEvent(pid)
    tes3mp.SetEventCell(self.description)

    for arrayIndex, refIndex in pairs(self.data.packets.place) do

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
        tes3mp.SetObjectPosition(self.data.objectData[refIndex].location.posX, self.data.objectData[refIndex].location.posY, self.data.objectData[refIndex].location.posZ)
        tes3mp.SetObjectRotation(self.data.objectData[refIndex].location.rotX, self.data.objectData[refIndex].location.rotY, self.data.objectData[refIndex].location.rotZ)

        tes3mp.AddWorldObject()

        objectCount = objectCount + 1
    end

    if objectCount > 0 then
        tes3mp.SendObjectPlace()
    end
end

function BaseCell:SendObjectsScaled(pid)

    local objectCount = 0

    tes3mp.InitiateEvent(pid)
    tes3mp.SetEventCell(self.description)

    for arrayIndex, refIndex in pairs(self.data.packets.scale) do

        local splitIndex = refIndex:split("-")
        tes3mp.SetObjectRefNumIndex(splitIndex[1])
        tes3mp.SetObjectMpNum(splitIndex[2])
        tes3mp.SetObjectRefId(self.data.objectData[refIndex].refId)
        tes3mp.SetObjectScale(self.data.objectData[refIndex].scale)
        tes3mp.AddWorldObject()

        objectCount = objectCount + 1
    end

    if objectCount > 0 then
        tes3mp.SendObjectScale()
    end
end

function BaseCell:SendObjectsLocked(pid)

    local objectCount = 0

    tes3mp.InitiateEvent(pid)
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

function BaseCell:SendObjectsUnlocked(pid)

    local objectCount = 0

    tes3mp.InitiateEvent(pid)
    tes3mp.SetEventCell(self.description)

    for arrayIndex, refIndex in pairs(self.data.packets.unlock) do

        local splitIndex = refIndex:split("-")
        tes3mp.SetObjectRefNumIndex(splitIndex[1])
        tes3mp.SetObjectMpNum(splitIndex[2])
        tes3mp.SetObjectRefId(self.data.objectData[refIndex].refId)
        tes3mp.AddWorldObject()

        objectCount = objectCount + 1
    end

    if objectCount > 0 then
        tes3mp.SendObjectUnlock()
    end
end

function BaseCell:SendDoorStates(pid)

    local objectCount = 0

    tes3mp.InitiateEvent(pid)
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

    tes3mp.InitiateEvent(pid)
    tes3mp.SetEventCell(self.description)

    for arrayIndex, refIndex in pairs(self.data.packets.container) do

        local splitIndex = refIndex:split("-")
        tes3mp.SetObjectRefNumIndex(splitIndex[1])
        tes3mp.SetObjectMpNum(splitIndex[2])
        tes3mp.SetObjectRefId(self.data.objectData[refIndex].refId)

        for itemIndex, item in pairs(self.data.objectData[refIndex].inventory) do
            tes3mp.SetContainerItemRefId(item.refId)
            tes3mp.SetContainerItemCount(item.count)
            tes3mp.SetContainerItemCharge(item.charge)

            tes3mp.AddContainerItem()
        end

        tes3mp.AddWorldObject()

        objectCount = objectCount + 1
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
        tes3mp.SetActorRefId(self.data.objectData[refIndex].refId)

        actorCount = actorCount + 1
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
        tes3mp.SetActorRefId(self.data.objectData[refIndex].refId)

        local location = self.data.objectData[refIndex].location

        tes3mp.SetActorPosition(location.posX, location.posY, location.posZ)
        tes3mp.SetActorRotation(location.rotX, location.rotY, location.rotZ)

        tes3mp.AddActor()

        actorCount = actorCount + 1
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
        tes3mp.SetActorRefId(self.data.objectData[refIndex].refId)

        local stats = self.data.objectData[refIndex].stats

        tes3mp.SetActorHealthBase(stats.healthBase)
        tes3mp.SetActorHealthCurrent(stats.healthCurrent)
        tes3mp.SetActorMagickaBase(stats.magickaBase)
        tes3mp.SetActorMagickaCurrent(stats.magickaCurrent)
        tes3mp.SetActorFatigueBase(stats.fatigueBase)
        tes3mp.SetActorFatigueCurrent(stats.fatigueCurrent)

        tes3mp.AddActor()

        actorCount = actorCount + 1
    end

    if actorCount > 0 then
        tes3mp.SendActorStatsDynamic()
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
        tes3mp.SetActorRefId(self.data.objectData[refIndex].refId)

        local newCellDescription = self.data.objectData[refIndex].cellChangeTo
        tes3mp.SetActorCell(newCellDescription)

        -- If the new cell is not loaded, load it temporarily
        if LoadedCells[newCellDescription] == nil then
            myMod.LoadCell(newCellDescription)
            table.insert(temporaryLoadedCells, newCellDescription)
        end

        local location = LoadedCells[newCellDescription].data.objectData[refIndex].location

        tes3mp.SetActorPosition(location.posX, location.posY, location.posZ)
        tes3mp.SetActorRotation(location.rotX, location.rotY, location.rotZ)

        tes3mp.AddActor()

        actorCount = actorCount + 1
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

        local originalCellDescription = self.data.objectData[refIndex].cellChangeFrom

        if cellChangesFrom[originalCellDescription] == nil then
            cellChangesFrom[originalCellDescription] = {}
        end

        table.insert(cellChangesFrom[originalCellDescription], refIndex)
    end

    -- Send a cell change packet for every cell that has sent actors to this cell
    for originalCellDescription, actorArray in pairs(cellChangesFrom) do
        
        tes3mp.InitializeActorList(pid)
        tes3mp.SetActorListCell(originalCellDescription)

        for arrayIndex, refIndex in pairs(actorArray) do

            local splitIndex = refIndex:split("-")
            tes3mp.SetActorRefNumIndex(splitIndex[1])
            tes3mp.SetActorMpNum(splitIndex[2])
            tes3mp.SetActorRefId(self.data.objectData[refIndex].refId)

            tes3mp.SetActorCell(self.description)

            local location = self.data.objectData[refIndex].location

            tes3mp.SetActorPosition(location.posX, location.posY, location.posZ)
            tes3mp.SetActorRotation(location.rotX, location.rotY, location.rotZ)

            tes3mp.AddActor()
        end

        tes3mp.SendActorCellChange()
    end
end

function BaseCell:RequestContainers(pid)

    tes3mp.InitiateEvent(pid)
    tes3mp.SetEventCell(self.description)

    -- Set the action to REQUEST
    tes3mp.SetEventAction(3)

    tes3mp.SendContainer()
end

function BaseCell:RequestActorList(pid)

    tes3mp.InitializeActorList(pid)
    tes3mp.SetActorListCell(self.description)

    -- Set the action to REQUEST
    tes3mp.SetActorListAction(3)

    tes3mp.SendActorList()
end

function BaseCell:SendCellData(pid)

    tes3mp.LogMessage(1, "Sending data of cell " .. self.description .. " to pid " .. pid)

    self:SendObjectsDeleted(pid)
    self:SendObjectsPlaced(pid)
    self:SendObjectsScaled(pid)
    self:SendObjectsLocked(pid)
    self:SendObjectsUnlocked(pid)
    self:SendDoorStates(pid)

    if self:HasContainerData() then
        self:SendContainers(pid)
    else
        self:RequestContainers(pid)
    end

    if self:HasActorData() then
        self:SendActorList(pid)
        self:SendActorCellChanges(pid)
        self:SendActorPositions(pid)
        self:SendActorStatsDynamic(pid)
    else
        self:RequestActorList(pid)
    end
end

return BaseCell
