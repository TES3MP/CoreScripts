require("config")
inventoryHelper = require("inventoryHelper")

local menuHelper = {}
menuHelper.conditions = {}
menuHelper.effects = {}
menuHelper.destinations = {}
menuHelper.variables = {}

function menuHelper.conditions.requireItem(inputRefIds, inputCount)

    if type(inputRefIds) ~= "table" then
        inputRefIds = { inputRefIds }
    end

    local condition = {
        conditionType = "item",
        refIds = inputRefIds,
        count = inputCount
    }

    return condition
end

function menuHelper.conditions.requireAttribute(inputName, inputValue)
    local condition = {
        conditionType = "attribute",
        attributeName = inputName,
        attributeValue = inputValue
    }

    return condition
end

function menuHelper.conditions.requireSkill(inputName, inputValue)
    local condition = {
        conditionType = "skill",
        skillName = inputName,
        skillValue = inputValue
    }

    return condition
end

function menuHelper.conditions.requireAdminRank(inputValue)
    local condition = {
        conditionType = "adminRank",
        rankValue = inputValue
    }

    return condition
end

function menuHelper.effects.giveItem(inputRefId, inputCount)
    local effect = {
        effectType = "item",
        action = "give",
        refId = inputRefId,
        count = inputCount
    }

    return effect
end

function menuHelper.effects.removeItem(inputRefIds, inputCount)

    if type(inputRefIds) ~= "table" then
        inputRefIds = { inputRefIds }
    end

    local effect = {
        effectType = "item",
        action = "remove",
        refIds = inputRefIds,
        count = inputCount
    }

    return effect
end

function menuHelper.effects.setPlayerDataVariable(inputVariable, inputValue)
    local effect = {
        effectType = "playerVariable",
        action = "data",
        variable = inputVariable,
        value = inputValue
    }

    return effect
end

function menuHelper.effects.runPlayerFunction(inputFunctionName, inputArguments)
    local effect = {
        effectType = "playerFunction",
        functionName = inputFunctionName,
        arguments = inputArguments
    }

    return effect
end

function menuHelper.effects.runGlobalFunction(inputObjectName, inputFunctionName, inputArguments)
    local effect = {
        effectType = "globalFunction",
        objectName = inputObjectName,
        functionName = inputFunctionName,
        arguments = inputArguments
    }

    return effect
end

-- Deprecated
function menuHelper.effects.setDataVariable(inputVariable, inputValue)
    return menuHelper.effects.setPlayerDataVariable(inputVariable, inputValue)
end

-- Deprecated
function menuHelper.effects.runFunction(inputFunctionName, inputArguments)
    return menuHelper.effects.runPlayerFunction(inputFunctionName, inputArguments)
end

function menuHelper.destinations.setDefault(inputMenu, inputEffects)
    local destination = {
        targetMenu = inputMenu,
        effects = inputEffects
    }

    return destination
end

function menuHelper.destinations.setFromCustomVariable(inputVariable)
    local destination = {
        customVariable = inputVariable
    }

    return destination
end

function menuHelper.destinations.setConditional(inputMenu, inputConditions, inputEffects)
    local destination = {
        targetMenu = inputMenu,
        conditions = inputConditions,
        effects = inputEffects
    }

    return destination
end

function menuHelper.variables.currentPid()
    local variable = {
        variableType = "pid",
        source = "current"
    }

    return variable
end

function menuHelper.checkCondition(pid, condition)

    local targetPlayer = Players[pid]

    if condition.conditionType == "item" then

        local remainingCount = condition.count

        for _, currentRefId in ipairs(condition.refIds) do

            if inventoryHelper.containsItem(targetPlayer.data.inventory, currentRefId) then
                local itemIndex = inventoryHelper.getItemIndex(targetPlayer.data.inventory, currentRefId)
                local item = targetPlayer.data.inventory[itemIndex]

                remainingCount = remainingCount - item.count

                if remainingCount < 1 then
                    return true
                end
            end
        end
    elseif condition.conditionType == "attribute" then

        if targetPlayer.data.skills[condition.attributeName] >= condition.attributeValue then
            return true
        end
    elseif condition.conditionType == "skill" then

        if targetPlayer.data.skills[condition.skillName] >= condition.skillValue then
            return true
        end
    elseif condition.conditionType == "adminRank" then

        if targetPlayer.data.settings.admin >= condition.rankValue then
            return true
        end
    end

    return false
end

function menuHelper.checkConditionTable(pid, conditions)

    local conditionCount = table.maxn(conditions)
    local conditionsMet = 0

    for _, condition in ipairs(conditions) do

        if menuHelper.checkCondition(pid, condition) then
            conditionsMet = conditionsMet + 1
        end
    end

    if conditionsMet == conditionCount then
        return true
    end

    return false
end

function menuHelper.processVariables(pid, inputTable)

    local resultTable = {}

    for tableIndex, tableElement in ipairs(inputTable) do

        if type(tableElement) == "table" and tableElement.variableType ~= nil then

            local variableType = tableElement.variableType
            local source = tableElement.source

            if variableType == "pid" then
                if source == "current" then
                    tableElement = pid
                end
            end
        end

        table.insert(resultTable, tableElement)
    end

    return resultTable
end

function menuHelper.processEffects(pid, effects)

    if effects == nil then return end

    local targetPlayer = Players[pid]
    local shouldReloadInventory = false

    for _, effect in ipairs(effects) do

        local effectType = effect.effectType

        if effectType == "item" then

            shouldReloadInventory = true

            if effect.action == "give" then

                inventoryHelper.addItem(targetPlayer.data.inventory, effect.refId, effect.count, -1, -1)

            elseif effect.action == "remove" then

                local remainingCount = effect.count

                for _, currentRefId in ipairs(effect.refIds) do

                    if remainingCount > 0 and inventoryHelper.containsItem(targetPlayer.data.inventory,
                        currentRefId) then

                        -- If the item is equipped by the target, unequip it first
                        if inventoryHelper.containsItem(targetPlayer.data.equipment, currentRefId) then
                            local equipmentItemIndex = inventoryHelper.getItemIndex(targetPlayer.data.equipment,
                                currentRefId)
                            targetPlayer.data.equipment[equipmentItemIndex] = nil
                        end

                        local inventoryItemIndex = inventoryHelper.getItemIndex(targetPlayer.data.inventory,
                            currentRefId)
                        local item = targetPlayer.data.inventory[inventoryItemIndex]
                        item.count = item.count - remainingCount

                        if item.count < 0 then
                            remainingCount = 0 - item.count
                            item.count = 0
                        else
                            remainingCount = 0
                        end

                        targetPlayer.data.inventory[inventoryItemIndex] = item
                    end
                end
            end
        elseif effectType == "playerVariable" then

            if effect.action == "data" then
                targetPlayer.data[effect.variable] = effect.value
            end
        elseif effectType == "playerFunction" or effectType == "globalFunction" then

            local functionName = effect.functionName
            local arguments = effect.arguments

            if arguments == nil then
                arguments = {}
            -- Fill in any variables placed inside the arguments
            else
                arguments = menuHelper.processVariables(pid, arguments)
            end

            if effectType == "playerFunction" then
                targetPlayer[functionName](targetPlayer, unpack(arguments))
            elseif effectType == "globalFunction" then

                local objectName = effect.objectName

                if objectName ~= nil then
                    local targetObject = _G[objectName]

                    -- If this object doesn't have a metatable, don't pass it to itself
                    -- as an argument
                    if getmetatable(targetObject) == nil then
                        targetObject[functionName](unpack(arguments))
                    else
                        targetObject[functionName](targetObject, unpack(arguments))
                    end
                else
                    _G[functionName](unpack(arguments))
                end
            end
        end
    end

    targetPlayer:Save()

    if shouldReloadInventory then
        targetPlayer:LoadInventory()
        targetPlayer:LoadEquipment()
    end
end

function menuHelper.getButtonDestination(pid, buttonPressed)

    if buttonPressed ~= nil then

        local defaultDestination = {}

        if buttonPressed.destinations ~= nil then

            for _, destination in ipairs(buttonPressed.destinations) do

                if destination.customVariable ~= nil then
                    local customVariable = destination.customVariable
                    destination.targetMenu = Players[pid][customVariable]
                end

                if destination.conditions == nil then
                    defaultDestination = destination
                else
                    local conditionsMet = menuHelper.checkConditionTable(pid, destination.conditions)

                    if conditionsMet then
                        return destination
                    end
                end
            end
        end

        return defaultDestination
    end

    return {}
end

function menuHelper.getDisplayedButtons(pid, menuIndex)

    if menuIndex == nil or Menus[menuIndex] == nil then return end
    local displayedButtons = {}

    for buttonIndex, button in ipairs(Menus[menuIndex].buttons) do

        -- Only display this button if there are no conditions for displaying it, or if
        -- the conditions for displaying it are met
        local conditionsMet = true

        if button.displayConditions ~= nil then
            conditionsMet = menuHelper.checkConditionTable(pid, button.displayConditions)
        end

        if conditionsMet then
            table.insert(displayedButtons, button)
        end
    end

    return displayedButtons
end

function menuHelper.displayMenu(pid, menuIndex)

    if menuIndex == nil or Menus[menuIndex] == nil then return end

    local text = Menus[menuIndex].text
    local displayedButtons = menuHelper.getDisplayedButtons(pid, menuIndex)
    local buttonCount = tableHelper.getCount(displayedButtons)
    local buttonList = ""

    for buttonIndex, button in ipairs(displayedButtons) do

        buttonList = buttonList .. button.caption

        if buttonIndex < buttonCount then
            buttonList = buttonList .. ";"
        end
    end

    Players[pid].displayedMenuButtons = displayedButtons

    tes3mp.CustomMessageBox(pid, config.customMenuIds.menuHelper, text, buttonList)
end

return menuHelper
