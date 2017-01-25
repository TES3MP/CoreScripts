require('utils')
local BaseCell = class("BaseCell")

function BaseCell:__init(cellName)

    self.data.objectsPlaced = {}
    self.data.objectsDeleted = {}
end

return BaseCell
