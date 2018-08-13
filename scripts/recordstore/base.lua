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

function BaseRecordStore:LoadArmors(pid)

    if self.storeType ~= "armor" then return end

    tes3mp.ClearRecords()
    tes3mp.SetRecordType(enumerations.recordType.ARMOR)

    for id, record in pairs(self.data.records) do
        packetBuilder.AddArmorRecord(id, record)
    end

    tes3mp.SendRecordDynamic(pid, false, false)
end

function BaseRecordStore:LoadBooks(pid)

    if self.storeType ~= "book" then return end

    tes3mp.ClearRecords()
    tes3mp.SetRecordType(enumerations.recordType.BOOK)

    for id, record in pairs(self.data.records) do
        packetBuilder.AddBookRecord(id, record)
    end

    tes3mp.SendRecordDynamic(pid, false, false)
end

function BaseRecordStore:LoadClothing(pid)

    if self.storeType ~= "clothing" then return end

    tes3mp.ClearRecords()
    tes3mp.SetRecordType(enumerations.recordType.CLOTHING)

    for id, record in pairs(self.data.records) do
        packetBuilder.AddClothingRecord(id, record)
    end

    tes3mp.SendRecordDynamic(pid, false, false)
end

function BaseRecordStore:LoadCreatures(pid)

    if self.storeType ~= "creature" then return end

    tes3mp.ClearRecords()
    tes3mp.SetRecordType(enumerations.recordType.CREATURE)

    for id, record in pairs(self.data.records) do
        packetBuilder.AddCreatureRecord(id, record)
    end

    tes3mp.SendRecordDynamic(pid, false, false)
end

function BaseRecordStore:LoadEnchantments(pid)

    if self.storeType ~= "enchantment" then return end

    tes3mp.ClearRecords()
    tes3mp.SetRecordType(enumerations.recordType.ENCHANTMENT)

    for id, record in pairs(self.data.records) do
        packetBuilder.AddEnchantmentRecord(id, record)
    end

    tes3mp.SendRecordDynamic(pid, false, false)
end

function BaseRecordStore:LoadMiscellaneous(pid)

    if self.storeType ~= "miscellaneous" then return end

    tes3mp.ClearRecords()
    tes3mp.SetRecordType(enumerations.recordType.MISCELLANEOUS)

    for id, record in pairs(self.data.records) do
        packetBuilder.AddMiscellaneousRecord(id, record)
    end

    tes3mp.SendRecordDynamic(pid, false, false)
end

function BaseRecordStore:LoadNpcs(pid)

    if self.storeType ~= "npc" then return end

    tes3mp.ClearRecords()
    tes3mp.SetRecordType(enumerations.recordType.NPC)

    for id, record in pairs(self.data.records) do
        packetBuilder.AddNpcRecord(id, record)
    end

    tes3mp.SendRecordDynamic(pid, false, false)
end

function BaseRecordStore:LoadPotions(pid)

    if self.storeType ~= "potion" then return end

    tes3mp.ClearRecords()
    tes3mp.SetRecordType(enumerations.recordType.POTION)

    for id, record in pairs(self.data.records) do
        packetBuilder.AddPotionRecord(id, record)
    end

    tes3mp.SendRecordDynamic(pid, false, false)
end

function BaseRecordStore:LoadSpells(pid)

    if self.storeType ~= "spell" then return end

    tes3mp.ClearRecords()
    tes3mp.SetRecordType(enumerations.recordType.SPELL)

    for id, record in pairs(self.data.records) do
        packetBuilder.AddSpellRecord(id, record)
    end

    tes3mp.SendRecordDynamic(pid, false, false)
end

function BaseRecordStore:LoadWeapons(pid)

    if self.storeType ~= "weapon" then return end

    tes3mp.ClearRecords()
    tes3mp.SetRecordType(enumerations.recordType.WEAPON)

    for id, record in pairs(self.data.records) do
        packetBuilder.AddWeaponRecord(id, record)
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
            magnitudeMin = tes3mp.GetRecordEffectMagnitudeMin(recordIndex, effectIndex),
            magnitudeMax = tes3mp.GetRecordEffectMagnitudeMax(recordIndex, effectIndex)
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
