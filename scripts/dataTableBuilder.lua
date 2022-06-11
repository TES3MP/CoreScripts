dataTableBuilder = {}

---@param targetPid integer
---@param targetUniqueIndex integer
---@param action integer
---@param posX number
---@param posY number
---@param posZ number
---@param distance number
---@param duration number
---@param shouldRepeat boolean
---@return AIData
dataTableBuilder.BuildAIData = function(targetPid, targetUniqueIndex, action,
    posX, posY, posZ, distance, duration, shouldRepeat)

    ---@type AIData
    local ai = {}
    ai.action = action
    ai.posX, ai.posY, ai.posZ = posX, posY, posZ
    ai.distance = distance
    ai.duration = duration
    ai.shouldRepeat = shouldRepeat

    if targetPid ~= nil then
        ai.targetPlayer = Players[targetPid].accountName
    else
        ai.targetUniqueIndex = targetUniqueIndex
    end

    return ai
end

-- Use with logicHandler.CreateObject() functions
---@param refId integer
---@param count integer
---@param charge integer
---@param enchantmentCharge number
---@param soul string
---@return ObjectData
dataTableBuilder.BuildObjectData = function(refId, count, charge, enchantmentCharge, soul)

    ---@type ObjectData
    local objectData = {}
    objectData.refId = refId
    objectData.count = count or 1
    objectData.charge = charge or -1
    objectData.enchantmentCharge = enchantmentCharge or -1
    objectData.soul = soul or ""

    return objectData
end

return dataTableBuilder
