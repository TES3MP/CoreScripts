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

    self.data.charge = {}
    self.data.count = {}
    self.data.goldValue = {}
    self.data.position = {}
    self.data.rotation = {}
    self.data.scale = {}
    self.data.lockLevel = {}
    self.data.state = {}

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

            self.data.charge[refNum] = nil
            self.data.count[refNum] = nil
            self.data.goldValue[refNum] = nil
            self.data.position[refNum] = nil
            self.data.rotation[refNum] = nil
            self.data.scale[refNum] = nil
            self.data.lockLevel[refNum] = nil
            self.data.state[refNum] = nil
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

        local charge = tes3mp.GetObjectCharge(i)
        local count = tes3mp.GetObjectCount(i)
        local goldValue = tes3mp.GetObjectGoldValue(i)
        
        -- Only save charge if it isn't the default value of -1
        if charge ~= -1 then
            self.data.charge[refNum] = charge
        end

        -- Only save count if it isn't the default value of 1
        if count ~= 1 then
            self.data.count[refNum] = count
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
        self.data.state[refNum] = tes3mp.GetObjectState(i)
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

        local charge = self.data.charge[refNum]
        local count = self.data.count[refNum]
        local goldValue = self.data.goldValue[refNum]

        -- Use default charge of -1 when the value is missing
        if charge == nil then
            charge = -1
        end

        -- Use default count of 1 when the value is missing
        if count == nil then
            count = 1
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
        tes3mp.SetObjectState(self.data.state[refNum])
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

function BaseCell:UpdateStructure()

    -- This data file has the original cell data experiment structure
    if self.data.general.version == nil then

        self.data.refIdDelete = {}
        self.data.refIdPlace = {}
        self.data.refIdScale = {}
        self.data.refIdLock = {}
        self.data.refIdUnlock = {}
        self.data.refIdDoorState = {}

        self.data.charge = {}
        self.data.count = {}
        self.data.goldValue = {}
        self.data.position = {}
        self.data.rotation = {}
        self.data.scale = {}
        self.data.lockLevel = {}
        self.data.state = {}

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
                    for refId, state in string.gmatch(value, doorStatePattern) do
                        
                        self.data.refIdDoorState[refNum] = refId
                        self.data.state[refNum] = state
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
