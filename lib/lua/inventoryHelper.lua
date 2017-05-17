local inventoryHelper = {};

function inventoryHelper.containsItem(inventory, refId, charge)
    for itemIndex, item in pairs(inventory) do
        if item.refId == refId and item.charge == charge then
            return true
        end
    end
    return false
end

function inventoryHelper.getItemIndex(inventory, refId, charge)
    for itemIndex, item in pairs(inventory) do
        if item.refId == refId and item.charge == charge then
            return itemIndex
        end
    end
    return nil
end

return inventoryHelper
