local inventoryHelper = {}

function inventoryHelper.containsItem(inventory, refId, charge, enchantmentCharge, soul)

    if charge ~= nil then charge = math.floor(charge) end
    if enchantmentCharge ~= nil then enchantmentCharge = math.floor(enchantmentCharge) end

    for itemIndex, item in pairs(inventory) do
        if item.refId == refId then

            local isValid = true

            if soul ~= nil and item.soul ~= soul then
                isValid = false
            elseif charge ~= nil and math.floor(item.charge) ~= charge then
                isValid = false
            elseif enchantmentCharge ~= nil and math.floor(item.enchantmentCharge) ~= enchantmentCharge then
                isValid = false
            end

            if isValid then
                return true
            end
        end
    end

    return false
end

-- Gets the index of an item in the inventory. Will not get the index of an inventory item that has an equipment index,
-- as that should be considered to be "equipment" for the purposes of altering an item's charges or condition
function inventoryHelper.getItemIndex(inventory, refId, charge, enchantmentCharge, soul, equipmentIndex)

    -- short circuit: if equipmentIndex is not nil, then all we need to do is search for the itemIndex
    -- whose equipmentIndex matches. If this is false, then move on and make sure not to return an item
    -- whose equipmentIndex is non-nil later on in the function.
    if equipmentIndex ~= nil then return getItemIndexByEquipmentIndex(inventory, equipmentIndex) end

    -- if we don't have an equipmentIndex, then we need to do it the old-fashioned way
    if charge ~= nil then charge = math.floor(charge) end
    if enchantmentCharge ~= nil then enchantmentCharge = math.floor(enchantmentCharge) end

    for itemIndex, item in pairs(inventory) do
        if item.refId == refId then

            local isValid = true

            if item.equipmentIndex ~= nil then -- by this point we know we're not looking for an equipment item
                isValid = false
            elseif soul ~= nil and item.soul ~= soul then
                isValid = false
            elseif charge ~= nil and math.floor(item.charge) ~= charge then
                isValid = false
            elseif enchantmentCharge ~= nil and math.floor(item.enchantmentCharge) ~= enchantmentCharge then
                isValid = false
            end

            if isValid then
                return itemIndex
            end
        end
    end

    return nil
end

-- Gets the index of the inventory item with the given equipmentIndex, or nil if no
-- inventory item has the given equipmentIndex
function inventoryHelper.getItemIndexByEquipmentIndex(inventory, equipmentIndex)

    for itemIndex, item in pairs(inventory) do
        if item.equipmentIndex == equipmentIndex then
            return itemIndex
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

-- Adds an item to the given inventory. The new item will not stack with an existing instance of the same exact item if
-- the existing item is equipped, it will instead stack with non-equipped entries of that item 
function inventoryHelper.addItem(inventory, refId, count, charge, enchantmentCharge, soul)

    local index = inventoryHelper.getItemIndex(inventory, refId, charge, enchantmentCharge, soul)

    if index ~= nil then
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

-- Sets a flag on an item in the inventory that indicates it is supposed to be in the player's equipment
-- table. This flag exists to map inventory items to their equivalent equipment table entries.
function inventoryHelper.setItemToEquipped(inventory, refId, count, charge, enchantmentCharge, equipIndex)

    -- If we're equipping an item, then it must exist in the inventory. If it does not exist in the inventory,
    -- then we want to do nothing so as not to compromise the inventory. This case occurs with lockpicks and
    -- probes reducing their charge (but not the last charge) because the inventory updates are handled elsewhere.
    if inventoryHelper.containsItem(inventory, refId, charge, enchantmentCharge, nil) then
        local index = inventoryHelper.getItemIndex(inventory, refId, charge, enchantmentCharge, nil)

        -- If there are multiple copies of the same exact item, we want to introduce a different, distinct copy of
        -- this item that has the equipmentIndex value set. To that end, we will remove one count of the equipped
        -- item from inventory and re-add it with equipmentIndex. Here we construct that copy, with equipmentIndex.
        local item = {}
        item.refId = inventory[index].refId
        item.count = count
        item.charge = inventory[index].charge
        item.enchantmentCharge = inventory[index].enchantmentCharge
        item.soul = inventory[index].soul
        item.equipmentIndex = equipIndex

        if inventory[index].count == count then
            -- remove the existing instance, it will be replaced
            table.remove(inventory, index)
        else
            -- reduce existing instance by one, that one will be added back in next
            inventory[index].count = inventory[index].count - count
        end

        -- We always want to add equipped items to the front of the inventory, so that on server
        -- start, they're always the first ones equipped. This is to address a bug where players on
        -- connect are equipped with the first item in their inventory of a given refId instead of
        -- being equipped with the item that most closely matches their current inventory.
        table.insert(inventory, count, item)
    end
end

function inventoryHelper.setItemToUnequipped(inventory, refId, charge, enchantmentCharge)

    local index = nil

    -- find the inventory index with an equipmentIndex and which matches the given refId
    for itemIndex, item in pairs(inventory) do
        if item.refId == refId and item.equipmentIndex ~= nil then
            index = itemIndex
            break
        end
    end

    -- if we got an index, then that's the index of the inventory item to unequip
    if index ~= nil then
        -- save soul and count, we'll need them in a moment
        local itemSoul = inventory[index].soul
        local itemCount = inventory[index].count

        -- first, remove the item with the equipmentIndex value from the inventory
        inventory[index] = nil

        -- next, add it back in, but without the equipmentIndex tag
        inventoryHelper.addItem(inventory, refId, itemCount, charge, enchantmentCharge, itemSoul)
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

    -- A difference in souls also instantly resolves the comparison
    if idealItem.soul ~= nil and not comparedItem.soul:ciEqual(otherItem.soul) then
        if idealItem.soul:ciEqual(comparedItem.soul) then
            return true
        elseif idealItem.soul:ciEqual(otherItem.soul) then
            return false
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

-- Removes the items in the inventory that most closely match the given parameters. If an entry in the inventory
-- is removed and it had an equipmentIndex, the removed equipmentIndex is returned.
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
        local equipmentIndex = nil

        for closenessRanking, currentItemIndex in ipairs(itemIndexesByCloseness) do

            if remainingCount > 0 then
                local currentItem = inventory[currentItemIndex]

                currentItem.count = currentItem.count - remainingCount

                if currentItem.count < 1 then
                    -- If there is an equipmentIndex, we want to record it so we can return it
                    if currentItem.equipmentIndex ~= nil then
                        equipmentIndex = currentItem.equipmentIndex
                    end
                
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

        return equipmentIndex
    end
end

-- Deprecated
function inventoryHelper.removeItem(inventory, refId, count, charge, enchantmentCharge, soul)
    return inventoryHelper.removeClosestItem(inventory, refId, count, charge, enchantmentCharge, soul)
end

return inventoryHelper