require('utils')
local BaseCell = class("BaseCell")

function BaseCell:__init(cellDescription)

    self.data = {}
    self.data.general = {}
    self.data.general.description = cellDescription
    self.data.objectsPlaced = {}
    self.data.objectsDeleted = {}
    self.data.objectsScaled = {}
    self.data.lastVisitTimestamps = {}

    self.visitors = {}
end

function BaseCell:HasFile()
    return self.hasFile
end

function BaseCell:AddVisitor(pid)

    -- Only add new visitor if we don't already have them
    if table.contains(self.visitors, pid) == false then
        table.insert(self.visitors, pid)

        -- Also add a record to the player's list of loaded cells
        Players[pid]:AddCellLoaded(self.description)

        local shouldSendInfo = false
        local lastVisitTimestamp = self.data.lastVisitTimestamps[Players[pid].accountName]

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

function BaseCell:SaveObjectsDeleted()

    local refNumIndex

    for i = 0, tes3mp.GetObjectChangesSize() - 1 do

        refNumIndex = tes3mp.GetObjectRefNumIndex(i)

        -- If any other attributes have been set for this object, they
        -- can now be safely removed
        if self.data.objectsScaled[refNumIndex] ~= nil then
            self.data.objectsScaled[refNumIndex] = nil
        end

        -- If this is an object that did not originally exist in the cell,
        -- remove it from objectsPlaced
        if self.data.objectsPlaced[refNumIndex] ~= nil then
            self.data.objectsPlaced[refNumIndex] = nil
        -- Otherwise, add it to objectsDeleted
        else
            self.data.objectsDeleted[refNumIndex] = tes3mp.GetObjectRefId(i)
        end
    end
end

function BaseCell:SaveObjectsPlaced()

    local refNumIndex
    local value

    for i = 0, tes3mp.GetObjectChangesSize() - 1 do

        refNumIndex = tes3mp.GetObjectRefNumIndex(i)
        value = tes3mp.GetObjectRefId(i)
        value = value .. ", " .. tes3mp.GetObjectCount(i)
        value = value .. ", " .. tes3mp.GetObjectGoldValue(i)
        value = value .. ", " .. tes3mp.GetObjectPosX(i)
        value = value .. ", " .. tes3mp.GetObjectPosY(i)
        value = value .. ", " .. tes3mp.GetObjectPosZ(i)
        value = value .. ", " .. tes3mp.GetObjectRotX(i)
        value = value .. ", " .. tes3mp.GetObjectRotY(i)
        value = value .. ", " .. tes3mp.GetObjectRotZ(i)
        self.data.objectsPlaced[refNumIndex] = value
    end
end

function BaseCell:SaveObjectsScaled()

    local refNumIndex
    local value

    print("WALRUS TITS")

    for i = 0, tes3mp.GetObjectChangesSize() - 1 do

        refNumIndex = tes3mp.GetObjectRefNumIndex(i)
        value = tes3mp.GetObjectRefId(i)
        value = value .. ", " .. tes3mp.GetObjectScale(i)
        self.data.objectsScaled[refNumIndex] = value
    end
end

function BaseCell:SaveLastVisit(playerName)

    self.data.lastVisitTimestamps[playerName] = os.time()
end

function BaseCell:SendObjectsDeleted(pid)

    local objectIndex = 0

    tes3mp.CreateWorldEvent(pid)
    tes3mp.SetWorldEventCell(self.description)

    -- Objects deleted
    for refNum, refId in pairs(self.data.objectsDeleted) do

        tes3mp.SetObjectRefId(refId)
        tes3mp.SetObjectRefNumIndex(refNum)
        tes3mp.AddWorldObject()

        objectIndex = objectIndex + 1
    end

    if objectIndex > 0 then
        tes3mp.SendObjectDelete()
    end
end

function BaseCell:SendObjectsPlaced(pid)

    -- RefId, count, goldValue
    local objectPlacedPattern = "(.+), (%d+), (%d+)"
    -- X, Y and Z positions
    objectPlacedPattern = objectPlacedPattern .. ", (%-?%d+%.?%d*), (%-?%d+%.?%d*), (%-?%d+%.?%d*)"
    -- X, Y and Z rotations
    objectPlacedPattern = objectPlacedPattern .. ", (%-?%d+%.?%d*), (%-?%d+%.?%d*), (%-?%d+%.?%d*)$"

    local objectIndex = 0

    tes3mp.CreateWorldEvent(pid)
    tes3mp.SetWorldEventCell(self.description)

    for refNum, value in pairs(self.data.objectsPlaced) do
        if string.match(value, objectPlacedPattern) ~= nil then
            for refId, count, goldValue, posX, posY, posZ, rotX, rotY, rotZ in string.gmatch(value, objectPlacedPattern) do
                
                tes3mp.SetObjectRefId(refId)
                tes3mp.SetObjectRefNumIndex(refNum)
                tes3mp.SetObjectCount(count)
                tes3mp.SetObjectGoldValue(goldValue)
                tes3mp.SetObjectPosition(posX, posY, posZ)
                tes3mp.SetObjectRotation(rotX, rotY, rotZ)
                tes3mp.AddWorldObject()

                objectIndex = objectIndex + 1
            end
        end
    end

    if objectIndex > 0 then
        tes3mp.SendObjectPlace()
    end
end

function BaseCell:SendObjectsScaled(pid)

    -- Keep this around to update everyone to the new BaseCell file format
    -- instead of crashing the server
    if self.data.objectsScaled == nil then
        self.data.objectsScaled = {}
    end

    -- RefId, scale
    local objectScaledPattern = "(.+), (%d+)"

    local objectIndex = 0

    tes3mp.CreateWorldEvent(pid)
    tes3mp.SetWorldEventCell(self.description)

    for refNum, value in pairs(self.data.objectsScaled) do
        if string.match(value, objectScaledPattern) ~= nil then
            for refId, scale in string.gmatch(value, objectScaledPattern) do
                
                tes3mp.SetObjectRefId(refId)
                tes3mp.SetObjectRefNumIndex(refNum)
                tes3mp.SetObjectScale(scale)
                tes3mp.AddWorldObject()

                objectIndex = objectIndex + 1
            end
        end
    end

    if objectIndex > 0 then
        tes3mp.SendObjectScale()
    end
end

function BaseCell:SendCellData(pid)
    
    self:SendObjectsDeleted(pid)
    self:SendObjectsPlaced(pid)
    self:SendObjectsScaled(pid)
end

return BaseCell
