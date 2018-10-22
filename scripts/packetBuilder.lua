packetBuilder = {}

packetBuilder.AddPlayerInventoryItemChange = function(pid, item)

    -- Use default values when necessary
    if item.charge == nil or item.charge < -1 then item.charge = -1 end
    if item.enchantmentCharge == nil or item.enchantmentCharge < -1 then item.enchantmentCharge = -1 end
    if item.soul == nil then item.soul = "" end

    tes3mp.AddItemChange(pid, item.refId, item.count, item.charge, item.enchantmentCharge, item.soul)
end

packetBuilder.AddObjectDelete = function(uniqueIndex, objectData)

    local splitIndex = uniqueIndex:split("-")
    tes3mp.SetObjectRefNum(splitIndex[1])
    tes3mp.SetObjectMpNum(splitIndex[2])
    tes3mp.SetObjectRefId(objectData.refId)
    tes3mp.AddObject()
end

packetBuilder.AddObjectPlace = function(uniqueIndex, objectData)

    local splitIndex = uniqueIndex:split("-")
    tes3mp.SetObjectRefNum(splitIndex[1])
    tes3mp.SetObjectMpNum(splitIndex[2])
    tes3mp.SetObjectRefId(objectData.refId)

    local count = objectData.count
    local charge = objectData.charge
    local enchantmentCharge = objectData.enchantmentCharge
    local soul = objectData.soul
    local goldValue = objectData.goldValue

    -- Use default values when necessary
    if count == nil then count = 1 end
    if charge == nil then charge = -1 end
    if enchantmentCharge == nil then enchantmentCharge = -1 end
    if soul == nil then soul = "" end
    if goldValue == nil then goldValue = 1 end

    tes3mp.SetObjectCount(count)
    tes3mp.SetObjectCharge(charge)
    tes3mp.SetObjectEnchantmentCharge(enchantmentCharge)
    tes3mp.SetObjectSoul(soul)
    tes3mp.SetObjectGoldValue(goldValue)

    local location = objectData.location
    tes3mp.SetObjectPosition(location.posX, location.posY, location.posZ)
    tes3mp.SetObjectRotation(location.rotX, location.rotY, location.rotZ)

    tes3mp.AddObject()
end

packetBuilder.AddObjectSpawn = function(uniqueIndex, objectData)

    local splitIndex = uniqueIndex:split("-")
    tes3mp.SetObjectRefNum(splitIndex[1])
    tes3mp.SetObjectMpNum(splitIndex[2])

    tes3mp.SetObjectRefId(objectData.refId)

    local location = objectData.location
    tes3mp.SetObjectPosition(location.posX, location.posY, location.posZ)
    tes3mp.SetObjectRotation(location.rotX, location.rotY, location.rotZ)

    tes3mp.AddObject()
end

packetBuilder.AddObjectLock = function(uniqueIndex, objectData)

    local splitIndex = uniqueIndex:split("-")
    tes3mp.SetObjectRefNum(splitIndex[1])
    tes3mp.SetObjectMpNum(splitIndex[2])
    tes3mp.SetObjectRefId(objectData.refId)
    tes3mp.SetObjectLockLevel(objectData.lockLevel)
    tes3mp.AddObject()
end

packetBuilder.AddObjectTrap = function(uniqueIndex, objectData)

    local splitIndex = uniqueIndex:split("-")
    tes3mp.SetObjectRefNum(splitIndex[1])
    tes3mp.SetObjectMpNum(splitIndex[2])
    tes3mp.SetObjectRefId(objectData.refId)
    tes3mp.SetObjectDisarmState(true)
    tes3mp.AddObject()
end

packetBuilder.AddObjectScale = function(uniqueIndex, objectData)

    local splitIndex = uniqueIndex:split("-")
    tes3mp.SetObjectRefNum(splitIndex[1])
    tes3mp.SetObjectMpNum(splitIndex[2])
    tes3mp.SetObjectRefId(objectData.refId)
    tes3mp.SetObjectScale(objectData.scale)
    tes3mp.AddObject()
end

packetBuilder.AddObjectState = function(uniqueIndex, objectData)

    local splitIndex = uniqueIndex:split("-")
    tes3mp.SetObjectRefNum(splitIndex[1])
    tes3mp.SetObjectMpNum(splitIndex[2])
    tes3mp.SetObjectRefId(objectData.refId)
    tes3mp.SetObjectState(objectData.state)
    tes3mp.AddObject()
end

packetBuilder.AddDoorState = function(uniqueIndex, objectData)

    local splitIndex = uniqueIndex:split("-")
    tes3mp.SetObjectRefNum(splitIndex[1])
    tes3mp.SetObjectMpNum(splitIndex[2])
    tes3mp.SetObjectRefId(objectData.refId)
    tes3mp.SetObjectDoorState(objectData.doorState)
    tes3mp.AddObject()
end

packetBuilder.AddAIActor = function(actorUniqueIndex, targetPid, aiData)

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

packetBuilder.AddEffectToRecord = function(effect)

    tes3mp.SetRecordEffectId(effect.id)
    if effect.attribute ~= nil then tes3mp.SetRecordEffectAttribute(effect.attribute) end
    if effect.skill ~= nil then tes3mp.SetRecordEffectSkill(effect.skill) end
    if effect.rangeType ~= nil then tes3mp.SetRecordEffectRangeType(effect.rangeType) end
    if effect.area ~= nil then tes3mp.SetRecordEffectArea(effect.area) end
    if effect.duration ~= nil then tes3mp.SetRecordEffectDuration(effect.duration) end
    if effect.magnitudeMin ~= nil then tes3mp.SetRecordEffectMagnitudeMin(effect.magnitudeMin) end
    if effect.magnitudeMax ~= nil then tes3mp.SetRecordEffectMagnitudeMax(effect.magnitudeMax) end

    tes3mp.AddRecordEffect()
end

packetBuilder.AddBodyPartToRecord = function(part)

    tes3mp.SetRecordBodyPartType(part.partType)
    if part.malePart ~= nil then tes3mp.SetRecordBodyPartIdForMale(part.malePart) end
    if part.femalePart ~= nil then tes3mp.SetRecordBodyPartIdForFemale(part.femalePart) end

    tes3mp.AddRecordBodyPart()
end

packetBuilder.AddInventoryItemToRecord = function(item)

    tes3mp.SetRecordInventoryItemId(item.id)
    if item.count ~= nil then tes3mp.SetRecordInventoryItemCount(item.count) end

    tes3mp.AddRecordInventoryItem()
end

packetBuilder.AddRecordByType = function(id, record, storeType)

    if storeType == "armor" then
        packetBuilder.AddArmorRecord(id, record)
    elseif storeType == "book" then
        packetBuilder.AddBookRecord(id, record)
    elseif storeType == "clothing" then
        packetBuilder.AddClothingRecord(id, record)
    elseif storeType == "creature" then
        packetBuilder.AddCreatureRecord(id, record)
    elseif storeType == "enchantment" then
        packetBuilder.AddEnchantmentRecord(id, record)
    elseif storeType == "miscellaneous" then
        packetBuilder.AddMiscellaneousRecord(id, record)
    elseif storeType == "npc" then
        packetBuilder.AddNpcRecord(id, record)
    elseif storeType == "potion" then
        packetBuilder.AddPotionRecord(id, record)
    elseif storeType == "spell" then
        packetBuilder.AddSpellRecord(id, record)
    elseif storeType == "weapon" then
        packetBuilder.AddWeaponRecord(id, record)
    end
end

packetBuilder.AddArmorRecord = function(id, record)

    tes3mp.SetRecordId(id)
    if record.baseId ~= nil then tes3mp.SetRecordBaseId(record.baseId) end
    if record.name ~= nil then tes3mp.SetRecordName(record.name) end
    if record.model ~= nil then tes3mp.SetRecordModel(record.model) end
    if record.icon ~= nil then tes3mp.SetRecordIcon(record.icon) end
    if record.subtype ~= nil then tes3mp.SetRecordSubtype(record.subtype) end
    if record.weight ~= nil then tes3mp.SetRecordWeight(record.weight) end
    if record.value ~= nil then tes3mp.SetRecordValue(record.value) end
    if record.health ~= nil then tes3mp.SetRecordHealth(record.health) end
    if record.armorRating ~= nil then tes3mp.SetRecordArmorRating(record.armorRating) end
    if record.enchantmentId ~= nil then tes3mp.SetRecordEnchantmentId(record.enchantmentId) end
    if record.enchantmentCharge ~= nil then tes3mp.SetRecordEnchantmentCharge(record.enchantmentCharge) end
    if record.script ~= nil then tes3mp.SetRecordScript(record.script) end

    if type(record.parts) == "table" then
        for _, part in pairs(record.parts) do
            packetBuilder.AddBodyPartToRecord(part)
        end
    end

    tes3mp.AddRecord()
end

packetBuilder.AddBookRecord = function(id, record)

    tes3mp.SetRecordId(id)
    if record.baseId ~= nil then tes3mp.SetRecordBaseId(record.baseId) end
    if record.name ~= nil then tes3mp.SetRecordName(record.name) end
    if record.model ~= nil then tes3mp.SetRecordModel(record.model) end
    if record.icon ~= nil then tes3mp.SetRecordIcon(record.icon) end
    if record.text ~= nil then tes3mp.SetRecordText(record.text) end
    if record.weight ~= nil then tes3mp.SetRecordWeight(record.weight) end
    if record.value ~= nil then tes3mp.SetRecordValue(record.value) end
    if record.scrollState ~= nil then tes3mp.SetRecordScrollState(record.scrollState) end
    if record.skillId ~= nil then tes3mp.SetRecordSkillId(record.skillId) end
    if record.enchantmentId ~= nil then tes3mp.SetRecordEnchantmentId(record.enchantmentId) end
    if record.enchantmentCharge ~= nil then tes3mp.SetRecordEnchantmentCharge(record.enchantmentCharge) end
    if record.script ~= nil then tes3mp.SetRecordScript(record.script) end

    tes3mp.AddRecord()
end

packetBuilder.AddClothingRecord = function(id, record)

    tes3mp.SetRecordId(id)
    if record.baseId ~= nil then tes3mp.SetRecordBaseId(record.baseId) end
    if record.name ~= nil then tes3mp.SetRecordName(record.name) end
    if record.model ~= nil then tes3mp.SetRecordModel(record.model) end
    if record.icon ~= nil then tes3mp.SetRecordIcon(record.icon) end
    if record.subtype ~= nil then tes3mp.SetRecordSubtype(record.subtype) end
    if record.weight ~= nil then tes3mp.SetRecordWeight(record.weight) end
    if record.value ~= nil then tes3mp.SetRecordValue(record.value) end
    if record.enchantmentId ~= nil then tes3mp.SetRecordEnchantmentId(record.enchantmentId) end
    if record.enchantmentCharge ~= nil then tes3mp.SetRecordEnchantmentCharge(record.enchantmentCharge) end
    if record.script ~= nil then tes3mp.SetRecordScript(record.script) end

    if type(record.parts) == "table" then
        for _, part in pairs(record.parts) do
            packetBuilder.AddBodyPartToRecord(part)
        end
    end

    tes3mp.AddRecord()
end

packetBuilder.AddCreatureRecord = function(id, record)

    tes3mp.SetRecordId(id)
    if record.baseId ~= nil then tes3mp.SetRecordBaseId(record.baseId) end
    if record.name ~= nil then tes3mp.SetRecordName(record.name) end
    if record.model ~= nil then tes3mp.SetRecordModel(record.model) end
    if record.subtype ~= nil then tes3mp.SetRecordSubtype(record.subtype) end
    if record.level ~= nil then tes3mp.SetRecordLevel(record.level) end
    if record.health ~= nil then tes3mp.SetRecordHealth(record.health) end
    if record.magicka ~= nil then tes3mp.SetRecordMagicka(record.magicka) end
    if record.fatigue ~= nil then tes3mp.SetRecordFatigue(record.fatigue) end
    if record.aiFight ~= nil then tes3mp.SetRecordAIFight(record.aiFight) end
    if record.flags ~= nil then tes3mp.SetRecordFlags(record.flags) end
    if record.script ~= nil then tes3mp.SetRecordScript(record.script) end

    if type(record.items) == "table" then
        for _, item in pairs(record.items) do
            packetBuilder.AddInventoryItemToRecord(item)
        end
    end

    tes3mp.AddRecord()
end

packetBuilder.AddEnchantmentRecord = function(id, record)

    tes3mp.SetRecordId(id)
    if record.baseId ~= nil then tes3mp.SetRecordBaseId(record.baseId) end
    if record.subtype ~= nil then tes3mp.SetRecordSubtype(record.subtype) end
    if record.cost ~= nil then tes3mp.SetRecordCost(record.cost) end
    if record.charge ~= nil then tes3mp.SetRecordCharge(record.charge) end
    if record.autoCalc ~= nil then tes3mp.SetRecordAutoCalc(record.autoCalc) end

    if type(record.effects) == "table" then
        for _, effect in pairs(record.effects) do
            packetBuilder.AddEffectToRecord(effect)
        end
    end

    tes3mp.AddRecord()
end

packetBuilder.AddMiscellaneousRecord = function(id, record)

    tes3mp.SetRecordId(id)
    if record.baseId ~= nil then tes3mp.SetRecordBaseId(record.baseId) end
    if record.name ~= nil then tes3mp.SetRecordName(record.name) end
    if record.model ~= nil then tes3mp.SetRecordModel(record.model) end
    if record.icon ~= nil then tes3mp.SetRecordIcon(record.icon) end
    if record.weight ~= nil then tes3mp.SetRecordWeight(record.weight) end
    if record.value ~= nil then tes3mp.SetRecordValue(record.value) end
    if record.keyState ~= nil then tes3mp.SetRecordKeyState(record.keyState) end
    if record.script ~= nil then tes3mp.SetRecordScript(record.script) end

    tes3mp.AddRecord()
end

packetBuilder.AddNpcRecord = function(id, record)

    tes3mp.SetRecordId(id)
    if record.baseId ~= nil then tes3mp.SetRecordBaseId(record.baseId) end
    if record.inventoryBaseId ~= nil then tes3mp.SetRecordInventoryBaseId(record.inventoryBaseId) end
    if record.name ~= nil then tes3mp.SetRecordName(record.name) end
    if record.gender ~= nil then tes3mp.SetRecordGender(record.gender) end
    if record.race ~= nil then tes3mp.SetRecordRace(record.race) end
    if record.hair ~= nil then tes3mp.SetRecordHair(record.hair) end
    if record.head ~= nil then tes3mp.SetRecordHead(record.head) end
    if record.class ~= nil then tes3mp.SetRecordClass(record.class) end
    if record.level ~= nil then tes3mp.SetRecordLevel(record.level) end
    if record.health ~= nil then tes3mp.SetRecordHealth(record.health) end
    if record.magicka ~= nil then tes3mp.SetRecordMagicka(record.magicka) end
    if record.fatigue ~= nil then tes3mp.SetRecordFatigue(record.fatigue) end
    if record.aiFight ~= nil then tes3mp.SetRecordAIFight(record.aiFight) end
    if record.autoCalc ~= nil then tes3mp.SetRecordAutoCalc(record.autoCalc) end
    if record.faction ~= nil then tes3mp.SetRecordFaction(record.faction) end
    if record.script ~= nil then tes3mp.SetRecordScript(record.script) end

    if type(record.items) == "table" then
        for _, item in pairs(record.items) do
            packetBuilder.AddInventoryItemToRecord(item)
        end
    end

    tes3mp.AddRecord()
end

packetBuilder.AddPotionRecord = function(id, record)

    tes3mp.SetRecordId(id)
    if record.baseId ~= nil then tes3mp.SetRecordBaseId(record.baseId) end
    if record.name ~= nil then tes3mp.SetRecordName(record.name) end
    if record.weight ~= nil then tes3mp.SetRecordWeight(record.weight) end
    if record.value ~= nil then tes3mp.SetRecordValue(record.value) end
    if record.autoCalc ~= nil then tes3mp.SetRecordAutoCalc(record.autoCalc) end
    if record.icon ~= nil then tes3mp.SetRecordIcon(record.icon) end
    if record.model ~= nil then tes3mp.SetRecordModel(record.model) end
    if record.script ~= nil then tes3mp.SetRecordScript(record.script) end

    if type(record.effects) == "table" then
        for _, effect in pairs(record.effects) do
            packetBuilder.AddEffectToRecord(effect)
        end
    end

    tes3mp.AddRecord()
end

packetBuilder.AddSpellRecord = function(id, record)

    tes3mp.SetRecordId(id)
    if record.baseId ~= nil then tes3mp.SetRecordBaseId(record.baseId) end
    if record.name ~= nil then tes3mp.SetRecordName(record.name) end
    if record.subtype ~= nil then tes3mp.SetRecordSubtype(record.subtype) end
    if record.cost ~= nil then tes3mp.SetRecordCost(record.cost) end
    if record.flags ~= nil then tes3mp.SetRecordFlags(record.flags) end

    if type(record.effects) == "table" then
        for _, effect in pairs(record.effects) do
            packetBuilder.AddEffectToRecord(effect)
        end
    end

    tes3mp.AddRecord()
end

packetBuilder.AddWeaponRecord = function(id, record)

    tes3mp.SetRecordId(id)
    if record.baseId ~= nil then tes3mp.SetRecordBaseId(record.baseId) end
    if record.name ~= nil then tes3mp.SetRecordName(record.name) end
    if record.model ~= nil then tes3mp.SetRecordModel(record.model) end
    if record.icon ~= nil then tes3mp.SetRecordIcon(record.icon) end
    if record.subtype ~= nil then tes3mp.SetRecordSubtype(record.subtype) end
    if record.weight ~= nil then tes3mp.SetRecordWeight(record.weight) end
    if record.value ~= nil then tes3mp.SetRecordValue(record.value) end
    if record.health ~= nil then tes3mp.SetRecordHealth(record.health) end
    if record.speed ~= nil then tes3mp.SetRecordSpeed(record.speed) end
    if record.reach ~= nil then tes3mp.SetRecordReach(record.reach) end
    if record.damageChop ~= nil then tes3mp.SetRecordDamageChop(record.damageChop.min, record.damageChop.max) end
    if record.damageSlash ~= nil then tes3mp.SetRecordDamageSlash(record.damageSlash.min, record.damageSlash.max) end
    if record.damageThrust ~= nil then tes3mp.SetRecordDamageThrust(record.damageThrust.min, record.damageThrust.max) end
    if record.flags ~= nil then tes3mp.SetRecordFlags(record.flags) end
    if record.enchantmentId ~= nil then tes3mp.SetRecordEnchantmentId(record.enchantmentId) end
    if record.enchantmentCharge ~= nil then tes3mp.SetRecordEnchantmentCharge(record.enchantmentCharge) end
    if record.script ~= nil then tes3mp.SetRecordScript(record.script) end

    tes3mp.AddRecord()
end

return packetBuilder
