dataTableBuilder = {}

dataTableBuilder.BuildAIData = function(targetPid, targetUniqueIndex, action,
    posX, posY, posZ, distance, duration, shouldRepeat)

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
dataTableBuilder.BuildObjectData = function(refId, count, charge, enchantmentCharge, soul)

    local objectData = {}
    objectData.refId = refId
    objectData.count = count or 1
    objectData.charge = charge or -1
    objectData.enchantmentCharge = enchantmentCharge or -1
    objectData.soul = soul or ""

    return objectData
end

return dataTableBuilder
