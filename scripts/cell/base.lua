require("patterns")
tableHelper = require("tableHelper")
require("utils")
local BaseCell = class("BaseCell")

function BaseCell:__init(cellDescription)

    self.data = {}
    self.data.entry = {}
    self.data.entry.description = cellDescription

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

function BaseCell:HasEntry()
    return self.hasEntry
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

function BaseCell:HasContainerData()
    if self.data.refIdContainer ~= nil then
        return true
    end

    return false
end

function BaseCell:HasActorData()
    if self.data.refIdActor ~= nil then
        return true
    end

    return false
end

function BaseCell:SaveObjectsDeleted()

    local refIndex

    for i = 0, tes3mp.GetObjectChangesSize() - 1 do

        refIndex = tes3mp.GetObjectRefNumIndex(i) .. "-" .. tes3mp.GetObjectMpNum(i)

        -- With this object being deleted, we no longer need to store
        -- any special information about it
        self.data.refIdScale[refIndex] = nil
        self.data.refIdLock[refIndex] = nil
        self.data.refIdUnlock[refIndex] = nil
        self.data.refIdDoorState[refIndex] = nil

        self.data.count[refIndex] = nil
        self.data.charge[refIndex] = nil
        self.data.goldValue[refIndex] = nil
        self.data.position[refIndex] = nil
        self.data.rotation[refIndex] = nil
        self.data.scale[refIndex] = nil
        self.data.lockLevel[refIndex] = nil
        self.data.doorState[refIndex] = nil

        -- If this is a container, make sure we remove its table
        if self.data.refIdContainer ~= nil and self.data.refIdContainer[refIndex] ~= nil then

            local containerName = self.data.refIdContainer[refIndex] .. refIndex

            self.data[containerName] = nil
            self.data.refIdContainer[refIndex] = nil
        end

        -- If this is an object that did not originally exist in the cell,
        -- remove it from refIdPlace
        if self.data.refIdPlace[refIndex] ~= nil then
            self.data.refIdPlace[refIndex] = nil
        -- Otherwise, add it to refIdDelete
        else
            self.data.refIdDelete[refIndex] = tes3mp.GetObjectRefId(i)
        end
    end
end

function BaseCell:SaveObjectsPlaced()

    local refIndex
    local tempValue

    for i = 0, tes3mp.GetObjectChangesSize() - 1 do

        refIndex = tes3mp.GetObjectRefNumIndex(i) .. "-" .. tes3mp.GetObjectMpNum(i)
        self.data.refIdPlace[refIndex] = tes3mp.GetObjectRefId(i)

        local count = tes3mp.GetObjectCount(i)
        local charge = tes3mp.GetObjectCharge(i)
        local goldValue = tes3mp.GetObjectGoldValue(i)

        -- Only save count if it isn't the default value of 1
        if count ~= 1 then
            self.data.count[refIndex] = count
        end

        -- Only save charge if it isn't the default value of -1
        if charge ~= -1 then
            self.data.charge[refIndex] = charge
        end

        -- Only save goldValue if it isn't the default value of 1
        if goldValue ~=1 then
            self.data.goldValue[refIndex] = goldValue
        end

        tempValue = tes3mp.GetObjectPosX(i)
        tempValue = tempValue .. ", " .. tes3mp.GetObjectPosY(i)
        tempValue = tempValue .. ", " .. tes3mp.GetObjectPosZ(i)
        self.data.position[refIndex] = tempValue

        tempValue = tes3mp.GetObjectRotX(i)
        tempValue = tempValue .. ", " .. tes3mp.GetObjectRotY(i)
        tempValue = tempValue .. ", " .. tes3mp.GetObjectRotZ(i)
        self.data.rotation[refIndex] = tempValue
    end
end

function BaseCell:SaveObjectsScaled()

    local refIndex

    for i = 0, tes3mp.GetObjectChangesSize() - 1 do

        refIndex = tes3mp.GetObjectRefNumIndex(i) .. "-" .. tes3mp.GetObjectMpNum(i)
        self.data.refIdScale[refIndex] = tes3mp.GetObjectRefId(i)
        self.data.scale[refIndex] = tes3mp.GetObjectScale(i)
    end
end

function BaseCell:SaveObjectsLocked()

    local refIndex

    for i = 0, tes3mp.GetObjectChangesSize() - 1 do

        refIndex = tes3mp.GetObjectRefNumIndex(i) .. "-" .. tes3mp.GetObjectMpNum(i)
        self.data.refIdLock[refIndex] = tes3mp.GetObjectRefId(i)
        self.data.lockLevel[refIndex] = tes3mp.GetObjectLockLevel(i)
    end
end

function BaseCell:SaveObjectsUnlocked()

    local refIndex

    for i = 0, tes3mp.GetObjectChangesSize() - 1 do

        refIndex = tes3mp.GetObjectRefNumIndex(i) .. "-" .. tes3mp.GetObjectMpNum(i)
        self.data.refIdUnlock[refIndex] = tes3mp.GetObjectRefId(i)
    end
end

function BaseCell:SaveDoorStates()

    local refIndex

    for i = 0, tes3mp.GetObjectChangesSize() - 1 do

        refIndex = tes3mp.GetObjectRefNumIndex(i) .. "-" .. tes3mp.GetObjectMpNum(i)
        self.data.refIdDoorState[refIndex] = tes3mp.GetObjectRefId(i)
        self.data.doorState[refIndex] = tes3mp.GetObjectDoorState(i)
    end
end

function BaseCell:SaveLastVisit(playerName)

    self.data.lastVisit[playerName] = os.time()
end

function BaseCell:SaveContainers()

    local actionTypes = { SET = 0, ADD = 1, REMOVE = 2}
    local action = tes3mp.GetLastEventAction()

    if self.data.refIdContainer == nil then
        self.data.refIdContainer = {}
    end

    for objectIndex = 0, tes3mp.GetObjectChangesSize() - 1 do

        local containerRefId = tes3mp.GetObjectRefId(objectIndex)
        local containerRefIndex = tes3mp.GetObjectRefNumIndex(objectIndex) .. "-" .. tes3mp.GetObjectMpNum(objectIndex)
        self.data.refIdContainer[containerRefIndex] = containerRefId

        local containerTableName = "container-" .. containerRefId .. "-" .. containerRefIndex

        -- If this table doesn't exist, initialize it
        -- If it exists and the action is SET, empty it
        if self.data[containerTableName] == nil or action == actionTypes.SET then
            self.data[containerTableName] = {}
        end

        for itemIndex = 0, tes3mp.GetContainerChangesSize(objectIndex) - 1 do

            local itemRefId = tes3mp.GetContainerItemRefId(objectIndex, itemIndex)
            local itemCount = tes3mp.GetContainerItemCount(objectIndex, itemIndex)
            local itemCharge = tes3mp.GetContainerItemCharge(objectIndex, itemIndex)

            local storedIndex, currentItemPattern = nil

            -- If this isn't a SET action, put together a pattern based on this item's refId and charge
            if action ~= actionTypes.SET then

                currentItemPattern = itemRefId .. ", (%d+), " .. itemCharge .. "$"

                -- Because both - and % are special characters, escape them with another % each
                currentItemPattern = string.gsub(currentItemPattern, "%-", "%%%-")

                -- Check if an item matching the pattern already exists in the container
                storedIndex = tableHelper.getIndexByPattern(self.data[containerTableName], currentItemPattern)
            end

            -- If storedIndex is nil, it can mean a number of things
            if storedIndex == nil then
                -- Tell the client that they are attempting to REMOVE a non-existent item,
                -- indicative of a data race situation
                -- (to be implemented later)
                if action == actionTypes.REMOVE then
                    tes3mp.LogMessage(2, "Attempt to remove non-existent item")
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
                    if action == actionTypes.ADD then

                        local newCount = tonumber(oldCount) + itemCount
                        self.data[containerTableName][storedIndex] = itemRefId .. ", " .. newCount .. ", " .. itemCharge

                    -- If the action was REMOVE, make sure we're not removing more than possible
                    elseif action == actionTypes.REMOVE then

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
                            tes3mp.LogMessage(2, "Attempt to remove more than possible from item")
                        end
                    end
                end
            end
        end
    end
end

function BaseCell:SaveActorList()

    local actionTypes = { SET = 0, ADD = 1, REMOVE = 2}
    local action = tes3mp.GetLastEventAction()

    if self.data.refIdActor == nil then
        self.data.refIdActor = {}
    end

    for objectIndex = 0, tes3mp.GetObjectChangesSize() - 1 do

        local refId = tes3mp.GetObjectRefId(objectIndex)
        local refIndex = tes3mp.GetObjectRefNumIndex(objectIndex) .. "-" .. tes3mp.GetObjectMpNum(objectIndex)
        self.data.refIdActor[refIndex] = refId

        local actorTableName = "actor-" .. refId .. "-" .. refIndex

        -- If this table doesn't exist, initialize it
        -- If it exists and the action is SET, empty it
        if self.data[actorTableName] == nil or action == actionTypes.SET then
            self.data[actorTableName] = {}
        end
    end
end

function BaseCell:SendObjectsDeleted(pid)

    local objectIndex = 0

    tes3mp.InitScriptEvent(pid)
    tes3mp.SetScriptEventCell(self.description)

    -- Objects deleted
    for refIndex, refId in pairs(self.data.refIdDelete) do

        local splitIndex = refIndex:split("-")
        tes3mp.SetObjectRefNumIndex(splitIndex[1])
        tes3mp.SetObjectMpNum(splitIndex[2])
        tes3mp.SetObjectRefId(refId)
        tes3mp.AddWorldObject()

        objectIndex = objectIndex + 1
    end

    if objectIndex > 0 then
        tes3mp.SendObjectDelete()
    end
end

function BaseCell:SendObjectsPlaced(pid)

    local objectIndex = 0

    tes3mp.InitScriptEvent(pid)
    tes3mp.SetScriptEventCell(self.description)

    for refIndex, refId in pairs(self.data.refIdPlace) do

        local splitIndex = refIndex:split("-")
        tes3mp.SetObjectRefNumIndex(splitIndex[1])
        tes3mp.SetObjectMpNum(splitIndex[2])
        tes3mp.SetObjectRefId(refId)

        local count = self.data.count[refIndex]
        local charge = self.data.charge[refIndex]
        local goldValue = self.data.goldValue[refIndex]

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

        for posX, posY, posZ in string.gmatch(self.data.position[refIndex], patterns.coordinates) do
            tes3mp.SetObjectPosition(posX, posY, posZ)
        end

        for rotX, rotY, rotZ in string.gmatch(self.data.rotation[refIndex], patterns.coordinates) do
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

    tes3mp.InitScriptEvent(pid)
    tes3mp.SetScriptEventCell(self.description)

    for refIndex, refId in pairs(self.data.refIdScale) do

        local splitIndex = refIndex:split("-")
        tes3mp.SetObjectRefNumIndex(splitIndex[1])
        tes3mp.SetObjectMpNum(splitIndex[2])
        tes3mp.SetObjectRefId(refId)
        tes3mp.SetObjectScale(self.data.scale[refIndex])
        tes3mp.AddWorldObject()

        objectIndex = objectIndex + 1
    end

    if objectIndex > 0 then
        tes3mp.SendObjectScale()
    end
end

function BaseCell:SendObjectsLocked(pid)

    local objectIndex = 0

    tes3mp.InitScriptEvent(pid)
    tes3mp.SetScriptEventCell(self.description)

    for refIndex, refId in pairs(self.data.refIdLock) do

        local splitIndex = refIndex:split("-")
        tes3mp.SetObjectRefNumIndex(splitIndex[1])
        tes3mp.SetObjectMpNum(splitIndex[2])
        tes3mp.SetObjectRefId(refId)
        tes3mp.SetObjectLockLevel(self.data.lockLevel[refIndex])
        tes3mp.AddWorldObject()

        objectIndex = objectIndex + 1
    end

    if objectIndex > 0 then
        tes3mp.SendObjectLock()
    end
end

function BaseCell:SendObjectsUnlocked(pid)

    local objectIndex = 0

    tes3mp.InitScriptEvent(pid)
    tes3mp.SetScriptEventCell(self.description)

    for refIndex, refId in pairs(self.data.refIdUnlock) do

        local splitIndex = refIndex:split("-")
        tes3mp.SetObjectRefNumIndex(splitIndex[1])
        tes3mp.SetObjectMpNum(splitIndex[2])
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

    tes3mp.InitScriptEvent(pid)
    tes3mp.SetScriptEventCell(self.description)

    for refIndex, refId in pairs(self.data.refIdDoorState) do

        local splitIndex = refIndex:split("-")
        tes3mp.SetObjectRefNumIndex(splitIndex[1])
        tes3mp.SetObjectMpNum(splitIndex[2])
        tes3mp.SetObjectRefId(refId)
        tes3mp.SetObjectDoorState(self.data.doorState[refIndex])
        tes3mp.AddWorldObject()

        objectIndex = objectIndex + 1
    end

    if objectIndex > 0 then
        tes3mp.SendDoorState()
    end
end

function BaseCell:SendContainers(pid)

    local objectIndex = 0

    tes3mp.InitScriptEvent(pid)
    tes3mp.SetScriptEventCell(self.description)

    for containerRefIndex, containerRefId in pairs(self.data.refIdContainer) do

        local splitIndex = containerRefIndex:split("-")
        tes3mp.SetObjectRefNumIndex(splitIndex[1])
        tes3mp.SetObjectMpNum(splitIndex[2])
        tes3mp.SetObjectRefId(containerRefId)

        local containerTableName = "container-" .. containerRefId .. "-" .. containerRefIndex

        -- If someone has (for whatever reason) removed a container table, ensure
        -- that the server doesn't crash because of it
        if self.data[containerTableName] ~= nil then

            for itemIndex, value in pairs(self.data[containerTableName]) do
                if string.match(value, patterns.item) ~= nil then
                    for itemRefId, itemCount, itemCharge in string.gmatch(value, patterns.item) do

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
    end

    if objectIndex > 0 then

        -- Set the action to SET
        tes3mp.SetScriptEventAction(0)

        tes3mp.SendContainer()
    end
end

function BaseCell:SendActorList(pid)

    local objectIndex = 0

    tes3mp.InitScriptEvent(pid)
    tes3mp.SetScriptEventCell(self.description)

    for refIndex, refId in pairs(self.data.refIdActor) do

        local splitIndex = refIndex:split("-")
        tes3mp.SetObjectRefNumIndex(splitIndex[1])
        tes3mp.SetObjectMpNum(splitIndex[2])
        tes3mp.SetObjectRefId(refId)

        local actorTableName = "actor-" .. refId .. "-" .. refIndex

        -- If someone has (for whatever reason) removed an actor table, ensure
        -- that the server doesn't crash because of it
        if self.data[actorTableName] ~= nil then

            tes3mp.AddWorldObject()

            objectIndex = objectIndex + 1
        end
    end

    if objectIndex > 0 then

        -- Set the action to SET
        tes3mp.SetScriptEventAction(0)

        tes3mp.SendActorList()
    end
end

function BaseCell:RequestContainers(pid)

    tes3mp.InitScriptEvent(pid)
    tes3mp.SetScriptEventCell(self.description)

    -- Set the action to REQUEST
    tes3mp.SetScriptEventAction(3)

    tes3mp.SendContainer()
end

function BaseCell:RequestActorList(pid)

    tes3mp.InitScriptEvent(pid)
    tes3mp.SetScriptEventCell(self.description)

    -- Set the action to REQUEST
    tes3mp.SetScriptEventAction(3)

    tes3mp.SendActorList()
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

    if self:HasActorData() then
        self:SendActorList(pid)
    else
        self:RequestActorList(pid)
    end
end

return BaseCell
