require('utils')
local BaseCell = class("BaseCell")

function BaseCell:__init(cellDescription)

    self.data = {}
    self.data.general = {}
    self.data.general.description = cellDescription
    self.data.objectsPlaced = {}
    self.data.objectsDeleted = {}
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
        self.data.objectsPlaced[refNumIndex] = value
    end
end

function BaseCell:SaveObjectsDeleted()

    local refNumIndex

    for i = 0, tes3mp.GetObjectChangesSize() - 1 do

        refNumIndex = tes3mp.GetObjectRefNumIndex(i)

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

function BaseCell:SaveLastVisit(playerName)

    self.data.lastVisitTimestamps[playerName] = os.time()
end

function BaseCell:SendObjectsDeleted(pid)

    local objectIndex = 0

    tes3mp.CreateWorldEvent(pid)
    tes3mp.SetWorldEventCell(self.description)

    -- Objects deleted
    for refNum, refId in pairs(self.data.objectsDeleted) do

        tes3mp.AddWorldObject()
        tes3mp.SetObjectRefId(objectIndex, refId)
        tes3mp.SetObjectRefNumIndex(objectIndex, refNum)

        objectIndex = objectIndex + 1
    end

    if objectIndex > 0 then
        tes3mp.SendObjectDelete()
    end
end

function BaseCell:SendObjectsPlaced(pid)

    local objectPlacedPattern = "(.+), (%d+), (%d+), (%-?%d+%.%d+), (%-?%d+%.%d+), (%-?%d+%.%d+)$"

    local objectIndex = 0

    tes3mp.CreateWorldEvent(pid)
    tes3mp.SetWorldEventCell(self.description)

    for refNum, value in pairs(self.data.objectsPlaced) do
        if string.match(value, objectPlacedPattern) ~= nil then
            for refId, count, goldValue, posX, posY, posZ in string.gmatch(value, objectPlacedPattern) do
                
                tes3mp.AddWorldObject()
                tes3mp.SetObjectRefId(objectIndex, refId)
                tes3mp.SetObjectRefNumIndex(objectIndex, refNum)
                tes3mp.SetObjectCount(objectIndex, count)
                tes3mp.SetObjectGoldValue(objectIndex, goldValue)
                tes3mp.SetObjectPosition(objectIndex, posX, posY, posZ)
            end
        end

        objectIndex = objectIndex + 1
    end

    if objectIndex > 0 then
        tes3mp.SendObjectPlace()
    end
end

function BaseCell:SendCellData(pid)
    
    self:SendObjectsDeleted(pid)
    self:SendObjectsPlaced(pid)
end

return BaseCell
