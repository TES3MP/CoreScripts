local inventoryHelper = {}

function inventoryHelper.containsItem(inventory, refId, charge, enchantmentCharge, soul)

    if charge ~= nil then charge = math.floor(charge) end
    if enchantmentCharge ~= nil then enchantmentCharge = math.floor(enchantmentCharge) end

    for itemIndex, item in pairs(inventory) do
        if item.refId == refId then

            local isValid = true

            if soul ~= nil and item.soul ~= soul then
                isValid = false
            elseif charge ~= nil and item.charge ~= nil and math.floor(item.charge) ~= charge then
                isValid = false
            elseif enchantmentCharge ~= nil and item.enchantmentCharge ~= nil and 
                math.floor(item.enchantmentCharge) ~= enchantmentCharge then
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

    if charge ~= nil then charge = math.floor(charge) end
    if enchantmentCharge ~= nil then enchantmentCharge = math.floor(enchantmentCharge) end

    for itemIndex, item in pairs(inventory) do
        if item.refId == refId then

            local isValid = true

            if soul ~= nil and item.soul ~= soul then
                isValid = false
            elseif charge ~= nil and item.charge ~= nil and math.floor(item.charge) ~= charge then
                isValid = false
            elseif enchantmentCharge ~= nil and item.enchantmentCharge ~= nil and
                math.floor(item.enchantmentCharge) ~= enchantmentCharge then
                isValid = false
            end

            if isValid then
                return itemIndex
            end
        end
    end

    return nil
end

function inventoryHelper.getItemIndexes(inventory, refId)

    local indexes = {}

    for itemIndex, item in pairs(inventory) do
        if item.refId == refId then
            table.insert(indexes, itemIndex)
        end
    end

    return indexes
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

-- Return true if an item (comparedItem) is closer to a desired item (idealItem) than
-- another item is (otherItem)
function inventoryHelper.compareClosenessToItem(idealItem, comparedItem, otherItem)

    if comparedItem == otherItem then
        return false
    end

    -- A difference in refIds instantly resolves the comparison
    if idealItem.refId ~= nil and not comparedItem.refId:ciEqual(otherItem.refId) then
        if idealItem.refId:ciEqual(comparedItem.refId) then
            return true
        elseif idealItem.refId:ciEqual(otherItem.refId) then
            return false
        end
    end

    if idealItem.soul ~= nil then
        if comparedItem.soul == nil then
            comparedItem.soul = ""
        end

        if otherItem.soul == nil then
            otherItem.soul = ""
        end

        -- A difference in souls also instantly resolves the comparison
        if not comparedItem.soul:ciEqual(otherItem.soul) then
            if idealItem.soul:ciEqual(comparedItem.soul) then
                return true
            elseif idealItem.soul:ciEqual(otherItem.soul) then
                return false
            end
        end
    end

    -- The TES3MP server doesn't yet load up data files, so it doesn't actually know what the
    -- maximum charge and enchantmentCharge are supposed to be for a particular refId
    --
    -- Use some dirty workarounds here to ignore that fact until the sensible and elegant
    -- solution becomes available

    local comparedChargeDiff, otherChargeDiff = 0, 0
    local comparedEnchantmentChargeDiff, otherEnchantmentChargeDiff = 0, 0

    if idealItem.charge ~= nil and comparedItem.charge ~= otherItem.charge then

        if comparedItem.charge == nil then
            comparedItem.charge = -1
        end

        if otherItem.charge == nil then
            otherItem.charge = -1
        end

        local maxValue = math.max(idealItem.charge, comparedItem.charge, otherItem.charge)

        if maxValue < 400 then maxValue = maxValue + 400 end

        local adjustedIdealCharge = idealItem.charge
        local adjustedComparedCharge = comparedItem.charge
        local adjustedOtherCharge = otherItem.charge

        if adjustedIdealCharge == -1 then adjustedIdealCharge = maxValue + maxValue / 2 end
        if adjustedComparedCharge == -1 then adjustedComparedCharge = maxValue + maxValue / 2 end
        if adjustedOtherCharge == -1 then adjustedOtherCharge = maxValue + maxValue / 2 end

        comparedChargeDiff = math.abs(adjustedIdealCharge - adjustedComparedCharge)
        otherChargeDiff = math.abs(adjustedIdealCharge - adjustedOtherCharge)
    end

    if idealItem.enchantmentCharge ~= nil and comparedItem.enchantmentCharge ~= otherItem.enchantmentCharge then

        if comparedItem.enchantmentCharge == nil then
            comparedItem.enchantmentCharge = -1
        end

        if otherItem.enchantmentCharge == nil then
            otherItem.enchantmentCharge = -1
        end

        local maxValue = math.max(idealItem.enchantmentCharge, comparedItem.enchantmentCharge, otherItem.enchantmentCharge)

        if maxValue < 200 then maxValue = maxValue + 200 end

        local adjustedIdealEnchantmentCharge = idealItem.enchantmentCharge
        local adjustedComparedEnchantmentCharge = comparedItem.enchantmentCharge
        local adjustedOtherEnchantmentCharge = otherItem.enchantmentCharge

        if adjustedIdealEnchantmentCharge == -1 then adjustedIdealEnchantmentCharge = maxValue + maxValue / 2 end
        if adjustedComparedEnchantmentCharge == -1 then adjustedComparedEnchantmentCharge = maxValue + maxValue / 2 end
        if adjustedOtherEnchantmentCharge == -1 then adjustedOtherEnchantmentCharge = maxValue + maxValue / 2 end

        comparedEnchantmentChargeDiff = math.abs(adjustedIdealEnchantmentCharge - adjustedComparedEnchantmentCharge)
        otherEnchantmentChargeDiff = math.abs(adjustedIdealEnchantmentCharge - adjustedOtherEnchantmentCharge)
    end

    if comparedChargeDiff + comparedEnchantmentChargeDiff < otherChargeDiff + otherEnchantmentChargeDiff then
        return true
    end

    return false
end

function inventoryHelper.removeClosestItem(inventory, refId, count, charge, enchantmentCharge, soul)

    if inventoryHelper.containsItem(inventory, refId) then
        local itemIndexesToCompare = inventoryHelper.getItemIndexes(inventory, refId)
        local itemIndexesByCloseness = {}
        local idealItem = { refId = refId, charge = charge, enchantmentCharge = enchantmentCharge,
            soul = soul }

        for _, comparedItemIndex in ipairs(itemIndexesToCompare) do

            local comparedItem = inventory[comparedItemIndex]
            local isLeastClose = true

            for closenessRanking, otherItemIndex in ipairs(itemIndexesByCloseness) do
                local otherItem = inventory[otherItemIndex]

                if inventoryHelper.compareClosenessToItem(idealItem, comparedItem, otherItem) then
                    table.insert(itemIndexesByCloseness, closenessRanking, comparedItemIndex)
                    isLeastClose = false
                    break
                end
            end

            if isLeastClose then
                table.insert(itemIndexesByCloseness, comparedItemIndex)
            end
        end

        local remainingCount = count

        for closenessRanking, currentItemIndex in ipairs(itemIndexesByCloseness) do

            if remainingCount > 0 then
                local currentItem = inventory[currentItemIndex]

                currentItem.count = currentItem.count - remainingCount

                if currentItem.count < 1 then
                    remainingCount = 0 - currentItem.count
                    currentItem = nil
                else
                    remainingCount = 0
                end

                inventory[currentItemIndex] = currentItem
            else
                break
            end
        end
    end
end

function inventoryHelper.removeExactItem(inventory, refId, count, charge, enchantmentCharge, soul)

    if inventoryHelper.containsItem(inventory, refId, charge, enchantmentCharge, soul) then
        local index = inventoryHelper.getItemIndex(inventory, refId, charge, enchantmentCharge, soul)

        inventory[index].count = inventory[index].count - count

        if inventory[index].count < 1 then
            inventory[index] = nil
        end
    end
end

-- Deprecated
function inventoryHelper.removeItem(inventory, refId, count, charge, enchantmentCharge, soul)
    return inventoryHelper.removeClosestItem(inventory, refId, count, charge, enchantmentCharge, soul)
end

return inventoryHelper
