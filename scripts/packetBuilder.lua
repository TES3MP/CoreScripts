packetBuilder = {}

packetBuilder.AddAIActorToPacket = function(actorUniqueIndex, targetPid, aiData)

    local splitIndex = actorUniqueIndex:split("-")
    tes3mp.SetActorRefNum(splitIndex[1])
    tes3mp.SetActorMpNum(splitIndex[2])

    tes3mp.SetActorAIAction(aiData.action)

    if targetPid ~= nil then
        tes3mp.SetActorAITargetToPlayer(targetPid)
    elseif aiData.targetUniqueIndex ~= nil then
        local targetSplitIndex = aiData.targetUniqueIndex:split("-")

        if targetSplitIndex[2] ~= nil then
            tes3mp.SetActorAITargetToObject(targetSplitIndex[1], targetSplitIndex[2])
        end
    elseif aiData.posX ~= nil and aiData.posY ~= nil and aiData.posZ ~= nil then
        tes3mp.SetActorAICoordinates(aiData.posX, aiData.posY, aiData.posZ)
    elseif aiData.distance ~= nil then
        tes3mp.SetActorAIDistance(aiData.distance)
    elseif aiData.duration ~= nil then
        tes3mp.SetActorAIDuration(aiData.duration)
    end

    tes3mp.SetActorAIRepetition(aiData.shouldRepeat)

    tes3mp.AddActor()
end

return packetBuilder
