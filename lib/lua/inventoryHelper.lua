local inventoryHelper = {}

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

function inventoryHelper.addItem(inventory, inputRefId, inputCount, inputCharge, inputEnchantmentCharge)

    if inventoryHelper.containsItem(inventory, inputRefId, inputCharge, inputEnchantmentCharge) then
        local index = inventoryHelper.getItemIndex(inventory, inputRefId, inputCharge, inputEnchantmentCharge)
        inventory[index].count = inventory[index].count + inputCount
    else
        local item = {
            refId = inputRefId,
            count = inputCount,
            charge = inputCharge,
            enchantmentCharge = inputEnchantmentCharge
        }
        table.insert(inventory, item)
    end
end

return inventoryHelper
