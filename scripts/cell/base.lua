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
    end
end

function BaseCell:RemoveVisitor(pid)

    table.removeValue(self.visitors, pid)
end

function BaseCell:PlaceObject(refId, refNum)

    self.data.objectsPlaced[refNum] = refId
end

function BaseCell:DeleteObject(refId, refNum)

    self.data.objectsDeleted[refNum] = refId
end

function BaseCell:SaveLastVisit(playerName)

    self.data.lastVisitTimestamps[playerName] = os.time()
end

return BaseCell
