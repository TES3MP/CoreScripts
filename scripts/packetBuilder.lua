packetBuilder = {}

packetBuilder.AddAIActorToPacket = function(actorUniqueIndex, action, targetPid, targetUniqueIndex,
    posX, posY, posZ, distance, duration, shouldRepeat)

    local splitIndex = actorUniqueIndex:split("-")
    tes3mp.SetActorRefNum(splitIndex[1])
    tes3mp.SetActorMpNum(splitIndex[2])

    tes3mp.SetActorAIAction(action)

    if targetPid ~= nil then
        tes3mp.SetActorAITargetToPlayer(targetPid)
    elseif targetUniqueIndex ~= nil then
        local targetSplitIndex = targetUniqueIndex:split("-")

        if targetSplitIndex[2] ~= nil then
            tes3mp.SetActorAITargetToObject(targetSplitIndex[1], targetSplitIndex[2])
        end
    elseif posX ~= nil and posY ~= nil and posZ ~= nil then
        tes3mp.SetActorAICoordinates(posX, posY, posZ)
    elseif distance ~= nil then
        tes3mp.SetActorAIDistance(distance)
    elseif duration ~= nil then
        tes3mp.SetActorAIDuration(duration)
    end

    tes3mp.SetActorAIRepetition(shouldRepeat)

    tes3mp.AddActor()
end

return packetBuilder
