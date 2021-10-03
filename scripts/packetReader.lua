packetReader = {}

packetReader.GetPlayerPacketTables = function(pid, packetType)

    local packetTable = {}

    if packetType == "PlayerClass" then
        packetTable.character = {}
        packetTable.character.defaultClassState = tes3mp.IsClassDefault(pid)

        if packetTable.character.defaultClassState == 1 then
            packetTable.character.class = tes3mp.GetDefaultClass(pid)
        else
            packetTable.character.class = "custom"
            packetTable.customClass = {
                name = tes3mp.GetClassName(pid),
                description = tes3mp.GetClassDesc(pid):gsub("\n", "\\n"),
                specialization = tes3mp.GetClassSpecialization(pid)
            }

            local majorAttributes = {}
            local majorSkills = {}
            local minorSkills = {}

            for index = 0, 1, 1 do
                majorAttributes[index + 1] = tes3mp.GetAttributeName(tonumber(tes3mp.GetClassMajorAttribute(pid, index)))
            end

            for index = 0, 4, 1 do
                majorSkills[index + 1] = tes3mp.GetSkillName(tonumber(tes3mp.GetClassMajorSkill(pid, index)))
                minorSkills[index + 1] = tes3mp.GetSkillName(tonumber(tes3mp.GetClassMinorSkill(pid, index)))
            end

            packetTable.customClass.majorAttributes = table.concat(majorAttributes, ", ")
            packetTable.customClass.majorSkills = table.concat(majorSkills, ", ")
            packetTable.customClass.minorSkills = table.concat(minorSkills, ", ")
        end
    elseif packetType == "PlayerStatsDynamic" then
        packetTable.stats = {
            healthBase = tes3mp.GetHealthBase(pid),
            magickaBase = tes3mp.GetMagickaBase(pid),
            fatigueBase = tes3mp.GetFatigueBase(pid),
            healthCurrent = tes3mp.GetHealthCurrent(pid),
            magickaCurrent = tes3mp.GetMagickaCurrent(pid),
            fatigueCurrent = tes3mp.GetFatigueCurrent(pid)
        }
    elseif packetType == "PlayerAttribute" then
        packetTable.attributes = {}

        for attributeIndex = 0, tes3mp.GetAttributeCount() - 1 do
            local attributeName = tes3mp.GetAttributeName(attributeIndex)

            packetTable.attributes[attributeName] = {
                base = tes3mp.GetAttributeBase(pid, attributeIndex),
                damage = tes3mp.GetAttributeDamage(pid, attributeIndex),
                skillIncrease = tes3mp.GetSkillIncrease(pid, attributeIndex),
                modifier = tes3mp.GetAttributeModifier(pid, attributeIndex)
            }
        end
    elseif packetType == "PlayerSkill" then
        packetTable.skills = {}

        for skillIndex = 0, tes3mp.GetSkillCount() - 1 do
            local skillName = tes3mp.GetSkillName(skillIndex)

            packetTable.skills[skillName] = {
                base = tes3mp.GetSkillBase(pid, skillIndex),
                damage = tes3mp.GetSkillDamage(pid, skillIndex),
                progress = tes3mp.GetSkillProgress(pid, skillIndex),
                modifier = tes3mp.GetSkillModifier(pid, skillIndex)
            }
        end
    elseif packetType == "PlayerLevel" then
        packetTable.stats = {
            level = tes3mp.GetLevel(pid),
            levelProgress = tes3mp.GetLevelProgress(pid)
        }
    elseif packetType == "PlayerShapeshift" then
        packetTable.shapeshift = {
            scale = tes3mp.GetScale(pid),
            isWerewolf = tes3mp.IsWerewolf(pid)
        }
    elseif packetType == "PlayerCellChange" then
        packetTable.location = {
            cell = tes3mp.GetCell(pid),
            posX = tes3mp.GetPosX(pid),
            posY = tes3mp.GetPosY(pid),
            posZ = tes3mp.GetPosZ(pid),
            rotX = tes3mp.GetRotX(pid),
            rotZ = tes3mp.GetRotZ(pid)
        }
    elseif packetType == "PlayerEquipment" then
        packetTable.equipment = {}

        for changesIndex = 0, tes3mp.GetEquipmentChangesSize(pid) - 1 do
            local slot = tes3mp.GetEquipmentChangesSlot(pid, changesIndex)

            packetTable.equipment[slot] = {
                refId = tes3mp.GetEquipmentItemRefId(pid, slot),
                count = tes3mp.GetEquipmentItemCount(pid, slot),
                charge = tes3mp.GetEquipmentItemCharge(pid, slot),
                enchantmentCharge = tes3mp.GetEquipmentItemEnchantmentCharge(pid, slot)
            }
        end
    elseif packetType == "PlayerInventory" then
        packetTable.inventory = {}
        packetTable.action = tes3mp.GetInventoryChangesAction(pid)

        for changesIndex = 0, tes3mp.GetInventoryChangesSize(pid) - 1 do
            local item = {
                refId = tes3mp.GetInventoryItemRefId(pid, changesIndex),
                count = tes3mp.GetInventoryItemCount(pid, changesIndex),
                charge = tes3mp.GetInventoryItemCharge(pid, changesIndex),
                enchantmentCharge = tes3mp.GetInventoryItemEnchantmentCharge(pid, changesIndex),
                soul = tes3mp.GetInventoryItemSoul(pid, changesIndex)
            }

            table.insert(packetTable.inventory, item)
        end
    elseif packetType == "PlayerSpellbook" then
        packetTable.spellbook = {}
        packetTable.action = tes3mp.GetSpellbookChangesAction(pid)

        for changesIndex = 0, tes3mp.GetSpellbookChangesSize(pid) - 1 do
            local spellId = tes3mp.GetSpellId(pid, changesIndex)
            table.insert(packetTable.spellbook, spellId)
        end
    elseif packetType == "PlayerSpellsActive" then
        packetTable.spellsActive = {}
        packetTable.action = tes3mp.GetSpellsActiveChangesAction(pid)

        for changesIndex = 0, tes3mp.GetSpellsActiveChangesSize(pid) - 1 do
            local spellId = tes3mp.GetSpellsActiveId(pid, changesIndex)

            if packetTable.spellsActive[spellId] == nil then
                packetTable.spellsActive[spellId] = {}
            end

            local spellInstance = {
                effects = {},
                displayName = tes3mp.GetSpellsActiveDisplayName(pid, changesIndex),
                stackingState = tes3mp.GetSpellsActiveStackingState(pid, changesIndex),
                startTime = os.time(),
                caster = {}
            }

            spellInstance.hasPlayerCaster = tes3mp.DoesSpellsActiveHavePlayerCaster(pid, changesIndex)

            if spellInstance.hasPlayerCaster == true then
                local casterPid = tes3mp.GetSpellsActiveCasterPid(pid, changesIndex)
                spellInstance.caster.pid = casterPid

                if Players[casterPid] ~= nil then
                    spellInstance.caster.playerName = Players[casterPid].accountName
                end
            else
                spellInstance.caster.uniqueIndex = tes3mp.GetSpellsActiveCasterRefNum(pid, changesIndex) ..
                    "-" .. tes3mp.GetSpellsActiveCasterMpNum(pid, changesIndex)
                spellInstance.caster.refId = tes3mp.GetSpellsActiveCasterRefId(pid, changesIndex)
            end

            for effectIndex = 0, tes3mp.GetSpellsActiveEffectCount(pid, changesIndex) - 1 do
                local effect = {
                    id = tes3mp.GetSpellsActiveEffectId(pid, changesIndex, effectIndex),
                    magnitude = tes3mp.GetSpellsActiveEffectMagnitude(pid, changesIndex, effectIndex),
                    duration = tes3mp.GetSpellsActiveEffectDuration(pid, changesIndex, effectIndex),
                    timeLeft = tes3mp.GetSpellsActiveEffectTimeLeft(pid, changesIndex, effectIndex),
                    arg = tes3mp.GetSpellsActiveEffectArg(pid, changesIndex, effectIndex)
                }

                table.insert(spellInstance.effects, effect)
            end

            table.insert(packetTable.spellsActive[spellId], spellInstance)
        end
    elseif packetType == "PlayerCooldowns" then
        packetTable.cooldowns = {}

        for changesIndex = 0, tes3mp.GetCooldownChangesSize(pid) - 1 do

            local cooldown = {
                spellId = tes3mp.GetCooldownSpellId(pid, changesIndex),
                startDay = tes3mp.GetCooldownStartDay(pid, changesIndex),
                startHour = tes3mp.GetCooldownStartHour(pid, changesIndex)
            }
            
            table.insert(packetTable.cooldowns, cooldown)
        end
    elseif packetType == "PlayerQuickKeys" then
        packetTable.quickKeys = {}

        for changesIndex = 0, tes3mp.GetQuickKeyChangesSize(pid) - 1 do

            local slot = tes3mp.GetQuickKeySlot(pid, changesIndex)

            packetTable.quickKeys[slot] = {
                keyType = tes3mp.GetQuickKeyType(pid, changesIndex),
                itemId = tes3mp.GetQuickKeyItemId(pid, changesIndex)
            }
        end
    elseif packetType == "PlayerJournal" then
        packetTable.journal = {}

        for changesIndex = 0, tes3mp.GetJournalChangesSize(pid) - 1 do
            local journalItem = {
                type = tes3mp.GetJournalItemType(pid, changesIndex),
                index = tes3mp.GetJournalItemIndex(pid, changesIndex),
                quest = tes3mp.GetJournalItemQuest(pid, changesIndex),
                timestamp = {
                    daysPassed = WorldInstance.data.time.daysPassed,
                    month = WorldInstance.data.time.month,
                    day = WorldInstance.data.time.day
                }
            }

            if journalItem.type == enumerations.journal.ENTRY then
                journalItem.actorRefId = tes3mp.GetJournalItemActorRefId(pid, changesIndex)
            end

            table.insert(packetTable.journal, journalItem)
        end
    end

    return packetTable
end

packetReader.GetActorPacketTables = function(packetType)
    
    local packetTables = { actors = {} }
    local actorListSize = tes3mp.GetActorListSize()

    if actorListSize == 0 then return packetTables end

    for packetIndex = 0, actorListSize - 1 do
        local actor = {}
        local uniqueIndex = tes3mp.GetActorRefNum(packetIndex) .. "-" .. tes3mp.GetActorMpNum(packetIndex)
        actor.uniqueIndex = uniqueIndex

        -- Only non-repetitive actor packets contain refId information
        if tableHelper.containsValue({"ActorList", "ActorDeath"}, packetType) then
            actor.refId = tes3mp.GetActorRefId(packetIndex)
        end

        if packetType == "ActorEquipment" then

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
        elseif packetType == "ActorSpellsActive" then

            actor.spellsActive = {}
            local spellsActiveChangesSize = tes3mp.GetActorSpellsActiveChangesSize(packetIndex)

            for spellIndex = 0, spellsActiveChangesSize - 1 do

                local spellId = tes3mp.GetActorSpellsActiveId(packetIndex, spellIndex)

                if actor.spellsActive[spellId] == nil then
                    actor.spellsActive[spellId] = {}
                end

                actor.spellActiveChangesAction = tes3mp.GetActorSpellsActiveChangesAction(packetIndex)

                local spellInstance = {
                    effects = {},
                    displayName = tes3mp.GetActorSpellsActiveDisplayName(packetIndex, spellIndex),
                    stackingState = tes3mp.GetActorSpellsActiveStackingState(packetIndex, spellIndex),
                    startTime = os.time(),
                    caster = {}
                }

                spellInstance.hasPlayerCaster = tes3mp.DoesActorSpellsActiveHavePlayerCaster(packetIndex, spellIndex)

                if spellInstance.hasPlayerCaster == true then
                    spellInstance.caster.pid = tes3mp.GetActorSpellsActiveCasterPid(packetIndex, spellIndex)

                    if Players[spellInstance.caster.pid] ~= nil then
                        spellInstance.caster.playerName = Players[spellInstance.caster.pid].accountName
                    end
                else
                    spellInstance.caster.uniqueIndex = tes3mp.GetActorSpellsActiveCasterRefNum(packetIndex, spellIndex) ..
                        "-" .. tes3mp.GetSpellsActiveCasterMpNum(packetIndex, spellIndex)
                    spellInstance.caster.refId = tes3mp.GetActorSpellsActiveCasterRefId(packetIndex, spellIndex)
                end

                for effectIndex = 0, tes3mp.GetActorSpellsActiveEffectCount(packetIndex, spellIndex) - 1 do
                    local effect = {
                        id = tes3mp.GetActorSpellsActiveEffectId(packetIndex, spellIndex, effectIndex),
                        magnitude = tes3mp.GetActorSpellsActiveEffectMagnitude(packetIndex, spellIndex, effectIndex),
                        duration = tes3mp.GetActorSpellsActiveEffectDuration(packetIndex, spellIndex, effectIndex),
                        timeLeft = tes3mp.GetActorSpellsActiveEffectTimeLeft(packetIndex, spellIndex, effectIndex),
                        arg = tes3mp.GetActorSpellsActiveEffectArg(packetIndex, spellIndex, effectIndex)
                    }

                    table.insert(spellInstance.effects, effect)
                end

                table.insert(actor.spellsActive[spellId], spellInstance)
            end
        elseif packetType == "ActorDeath" then

            actor.deathState = tes3mp.GetActorDeathState(packetIndex)
            actor.killer = {}

            local doesActorHavePlayerKiller = tes3mp.DoesActorHavePlayerKiller(packetIndex)

            if doesActorHavePlayerKiller then
                actor.killer.pid = tes3mp.GetActorKillerPid(packetIndex)

                if Players[actor.killer.pid] ~= nil then
                    actor.killer.playerName = Players[actor.killer.pid].accountName
                end
            else
                actor.killer.refId = tes3mp.GetActorKillerRefId(packetIndex)
                actor.killer.name = tes3mp.GetActorKillerName(packetIndex)
                actor.killer.uniqueIndex = tes3mp.GetActorKillerRefNum(packetIndex) ..
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
        
        if tableHelper.containsValue({"ObjectActivate", "ObjectHit", "ObjectSound", "ConsoleCommand"}, packetType) then

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

            if packetType == "ObjectSound" then

                local soundId = tes3mp.GetObjectSoundId(packetIndex)

                if isObjectPlayer then
                    player.soundId = soundId
                else
                    object.soundId = soundId
                end

            elseif packetType == "ObjectActivate" then

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
                    local activatingRefId = tes3mp.GetObjectActivatingRefId(packetIndex)
                    local activatingUniqueIndex = tes3mp.GetObjectActivatingRefNum(packetIndex) ..
                        "-" .. tes3mp.GetObjectActivatingMpNum(packetIndex)

                    if isObjectPlayer then
                        player.activatingRefId = activatingRefId
                        player.activatingUniqueIndex = activatingUniqueIndex
                    else
                        object.activatingRefId = activatingRefId
                        object.activatingUniqueIndex = activatingUniqueIndex
                    end
                end

            elseif packetType == "ObjectHit" then

                local hit = {
                    success = tes3mp.GetObjectHitSuccess(packetIndex),
                    damage = tes3mp.GetObjectHitDamage(packetIndex),
                    block = tes3mp.GetObjectHitBlock(packetIndex),
                    knockdown = tes3mp.GetObjectHitKnockdown(packetIndex)
                }

                if isObjectPlayer then
                    player.hit = hit
                else
                    object.hit = hit
                end

                local doesObjectHaveHittingPlayer = tes3mp.DoesObjectHavePlayerHitting(packetIndex)

                if doesObjectHaveHittingPlayer then
                    local hittingPid = tes3mp.GetObjectHittingPid(packetIndex)

                    if isObjectPlayer then
                        player.hittingPid = hittingPid
                    else
                        object.hittingPid = hittingPid
                    end
                else
                    local hittingRefId = tes3mp.GetObjectHittingRefId(packetIndex)
                    local hittingUniqueIndex = tes3mp.GetObjectHittingRefNum(packetIndex) ..
                        "-" .. tes3mp.GetObjectHittingMpNum(packetIndex)

                    if isObjectPlayer then
                        player.hittingRefId = hittingRefId
                        player.hittingUniqueIndex = hittingUniqueIndex
                    else
                        object.hittingRefId = hittingRefId
                        object.hittingUniqueIndex = hittingUniqueIndex
                    end
                end
            end
        else
            object = {}
            uniqueIndex = tes3mp.GetObjectRefNum(packetIndex) .. "-" .. tes3mp.GetObjectMpNum(packetIndex)
            object.refId = tes3mp.GetObjectRefId(packetIndex)
            object.uniqueIndex = uniqueIndex

            if tableHelper.containsValue({"ObjectPlace", "ObjectSpawn"}, packetType) then
                
                object.location = {
                    posX = tes3mp.GetObjectPosX(packetIndex), posY = tes3mp.GetObjectPosY(packetIndex),
                    posZ = tes3mp.GetObjectPosZ(packetIndex), rotX = tes3mp.GetObjectRotX(packetIndex),
                    rotY = tes3mp.GetObjectRotY(packetIndex), rotZ = tes3mp.GetObjectRotZ(packetIndex)
                }

                if packetType == "ObjectPlace" then
                    object.count = tes3mp.GetObjectCount(packetIndex)
                    object.charge = tes3mp.GetObjectCharge(packetIndex)
                    object.enchantmentCharge = tes3mp.GetObjectEnchantmentCharge(packetIndex)
                    object.soul = tes3mp.GetObjectSoul(packetIndex)
                    object.goldValue = tes3mp.GetObjectGoldValue(packetIndex)
                    object.hasContainer = tes3mp.DoesObjectHaveContainer(packetIndex)
                    object.droppedByPlayer = tes3mp.IsObjectDroppedByPlayer(packetIndex)
                elseif packetType == "ObjectSpawn" then
                    local summonState = tes3mp.GetObjectSummonState(packetIndex)

                    if summonState == true then
                        object.summon = {}
                        object.summon.effectId = tes3mp.GetObjectSummonEffectId(packetIndex)
                        object.summon.spellId = tes3mp.GetObjectSummonSpellId(packetIndex)
                        object.summon.duration = tes3mp.GetObjectSummonDuration(packetIndex)
                        object.summon.startTime = os.time()
                        object.summon.summoner = {}
                        object.summon.hasPlayerSummoner = tes3mp.DoesObjectHavePlayerSummoner(packetIndex)

                        if object.summon.hasPlayerSummoner == true then
                            object.summon.summoner.pid = tes3mp.GetObjectSummonerPid(packetIndex)

                            if Players[object.summon.summoner.pid] ~= nil then
                                object.summon.summoner.playerName = Players[object.summon.summoner.pid].accountName
                            end
                        else
                            object.summon.summoner.refId = tes3mp.GetObjectSummonerRefId(packetIndex)
                            object.summon.summoner.uniqueIndex = tes3mp.GetObjectSummonerRefNum(packetIndex) ..
                                "-" .. tes3mp.GetObjectSummonerMpNum(packetIndex)
                        end
                    end
                end

            elseif packetType == "ObjectLock" then
                object.lockLevel = tes3mp.GetObjectLockLevel(packetIndex)
            elseif packetType == "ObjectDialogueChoice" then
                object.dialogueChoiceType = tes3mp.GetObjectDialogueChoiceType(packetIndex)

                if object.dialogueChoiceType == enumerations.dialogueChoice.TOPIC then
                    object.dialogueTopic = tes3mp.GetObjectDialogueChoiceTopic(packetIndex)
                end
            elseif packetType == "ObjectMiscellaneous" then
                object.goldPool = tes3mp.GetObjectGoldPool(packetIndex)
                object.lastGoldRestockHour = tes3mp.GetObjectLastGoldRestockHour(packetIndex)
                object.lastGoldRestockDay = tes3mp.GetObjectLastGoldRestockDay(packetIndex)
            elseif packetType == "ObjectScale" then
                object.scale = tes3mp.GetObjectScale(packetIndex)
            elseif packetType == "ObjectState" then
                object.state = tes3mp.GetObjectState(packetIndex)
            elseif packetType == "DoorState" then
                object.doorState = tes3mp.GetObjectDoorState(packetIndex)
            elseif packetType =="ClientScriptLocal" then

                local variables = {}
                local variableCount = tes3mp.GetClientLocalsSize(packetIndex)

                for variableIndex = 0, variableCount - 1 do
                    local internalIndex = tes3mp.GetClientLocalInternalIndex(packetIndex, variableIndex)
                    local variableType = tes3mp.GetClientLocalVariableType(packetIndex, variableIndex)
                    local value

                    if tableHelper.containsValue({enumerations.variableType.SHORT, enumerations.variableType.LONG},
                        variableType) then
                        value = tes3mp.GetClientLocalIntValue(packetIndex, variableIndex)
                    elseif variableType == enumerations.variableType.FLOAT then
                        value = tes3mp.GetClientLocalFloatValue(packetIndex, variableIndex)
                    end

                    if variables[variableType] == nil then
                        variables[variableType] = {}
                    end

                    variables[variableType][internalIndex] = value
                end

                object.variables = variables
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

packetReader.GetWorldMapTileArray = function()

    local mapTileArray = {}
    local mapTileCount = tes3mp.GetMapChangesSize()

    for index = 0, mapTileCount - 1 do
        mapTile = {
            cellX = tes3mp.GetMapTileCellX(index),
            cellY = tes3mp.GetMapTileCellY(index),
        }

        mapTile.filename = mapTile.cellX .. ", " .. mapTile.cellY .. ".png"

        table.insert(mapTileArray, mapTile)
    end

    return mapTileArray
end

packetReader.GetClientScriptGlobalPacketTable = function()

    local variables = {}
    local variableCount = tes3mp.GetClientGlobalsSize()

    for index = 0, variableCount - 1 do
        local id = tes3mp.GetClientGlobalId(index)
        local variable = { variableType = tes3mp.GetClientGlobalVariableType(index) }

        if tableHelper.containsValue({enumerations.variableType.SHORT, enumerations.variableType.LONG},
            variable.variableType) then
            variable.intValue = tes3mp.GetClientGlobalIntValue(index)
        elseif variable.variableType == enumerations.variableType.FLOAT then
            variable.floatValue = tes3mp.GetClientGlobalFloatValue(index)
        end

        variables[id] = variable
    end

    return variables
end

packetReader.GetRecordDynamicArray = function(pid)

    local recordArray = {}
    local recordCount = tes3mp.GetRecordCount(pid)
    local recordNumericalType = tes3mp.GetRecordType(pid)

    for recordIndex = 0, recordCount - 1 do
        local record = {}

        if recordNumericalType ~= enumerations.recordType.ENCHANTMENT then
            record.name = tes3mp.GetRecordName(recordIndex)
        end

        if recordNumericalType == enumerations.recordType.SPELL then
            record.subtype = tes3mp.GetRecordSubtype(recordIndex)
            record.cost = tes3mp.GetRecordCost(recordIndex)
            record.flags = tes3mp.GetRecordFlags(recordIndex)
            record.effects = packetReader.GetRecordPacketEffectArray(recordIndex)

        elseif recordNumericalType == enumerations.recordType.POTION then
            record.weight = math.floor(tes3mp.GetRecordWeight(recordIndex) * 100) / 100
            record.value = tes3mp.GetRecordValue(recordIndex)
            record.autoCalc = tes3mp.GetRecordAutoCalc(recordIndex)
            record.icon = tes3mp.GetRecordIcon(recordIndex)
            record.model = tes3mp.GetRecordModel(recordIndex)
            record.script = tes3mp.GetRecordScript(recordIndex)
            record.effects = packetReader.GetRecordPacketEffectArray(recordIndex)

            -- Temporary data that should be discarded afterwards
            record.quantity = tes3mp.GetRecordQuantity(recordIndex)

        elseif recordNumericalType == enumerations.recordType.ENCHANTMENT then
            record.subtype = tes3mp.GetRecordSubtype(recordIndex)
            record.cost = tes3mp.GetRecordCost(recordIndex)
            record.charge = tes3mp.GetRecordCharge(recordIndex)
            record.flags = tes3mp.GetRecordFlags(recordIndex)
            record.effects = packetReader.GetRecordPacketEffectArray(recordIndex)

            -- Temporary data that should be discarded afterwards
            record.clientsideEnchantmentId = tes3mp.GetRecordId(recordIndex)

        else
            record.baseId = tes3mp.GetRecordBaseId(recordIndex)
            record.enchantmentCharge = tes3mp.GetRecordEnchantmentCharge(recordIndex)

            -- Temporary data that should be discarded afterwards
            if recordNumericalType == enumerations.recordType.WEAPON then
                record.quantity = tes3mp.GetRecordQuantity(recordIndex)
            else
                record.quantity = 1
            end

            -- Enchanted item records always have client-set ids for their enchantments
            -- when received by us, so we need to check for the server-set ids matching
            -- them in the player's unresolved enchantments
            local clientEnchantmentId = tes3mp.GetRecordEnchantmentId(recordIndex)
            record.enchantmentId = Players[pid].unresolvedEnchantments[clientEnchantmentId]

            -- Stop tracking this as an unresolved enchantment, assuming the enchantment
            -- itself wasn't previously denied
            if record.enchantmentId ~= nil and Players[pid] ~= nil then
                Players[pid].unresolvedEnchantments[clientEnchantmentId] = nil
            end
        end

        table.insert(recordArray, record)
    end

    return recordArray
end

packetReader.GetRecordPacketEffectArray = function(recordIndex)

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
