--- Data table builder
-- @module dataTableBuilder
dataTableBuilder = {}

--- Build AI data
-- @int targetPid target player ID
-- @param targetUniqueIndex
-- @param action
-- @double posX
-- @double posY
-- @double posZ
-- @double distance
-- @param duration
-- @bool shouldRepeat
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

return dataTableBuilder
