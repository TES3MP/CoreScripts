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

        -- Send information about this cell to the visitor
        self:SendCellData(pid)
    end
end

function BaseCell:RemoveVisitor(pid)

    table.removeValue(self.visitors, pid)
end

function BaseCell:SaveObjectPlaced(refId, refNum)

    self.data.objectsPlaced[refNum] = refId
end

function BaseCell:SaveObjectDeleted(refId, refNum)

    self.data.objectsDeleted[refNum] = refId
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
