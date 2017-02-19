require('utils')
local BaseCell = class("BaseCell")

function BaseCell:__init(cellDescription)

    self.data = {}
    self.data.general = {}
    self.data.general.description = cellDescription
    self.data.general.version = tes3mp.GetServerVersion()

    self.data.refIdDelete = {}
    self.data.refIdPlace = {}
    self.data.refIdScale = {}
    self.data.refIdLock = {}
    self.data.refIdUnlock = {}
    self.data.refIdDoorState = {}

    self.data.count = {}
    self.data.charge = {}
    self.data.goldValue = {}
    self.data.position = {}
    self.data.rotation = {}
    self.data.scale = {}
    self.data.lockLevel = {}
    self.data.doorState = {}

    self.data.lastVisit = {}

    self.visitors = {}
end

function BaseCell:HasFile()
    return self.hasFile
end

function BaseCell:HasCurrentStructure()

    if self.data.general.version == nil or self.data.general.version ~= tes3mp.GetServerVersion() then
        return false
    end

    return true
end

function BaseCell:AddVisitor(pid)

    -- Only add new visitor if we don't already have them
    if table.contains(self.visitors, pid) == false then
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
    if table.contains(self.visitors, pid) == true then
        table.removeValue(self.visitors, pid)

        -- Also remove the record from the player's list of loaded cells
        Players[pid]:RemoveCellLoaded(self.description)

        -- Remember when this visitor left
        self:SaveLastVisit(Players[pid].accountName)
    end
end

function BaseCell:HasContainerData()
    if self.data.refIdContainer ~= nil then
        return true
    end

    return false
end

function BaseCell:SaveObjectsDeleted()

    local refNum

    for i = 0, tes3mp.GetObjectChangesSize() - 1 do

        refNum = tes3mp.GetObjectRefNumIndex(i)

        -- With this object being deleted, we no longer need to store
        -- any special information about it
        self.data.refIdScale[refNum] = nil
        self.data.refIdLock[refNum] = nil
        self.data.refIdUnlock[refNum] = nil
        self.data.refIdDoorState[refNum] = nil

        self.data.count[refNum] = nil
        self.data.charge[refNum] = nil
        self.data.goldValue[refNum] = nil
        self.data.position[refNum] = nil
        self.data.rotation[refNum] = nil
        self.data.scale[refNum] = nil
        self.data.lockLevel[refNum] = nil
        self.data.doorState[refNum] = nil

        -- If this is a container, make sure we remove its table
        if self.data.refIdContainer[refNum] ~= nil then

            local containerName = self.data.refIdContainer[refNum] .. refNum

            self.data[containerName] = nil
            self.data.refIdContainer[refNum] = nil
        end

        -- If this is an object that did not originally exist in the cell,
        -- remove it from refIdPlace
        if self.data.refIdPlace[refNum] ~= nil then
            self.data.refIdPlace[refNum] = nil
        -- Otherwise, add it to refIdDelete
        else
            self.data.refIdDelete[refNum] = tes3mp.GetObjectRefId(i)
        end
    end
end

function BaseCell:SaveObjectsPlaced()

    local refNum
    local tempValue

    for i = 0, tes3mp.GetObjectChangesSize() - 1 do

        refNum = tes3mp.GetObjectRefNumIndex(i)
        self.data.refIdPlace[refNum] = tes3mp.GetObjectRefId(i)

        local count = tes3mp.GetObjectCount(i)
        local charge = tes3mp.GetObjectCharge(i)
        local goldValue = tes3mp.GetObjectGoldValue(i)

        -- Only save count if it isn't the default value of 1
        if count ~= 1 then
            self.data.count[refNum] = count
        end

        -- Only save charge if it isn't the default value of -1
        if charge ~= -1 then
            self.data.charge[refNum] = charge
        end

        -- Only save goldValue if it isn't the default value of 1
        if goldValue ~=1 then
            self.data.goldValue[refNum] = goldValue
        end

        tempValue = tes3mp.GetObjectPosX(i)
        tempValue = tempValue .. ", " .. tes3mp.GetObjectPosY(i)
        tempValue = tempValue .. ", " .. tes3mp.GetObjectPosZ(i)
        self.data.position[refNum] = tempValue

        tempValue = tes3mp.GetObjectRotX(i)
        tempValue = tempValue .. ", " .. tes3mp.GetObjectRotY(i)
        tempValue = tempValue .. ", " .. tes3mp.GetObjectRotZ(i)
        self.data.rotation[refNum] = tempValue
    end
end

function BaseCell:SaveObjectsScaled()

    local refNum

    for i = 0, tes3mp.GetObjectChangesSize() - 1 do

        refNum = tes3mp.GetObjectRefNumIndex(i)
        self.data.refIdScale[refNum] = tes3mp.GetObjectRefId(i)
        self.data.scale[refNum] = tes3mp.GetObjectScale(i)
    end
end

function BaseCell:SaveObjectsLocked()

    local refNum

    for i = 0, tes3mp.GetObjectChangesSize() - 1 do

        refNum = tes3mp.GetObjectRefNumIndex(i)
        self.data.refIdLock[refNum] = tes3mp.GetObjectRefId(i)
        self.data.lockLevel[refNum] = tes3mp.GetObjectLockLevel(i)
    end
end

function BaseCell:SaveObjectsUnlocked()

    local refNum

    for i = 0, tes3mp.GetObjectChangesSize() - 1 do

        refNum = tes3mp.GetObjectRefNumIndex(i)
        self.data.refIdUnlock[refNum] = tes3mp.GetObjectRefId(i)
    end
end

function BaseCell:SaveDoorStates()

    local refNum

    for i = 0, tes3mp.GetObjectChangesSize() - 1 do

        refNum = tes3mp.GetObjectRefNumIndex(i)
        self.data.refIdDoorState[refNum] = tes3mp.GetObjectRefId(i)
        self.data.doorState[refNum] = tes3mp.GetObjectDoorState(i)
    end
end

function BaseCell:SaveLastVisit(playerName)

    self.data.lastVisit[playerName] = os.time()
end

function BaseCell:SaveContainers()

    local containerActions = { SET = 0, ADD = 1, REMOVE = 2}
    local action = tes3mp.GetBaseEventAction(pid)

    if self.data.refIdContainer == nil then
        self.data.refIdContainer = {}
    end

    for objectIndex = 0, tes3mp.GetObjectChangesSize() - 1 do

        local containerRefId = tes3mp.GetObjectRefId(objectIndex)
        local containerRefNum = tes3mp.GetObjectRefNumIndex(objectIndex)
        self.data.refIdContainer[containerRefNum] = containerRefId

        local containerTableName = "container-" .. containerRefId .. "-" .. containerRefNum

        -- If this table doesn't exist, initialize it
        -- If it exists and the action is SET, empty it
        if self.data[containerTableName] == nil or action == containerActions.SET then
            self.data[containerTableName] = {}
        end

        for itemIndex = 0, tes3mp.GetContainerChangesSize(objectIndex) - 1 do

            local itemRefId = tes3mp.GetContainerItemRefId(objectIndex, itemIndex)
            local itemCount = tes3mp.GetContainerItemCount(objectIndex, itemIndex)
            local itemCharge = tes3mp.GetContainerItemCharge(objectIndex, itemIndex)

            local storedIndex, currentItemPattern = nil

            -- If this isn't a SET action, put together a pattern based on this item's refId and charge
            if action ~= containerActions.SET then

                currentItemPattern = itemRefId .. ", (%d+), " .. itemCharge .. "$"

                -- Because both - and % are special characters, escape them with another % each
                currentItemPattern = string.gsub(currentItemPattern, "%-", "%%%-")

                -- Check if an item matching the pattern already exists in the container
                storedIndex = table.getIndexByPattern(self.data[containerTableName], currentItemPattern)
            end

            -- If storedIndex is nil, it can mean a number of things
            if storedIndex == nil then
                -- Tell the client that they are attempting to REMOVE a non-existent item,
                -- indicative of a data race situation
                -- (to be implemented later)
                if action == containerActions.REMOVE then
                    print("Attempt to remove non-existent item")
                -- If we have received ADD for a previously non-existent item, or we are
                -- just using SET, simply insert the item
                else
                    local itemData = itemRefId .. ", " .. itemCount .. ", " .. itemCharge
                    table.insert(self.data[containerTableName], itemData)
                end
            -- A similar item was found in the container's data
            else
                for oldCount in string.gmatch(self.data[containerTableName][storedIndex], currentItemPattern) do
                    -- If the action was ADD, then sum up the counts
                    if action == containerActions.ADD then

                        local newCount = tonumber(oldCount) + itemCount
                        self.data[containerTableName][storedIndex] = itemRefId .. ", " .. newCount .. ", " .. itemCharge

                    -- If the action was REMOVE, make sure we're not removing more than possible
                    elseif action == containerActions.REMOVE then

                        local newCount = tonumber(oldCount) - tes3mp.GetContainerItemActionCount(objectIndex, itemIndex)
                        
                        -- The item will still exist in the container with a lower count
                        if newCount > 0 then
                            self.data[containerTableName][storedIndex] = itemRefId .. ", " .. newCount .. ", " .. itemCharge
                        -- The item is to be completely removed
                        elseif newCount == 0 then
                            self.data[containerTableName][storedIndex] = nil
                        -- Tell the client that they are attempting to REMOVE more of an item
                        -- than is possible, indicative of a data race situation
                        -- (to be implemented later)
                        else
                            print("Attempt to remove more than possible from item")
                        end
                    end
                end
            end
        end
    end
end

function BaseCell:SendObjectsDeleted(pid)

    local objectIndex = 0

    tes3mp.CreateBaseEvent(pid)
    tes3mp.SetBaseEventCell(self.description)

    -- Objects deleted
    for refNum, refId in pairs(self.data.refIdDelete) do

        tes3mp.SetObjectRefNumIndex(refNum)
        tes3mp.SetObjectRefId(refId)
        tes3mp.AddWorldObject()

        objectIndex = objectIndex + 1
    end

    if objectIndex > 0 then
        tes3mp.SendObjectDelete()
    end
end

function BaseCell:SendObjectsPlaced(pid)

    local coordinatesPattern = "(%-?%d+%.?%d*), (%-?%d+%.?%d*), (%-?%d+%.?%d*)$"
    local objectIndex = 0

    tes3mp.CreateBaseEvent(pid)
    tes3mp.SetBaseEventCell(self.description)

    for refNum, refId in pairs(self.data.refIdPlace) do

        tes3mp.SetObjectRefNumIndex(refNum)
        tes3mp.SetObjectRefId(refId)

        local count = self.data.count[refNum]
        local charge = self.data.charge[refNum]
        local goldValue = self.data.goldValue[refNum]

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

        for posX, posY, posZ in string.gmatch(self.data.position[refNum], coordinatesPattern) do
            tes3mp.SetObjectPosition(posX, posY, posZ)
        end

        for rotX, rotY, rotZ in string.gmatch(self.data.rotation[refNum], coordinatesPattern) do
            tes3mp.SetObjectRotation(rotX, rotY, rotZ)
        end

        tes3mp.AddWorldObject()

        objectIndex = objectIndex + 1
    end

    if objectIndex > 0 then
        tes3mp.SendObjectPlace()
    end
end

function BaseCell:SendObjectsScaled(pid)

    local objectIndex = 0

    tes3mp.CreateBaseEvent(pid)
    tes3mp.SetBaseEventCell(self.description)

    for refNum, refId in pairs(self.data.refIdScale) do

        tes3mp.SetObjectRefNumIndex(refNum)
        tes3mp.SetObjectRefId(refId)
        tes3mp.SetObjectScale(self.data.scale[refNum])
        tes3mp.AddWorldObject()

        objectIndex = objectIndex + 1
    end

    if objectIndex > 0 then
        tes3mp.SendObjectScale()
    end
end

function BaseCell:SendObjectsLocked(pid)

    local objectIndex = 0

    tes3mp.CreateBaseEvent(pid)
    tes3mp.SetBaseEventCell(self.description)

    for refNum, refId in pairs(self.data.refIdLock) do

        tes3mp.SetObjectRefNumIndex(refNum)
        tes3mp.SetObjectRefId(refId)
        tes3mp.SetObjectLockLevel(self.data.lockLevel[refNum])
        tes3mp.AddWorldObject()

        objectIndex = objectIndex + 1
    end

    if objectIndex > 0 then
        tes3mp.SendObjectLock()
    end
end

function BaseCell:SendObjectsUnlocked(pid)

    local objectIndex = 0

    tes3mp.CreateBaseEvent(pid)
    tes3mp.SetBaseEventCell(self.description)

    for refNum, refId in pairs(self.data.refIdUnlock) do

        tes3mp.SetObjectRefNumIndex(refNum)
        tes3mp.SetObjectRefId(refId)
        tes3mp.AddWorldObject()

        objectIndex = objectIndex + 1
    end

    if objectIndex > 0 then
        tes3mp.SendObjectUnlock()
    end
end

function BaseCell:SendDoorStates(pid)

    local objectIndex = 0

    tes3mp.CreateBaseEvent(pid)
    tes3mp.SetBaseEventCell(self.description)

    for refNum, refId in pairs(self.data.refIdDoorState) do

        tes3mp.SetObjectRefNumIndex(refNum)
        tes3mp.SetObjectRefId(refId)
        tes3mp.SetObjectDoorState(self.data.doorState[refNum])
        tes3mp.AddWorldObject()

        objectIndex = objectIndex + 1
    end

    if objectIndex > 0 then
        tes3mp.SendDoorState()
    end
end

function BaseCell:SendContainers(pid)

    local objectIndex = 0
    local itemPattern = "(.+), (%d+), (%-?%d+)$"

    tes3mp.CreateBaseEvent(pid)
    tes3mp.SetBaseEventCell(self.description)

    for containerRefNum, containerRefId in pairs(self.data.refIdContainer) do

        tes3mp.SetObjectRefNumIndex(containerRefNum)
        tes3mp.SetObjectRefId(containerRefId)

        local containerTableName = "container-" .. containerRefId .. "-" .. containerRefNum

        for itemIndex, value in pairs(self.data[containerTableName]) do
            if string.match(value, itemPattern) ~= nil then
                for itemRefId, itemCount, itemCharge in string.gmatch(value, itemPattern) do

                    tes3mp.SetContainerItemRefId(itemRefId)
                    tes3mp.SetContainerItemCount(itemCount)
                    tes3mp.SetContainerItemCharge(itemCharge)

                    tes3mp.AddContainerItem()
                end
            end
        end

        tes3mp.AddWorldObject()

        objectIndex = objectIndex + 1
    end

    if objectIndex > 0 then

        -- Set the action to SET
        tes3mp.SetBaseEventAction(0)

        tes3mp.SendContainer()
    end
end

function BaseCell:RequestContainers(pid)

    tes3mp.CreateBaseEvent(pid)
    tes3mp.SetBaseEventCell(self.description)

    -- Set the action to REQUEST
    tes3mp.SetBaseEventAction(3)

    tes3mp.SendContainer()
end

function BaseCell:SendCellData(pid)

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
end

function BaseCell:UpdateStructure()

    if self.data.general.version == "0.4.1" then

        if self.data.doorState == nil then
            self.data.doorState = {}
        end

        if self.data.state ~= nil then

            for refNum, doorState in pairs(self.data.state) do
                self.data.doorState[refNum] = doorState
            end

            self.data.state = nil
        end

    -- This data file has the original cell data experiment structure
    elseif self.data.general.version == nil then

        self.data.refIdDelete = {}
        self.data.refIdPlace = {}
        self.data.refIdScale = {}
        self.data.refIdLock = {}
        self.data.refIdUnlock = {}
        self.data.refIdDoorState = {}

        self.data.count = {}
        self.data.charge = {}
        self.data.goldValue = {}
        self.data.position = {}
        self.data.rotation = {}
        self.data.scale = {}
        self.data.lockLevel = {}
        self.data.doorState = {}

        self.data.lastVisit = {}

        if self.data.objectsPlaced ~= nil then

            -- RefId, count, goldValue
            local objectPlacedPattern = "(.+), (%d+), (%d+)"
            -- X, Y and Z positions
            objectPlacedPattern = objectPlacedPattern .. ", (%-?%d+%.?%d*), (%-?%d+%.?%d*), (%-?%d+%.?%d*)"
            -- X, Y and Z rotations
            objectPlacedPattern = objectPlacedPattern .. ", (%-?%d+%.?%d*), (%-?%d+%.?%d*), (%-?%d+%.?%d*)$"

            for refNum, value in pairs(self.data.objectsPlaced) do
                if string.match(value, objectPlacedPattern) ~= nil then
                    for refId, count, goldValue, posX, posY, posZ, rotX, rotY, rotZ in string.gmatch(value, objectPlacedPattern) do

                        self.data.refIdPlace[refNum] = refId

                        if tonumber(count) ~= 1 then
                            self.data.count[refNum] = count
                        end

                        if tonumber(goldValue) ~= 1 then
                            self.data.goldValue[refNum] = goldValue
                        end

                        self.data.position[refNum] = posX .. ", " .. posY .. ", " .. posZ
                        self.data.rotation[refNum] = rotX .. ", " .. rotY .. ", " .. rotZ
                    end
                end
            end

            self.data.objectsPlaced = nil
        end

        if self.data.objectsDeleted ~= nil then

            for refNum, refId in pairs(self.data.objectsDeleted) do
                self.data.refIdDelete[refNum] = refId
            end

            self.data.objectsDeleted = nil
        end

        if self.data.objectsScaled ~= nil then

            -- RefId, scale
            local objectScaledPattern = "(.+), (%d+%.?%d*)"

            for refNum, value in pairs(self.data.objectsScaled) do
                if string.match(value, objectScaledPattern) ~= nil then
                    for refId, scale in string.gmatch(value, objectScaledPattern) do

                        self.data.refIdScale[refNum] = refId
                        self.data.scale[refNum] = scale
                    end
                end
            end

            self.data.objectsScaled = nil
        end

        if self.data.objectsLocked ~= nil then

            -- RefId, lockLevel
            local objectLockedPattern = "(.+), (%d+)"

            for refNum, value in pairs(self.data.objectsLocked) do
                if string.match(value, objectLockedPattern) ~= nil then
                    for refId, lockLevel in string.gmatch(value, objectLockedPattern) do

                        self.data.refIdLock[refNum] = refId
                        self.data.lockLevel[refNum] = lockLevel
                    end
                end
            end

            self.data.objectsLocked = nil
        end

        if self.data.objectsUnlocked ~= nil then

            for refNum, refId in pairs(self.data.objectsUnlocked) do
                self.data.refIdUnlock[refNum] = refId
            end

            self.data.objectsUnlocked = nil
        end

        if self.data.doorStates ~= nil then

            -- RefId, state
            local doorStatePattern = "(.+), (%d+)"

            for refNum, value in pairs(self.data.doorStates) do
                if string.match(value, doorStatePattern) ~= nil then
                    for refId, doorState in string.gmatch(value, doorStatePattern) do

                        self.data.refIdDoorState[refNum] = refId
                        self.data.doorState[refNum] = doorState
                    end
                end
            end

            self.data.doorStates = nil
        end

        if self.data.lastVisitTimestamps ~= nil then

            self.data.lastVisit = {}

            for player, timestamp in pairs(self.data.lastVisitTimestamps) do

                self.data.lastVisit[player] = timestamp
            end

            self.data.lastVisitTimestamps = nil
        end
    end

    self.data.general.version = tes3mp.GetServerVersion()
    self:Save()
end

return BaseCell
