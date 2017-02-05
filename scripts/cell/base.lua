require('utils')
local BaseCell = class("BaseCell")

function BaseCell:__init(cellDescription)

    self.data = {}
    self.data.general = {}
    self.data.general.description = cellDescription

    self.data.refIdDelete = {}
    self.data.refIdPlace = {}
    self.data.refIdScale = {}
    self.data.refIdLock = {}
    self.data.refIdUnlock = {}
    self.data.refIdDoorState = {}

    self.data.count = {}
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

function BaseCell:SaveObjectsDeleted()

    local refNum

    for i = 0, tes3mp.GetObjectChangesSize() - 1 do

        refNum = tes3mp.GetObjectRefNumIndex(i)

        -- If this is an object that did not originally exist in the cell,
        -- remove it from refIdPlace and all other tables
        if self.data.refIdPlace[refNum] ~= nil then
            self.data.refIdPlace[refNum] = nil
            self.data.refIdScale[refNum] = nil
            self.data.refIdLock[refNum] = nil
            self.data.refIdUnlock[refNum] = nil
            self.data.refIdDoorState[refNum] = nil

            self.data.count[refNum] = nil
            self.data.goldValue[refNum] = nil
            self.data.position[refNum] = nil
            self.data.rotation[refNum] = nil
            self.data.scale[refNum] = nil
            self.data.lockLevel[refNum] = nil
            self.data.doorState[refNum] = nil
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
        self.data.count[refNum] = tes3mp.GetObjectCount(i)
        self.data.goldValue[refNum] = tes3mp.GetObjectGoldValue(i)
        
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
        self.data.doorState[refNum] = tes3mp.GetObjectState(i)
    end
end

function BaseCell:SaveLastVisit(playerName)

    self.data.lastVisit[playerName] = os.time()
end

function BaseCell:SendObjectsDeleted(pid)

    local objectIndex = 0

    tes3mp.CreateWorldEvent(pid)
    tes3mp.SetWorldEventCell(self.description)

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

    tes3mp.CreateWorldEvent(pid)
    tes3mp.SetWorldEventCell(self.description)

    for refNum, refId in pairs(self.data.refIdPlace) do

        tes3mp.SetObjectRefNumIndex(refNum)
        tes3mp.SetObjectRefId(refId)
        tes3mp.SetObjectCount(self.data.count[refNum])
        tes3mp.SetObjectGoldValue(self.data.goldValue[refNum])

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

    tes3mp.CreateWorldEvent(pid)
    tes3mp.SetWorldEventCell(self.description)

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

    tes3mp.CreateWorldEvent(pid)
    tes3mp.SetWorldEventCell(self.description)

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

    tes3mp.CreateWorldEvent(pid)
    tes3mp.SetWorldEventCell(self.description)

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

    tes3mp.CreateWorldEvent(pid)
    tes3mp.SetWorldEventCell(self.description)

    for refNum, refId in pairs(self.data.refIdDoorState) do
        
        tes3mp.SetObjectRefNumIndex(refNum)
        tes3mp.SetObjectRefId(refId)
        tes3mp.SetObjectState(self.data.doorState[refNum])
        tes3mp.AddWorldObject()

        objectIndex = objectIndex + 1
    end

    if objectIndex > 0 then
        tes3mp.SendDoorState()
    end
end

function BaseCell:SendCellData(pid)
    
    self:SendObjectsDeleted(pid)
    self:SendObjectsPlaced(pid)
    self:SendObjectsScaled(pid)
    self:SendObjectsLocked(pid)
    self:SendObjectsUnlocked(pid)
    self:SendDoorStates(pid)
end

return BaseCell
