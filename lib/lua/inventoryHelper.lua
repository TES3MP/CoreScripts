local inventoryHelper = {};

function inventoryHelper.containsItem(inventory, refId, charge, enchantmentCharge)
    for itemIndex, item in pairs(inventory) do
        if item.refId == refId then
            if charge == nil and enchantmentCharge == nil then
                return true
            elseif item.charge == charge then
                if enchantmentCharge == nil then
                    return true
                elseif item.enchantmentCharge == enchantmentCharge then
                    return true
                end
            end
        end
    end
    return false
end

function inventoryHelper.getItemIndex(inventory, refId, charge, enchantmentCharge)
    for itemIndex, item in pairs(inventory) do
        if item.refId == refId then
            if charge == nil and enchantmentCharge == nil then
                return itemIndex
            elseif item.charge == charge then
                if enchantmentCharge == nil then
                    return itemIndex
                elseif item.enchantmentCharge == enchantmentCharge then
                    return itemIndex
                end
            end
        end
    end
    return nil
end

return inventoryHelper
