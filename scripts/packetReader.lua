packetReader = {}

packetReader.GetActorPacketTables = function(packetType)
    
    local packetTables = { actors = {} }
    local actorListSize = tes3mp.GetActorListSize()

    if actorListSize == 0 then return packetTables end

    for packetIndex = 0, actorListSize - 1 do
        local actor = {}
        local uniqueIndex = tes3mp.GetActorRefNum(packetIndex) .. "-" .. tes3mp.GetActorMpNum(packetIndex)
        actor.uniqueIndex = uniqueIndex

        -- Only non-repetitive actor packets contain refId information
        if tableHelper.containsValue({"list", "death"}, packetType) then
            actor.refId = tes3mp.GetActorRefId(packetIndex)
        end

        if packetType == "equipment" then

            actor.equipment = {}
            local equipmentSize = tes3mp.GetEquipmentSize()

            for itemIndex = 0, equipmentSize - 1 do
                local itemRefId = tes3mp.GetActorEquipmentItemRefId(packetIndex, itemIndex)

                if itemRefId ~= "" then
                    actor.equipment[itemIndex] = {
                        refId = itemRefId,
                        count = tes3mp.GetActorEquipmentItemCount(packetIndex, itemIndex),
                        charge = tes3mp.GetActorEquipmentItemCharge(packetIndex, itemIndex),
                        enchantmentCharge = tes3mp.GetActorEquipmentItemEnchantmentCharge(packetIndex, itemIndex)
                    }
                end
            end
        elseif packetType == "death" then

            actor.deathState = tes3mp.GetActorDeathState(packetIndex)
            local doesActorHavePlayerKiller = tes3mp.DoesActorHavePlayerKiller(packetIndex)

            if doesActorHavePlayerKiller then
                actor.killerPid = tes3mp.GetActorKillerPid(packetIndex)
            else
                actor.killerRefId = tes3mp.GetActorKillerRefId(packetIndex)
                actor.killerName = tes3mp.GetActorKillerName(packetIndex)
                actor.killerUniqueIndex = tes3mp.GetActorKillerRefNum(packetIndex) ..
                    "-" .. tes3mp.GetActorKillerMpNum(packetIndex)
            end
        end

        packetTables.actors[uniqueIndex] = actor
    end

    return packetTables
end

packetReader.GetObjectPacketTables = function(packetType)

    local packetTables = { objects = {}, players = {} }
    local objectListSize = tes3mp.GetObjectListSize()

    if objectListSize == 0 then return packetTables end

    for packetIndex = 0, objectListSize - 1 do
        local object, uniqueIndex, player, pid = nil, nil, nil, nil
        
        if tableHelper.containsValue({"activate", "consoleCommand"}, packetType) then

            local isObjectPlayer = tes3mp.IsObjectPlayer(packetIndex)

            if isObjectPlayer then
                pid = tes3mp.GetObjectPid(packetIndex)
                player = Players[pid]
            else
                object = {}
                uniqueIndex = tes3mp.GetObjectRefNum(packetIndex) .. "-" .. tes3mp.GetObjectMpNum(packetIndex)
                object.refId = tes3mp.GetObjectRefId(packetIndex)
                object.uniqueIndex = uniqueIndex
            end

            if packetType == "activate" then

                local doesObjectHaveActivatingPlayer = tes3mp.DoesObjectHavePlayerActivating(packetIndex)

                if doesObjectHaveActivatingPlayer then
                    local activatingPid = tes3mp.GetObjectActivatingPid(packetIndex)

                    if isObjectPlayer then
                        player.activatingPid = activatingPid
                        player.drawState = tes3mp.GetDrawState(activatingPid) -- for backwards compatibility
                    else
                        object.activatingPid = activatingPid
                    end
                else
                    object.activatingRefId = tes3mp.GetObjectActivatingRefId(packetIndex)
                    object.activatingUniqueIndex = tes3mp.GetObjectActivatingRefNum(packetIndex) ..
                        "-" .. tes3mp.GetObjectActivatingMpNum(packetIndex)
                end
            end
        else
            object = {}
            uniqueIndex = tes3mp.GetObjectRefNum(packetIndex) .. "-" .. tes3mp.GetObjectMpNum(packetIndex)
            object.refId = tes3mp.GetObjectRefId(packetIndex)
            object.uniqueIndex = uniqueIndex

            if tableHelper.containsValue({"place", "spawn"}, packetType) then
                
                object.location = {
                    posX = tes3mp.GetObjectPosX(packetIndex), posY = tes3mp.GetObjectPosY(packetIndex),
                    posZ = tes3mp.GetObjectPosZ(packetIndex), rotX = tes3mp.GetObjectRotX(packetIndex),
                    rotY = tes3mp.GetObjectRotY(packetIndex), rotZ = tes3mp.GetObjectRotZ(packetIndex)
                }

                if packetType == "place" then
                    object.count = tes3mp.GetObjectCount(packetIndex)
                    object.charge = tes3mp.GetObjectCharge(packetIndex)
                    object.enchantmentCharge = tes3mp.GetObjectEnchantmentCharge(packetIndex)
                    object.soul = tes3mp.GetObjectSoul(packetIndex)
                    object.goldValue = tes3mp.GetObjectGoldValue(packetIndex)
                    object.hasContainer = tes3mp.DoesObjectHaveContainer(packetIndex)
                elseif packetType == "spawn" then
                    local summonState = tes3mp.GetObjectSummonState(packetIndex)

                    if summonState == true then
                        object.summon = {}
                        object.summon.effectId = tes3mp.GetObjectSummonEffectId(packetIndex)
                        object.summon.spellId = tes3mp.GetObjectSummonSpellId(packetIndex)
                        object.summon.duration = tes3mp.GetObjectSummonDuration(packetIndex)
                        object.summon.startTime = os.time()
                        object.hasPlayerSummoner = tes3mp.DoesObjectHavePlayerSummoner(packetIndex)

                        if object.hasPlayerSummoner == true then
                            local summonerPid = tes3mp.GetObjectSummonerPid(packetIndex)
                            object.summon.summonerPid = summonerPid

                            if Players[summonerPid] ~= nil then
                                object.summon.summonerPlayer = Players[summonerPid].accountName
                            end
                        else
                            object.summon.summonerUniqueIndex = tes3mp.GetObjectSummonerRefNum(packetIndex) ..
                                "-" .. tes3mp.GetObjectSummonerMpNum(packetIndex)
                            object.summon.summonerRefId = tes3mp.GetObjectSummonerRefId(packetIndex)
                        end
                    end
                end

            elseif packetType == "lock" then
                object.lockLevel = tes3mp.GetObjectLockLevel(packetIndex)
            elseif packetType == "scale" then
                object.scale = tes3mp.GetObjectScale(packetIndex)
            elseif packetType == "state" then
                object.state = tes3mp.GetObjectState(packetIndex)
            elseif packetType == "doorState" then
                object.doorState = tes3mp.GetObjectDoorState(packetIndex)
            end
        end

        if object ~= nil then
            packetTables.objects[uniqueIndex] = object
        elseif player ~= nil then
            packetTables.players[pid] = player
        end
    end

    return packetTables
end

packetReader.GetRecordEffects = function(recordIndex)

    local effectArray = {}
    local effectCount = tes3mp.GetRecordEffectCount(recordIndex)

    for effectIndex = 0, effectCount - 1 do

        local effect = {
            id = tes3mp.GetRecordEffectId(recordIndex, effectIndex),
            attribute = tes3mp.GetRecordEffectAttribute(recordIndex, effectIndex),
            skill = tes3mp.GetRecordEffectSkill(recordIndex, effectIndex),
            rangeType = tes3mp.GetRecordEffectRangeType(recordIndex, effectIndex),
            area = tes3mp.GetRecordEffectArea(recordIndex, effectIndex),
            duration = tes3mp.GetRecordEffectDuration(recordIndex, effectIndex),
            magnitudeMin = tes3mp.GetRecordEffectMagnitudeMin(recordIndex, effectIndex),
            magnitudeMax = tes3mp.GetRecordEffectMagnitudeMax(recordIndex, effectIndex)
        }

        table.insert(effectArray, effect)
    end

    return effectArray
end

return packetReader
