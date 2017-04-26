local inventoryHelper = {};

function inventoryHelper.containsItem(inventory, refId, charge)
    for itemIndex, item in pairs(inventory) do
        if item.refId == refId and item.charge == charge then
            return true
        end
    end
    return false
end

function inventoryHelper.getItem(inventory, refId, charge)
    for itemIndex, item in pairs(inventory) do
        if item.refId == refId and item.charge == charge then
            return item
        end
    end
    return nil
end

return inventoryHelper
