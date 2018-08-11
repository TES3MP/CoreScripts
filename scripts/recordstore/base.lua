local BaseRecordStore = class("BaseRecordStore")

function BaseRecordStore:__init(storeType)

    self.data =
    {
        general = {
            currentRecordNum = 0
        },
        records = {}
    }

    self.storeType = storeType
end

function BaseRecordStore:HasEntry()
    return self.hasEntry
end

function BaseRecordStore:GetCurrentRecordNum()
    return self.data.general.currentRecordNum
end

function BaseRecordStore:SetCurrentRecordNum(currentRecordNum)
    self.data.general.currentRecordNum = currentRecordNum
    self:Save()
end

function BaseRecordStore:IncrementRecordNum()
    self:SetCurrentRecordNum(self:GetCurrentRecordNum() + 1)
    return self:GetCurrentRecordNum()
end

function BaseRecordStore:LoadRecordEffects(effects)

    if type(effects) ~= "table" then return end

    for _, effect in pairs(effects) do

        tes3mp.SetRecordEffectId(effect.id)
        if effect.attribute ~= nil then tes3mp.SetRecordEffectAttribute(effect.attribute) end
        if effect.skill ~= nil then tes3mp.SetRecordEffectSkill(effect.skill) end
        if effect.rangeType ~= nil then tes3mp.SetRecordEffectRangeType(effect.rangeType) end
        if effect.area ~= nil then tes3mp.SetRecordEffectArea(effect.area) end
        if effect.duration ~= nil then tes3mp.SetRecordEffectDuration(effect.duration) end
        if effect.magnitudeMax ~= nil then tes3mp.SetRecordEffectMagnitudeMax(effect.magnitudeMax) end
        if effect.magnitudeMin ~= nil then tes3mp.SetRecordEffectMagnitudeMin(effect.magnitudeMin) end

        tes3mp.AddRecordEffect()
    end
end

function BaseRecordStore:LoadRecordBodyParts(parts)

    if type(parts) ~= "table" then return end

    for _, part in pairs(parts) do

        tes3mp.SetRecordBodyPartType(part.partType)
        if part.malePart ~= nil then tes3mp.SetRecordBodyPartIdForMale(part.malePart) end
        if part.femalePart ~= nil then tes3mp.SetRecordBodyPartIdForFemale(part.femalePart) end

        tes3mp.AddRecordBodyPart()
    end
end

function BaseRecordStore:LoadRecordInventoryItems(items)

    if type(items) ~= "table" then return end

    for _, item in pairs(items) do

        tes3mp.SetRecordInventoryItemId(item.id)
        if item.count ~= nil then tes3mp.SetRecordInventoryItemCount(item.count) end

        tes3mp.AddRecordInventoryItem()
    end
end

function BaseRecordStore:LoadArmors(pid)

    if self.storeType ~= "armor" then return end

    tes3mp.ClearRecords()
    tes3mp.SetRecordType(enumerations.recordType.ARMOR)

    for id, record in pairs(self.data.records) do

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

        self:LoadRecordBodyParts(record.parts)
        tes3mp.AddRecord()
    end

    tes3mp.SendRecordDynamic(pid, false, false)
end

function BaseRecordStore:LoadBooks(pid)

    if self.storeType ~= "book" then return end

    tes3mp.ClearRecords()
    tes3mp.SetRecordType(enumerations.recordType.BOOK)

    for id, record in pairs(self.data.records) do

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

    tes3mp.SendRecordDynamic(pid, false, false)
end

function BaseRecordStore:LoadClothing(pid)

    if self.storeType ~= "clothing" then return end

    tes3mp.ClearRecords()
    tes3mp.SetRecordType(enumerations.recordType.CLOTHING)

    for id, record in pairs(self.data.records) do

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

        self:LoadRecordBodyParts(record.parts)
        tes3mp.AddRecord()
    end

    tes3mp.SendRecordDynamic(pid, false, false)
end

function BaseRecordStore:LoadCreatures(pid)

    if self.storeType ~= "creature" then return end

    tes3mp.ClearRecords()
    tes3mp.SetRecordType(enumerations.recordType.CREATURE)

    for id, record in pairs(self.data.records) do

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

        tes3mp.AddRecord()
    end

    tes3mp.SendRecordDynamic(pid, false, false)
end

function BaseRecordStore:LoadEnchantments(pid)

    if self.storeType ~= "enchantment" then return end

    tes3mp.ClearRecords()
    tes3mp.SetRecordType(enumerations.recordType.ENCHANTMENT)

    for id, record in pairs(self.data.records) do

        tes3mp.SetRecordId(id)
        if record.baseId ~= nil then tes3mp.SetRecordBaseId(record.baseId) end
        if record.subtype ~= nil then tes3mp.SetRecordSubtype(record.subtype) end
        if record.cost ~= nil then tes3mp.SetRecordCost(record.cost) end
        if record.charge ~= nil then tes3mp.SetRecordCharge(record.charge) end
        if record.autoCalc ~= nil then tes3mp.SetRecordAutoCalc(record.autoCalc) end

        self:LoadRecordEffects(record.effects)
        tes3mp.AddRecord()
    end

    tes3mp.SendRecordDynamic(pid, false, false)
end

function BaseRecordStore:LoadMiscellaneous(pid)

    if self.storeType ~= "miscellaneous" then return end

    tes3mp.ClearRecords()
    tes3mp.SetRecordType(enumerations.recordType.MISCELLANEOUS)

    for id, record in pairs(self.data.records) do

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

    tes3mp.SendRecordDynamic(pid, false, false)
end

function BaseRecordStore:LoadNpcs(pid)

    if self.storeType ~= "npc" then return end

    tes3mp.ClearRecords()
    tes3mp.SetRecordType(enumerations.recordType.NPC)

    for id, record in pairs(self.data.records) do

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

        tes3mp.AddRecord()
    end

    tes3mp.SendRecordDynamic(pid, false, false)
end

function BaseRecordStore:LoadPotions(pid)

    if self.storeType ~= "potion" then return end

    tes3mp.ClearRecords()
    tes3mp.SetRecordType(enumerations.recordType.POTION)

    for id, record in pairs(self.data.records) do

        tes3mp.SetRecordId(id)
        if record.baseId ~= nil then tes3mp.SetRecordBaseId(record.baseId) end
        if record.name ~= nil then tes3mp.SetRecordName(record.name) end
        if record.weight ~= nil then tes3mp.SetRecordWeight(record.weight) end
        if record.value ~= nil then tes3mp.SetRecordValue(record.value) end
        if record.autoCalc ~= nil then tes3mp.SetRecordAutoCalc(record.autoCalc) end
        if record.icon ~= nil then tes3mp.SetRecordIcon(record.icon) end
        if record.model ~= nil then tes3mp.SetRecordModel(record.model) end
        if record.script ~= nil then tes3mp.SetRecordScript(record.script) end

        self:LoadRecordEffects(record.effects)
        tes3mp.AddRecord()
    end

    tes3mp.SendRecordDynamic(pid, false, false)
end

function BaseRecordStore:LoadSpells(pid)

    if self.storeType ~= "spell" then return end

    tes3mp.ClearRecords()
    tes3mp.SetRecordType(enumerations.recordType.SPELL)

    for id, record in pairs(self.data.records) do

        tes3mp.SetRecordId(id)
        if record.baseId ~= nil then tes3mp.SetRecordBaseId(record.baseId) end
        if record.name ~= nil then tes3mp.SetRecordName(record.name) end
        if record.subtype ~= nil then tes3mp.SetRecordSubtype(record.subtype) end
        if record.cost ~= nil then tes3mp.SetRecordCost(record.cost) end
        if record.flags ~= nil then tes3mp.SetRecordFlags(record.flags) end

        self:LoadRecordEffects(record.effects)
        tes3mp.AddRecord()
    end

    tes3mp.SendRecordDynamic(pid, false, false)
end

function BaseRecordStore:LoadWeapons(pid)

    if self.storeType ~= "weapon" then return end

    tes3mp.ClearRecords()
    tes3mp.SetRecordType(enumerations.recordType.WEAPON)

    for id, record in pairs(self.data.records) do

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

    tes3mp.SendRecordDynamic(pid, false, false)
end

function BaseRecordStore:GetRecordEffects(recordIndex)

    local effectTable = {}
    local effectCount = tes3mp.GetRecordEffectCount(recordIndex)

    tes3mp.LogAppend(3, "- Effects have count " .. effectCount)

    for effectIndex = 0, effectCount - 1 do

        local effect = {
            id = tes3mp.GetRecordEffectId(recordIndex, effectIndex),
            attribute = tes3mp.GetRecordEffectAttribute(recordIndex, effectIndex),
            skill = tes3mp.GetRecordEffectSkill(recordIndex, effectIndex),
            rangeType = tes3mp.GetRecordEffectRangeType(recordIndex, effectIndex),
            area = tes3mp.GetRecordEffectArea(recordIndex, effectIndex),
            duration = tes3mp.GetRecordEffectDuration(recordIndex, effectIndex),
            magnitudeMax = tes3mp.GetRecordEffectMagnitudeMax(recordIndex, effectIndex),
            magnitudeMin = tes3mp.GetRecordEffectMagnitudeMin(recordIndex, effectIndex)
        }

        table.insert(effectTable, effect)
    end

    return effectTable
end

function BaseRecordStore:SaveEnchantedItems(pid)

    if self.storeType ~= "armor" and self.storeType ~= "book" and
        self.storeType ~= "clothing" and self.storeType ~= "weapon" then
        return
    end

    local recordAdditions = {}
    local recordCount = tes3mp.GetRecordCount(pid)

    for recordIndex = 0, recordCount - 1 do

        -- Enchanted item records always have client-set ids for their enchantments
        -- when received by us, so we need to check for the server-set ids matching
        -- them in the player's unresolved enchantments
        local clientEnchantmentId = tes3mp.GetRecordEnchantmentId(recordIndex)
        local serverEnchantmentId = Players[pid].unresolvedEnchantments[clientEnchantmentId]

        if serverEnchantmentId ~= nil then

            -- Stop tracking this as an unresolved enchantment
            Players[pid].unresolvedEnchantments[clientEnchantmentId] = nil

            local recordId = "custom_" .. self.storeType .. "_" .. self:IncrementRecordNum()

            -- We don't need to track all the details of the enchanted items, just their base
            -- id and their enchantment information
            local record = {
                baseId = tes3mp.GetRecordBaseId(recordIndex),
                name = tes3mp.GetRecordName(recordIndex),
                enchantmentId = serverEnchantmentId,
                enchantmentCharge = tes3mp.GetRecordEnchantmentCharge(recordIndex)
            }

            self.data.records[recordId] = record
            table.insert(recordAdditions, { index = recordIndex, id = recordId,
                enchantmentId = serverEnchantmentId })
        end
    end

    self:Save()
    return recordAdditions
end

function BaseRecordStore:SaveEnchantments(pid)

    if self.storeType ~= "enchantment" then return end

    local recordAdditions = {}
    local recordCount = tes3mp.GetRecordCount(pid)

    for recordIndex = 0, recordCount - 1 do

        local recordId = "custom_enchantment_" .. self:IncrementRecordNum()

        local record = {
            subtype = tes3mp.GetRecordSubtype(recordIndex),
            cost = tes3mp.GetRecordCost(recordIndex),
            charge = tes3mp.GetRecordCharge(recordIndex),
            autoCalc = tes3mp.GetRecordAutoCalc(recordIndex),
            effects = self:GetRecordEffects(recordIndex)
        }

        self.data.records[recordId] = record
        table.insert(recordAdditions, { index = recordIndex, id = recordId,
            clientsideId = tes3mp.GetRecordId(recordIndex) })
    end

    self:Save()
    return recordAdditions
end

function BaseRecordStore:SavePotions(pid)

    if self.storeType ~= "potion" then return end

    local recordAdditions = {}
    local recordCount = tes3mp.GetRecordCount(pid)

    for recordIndex = 0, recordCount - 1 do

        local recordId = "custom_potion_" .. self:IncrementRecordNum()

        local record = {
            name = tes3mp.GetRecordName(recordIndex),
            weight = tes3mp.GetRecordWeight(recordIndex),
            value = tes3mp.GetRecordValue(recordIndex),
            autoCalc = tes3mp.GetRecordAutoCalc(recordIndex),
            icon = tes3mp.GetRecordIcon(recordIndex),
            model = tes3mp.GetRecordModel(recordIndex),
            script = tes3mp.GetRecordScript(recordIndex),
            effects = self:GetRecordEffects(recordIndex)
        }

        self.data.records[recordId] = record
        table.insert(recordAdditions, { index = recordIndex, id = recordId })
    end

    self:Save()
    return recordAdditions
end

function BaseRecordStore:SaveSpells(pid)

    if self.storeType ~= "spell" then return end

    local recordAdditions = {}
    local recordCount = tes3mp.GetRecordCount(pid)

    for recordIndex = 0, recordCount - 1 do

        local recordId = "custom_spell_" .. self:IncrementRecordNum()

        local record = {
            name = tes3mp.GetRecordName(recordIndex),
            subtype = tes3mp.GetRecordSubtype(recordIndex),
            cost = tes3mp.GetRecordCost(recordIndex),
            flags = tes3mp.GetRecordFlags(recordIndex),
            effects = self:GetRecordEffects(recordIndex)
        }

        self.data.records[recordId] = record
        table.insert(recordAdditions, { index = recordIndex, id = recordId })
    end

    self:Save()
    return recordAdditions
end

return BaseRecordStore
