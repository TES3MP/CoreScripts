local inventoryHelper = {}

function inventoryHelper.containsItem(inventory, refId, charge, enchantmentCharge, soul)
    for itemIndex, item in pairs(inventory) do
        if item.refId == refId then

            isValid = true

            if charge ~= nil and item.charge ~= charge then
                isValid = false
            elseif enchantmentCharge ~= nil and item.enchantmentCharge ~= enchantmentCharge then
                isValid = false
            elseif soul ~= nil and item.soul ~= soul then
                isValid = false
            end

            if isValid then
                return true
            end
        end
    end
    return false
end

function inventoryHelper.getItemIndex(inventory, refId, charge, enchantmentCharge, soul)
    for itemIndex, item in pairs(inventory) do
        if item.refId == refId then

            isValid = true

            if charge ~= nil and item.charge ~= charge then
                isValid = false
            elseif enchantmentCharge ~= nil and item.enchantmentCharge ~= enchantmentCharge then
                isValid = false
            elseif soul ~= nil and item.soul ~= soul then
                isValid = false
            end

            if isValid then
                return itemIndex
            end
        end
    end
    return nil
end

function inventoryHelper.addItem(inventory, refId, count, charge, enchantmentCharge, soul)

    if inventoryHelper.containsItem(inventory, refId, charge, enchantmentCharge, soul) then
        local index = inventoryHelper.getItemIndex(inventory, refId, charge, enchantmentCharge, soul)

        inventory[index].count = inventory[index].count + count
    else
        local item = {}
        item.refId = refId
        item.count = count
        item.charge = charge
        item.enchantmentCharge = enchantmentCharge
        item.soul = soul

        table.insert(inventory, item)
    end
end

function inventoryHelper.removeItem(inventory, refId, count, charge, enchantmentCharge, soul)

    if inventoryHelper.containsItem(inventory, refId, charge, enchantmentCharge, soul) then
        local index = inventoryHelper.getItemIndex(inventory, refId, charge, enchantmentCharge, soul)

        inventory[index].count = inventory[index].count - count

        if inventory[index].count < 1 then
            inventory[index] = nil
        end

        return inventory[index]
    end

    return nil
end

return inventoryHelper
