local BaseRecordStore = class("BaseRecordStore")

BaseRecordStore.defaultData = 
    {
        general = {
            currentGeneratedNum = 0
        },
        permanentRecords = {},
        generatedRecords = {},
        recordLinks = {},
        unlinkedRecordsToCheck = {}
    }

function BaseRecordStore:__init(storeType)

    self.data = tableHelper.shallowCopy(self.defaultData)
    self.storeType = storeType
end

function BaseRecordStore:HasEntry()
    return self.hasEntry
end

function BaseRecordStore:EnsureDataStructure()

    for key, value in pairs(self.defaultData) do
        if self.data[key] == nil then
            self.data[key] = tableHelper.shallowCopy(value)
        end
    end
end

function BaseRecordStore:GetCurrentGeneratedNum()
    return self.data.general.currentGeneratedNum
end

function BaseRecordStore:SetCurrentGeneratedNum(currentGeneratedNum)
    self.data.general.currentGeneratedNum = currentGeneratedNum
    self:QuicksaveToDrive()
end

function BaseRecordStore:IncrementGeneratedNum()
    self:SetCurrentGeneratedNum(self:GetCurrentGeneratedNum() + 1)
    return self:GetCurrentGeneratedNum()
end

function BaseRecordStore:GenerateRecordId()
    return config.generatedRecordIdPrefix .. "_" .. self.storeType .. "_" .. self:IncrementGeneratedNum()
end

-- Go through all the generated records that were at some point tracked as having no links remaining
-- and delete them if they still have no links
function BaseRecordStore:DeleteUnlinkedRecords()

    if type(self.data.unlinkedRecordsToCheck) == "table" then
        for arrayIndex, recordId in pairs(self.data.unlinkedRecordsToCheck) do
            if not self:HasLinks(recordId) then
                self:DeleteGeneratedRecord(recordId)
            end

            self.data.unlinkedRecordsToCheck[arrayIndex] = nil
        end
    end
end

function BaseRecordStore:DeleteGeneratedRecord(recordId)

    if self.data.generatedRecords[recordId] == nil then
        tes3mp.LogMessage(enumerations.log.WARN, "Tried deleting " .. self.storeType .. " record " .. recordId ..
            " which doesn't exist!")
        return
    end

    tes3mp.LogMessage(enumerations.log.WARN, "Deleting generated " .. self.storeType .. " record " .. recordId)

    -- Is this an enchantable record? If so, we should remove any links to it
    -- from its associated generated enchantment record if there is one
    if tableHelper.containsValue(config.enchantableRecordTypes, self.storeType) then
        local enchantmentId = self.data.generatedRecords[recordId].enchantmentId

        if enchantmentId ~= nil and logicHandler.IsGeneratedRecord(enchantmentId) then
            local enchantmentStore = RecordStores["enchantment"]
            enchantmentStore:RemoveLinkToRecord(enchantmentId, recordId, self.storeType)
            enchantmentStore:QuicksaveToDrive()
        end
    end

    self.data.generatedRecords[recordId] = nil

    if self.data.recordLinks[recordId] ~= nil then
        self.data.recordLinks[recordId] = nil
    end

    self:QuicksaveToDrive()
end

-- Check whether there are any links remaining to a certain generated record
function BaseRecordStore:HasLinks(recordId)

    local recordLinks = self.data.recordLinks

    if recordLinks[recordId] == nil then
        return false
    elseif (recordLinks[recordId].cells ~= nil and not tableHelper.isEmpty(recordLinks[recordId].cells)) or
        (recordLinks[recordId].players ~= nil and not tableHelper.isEmpty(recordLinks[recordId].players)) then
        return true
    -- Is this an enchantment record? If so, check for links to other records for enchantable items
    elseif self.storeType == "enchantment" then
        for _, enchantableType in pairs(config.enchantableRecordTypes) do
            if recordLinks[recordId].records ~= nil and recordLinks[recordId].records[enchantableType] ~= nil and not
                tableHelper.isEmpty(recordLinks[recordId].records[enchantableType]) then
                return true
            end
        end
    end

    return false
end

-- Add a link between a record and another record from a different record store,
-- i.e. for enchantments being used by other items
function BaseRecordStore:AddLinkToRecord(recordId, otherRecordId, otherStoreType)

    local recordLinks = self.data.recordLinks

    if recordLinks[recordId] == nil then recordLinks[recordId] = {} end
    if recordLinks[recordId].records == nil then recordLinks[recordId].records = {} end
    if recordLinks[recordId].records[otherStoreType] == nil then recordLinks[recordId].records[otherStoreType] = {} end

    if not tableHelper.containsValue(recordLinks[recordId].records[otherStoreType], otherRecordId) then
        table.insert(recordLinks[recordId].records[otherStoreType], otherRecordId)
    end
end

function BaseRecordStore:RemoveLinkToRecord(recordId, otherRecordId, otherStoreType)

    local recordLinks = self.data.recordLinks

    if recordLinks[recordId] ~= nil and recordLinks[recordId].records ~= nil and
        recordLinks[recordId].records[otherStoreType] ~= nil then

        local linkIndex = tableHelper.getIndexByValue(recordLinks[recordId].records[otherStoreType], otherRecordId)

        if linkIndex ~= nil then
            recordLinks[recordId].records[otherStoreType][linkIndex] = nil
        end

        if not self:HasLinks(recordId) then
            table.insert(self.data.unlinkedRecordsToCheck, recordId)
        end
    end
end

-- Add a link between a record and a cell it is found in
function BaseRecordStore:AddLinkToCell(recordId, cell)

    local cellDescription = cell.description
    local recordLinks = self.data.recordLinks

    if recordLinks[recordId] == nil then recordLinks[recordId] = {} end
    if recordLinks[recordId].cells == nil then recordLinks[recordId].cells = {} end

    if not tableHelper.containsValue(recordLinks[recordId].cells, cellDescription) then
        table.insert(recordLinks[recordId].cells, cellDescription)
    end
end

function BaseRecordStore:RemoveLinkToCell(recordId, cell)

    local cellDescription = cell.description
    local recordLinks = self.data.recordLinks

    if recordLinks[recordId] ~= nil and recordLinks[recordId].cells ~= nil then

        local linkIndex = tableHelper.getIndexByValue(recordLinks[recordId].cells, cellDescription)

        if linkIndex ~= nil then
            recordLinks[recordId].cells[linkIndex] = nil
        end

        if not self:HasLinks(recordId) then
            table.insert(self.data.unlinkedRecordsToCheck, recordId)
        end
    end
end

-- Add a link between a record and a player in whose inventory or spellbook it is found
function BaseRecordStore:AddLinkToPlayer(recordId, player)

    local accountName = player.accountName
    local recordLinks = self.data.recordLinks

    if recordLinks[recordId] == nil then recordLinks[recordId] = {} end
    if recordLinks[recordId].players == nil then recordLinks[recordId].players = {} end

    if not tableHelper.containsValue(recordLinks[recordId].players, accountName) then
        table.insert(recordLinks[recordId].players, accountName)
    end
end

function BaseRecordStore:RemoveLinkToPlayer(recordId, player)

    local accountName = player.accountName
    local recordLinks = self.data.recordLinks

    if recordLinks[recordId] == nil then recordLinks[recordId] = {} end
    if recordLinks[recordId].players == nil then recordLinks[recordId].players = {} end

    local linkIndex = tableHelper.getIndexByValue(recordLinks[recordId].players, accountName)

    if linkIndex ~= nil then
        recordLinks[recordId].players[linkIndex] = nil
    end

    if not self:HasLinks(recordId) then
        table.insert(self.data.unlinkedRecordsToCheck, recordId)
    end
end

function BaseRecordStore:LoadGeneratedRecords(pid, recordList, idArray, forEveryone)

    if type(recordList) ~= "table" then return end
    if type(idArray) ~= "table" then return end

    local validIdArray = {}

    -- If these are enchantable records, track generated enchantment records used by them
    -- and send them beforehand
    local isEnchantable = false
    local enchantmentIdArray

    if tableHelper.containsValue(config.enchantableRecordTypes, self.storeType) then
        isEnchantable = true
        enchantmentIdArray = {}
    end

    for _, recordId in pairs(idArray) do
        if not tableHelper.containsValue(Players[pid].generatedRecordsReceived, recordId) then

            table.insert(Players[pid].generatedRecordsReceived, recordId)
            table.insert(validIdArray, recordId)

            if isEnchantable then
                local record = recordList[recordId]
                local shouldLoadEnchantment = record ~= nil and record.enchantmentId ~= nil and
                    logicHandler.IsGeneratedRecord(record.enchantmentId) and not
                    tableHelper.containsValue(Players[pid].generatedRecordsReceived, record.enchantmentId)

                if shouldLoadEnchantment then
                    table.insert(enchantmentIdArray, record.enchantmentId)
                end
            end
        end
    end

    -- Load the associated generated enchantment records first
    if isEnchantable and not tableHelper.isEmpty(enchantmentIdArray) then
        local enchantmentStore = RecordStores["enchantment"]
        enchantmentStore:LoadRecords(pid, enchantmentStore.data.generatedRecords, enchantmentIdArray, forEveryone)
    end

    -- Load our own valid generated records
    self:LoadRecords(pid, recordList, validIdArray, forEveryone)
end

function BaseRecordStore:LoadRecords(pid, recordList, idArray, forEveryone)

    if type(recordList) ~= "table" then return end
    if type(idArray) ~= "table" then return end

    tes3mp.ClearRecords()
    tes3mp.SetRecordType(enumerations.recordType[string.upper(self.storeType)])
    local recordCount = 0

    for _, recordId in pairs(idArray) do
        local record = recordList[recordId]

        if record ~= nil then
            packetBuilder.AddRecordByType(recordId, record, self.storeType)
            recordCount = recordCount + 1
        end
    end

    if recordCount > 0 then
        tes3mp.SendRecordDynamic(pid, forEveryone, false)
    end
end

-- Check if a record is a perfect match for any of the records whose IDs
-- are contained in an ID array
function BaseRecordStore:GetMatchingRecordId(comparedRecord, recordList, idArray, ignoredKeys)

    if idArray == nil then
        return nil
    end

    for _, recordId in pairs(idArray) do
        local record = recordList[recordId]

        if record ~= nil and tableHelper.isEqualTo(comparedRecord, record, ignoredKeys) then
            return recordId
        end
    end

    return nil
end

function BaseRecordStore:SaveGeneratedEnchantedItems(pid)

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

            local recordId = self:GenerateRecordId()

            -- We don't need to track all the details of the enchanted items, just their base
            -- id and their enchantment information
            local record = {
                baseId = tes3mp.GetRecordBaseId(recordIndex),
                name = tes3mp.GetRecordName(recordIndex),
                enchantmentId = serverEnchantmentId,
                enchantmentCharge = tes3mp.GetRecordEnchantmentCharge(recordIndex)
            }

            self.data.generatedRecords[recordId] = record
            table.insert(recordAdditions, { index = recordIndex, id = recordId,
                enchantmentId = serverEnchantmentId })
        end
    end

    self:QuicksaveToDrive()
    return recordAdditions
end

function BaseRecordStore:SaveGeneratedEnchantments(pid)

    if self.storeType ~= "enchantment" then return end

    local recordAdditions = {}
    local recordCount = tes3mp.GetRecordCount(pid)

    for recordIndex = 0, recordCount - 1 do

        local recordId = self:GenerateRecordId()

        local effectCount = tes3mp.GetRecordEffectCount(recordIndex)
        tes3mp.LogAppend(enumerations.log.ERROR, "- Effects have count " .. effectCount)

        local record = {
            subtype = tes3mp.GetRecordSubtype(recordIndex),
            cost = tes3mp.GetRecordCost(recordIndex),
            charge = tes3mp.GetRecordCharge(recordIndex),
            autoCalc = tes3mp.GetRecordAutoCalc(recordIndex),
            effects = packetReader.GetRecordEffects(recordIndex)
        }

        self.data.generatedRecords[recordId] = record
        table.insert(recordAdditions, { index = recordIndex, id = recordId,
            clientsideId = tes3mp.GetRecordId(recordIndex) })
    end

    self:QuicksaveToDrive()
    return recordAdditions
end

function BaseRecordStore:SaveGeneratedPotions(pid)

    if self.storeType ~= "potion" then return end

    local recordAdditions = {}
    local recordCount = tes3mp.GetRecordCount(pid)

    for recordIndex = 0, recordCount - 1 do

        local effectCount = tes3mp.GetRecordEffectCount(recordIndex)
        tes3mp.LogAppend(enumerations.log.ERROR, "- Effects have count " .. effectCount)

        local record = {
            name = tes3mp.GetRecordName(recordIndex),
            weight = tes3mp.GetRecordWeight(recordIndex),
            value = tes3mp.GetRecordValue(recordIndex),
            autoCalc = tes3mp.GetRecordAutoCalc(recordIndex),
            icon = tes3mp.GetRecordIcon(recordIndex),
            model = tes3mp.GetRecordModel(recordIndex),
            script = tes3mp.GetRecordScript(recordIndex),
            effects = packetReader.GetRecordEffects(recordIndex)
        }

        -- Is there already a record exactly like this one, icon and model aside?
        -- If so, we'll just reuse it the way OpenMW would
        local recordId = self:GetMatchingRecordId(record, self.data.generatedRecords,
            Players[pid].data.recordLinks.potion, {"icon", "model"})

        if recordId == nil then
            recordId = self:GenerateRecordId()
            self.data.generatedRecords[recordId] = record
        end

        table.insert(recordAdditions, { index = recordIndex, id = recordId })
    end

    self:QuicksaveToDrive()
    return recordAdditions
end

function BaseRecordStore:SaveGeneratedSpells(pid)

    if self.storeType ~= "spell" then return end

    local recordAdditions = {}
    local recordCount = tes3mp.GetRecordCount(pid)

    for recordIndex = 0, recordCount - 1 do

        local recordId = self:GenerateRecordId()

        local effectCount = tes3mp.GetRecordEffectCount(recordIndex)
        tes3mp.LogAppend(enumerations.log.ERROR, "- Effects have count " .. effectCount)

        local record = {
            name = tes3mp.GetRecordName(recordIndex),
            subtype = tes3mp.GetRecordSubtype(recordIndex),
            cost = tes3mp.GetRecordCost(recordIndex),
            flags = tes3mp.GetRecordFlags(recordIndex),
            effects = packetReader.GetRecordEffects(recordIndex)
        }

        self.data.generatedRecords[recordId] = record
        table.insert(recordAdditions, { index = recordIndex, id = recordId })
    end

    self:QuicksaveToDrive()
    return recordAdditions
end

return BaseRecordStore
