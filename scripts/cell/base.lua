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

        -- Send information about this cell to the visitor, but only
        -- if they haven't visited since last connecting to the server
        if Players[pid].initTimestamp > self.data.lastVisitTimestamps[Players[pid].accountName] then

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

    for i = 0, tes3mp.GetObjectChangesSize() - 1 do

        refNumIndex = tes3mp.GetObjectRefNumIndex(i)
        self.data.objectsPlaced[refNumIndex] = tes3mp.GetObjectRefId(i)
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

function BaseCell:SendCellData(pid)
    
    local objectIndex = 0

    tes3mp.CreateWorldEvent(pid)
    tes3mp.SetWorldEventCell(self.description)

    -- Objects deleted
    for refNum, value in pairs(self.data.objectsDeleted) do

        tes3mp.AddWorldObject()
        tes3mp.SetObjectRefId(objectIndex, value)
        tes3mp.SetObjectRefNumIndex(objectIndex, refNum)

        objectIndex = objectIndex + 1
    end

    if objectIndex > 0 then
        tes3mp.SendObjectDelete()
    end
end

return BaseCell
