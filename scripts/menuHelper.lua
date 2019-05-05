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

function menuHelper.conditions.requireStaffRank(inputValue)
    local condition = {
        conditionType = "staffRank",
        rankValue = inputValue
    }

    return condition
end

function menuHelper.conditions.requirePlayerFunction(inputFunctionName, inputArguments)
    local condition = {
        conditionType = "playerFunction",
        functionName = inputFunctionName,
        arguments = inputArguments
    }

    return condition
end

-- Deprecated
function menuHelper.conditions.requireAdminRank(inputValue)
    return menuHelper.conditions.requireStaffRank(inputValue)
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

function menuHelper.variables.currentChatName()
    local variable = {
        variableType = "chatName",
        source = "current"
    }

    return variable
end

function menuHelper.variables.currentPlayerVariable(inputVariableName)
    local variable = {
        variableType = "playerVariable",
        source = "current",
        variableName = inputVariableName
    }

    return variable
end

-- Deprecated
function menuHelper.variables.currentPlayerDataVariable(inputVariableName)
    return menuHelper.variables.currentPlayerVariable("data." .. inputVariableName)
end

function menuHelper.variables.globalVariable(inputObjectName, inputVariableName)
    local variable = {
        variableType = "globalVariable",
        objectName = inputObjectName,
        variableName = inputVariableName
    }

    return variable
end

function menuHelper.variables.concatenation(inputDelimiter, ...)
    local variable = {
        variableType = "argumentArray",
        operation = "concatenation",
        delimiter = inputDelimiter,
        containedVariables = {...}
    }

    return variable
end

function menuHelper.CheckCondition(pid, condition)

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

        if targetPlayer.data.attributes[condition.attributeName].base >= condition.attributeValue then
            return true
        end
    elseif condition.conditionType == "skill" then

        if targetPlayer.data.skills[condition.skillName].base >= condition.skillValue then
            return true
        end
    elseif condition.conditionType == "staffRank" then

        if targetPlayer.data.settings.staffRank >= condition.rankValue then
            return true
        end
    elseif condition.conditionType == "playerFunction" then

        local functionName = condition.functionName
        local arguments = condition.arguments

        if arguments == nil then
            arguments = {}
        -- Fill in any variables placed inside the arguments
        else
            arguments = menuHelper.ProcessVariables(pid, arguments)
        end

        if targetPlayer[functionName](targetPlayer, unpack(arguments)) then
            return true
        end
    end

    return false
end

function menuHelper.CheckConditionTable(pid, conditions)

    local conditionCount = table.maxn(conditions)
    local conditionsMet = 0

    for _, condition in ipairs(conditions) do

        if menuHelper.CheckCondition(pid, condition) then
            conditionsMet = conditionsMet + 1
        end
    end

    if conditionsMet == conditionCount then
        return true
    end

    return false
end

function menuHelper.ProcessVariables(pid, inputTable)

    local resultTable = {}

    for tableIndex, tableElement in ipairs(inputTable) do

        local resultValue = "nil"

        if type(tableElement) == "table" and tableElement.variableType ~= nil then

            local variableType = tableElement.variableType
            local subType = tableElement.subType
            local source = tableElement.source

            if variableType == "pid" then
                if source == "current" then
                    resultValue = pid
                end
            elseif variableType == "chatName" then
                if source == "current" then
                    resultValue = logicHandler.GetChatName(pid)
                end
            elseif variableType == "playerVariable" or variableType == "globalVariable" then

                local variableName = tableElement.variableName

                if variableType == "playerVariable" and source == "current" then
                    resultValue = Players[pid]
                elseif variableType == "globalVariable" then
                    local objectName = tableElement.objectName

                    if objectName ~= nil then
                        resultValue = _G[objectName]
                    else
                        resultValue = _G
                    end
                end

                if type(resultValue) == "table" then
                    -- Allow for nested variables (such as character.race or location.cell)
                    -- by iterating through every value separated by a period
                    for nestedName in string.gmatch(variableName, patterns.periodSplit) do
                        if type(resultValue[nestedName]) ~= "nil" then
                            resultValue = resultValue[nestedName]
                        else
                            resultValue = "nil"
                            break
                        end
                    end
                end
            elseif variableType == "argumentArray" then
                local operation = tableElement.operation
                local delimiter = tableElement.delimiter

                local processedVariables = menuHelper.ProcessVariables(pid, tableElement.containedVariables)

                if operation == "concatenation" then
                    resultValue = tableHelper.concatenateArrayValues(processedVariables, 1, delimiter)
                end
            end
        else
            resultValue = tostring(tableElement)
        end

        table.insert(resultTable, resultValue)
    end

    return resultTable
end

function menuHelper.ProcessEffects(pid, effects)

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

                        if item.count < 1 then
                            remainingCount = 0 - item.count
                            item = nil
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
                arguments = menuHelper.ProcessVariables(pid, arguments)
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

    targetPlayer:QuicksaveToDrive()

    if shouldReloadInventory then
        targetPlayer:LoadInventory()
        targetPlayer:LoadEquipment()
    end
end

function menuHelper.GetButtonDestination(pid, buttonPressed)

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
                    local conditionsMet = menuHelper.CheckConditionTable(pid, destination.conditions)

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

function menuHelper.GetDisplayedButtons(pid, menuIndex)

    if menuIndex == nil or Menus[menuIndex] == nil then return end
    local displayedButtons = {}

    for buttonIndex, button in ipairs(Menus[menuIndex].buttons) do

        -- Only display this button if there are no conditions for displaying it, or if
        -- the conditions for displaying it are met
        local conditionsMet = true

        if button.displayConditions ~= nil then
            conditionsMet = menuHelper.CheckConditionTable(pid, button.displayConditions)
        end

        if conditionsMet then
            table.insert(displayedButtons, button)
        end
    end

    return displayedButtons
end

function menuHelper.DisplayMenu(pid, menuIndex)

    if menuIndex == nil or Menus[menuIndex] == nil then return end

    local text = Menus[menuIndex].text

    -- Is this a table? If so, process the variables in it and then concatenate them
    if text == nil then
        text = ""
    elseif type(text) == "table" then
        local processedTextVariables = menuHelper.ProcessVariables(pid, text)
        text = tableHelper.concatenateArrayValues(processedTextVariables, 1, "")
    end

    local displayedButtons = menuHelper.GetDisplayedButtons(pid, menuIndex)
    local buttonCount = tableHelper.getCount(displayedButtons)
    local buttonList = ""

    for buttonIndex, button in ipairs(displayedButtons) do

        local caption = button.caption

        -- Handle button captions the same way as menu text
        if type(caption) == "table" then
            local processedTextVariables = menuHelper.ProcessVariables(pid, caption)
            caption = tableHelper.concatenateArrayValues(processedTextVariables, 1, "")
        end

        buttonList = buttonList .. caption

        if buttonIndex < buttonCount then
            buttonList = buttonList .. ";"
        end
    end

    Players[pid].displayedMenuButtons = displayedButtons

    tes3mp.CustomMessageBox(pid, config.customMenuIds.menuHelper, text, buttonList)
end

return menuHelper
