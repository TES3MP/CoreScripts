require("config")
require("patterns")
stateHelper = require("stateHelper")
tableHelper = require("tableHelper")
local BasePlayer = class("BasePlayer")

function BasePlayer:__init(pid, playerName)
    self.dbPid = nil

    self.data =
    {
        login = {
            name = "",
            passwordSalt = "",
            passwordHash = ""
        },
        timestamps = {
            creation = os.time(),
            lastLogin = os.time(),
            lastDisconnect = 0,
            lastFixMe = 0,
            lastSessionDuration = 0
        },
        settings = {
            staffRank = 0,
            difficulty = "default",
            consoleAllowed = "default",
            bedRestAllowed = "default",
            wildernessRestAllowed = "default",
            waitAllowed = "default",
            enforcedLogLevel = "default",
            physicsFramerate = "default"
        },
        character = {
            race = "",
            head = "",
            hair = "",
            gender = 1,
            class = "",
            birthsign = ""
        },
        location = {
            cell = "",
            regionName = "",
            posX = 0,
            posY = 0,
            posZ = 0,
            rotX = 0,
            rotZ = 0
        },
        stats = {
            level = 1,
            levelProgress = 0,
            healthBase = 1,
            healthCurrent = 1,
            magickaBase = 1,
            magickaCurrent = 1,
            fatigueBase = 1,
            fatigueCurrent = 1
        },
        fame = {
            bounty = 0,
            reputation = 0
        },
        miscellaneous = {
            markLocation = {
                cell = "",
                posX = 0,
                posY = 0,
                posZ = 0,
                rotX = 0,
                rotZ = 0
            },
            selectedSpell = ""
        },
        customClass = {},
        attributes = {},
        skills = {},
        equipment = {},
        inventory = {},
        spellbook = {},
        spellsActive = {},
        cooldowns = {},
        quickKeys = {},
        shapeshift = {},
        journal = {},
        factionRanks = {},
        factionExpulsion = {},
        factionReputation = {},
        topics = {},
        books = {},
        mapExplored = {},
        ipAddresses = {},
        recordLinks = {},
        alliedPlayers = {},
        destinationOverrides = {},
        customVariables = {}
    }

    for index = 0, (tes3mp.GetAttributeCount() - 1) do
        local attributeName = tes3mp.GetAttributeName(index)
        self.data.attributes[attributeName] = {
            base = 1,
            damage = 0,
            skillIncrease = 0
        }
    end

    for index = 0, (tes3mp.GetSkillCount() - 1) do
        local skillName = tes3mp.GetSkillName(index)
        self.data.skills[skillName] = {
            base = 1,
            damage = 0,
            progress = 0
        }
    end

    if playerName == nil then
        self.accountName = tes3mp.GetName(pid)
    else
        self.accountName = playerName
    end

    self.pid = pid
    self.loggedIn = false
    self.isNewlyRegistered = false
    self.loginTimerId = nil
    self.hasAccount = nil

    self.cellsLoaded = {}
    self.summons = {}
    self.generatedRecordsReceived = {}
    self.unresolvedEnchantments = {}
    self.previousEquipment = {}
    self.consoleCommandsQueued = {}

    self.hasFinishedInitialTeleportation = false
end

function BasePlayer:Destroy()
    if self.loginTimerId ~= nil then
        tes3mp.StopTimer(self.loginTimerId)
        self.loginTimerId = nil
    end

    self.loggedIn = false
    self.hasAccount = nil
end

function BasePlayer:Kick()
    self:Destroy()
    tes3mp.Kick(self.pid)
end

function BasePlayer:GenerateSaltedHash(inputString)
    self.data.login.passwordSalt = tes3mp.GenerateRandomString(64)
    self.data.login.passwordHash = tes3mp.GetSHA256Hash(inputString .. self.data.login.passwordSalt)
end

-- Replace any plaintext passwords with an unpredictable serverside
-- salted hash of a predictable clientside salted hash
function BasePlayer:ConvertPlaintextPassword()
    local inputHash = tes3mp.GetSHA256Hash(self.data.login.password)
    inputHash = tes3mp.GetSHA256Hash(inputHash .. tes3mp.GetSHA256Hash(tes3mp.GetSHA256Hash(inputHash)))
    self:GenerateSaltedHash(inputHash)
    self.data.login.password = nil
end

function BasePlayer:Register(clientPasswordHash)
    self.loggedIn = true
    self.isNewlyRegistered = true
    self:GenerateSaltedHash(clientPasswordHash)
    self.data.settings.consoleAllowed = "default"

    if not self.hasAccount then
        tes3mp.SetCharGenStage(self.pid, 1, 4)
    end
end

function BasePlayer:FinishLogin()

    if self.hasAccount then
        self:SaveIpAddress()

        if self.data.timestamps == nil then
            self.data.timestamps = {
                creation = os.time(),
                lastDisconnect = 0,
                lastFixMe = 0,
                lastSessionDuration = 0
            }
        end

        self.data.timestamps.lastLogin = os.time()

        self:LoadSettings()
        self:LoadCharacter()
        self:LoadClass()
        self:LoadLevel()
        self:LoadAttributes()
        self:LoadSkills()
        self:LoadStatsDynamic()

        WorldInstance:LoadTime(self.pid, false)
        WorldInstance:LoadWeather(self.pid, false)

        if self.data.recordLinks == nil then self.data.recordLinks = {} end

        -- Load high priority records linked to us, then load lower priority permanent
        -- records and lower priority records linked to this player
        for priorityLevel, recordStoreTypes in ipairs(config.recordStoreLoadOrder) do
            for _, storeType in ipairs(recordStoreTypes) do
                local recordStore = RecordStores[storeType]

                if recordStore ~= nil then
                    -- Skip permanent records from high priority stores here because those
                    -- were already loaded upon first connecting to the server
                    if priorityLevel > 1 then
                        recordStore:LoadRecords(self.pid, recordStore.data.permanentRecords,
                            tableHelper.getArrayFromIndexes(recordStore.data.permanentRecords))
                    end

                    -- Load the generated records linked to us in this record store
                    if self.data.recordLinks[storeType] ~= nil then
                        recordStore:LoadGeneratedRecords(self.pid, recordStore.data.generatedRecords,
                            self.data.recordLinks[storeType])
                    end
                end
            end
        end

        self:CleanInventory()
        self:LoadInventory()
        self:LoadEquipment()
        self:CleanSpellbook()
        self:LoadSpellbook()
        self:LoadSpellsActive()
        self:LoadCooldowns()
        self:LoadQuickKeys()
        self:LoadBooks()
        self:LoadShapeshift()
        self:LoadMarkLocation()
        self:LoadSelectedSpell()

        if config.shareJournal == true then
            WorldInstance:LoadJournal(self.pid)
        else
            self:LoadJournal()
        end

        if config.shareFactionRanks == true then
            WorldInstance:LoadFactionRanks(self.pid)
        else
            self:LoadFactionRanks()
        end

        if config.shareFactionExpulsion == true then
            WorldInstance:LoadFactionExpulsion(self.pid)
        else
            self:LoadFactionExpulsion()
        end

        if config.shareFactionReputation == true then
            WorldInstance:LoadFactionReputation(self.pid)
        else
            self:LoadFactionReputation()
        end

        if config.shareTopics == true then
            WorldInstance:LoadTopics(self.pid)
        else
            self:LoadTopics()
        end

        if config.shareBounty == true then
            WorldInstance:LoadBounty(self.pid)
        else
            self:LoadBounty()
        end

        if config.shareReputation == true then
            WorldInstance:LoadReputation(self.pid)
        else
            self:LoadReputation()
        end

        WorldInstance:LoadKills(self.pid)

        self:LoadSpecialStates()

        if config.shareMapExploration == true then
            WorldInstance:LoadMap(self.pid)
        else
            self:LoadMap()
        end

        self:LoadClientScriptVariables()        
        WorldInstance:LoadClientScriptVariables(self.pid)

        self:LoadDestinationOverrides()
        WorldInstance:LoadDestinationOverrides(self.pid)

        self:LoadAllies()
        self:LoadCell()

        self.loggedIn = true

        if self.data.alliedPlayers == nil then self.data.alliedPlayers = {} end

        for _, otherAccountName in ipairs(self.data.alliedPlayers) do
            if logicHandler.IsPlayerNameLoggedIn(otherAccountName) then
                local otherPlayer = logicHandler.GetPlayerByName(otherAccountName)
                otherPlayer:LoadAllies()
            end
        end

        self:RunPlayerSpecificStartupScripts()
        
        customEventHooks.triggerHandlers("OnPlayerFinishLogin", customEventHooks.makeEventStatus(true, true), {self.pid})
        customEventHooks.triggerHandlers("OnPlayerAuthentified", customEventHooks.makeEventStatus(true, true), {self.pid})
    end
end

function BasePlayer:EndCharGen()
    self:SaveLogin()
    self:SaveCharacter()
    self:SaveClass(packetReader.GetPlayerPacketTables(self.pid, "PlayerClass"))
    self:SaveStatsDynamic(packetReader.GetPlayerPacketTables(self.pid, "PlayerStatsDynamic"))
    self:SaveEquipment(packetReader.GetPlayerPacketTables(self.pid, "PlayerEquipment"))
    self:SaveIpAddress()
    self:CreateAccount()

    WorldInstance:LoadTime(self.pid, false)
    WorldInstance:LoadWeather(self.pid, false, true)

    local spawnUsed

    if config.useInstancedSpawn == true and config.instancedSpawn ~= nil then
        spawnUsed = tableHelper.shallowCopy(config.instancedSpawn)
        local originalCellDescription = spawnUsed.cellDescription
        spawnUsed.cellDescription = originalCellDescription .. " - Instance for " .. self.name
    elseif config.noninstancedSpawn ~= nil then
        spawnUsed = config.noninstancedSpawn
    end

    -- Load lower priority permanent records
    for priorityLevel, recordStoreTypes in ipairs(config.recordStoreLoadOrder) do
        if priorityLevel > 1 then
            for _, storeType in ipairs(recordStoreTypes) do
                local recordStore = RecordStores[storeType]

                -- Load all the permanent records in this record store
                recordStore:LoadRecords(self.pid, recordStore.data.permanentRecords,
                    tableHelper.getArrayFromIndexes(recordStore.data.permanentRecords))
            end
        end
    end

    if config.shareJournal == true then
        WorldInstance:LoadJournal(self.pid)
    end

    if config.shareFactionRanks == true then
        WorldInstance:LoadFactionRanks(self.pid)
    end

    if config.shareFactionExpulsion == true then
        WorldInstance:LoadFactionExpulsion(self.pid)
    end

    if config.shareFactionReputation == true then
        WorldInstance:LoadFactionReputation(self.pid)
    end

    if config.shareTopics == true then
        WorldInstance:LoadTopics(self.pid)
    end

    WorldInstance:LoadKills(self.pid)

    if spawnUsed ~= nil and spawnUsed.cellDescription ~= nil then
        tes3mp.SetCell(self.pid, spawnUsed.cellDescription)
        tes3mp.SendCell(self.pid)

        if spawnUsed.position ~= nil and spawnUsed.rotation ~= nil then
            tes3mp.SetPos(self.pid, spawnUsed.position[1], spawnUsed.position[2], spawnUsed.position[3])
            tes3mp.SetRot(self.pid, spawnUsed.rotation[1], spawnUsed.rotation[2])
            tes3mp.SendPos(self.pid)
        end

        if spawnUsed.text then
            tes3mp.MessageBox(self.pid, -1, spawnUsed.text)
        end

        if spawnUsed.items then
            for _, item in pairs(spawnUsed.items) do
                inventoryHelper.addItem(self.data.inventory, item.refId, item.count, item.charge,
                    item.enchantmentCharge, item.soul)
            end
            self:LoadItemChanges(spawnUsed.items, enumerations.inventory.ADD)
        end
    end

    self:RunPlayerSpecificStartupScripts()
end

function BasePlayer:IsLoggedIn()
    return self.loggedIn
end

function BasePlayer:IsServerStaff()
    return self.data.settings.staffRank > 0
end

function BasePlayer:IsServerOwner()
    return self.data.settings.staffRank == 3
end

function BasePlayer:IsAdmin()
    return self.data.settings.staffRank >= 2
end

function BasePlayer:IsModerator()
    return self.data.settings.staffRank >= 1
end

function BasePlayer:AddLinkToRecord(storeType, recordId)

    if self.data.recordLinks == nil then self.data.recordLinks = {} end

    local recordStore = RecordStores[storeType]

    if recordStore ~= nil then

        local recordLinks = self.data.recordLinks

        if recordLinks[storeType] == nil then recordLinks[storeType] = {} end

        if not tableHelper.containsValue(recordLinks[storeType], recordId) then
            table.insert(recordLinks[storeType], recordId)
        end

        recordStore:AddLinkToPlayer(recordId, self)
        recordStore:QuicksaveToDrive()
    end
end

function BasePlayer:RemoveLinkToRecord(storeType, recordId)

    local recordStore = RecordStores[storeType]

    if recordStore ~= nil then

        local recordLinks = self.data.recordLinks

        if recordLinks ~= nil and recordLinks[storeType] ~= nil then

            local linkIndex = tableHelper.getIndexByValue(recordLinks[storeType], recordId)

            if linkIndex ~= nil then
                recordLinks[storeType][linkIndex] = nil
                tableHelper.cleanNils(recordLinks[storeType])
            end

            recordStore:RemoveLinkToPlayer(recordId, self)
            recordStore:QuicksaveToDrive()
        end
    end
end

function BasePlayer:GetHealthCurrent()
    self.data.stats.healthCurrent = tes3mp.GetHealthCurrent(self.pid)
    return self.data.stats.healthCurrent
end

function BasePlayer:SetHealthCurrent(health)
    self.data.stats.healthCurrent = health
    tes3mp.SetHealthCurrent(self.pid, health)
end

function BasePlayer:GetHealthBase()
    self.data.stats.healthBase = tes3mp.GetHealthBase(self.pid)
    return self.data.stats.healthBase
end

function BasePlayer:SetHealthBase(health)
    self.data.stats.healthBase = health
    tes3mp.SetHealthBase(self.pid, health)
end

function BasePlayer:HasAccount()
    return self.hasAccount
end

function BasePlayer:Message(message)
    tes3mp.SendMessage(self.pid, message, false)
end

function BasePlayer:CreateAccount()
    error("Not implemented")
end

function BasePlayer:SaveToDrive()
    error("Not implemented")
end

function BasePlayer:LoadFromDrive()
    error("Not implemented")
end

function BasePlayer:SaveLogin()
    self.data.login.name = tes3mp.GetName(self.pid)
end

function BasePlayer:SaveIpAddress()
    if self.data.ipAddresses == nil then
        self.data.ipAddresses = {}
    end

    local ipAddress = tes3mp.GetIP(self.pid)

    if not tableHelper.containsValue(self.data.ipAddresses, ipAddress) then
        table.insert(self.data.ipAddresses, ipAddress)
    end
end

function BasePlayer:ProcessDeath()

    -- Clear this player's active spell effects
    self.data.spellsActive = {}

    local deathReason = "committed suicide"

    if tes3mp.DoesPlayerHavePlayerKiller(self.pid) then
        local killerPid = tes3mp.GetPlayerKillerPid(self.pid)

        if self.pid ~= killerPid then
            deathReason = "was killed by player " .. logicHandler.GetChatName(killerPid)
        end
    else
        local killerName = tes3mp.GetPlayerKillerName(self.pid)

        if killerName ~= "" then
            deathReason = "was killed by " .. killerName
        end
    end

    local message = logicHandler.GetChatName(self.pid) .. " " .. deathReason .. ".\n"

    tes3mp.SendMessage(self.pid, message, true)

    if config.playersRespawn then
        self.resurrectTimerId = tes3mp.CreateTimerEx("OnDeathTimeExpiration",
            time.seconds(config.deathTime), "is", self.pid, self.accountName)
        tes3mp.StartTimer(self.resurrectTimerId)
    else
        tes3mp.SendMessage(self.pid, "You have died permanently.", false)
    end
end

function BasePlayer:Resurrect()

    local currentResurrectType = enumerations.resurrect.REGULAR

    if config.respawnAtImperialShrine == true then
        if config.respawnAtTribunalTemple == true then
            if math.random() > 0.5 then
                currentResurrectType = enumerations.resurrect.IMPERIAL_SHRINE
            else
                currentResurrectType = enumerations.resurrect.TRIBUNAL_TEMPLE
            end
        else
            currentResurrectType = enumerations.resurrect.IMPERIAL_SHRINE
        end

    elseif config.respawnAtTribunalTemple == true then
        currentResurrectType = enumerations.resurrect.TRIBUNAL_TEMPLE

    elseif config.defaultRespawn ~= nil and config.defaultRespawn.cellDescription ~= nil then
        currentResurrectType = enumerations.resurrect.REGULAR

        tes3mp.SetCell(self.pid, config.defaultRespawn.cellDescription)
        tes3mp.SendCell(self.pid)

        if config.defaultRespawn.position ~= nil and config.defaultRespawn.rotation ~= nil then
            tes3mp.SetPos(self.pid, config.defaultRespawn.position[1],
                config.defaultRespawn.position[2], config.defaultRespawn.position[3])
            tes3mp.SetRot(self.pid, config.defaultRespawn.rotation[1], config.defaultRespawn.rotation[2])
            tes3mp.SendPos(self.pid)
        end
    end

    local message = "You have been revived"

    if currentResurrectType == enumerations.resurrect.IMPERIAL_SHRINE then
        message = message .. " at the nearest Imperial shrine"
    elseif currentResurrectType == enumerations.resurrect.TRIBUNAL_TEMPLE then
        message = message .. " at the nearest Tribunal temple"
    end

    message = message .. ".\n"

    -- Ensure that dying as a werewolf turns you back into your normal form
    if self.data.shapeshift.isWerewolf == true then
        self:SetWerewolfState(false)
    end

    -- Ensure that we unequip deadly items when applicable, to prevent an
    -- infinite death loop
    contentFixer.UnequipDeadlyItems(self.pid)

    tes3mp.Resurrect(self.pid, currentResurrectType)

    if config.deathPenaltyJailDays > 0 or config.bountyDeathPenalty then
        local jailTime = 0
        local resurrectionText = "You've been revived and brought back here, " ..
            "but your skills have been affected by "

        if config.bountyDeathPenalty then
            local currentBounty = tes3mp.GetBounty(self.pid)

            if currentBounty > 0 then
                jailTime = jailTime + math.floor(currentBounty / 100)
                resurrectionText = resurrectionText .. "your bounty"
            end
        end

        if config.deathPenaltyJailDays > 0 then
            if jailTime > 0 then
                resurrectionText = resurrectionText .. " and "
            end

            jailTime = jailTime + config.deathPenaltyJailDays
            resurrectionText = resurrectionText .. "your time spent incapacitated"    
        end

        resurrectionText = resurrectionText .. ".\n"
        tes3mp.Jail(self.pid, jailTime, true, true, "Recovering", resurrectionText)
    end

    if config.bountyResetOnDeath then
        tes3mp.SetBounty(self.pid, 0)
        tes3mp.SendBounty(self.pid)
        self:SaveBounty()
    end

    tes3mp.SendMessage(self.pid, message, false)
end

function BasePlayer:DeleteSummons()

    if self.summons ~= nil then
        for summonUniqueIndex, summonRefId in pairs(self.summons) do
            tes3mp.LogAppend(enumerations.log.INFO, "- removing player's summon " .. summonUniqueIndex ..
                ", refId " .. summonRefId)

            local cell = logicHandler.GetCellContainingActor(summonUniqueIndex)

            if cell ~= nil then
                cell:DeleteObjectData(summonUniqueIndex)
                logicHandler.DeleteObjectForEveryone(cell.description, summonUniqueIndex)
            end
        end
    end
end

function BasePlayer:SaveDataByPacketType(packetType, playerPacket)
    if packetType == "PlayerAttribute" then
        self:SaveAttributes(playerPacket)
    elseif packetType == "PlayerSkill" then
        self:SaveSkills(playerPacket)
    elseif packetType == "PlayerLevel" then
        self:SaveLevel(playerPacket)
    elseif packetType == "PlayerShapeshift" then
        self:SaveShapeshift(playerPacket)
    elseif packetType == "PlayerEquipment" then
        self:SaveEquipment(playerPacket)
    elseif packetType == "PlayerInventory" then
        self:SaveInventory(playerPacket)
    elseif packetType == "PlayerSpellbook" then
        self:SaveSpellbook(playerPacket)
    elseif packetType == "PlayerCooldowns" then
        self:SaveCooldowns(playerPacket)
    elseif packetType == "PlayerQuickKeys" then
        self:SaveQuickKeys(playerPacket)
    end
end

function BasePlayer:LoadCharacter()
    tes3mp.SetRace(self.pid, self.data.character.race)
    tes3mp.SetHead(self.pid, self.data.character.head)
    tes3mp.SetHair(self.pid, self.data.character.hair)
    tes3mp.SetIsMale(self.pid, self.data.character.gender)
    if self.data.character.modelOverride ~= nil then
        tes3mp.SetModel(self.pid, self.data.character.modelOverride)
    end
    tes3mp.SetBirthsign(self.pid, self.data.character.birthsign)

    tes3mp.SendBaseInfo(self.pid)
end

function BasePlayer:SaveCharacter()
    self.data.character.race = tes3mp.GetRace(self.pid)
    self.data.character.head = tes3mp.GetHead(self.pid)
    self.data.character.hair = tes3mp.GetHair(self.pid)
    self.data.character.gender = tes3mp.GetIsMale(self.pid)
    self.data.character.modelOverride = tes3mp.GetModel(self.pid)
    self.data.character.birthsign = tes3mp.GetBirthsign(self.pid)
end

function BasePlayer:LoadClass()
    if self.data.character.class ~= "custom" then
        tes3mp.SetDefaultClass(self.pid, self.data.character.class)
    elseif self.data.customClass ~= nil then
        tes3mp.SetClassName(self.pid, self.data.customClass.name)
        tes3mp.SetClassSpecialization(self.pid, self.data.customClass.specialization)

        if self.data.customClass.description ~= nil then
            tes3mp.SetClassDesc(self.pid, self.data.customClass.description)
        end

        local index = 0
        for value in string.gmatch(self.data.customClass.majorAttributes, patterns.commaSplit) do
            tes3mp.SetClassMajorAttribute(self.pid, index, tes3mp.GetAttributeId(value))
            index = index + 1
        end

        index = 0
        for value in string.gmatch(self.data.customClass.majorSkills, patterns.commaSplit) do
            tes3mp.SetClassMajorSkill(self.pid, index, tes3mp.GetSkillId(value))
            index = index + 1
        end

        index = 0
        for value in string.gmatch(self.data.customClass.minorSkills, patterns.commaSplit) do
            tes3mp.SetClassMinorSkill(self.pid, index, tes3mp.GetSkillId(value))
            index = index + 1
        end
    end

    tes3mp.SendClass(self.pid)
end

function BasePlayer:SaveClass(playerPacket)

    self.data.character.class = playerPacket.character.class

    if playerPacket.character.defaultClassState == 0 then
        for key, value in pairs(playerPacket.customClass) do
            self.data.customClass[key] = tableHelper.deepCopy(playerPacket.customClass[key])
        end
    end
end

function BasePlayer:LoadStatsDynamic()

    local healthBase

    if tes3mp.IsWerewolf(self.pid) then
        healthBase = self.data.shapeshift.werewolfHealthBase
    else
        healthBase = self.data.stats.healthBase
    end

    tes3mp.SetHealthBase(self.pid, healthBase)
    tes3mp.SetMagickaBase(self.pid, self.data.stats.magickaBase)
    tes3mp.SetFatigueBase(self.pid, self.data.stats.fatigueBase)
    tes3mp.SetHealthCurrent(self.pid, self.data.stats.healthCurrent)
    tes3mp.SetMagickaCurrent(self.pid, self.data.stats.magickaCurrent)
    tes3mp.SetFatigueCurrent(self.pid, self.data.stats.fatigueCurrent)

    tes3mp.SendStatsDynamic(self.pid)
end

function BasePlayer:SaveStatsDynamic(playerPacket)

    local healthBase = playerPacket.stats.healthBase

    -- Sometimes, the player's base health gets set to 1 serverside;
    -- use this temporary fix until we figure out why
    if healthBase > 1 then

        if tes3mp.IsWerewolf(self.pid) then
            self.data.shapeshift.werewolfHealthBase = healthBase
        else
            self.data.stats.healthBase = healthBase
        end

        self.data.stats.magickaBase = playerPacket.stats.magickaBase
        self.data.stats.fatigueBase = playerPacket.stats.fatigueBase
        self.data.stats.healthCurrent = playerPacket.stats.healthCurrent
        self.data.stats.magickaCurrent = playerPacket.stats.magickaCurrent
        self.data.stats.fatigueCurrent = playerPacket.stats.fatigueCurrent
    end
end

function BasePlayer:LoadAttributes()

    for attributeName, value in pairs(self.data.attributes) do
        local attributeId = tes3mp.GetAttributeId(attributeName)

        if type(value) == "table" then
            tes3mp.SetAttributeBase(self.pid, attributeId, value.base)
            tes3mp.SetAttributeDamage(self.pid, attributeId, value.damage)
            tes3mp.SetSkillIncrease(self.pid, attributeId, value.skillIncrease)

        -- Maintain backwards compatibility with the old way of storing skills
        elseif type(value) == "number" then
            tes3mp.SetAttributeBase(self.pid, attributeId, value)
        end
    end

    tes3mp.SendAttributes(self.pid)
end

function BasePlayer:SaveAttributes(playerPacket)

    for attributeName in pairs(self.data.attributes) do

        local attributeId = tes3mp.GetAttributeId(attributeName)
        local attribute = playerPacket.attributes[attributeName]
        local maxAttributeValue = config.maxAttributeValue

        if attributeName == "Speed" then
            maxAttributeValue = config.maxSpeedValue
        end

        if attribute.base > maxAttributeValue then
            self:LoadAttributes()

            local message = "Your base " .. attributeName .. " has exceeded the maximum allowed value " ..
                "and been reset to its last recorded one.\n"
            tes3mp.SendMessage(self.pid, message)
        elseif (attribute.base + attribute.modifier) > maxAttributeValue then
            tes3mp.ClearAttributeModifier(self.pid, attributeId)
            tes3mp.SendAttributes(self.pid)

            local message = "Your " .. attributeName .. " fortification has exceeded the maximum allowed " ..
                "value and been removed.\n"
            tes3mp.SendMessage(self.pid, message)
        else
            self.data.attributes[attributeName] = {
                base = attribute.base,
                damage = attribute.damage,
                skillIncrease = attribute.skillIncrease
            }
        end
    end
end

function BasePlayer:LoadSkills()

    for skillName, value in pairs(self.data.skills) do

        local skillId = tes3mp.GetSkillId(skillName)

        if type(value) == "table" then
            tes3mp.SetSkillBase(self.pid, skillId, value.base)
            tes3mp.SetSkillDamage(self.pid, skillId, value.damage)
            tes3mp.SetSkillProgress(self.pid, skillId, value.progress)

        -- Maintain backwards compatibility with the old way of storing skills
        elseif type(value) == "number" then
            tes3mp.SetSkillBase(self.pid, skillId, value)
        end
    end

    tes3mp.SendSkills(self.pid)
end

function BasePlayer:SaveSkills(playerPacket)

    for skillName in pairs(self.data.skills) do

        local skillId = tes3mp.GetSkillId(skillName)
        local skill = playerPacket.skills[skillName]
        local maxSkillValue = config.maxSkillValue

        if skillName == "Acrobatics" then
            maxSkillValue = config.maxAcrobaticsValue
        end

        if skill.base > maxSkillValue then
            self:LoadSkills()

            local message = "Your base " .. skillName .. " has exceeded the maximum allowed value " ..
                "and been reset to its last recorded one.\n"
            tes3mp.SendMessage(self.pid, message)
        elseif (skill.base + skill.modifier) > maxSkillValue and not config.ignoreModifierWithMaxSkill then
            tes3mp.ClearSkillModifier(self.pid, skillId)
            tes3mp.SendSkills(self.pid)

            local message = "Your " .. skillName .. " fortification has exceeded the maximum allowed " ..
                "value and been removed.\n"
            tes3mp.SendMessage(self.pid, message)
        else
            self.data.skills[skillName] = {
                base = skill.base,
                damage = skill.damage,
                progress = skill.progress
            }
        end
    end
end

function BasePlayer:LoadLevel()

    if self.data.stats.level == nil then self.data.stats.level = 1 end
    if self.data.stats.levelProgress == nil then self.data.stats.levelProgress = 0 end

    tes3mp.SetLevel(self.pid, self.data.stats.level)
    tes3mp.SetLevelProgress(self.pid, self.data.stats.levelProgress)
    tes3mp.SendLevel(self.pid)
end

function BasePlayer:SaveLevel(playerPacket)
    self.data.stats.level = playerPacket.stats.level
    self.data.stats.levelProgress = playerPacket.stats.levelProgress
end

function BasePlayer:LoadShapeshift()

    if self.data.shapeshift == nil then self.data.shapeshift = {} end
    if self.data.shapeshift.scale == nil then self.data.shapeshift.scale = 1 end
    if self.data.shapeshift.isWerewolf == nil then self.data.shapeshift.isWerewolf = false end
    if self.data.shapeshift.creatureRefId == nil then self.data.shapeshift.creatureRefId = "" end
    if self.data.shapeshift.displayCreatureName == nil then self.data.shapeshift.displayCreatureName = false end

    tes3mp.SetScale(self.pid, self.data.shapeshift.scale)
    tes3mp.SetWerewolfState(self.pid, self.data.shapeshift.isWerewolf)
    tes3mp.SetCreatureRefId(self.pid, self.data.shapeshift.creatureRefId)
    tes3mp.SetCreatureNameDisplayState(self.pid, self.data.shapeshift.displayCreatureName)
    tes3mp.SendShapeshift(self.pid)
end

function BasePlayer:SaveShapeshift(playerPacket)

    if self.data.shapeshift == nil then self.data.shapeshift = {} end

    local newScale = playerPacket.shapeshift.scale

    if newScale ~= self.data.shapeshift.scale then
        tes3mp.LogMessage(enumerations.log.INFO, "Player " .. logicHandler.GetChatName(self.pid) ..
            " has changed their scale to " .. newScale)
        self.data.shapeshift.scale = newScale
    end

    self.data.shapeshift.isWerewolf = playerPacket.shapeshift.isWerewolf
end

function BasePlayer:LoadCell()

    if self.data.location ~= nil then
        local newCell = self.data.location.cell

        if newCell ~= nil then

            tes3mp.SetCell(self.pid, newCell)

            local pos = { self.data.location.posX, self.data.location.posY, self.data.location.posZ }
            local rot = { self.data.location.rotX, self.data.location.rotZ }

            if pos[1] ~= nil and pos[2] ~= nil and pos[3] ~= nil then
                tes3mp.SetPos(self.pid, pos[1], pos[2], pos[3])
            end

            if rot[1] ~= nil and rot[2] ~= nil then
                tes3mp.SetRot(self.pid, rot[1], rot[2])
            end

            tes3mp.SendCell(self.pid)
            tes3mp.SendPos(self.pid)

            local regionName = self.data.location.regionName

            if regionName ~= nil then
                logicHandler.LoadRegionForPlayer(self.pid, regionName, true)
            end
        end
    end
end

function BasePlayer:SaveCell(playerPacket)

    if self.data.location == nil then self.data.location = {} end

    -- Keep this around to update old player files
    if self.data.mapExplored == nil then self.data.mapExplored = {} end

    self.data.location.cell = playerPacket.location.cell
    self.data.location.posX = playerPacket.location.posX
    self.data.location.posY = playerPacket.location.posY
    self.data.location.posZ = playerPacket.location.posZ
    self.data.location.rotX = playerPacket.location.rotX
    self.data.location.rotZ = playerPacket.location.rotZ

    stateHelper:SaveMapExploration(self.pid, self)
end

function BasePlayer:LoadEquipment()

    for index = 0, tes3mp.GetEquipmentSize() - 1 do

        local currentItem = self.data.equipment[index]

        if currentItem ~= nil then
            if currentItem.enchantmentCharge == nil then
                currentItem.enchantmentCharge = -1
            end

            tes3mp.EquipItem(self.pid, index, currentItem.refId, currentItem.count,
                currentItem.charge, currentItem.enchantmentCharge)
        else
            tes3mp.UnequipItem(self.pid, index)
        end
    end

    -- Store a copy of previous equipment to understand when any given
    -- equipment item's count, charge or enchantmentCharge have changed
    self.previousEquipment = tableHelper.deepCopy(self.data.equipment)

    tes3mp.SendEquipment(self.pid)
end

function BasePlayer:SaveEquipment(playerPacket)

    local reloadAtEnd = false

    for slot, equipmentItem in pairs(playerPacket.equipment) do
        local newRefId = equipmentItem.refId

        if newRefId ~= "" and tableHelper.containsValue(config.bannedEquipmentItems, newRefId) then
            self:Message("You have tried wearing an item that isn't allowed!\n")
            reloadAtEnd = true
        else
            local newCount = equipmentItem.count
            local newCharge = equipmentItem.charge
            local newEnchantmentCharge = equipmentItem.enchantmentCharge

            self.data.equipment[slot] = {
                refId = newRefId,
                count = newCount,
                charge = newCharge,
                enchantmentCharge = newEnchantmentCharge
            }

            -- Is this the same item that was previously in this slot? In that case,
            -- its count, charge or enchantmentCharge must have changed, so we need
            -- to also update that in the inventory table
            local previousItem = self.previousEquipment[slot]

            if previousItem ~= nil and previousItem.refId == newRefId then
                local inventoryIndex = inventoryHelper.getItemIndex(self.data.inventory,
                    previousItem.refId, previousItem.charge, previousItem.enchantmentCharge)

                if inventoryIndex ~= nil then
                    self.data.inventory[inventoryIndex].count = newCount
                    self.data.inventory[inventoryIndex].charge = newCharge
                    self.data.inventory[inventoryIndex].enchantmentCharge = newEnchantmentCharge
                end
            end

            self.previousEquipment[slot] = tableHelper.deepCopy(self.data.equipment[slot])
        end
    end

    if reloadAtEnd then
        self:LoadEquipment()
    end
end

-- Iterate through inventory items and remove nil values as well as items whose
-- records no longer exist
-- Note: The check for existing records can only handle generated records for now
function BasePlayer:CleanInventory()

    for index, currentItem in pairs(self.data.inventory) do

        if logicHandler.IsGeneratedRecord(currentItem.refId) then

            local recordStore = logicHandler.GetRecordStoreByRecordId(currentItem.refId)

            if recordStore == nil or recordStore.data.generatedRecords[currentItem.refId] == nil then
                self.data.inventory[index] = nil
            end
        end
    end

    if not tableHelper.isArray(self.data.inventory) then
        tableHelper.cleanNils(self.data.inventory)
    end
end

-- Send a packet with some specific item changes to the player, to avoid having
-- to resend the entire inventory
--
-- Note: This just sends a packet, so the same item changes should be applied to
--       self.data.inventory separately
function BasePlayer:LoadItemChanges(itemArray, inventoryAction)

    tes3mp.ClearInventoryChanges(self.pid)
    tes3mp.SetInventoryChangesAction(self.pid, inventoryAction)

    for index, currentItem in pairs(itemArray) do

        if currentItem.count > 0 then
            packetBuilder.AddPlayerInventoryItemChange(self.pid, currentItem)
        end
    end

    tes3mp.SendInventoryChanges(self.pid)
end

function BasePlayer:LoadInventory()

    if self.data.inventory == nil then self.data.inventory = {} end

    tes3mp.ClearInventoryChanges(self.pid)
    tes3mp.SetInventoryChangesAction(self.pid, enumerations.inventory.SET)

    for index, currentItem in pairs(self.data.inventory) do

        if currentItem.count ~= nil and currentItem.count > 0 then
            packetBuilder.AddPlayerInventoryItemChange(self.pid, currentItem)
        else
            tes3mp.LogMessage(enumerations.log.INFO, "Caught nil or empty item in inventory for player " .. self.name .. " with item " .. tostring(currentItem) .. ", purging from data store.")
            self.data.inventory[index] = nil
        end
    end

    tes3mp.SendInventoryChanges(self.pid)
end

function BasePlayer:SaveInventory(playerPacket)

    local action = playerPacket.action

    tes3mp.LogMessage(enumerations.log.INFO, "Saving " .. tableHelper.getCount(playerPacket.inventory) ..
        " item(s) to inventory with action " .. tableHelper.getIndexByValue(enumerations.inventory, action))

    if action == enumerations.inventory.SET then self.data.inventory = {} end

    for itemIndex, item in pairs(playerPacket.inventory) do
        if item.refId ~= "" then

            tes3mp.LogAppend(enumerations.log.INFO, "- id: " .. item.refId .. ", count: " .. item.count ..
                ", charge: " .. item.charge .. ", enchantmentCharge: " .. item.enchantmentCharge ..
                ", soul: " .. item.soul)

            if action == enumerations.inventory.SET or action == enumerations.inventory.ADD then

                inventoryHelper.addItem(self.data.inventory, item.refId, item.count, item.charge,
                    item.enchantmentCharge, item.soul)

                if logicHandler.IsGeneratedRecord(item.refId) then

                    local recordStore = logicHandler.GetRecordStoreByRecordId(item.refId)

                    if recordStore ~= nil then
                        self:AddLinkToRecord(recordStore.storeType, item.refId)
                    end
                end

            elseif action == enumerations.inventory.REMOVE then

                inventoryHelper.removeClosestItem(self.data.inventory, item.refId, item.count,
                    item.charge, item.enchantmentCharge, item.soul)

                if not inventoryHelper.containsItem(self.data.inventory, item.refId) and
                    logicHandler.IsGeneratedRecord(item.refId) then

                    local recordStore = logicHandler.GetRecordStoreByRecordId(item.refId)

                    if recordStore ~= nil then
                        self:RemoveLinkToRecord(recordStore.storeType, item.refId)
                    end
                end
            end
        end
    end

    self:QuicksaveToDrive()
end

-- Iterate through spells and remove nil values as well as spells whose records
-- no longer exist
-- Note: The check for existing records can only handle generated records for now
function BasePlayer:CleanSpellbook()

    local recordStore = RecordStores["spell"]

    for index, spellId in pairs(self.data.spellbook) do

        -- Make sure we skip over old spell tables from previous versions of TES3MP
        if type(spellId) ~= "table" and logicHandler.IsGeneratedRecord(spellId) then

            if recordStore.data.generatedRecords[spellId] == nil then
                self.data.spellbook[index] = nil
            end
        end
    end

    if not tableHelper.isArray(self.data.spellbook) then
        tableHelper.cleanNils(self.data.spellbook)
    end
end

function BasePlayer:LoadSpellbook()

    if self.data.spellbook == nil then self.data.spellbook = {} end

    tes3mp.ClearSpellbookChanges(self.pid)
    tes3mp.SetSpellbookChangesAction(self.pid, enumerations.spellbook.SET)

    for index, spellId in pairs(self.data.spellbook) do

        -- Is this an old spell table from a previous version of TES3MP?
        -- If so, update it to the new format
        if type(spellId) == "table" then
            spellId = spellId.spellId
            self.data.spellbook[index] = spellId
        end

        tes3mp.AddSpell(self.pid, spellId)
    end

    tes3mp.SendSpellbookChanges(self.pid)
end

function BasePlayer:SaveSpellbook(playerPacket)

    local action = playerPacket.action

    if action == enumerations.spellbook.SET then
        self.data.spellbook = {}
    end

    for spellIndex, spellId in pairs(playerPacket.spellbook) do
        if action == enumerations.spellbook.SET or action == enumerations.spellbook.ADD then
            -- Only add new spell if we don't already have it
            if not tableHelper.containsValue(self.data.spellbook, spellId) then
                tes3mp.LogMessage(enumerations.log.INFO, "Adding spellbook spell " .. spellId .. " to " ..
                    logicHandler.GetChatName(self.pid))
                table.insert(self.data.spellbook, spellId)
            end
        elseif action == enumerations.spellbook.REMOVE then
            -- Only print spell removal if the spell actually exists
            if tableHelper.containsValue(self.data.spellbook, spellId) == true then
                tes3mp.LogMessage(enumerations.log.INFO, "Removing spellbook spell " .. spellId .. " from " ..
                    logicHandler.GetChatName(self.pid))
                local foundIndex = tableHelper.getIndexByValue(self.data.spellbook, spellId)
                self.data.spellbook[foundIndex] = nil

                if logicHandler.IsGeneratedRecord(spellId) then
                    local recordStore = RecordStores["spell"]

                    if recordStore ~= nil then
                        self:RemoveLinkToRecord(recordStore.storeType, spellId)
                    end
                end
            end
        end
    end

    if action == enumerations.spellbook.REMOVE then
        tableHelper.cleanNils(self.data.spellbook)
    end
end

function BasePlayer:UpdateActiveSpellTimes()

    for spellId, spellInstances in pairs(self.data.spellsActive) do
        for spellInstanceIndex, spellInstanceValues in pairs(spellInstances) do
            local hadRemainingEffect = false

            for effectIndex, effectTable in pairs(spellInstanceValues.effects) do

                local timeSinceCast = os.time() - spellInstanceValues.startTime

                if timeSinceCast <= 0 then
                    self.data.spellsActive[spellId][spellInstanceIndex].effects[effectIndex] = nil
                else
                    hadRemainingEffect = true

                    -- Subtract the time elapsed since casting the spell from the
                    -- effect's remaining time
                    effectTable.timeLeft = effectTable.timeLeft - timeSinceCast
                end
            end

            if hadRemainingEffect == false then
                self.data.spellsActive[spellId][spellInstanceIndex] = nil
            end        
        end

        if tableHelper.getCount(self.data.spellsActive[spellId]) == 0 then
            self.data.spellsActive[spellId] = nil
        end
    end

    tableHelper.cleanNils(self.data.spellsActive)
end

function BasePlayer:LoadSpellsActive()

    if self.data.spellsActive == nil then self.data.spellsActive = {} end

    if tableHelper.getCount(self.data.spellsActive) > 0 then
        packetBuilder.AddPlayerSpellsActive(self.pid, self.data.spellsActive, enumerations.spellbook.SET)

        -- Send this to all players, or they'll only know about active spells added afterwards
        tes3mp.SendSpellsActiveChanges(self.pid, true)
    end
end

function BasePlayer:SaveSpellsActive(playerPacket)

    local action = playerPacket.action

    if action == enumerations.spellbook.SET or self.data.spellsActive == nil then
        self.data.spellsActive = {}
    end

    for spellId, spellInstances in pairs(playerPacket.spellsActive) do

        if action == enumerations.spellbook.SET or action == enumerations.spellbook.ADD then
            if self.data.spellsActive[spellId] == nil then
                self.data.spellsActive[spellId] = {}
            end

            for _, spellInstanceValues in pairs(spellInstances) do

                tes3mp.LogMessage(enumerations.log.INFO, "Adding instance of active spell " .. spellId .. " to " ..
                    logicHandler.GetChatName(self.pid))

                local spellInstanceIndex

                -- Get an unused spellInstanceIndex if this is a spell with stacking effects
                if spellInstanceValues.stackingState then
                    spellInstanceIndex = tableHelper.getUnusedNumericalIndex(self.data.spellsActive[spellId])
                -- Otherwise, replace what's under index 1
                else
                    spellInstanceIndex = 1
                end

                self.data.spellsActive[spellId][spellInstanceIndex] = {
                    displayName = spellInstanceValues.displayName,
                    stackingState = spellInstanceValues.stackingState,
                    effects = tableHelper.deepCopy(spellInstanceValues.effects),
                    startTime = os.time()
                }

                if spellInstanceValues.caster ~= nil then
                    self.data.spellsActive[spellId][spellInstanceIndex].caster = {
                        playerName = spellInstanceValues.caster.playerName,
                        refId = spellInstanceValues.caster.refId,
                        uniqueIndex = spellInstanceValues.caster.uniqueIndex
                    }
                end
            end
        elseif action == enumerations.spellbook.REMOVE then
            -- Only print spell removal if the spell actually exists
            if self.data.spellsActive[spellId] ~= nil then
                tes3mp.LogMessage(enumerations.log.INFO, "Removing active spell " .. spellId .. " from " ..
                    logicHandler.GetChatName(self.pid))
                self.data.spellsActive[spellId][1] = nil
            end
        end
    end

    if action == enumerations.spellbook.REMOVE then
        tableHelper.cleanNils(self.data.spellsActive)
    end
end

function BasePlayer:LoadCooldowns()

    if self.data.cooldowns == nil then self.data.cooldowns = {} end

    if tableHelper.getCount(self.data.cooldowns) > 0 then
        tes3mp.ClearCooldownChanges(self.pid)

        for _, cooldown in pairs(self.data.cooldowns) do
            tes3mp.AddCooldownSpell(self.pid, cooldown.spellId, cooldown.startDay, cooldown.startHour)
        end

        tes3mp.SendCooldownChanges(self.pid)
    end
end

function BasePlayer:SaveCooldowns(playerPacket)

    for _, cooldown in pairs(playerPacket.cooldowns) do
        table.insert(self.data.cooldowns, cooldown)
    end
end

function BasePlayer:LoadQuickKeys()

    if self.data.quickKeys == nil then self.data.quickKeys = {} end

    tes3mp.ClearQuickKeyChanges(self.pid)

    for slot, currentQuickKey in pairs(self.data.quickKeys) do

        if currentQuickKey ~= nil then
            tes3mp.AddQuickKey(self.pid, slot, currentQuickKey.keyType, currentQuickKey.itemId)
        end
    end

    tes3mp.SendQuickKeyChanges(self.pid)
end

function BasePlayer:SaveQuickKeys(playerPacket)

    for slot, quickKey in pairs(playerPacket.quickKeys) do
        self.data.quickKeys[slot] = {
            keyType = quickKey.keyType,
            itemId = quickKey.itemId
        }
    end
end

function BasePlayer:LoadJournal()
    stateHelper:LoadJournal(self.pid, self)
end

function BasePlayer:SaveJournal(playerPacket)
    stateHelper:SaveJournal(self, playerPacket)
end

function BasePlayer:LoadFactionRanks()
    stateHelper:LoadFactionRanks(self.pid, self)
end

function BasePlayer:SaveFactionRanks()
    stateHelper:SaveFactionRanks(self.pid, self)
end

function BasePlayer:LoadFactionExpulsion()
    stateHelper:LoadFactionExpulsion(self.pid, self)
end

function BasePlayer:SaveFactionExpulsion()
    stateHelper:SaveFactionExpulsion(self.pid, self)
end

function BasePlayer:LoadFactionReputation()
    stateHelper:LoadFactionReputation(self.pid, self)
end

function BasePlayer:SaveFactionReputation()
    stateHelper:SaveFactionReputation(self.pid, self)
end

function BasePlayer:LoadTopics()
    stateHelper:LoadTopics(self.pid, self)
end

function BasePlayer:SaveTopics()
    stateHelper:SaveTopics(self.pid, self)
end

function BasePlayer:LoadBounty()
    stateHelper:LoadBounty(self.pid, self)
end

function BasePlayer:SaveBounty()
    stateHelper:SaveBounty(self.pid, self)
end

function BasePlayer:LoadReputation()
    stateHelper:LoadReputation(self.pid, self)
end

function BasePlayer:SaveReputation()
    stateHelper:SaveReputation(self.pid, self)
end

function BasePlayer:LoadClientScriptVariables()
    stateHelper:LoadClientScriptVariables(self.pid, self)
end

function BasePlayer:SaveClientScriptGlobal(variables)
    stateHelper:SaveClientScriptGlobal(self, variables)
end

function BasePlayer:LoadDestinationOverrides(pid)
    stateHelper:LoadDestinationOverrides(self.pid, self)
end

function BasePlayer:LoadMap()
    stateHelper:LoadMap(self.pid, self)
end

function BasePlayer:LoadAllies()
    
    if self.data.alliedPlayers == nil then self.data.alliedPlayers = {} end

    tes3mp.ClearAlliedPlayersForPlayer(self.pid)

    for _, otherAccountName in ipairs(self.data.alliedPlayers) do
        if logicHandler.IsPlayerNameLoggedIn(otherAccountName) then
            local otherPlayer = logicHandler.GetPlayerByName(otherAccountName)
            tes3mp.AddAlliedPlayerForPlayer(self.pid, otherPlayer.pid)
        end
    end

    tes3mp.SendAlliedPlayers(self.pid, true)
end

function BasePlayer:LoadBooks()

    if self.data.books == nil then self.data.books = {} end

    tes3mp.ClearBookChanges(self.pid)

    for index, bookId in pairs(self.data.books) do

        tes3mp.AddBook(self.pid, bookId)
    end

    tes3mp.SendBookChanges(self.pid)
end

function BasePlayer:AddBooks()

    for index = 0, tes3mp.GetBookChangesSize(self.pid) - 1 do
        local bookId = tes3mp.GetBookId(self.pid, index)

        -- Only add new book if we don't already have it
        if not tableHelper.containsValue(self.data.books, bookId, false) then
            tes3mp.LogMessage(enumerations.log.INFO, "Adding book " .. bookId .. " to " ..
                logicHandler.GetChatName(self.pid))
            table.insert(self.data.books, bookId)
        end
    end
end

function BasePlayer:LoadMarkLocation()

    if self.data.miscellaneous == nil then self.data.miscellaneous = {} end

    if self.data.miscellaneous.markLocation ~= nil then
        local markLocation = self.data.miscellaneous.markLocation
        tes3mp.SetMarkCell(self.pid, markLocation.cell)
        tes3mp.SetMarkPos(self.pid, markLocation.posX, markLocation.posY, markLocation.posZ)
        tes3mp.SetMarkRot(self.pid, markLocation.rotX, markLocation.rotZ)
        tes3mp.SendMarkLocation(self.pid)
    end
end

function BasePlayer:SaveMarkLocation()

    if self.data.miscellaneous == nil then self.data.miscellaneous = {} end

    self.data.miscellaneous.markLocation = {
        cell = tes3mp.GetMarkCell(self.pid),
        posX = tes3mp.GetMarkPosX(self.pid),
        posY = tes3mp.GetMarkPosY(self.pid),
        posZ = tes3mp.GetMarkPosZ(self.pid),
        rotX = tes3mp.GetMarkRotX(self.pid),
        rotZ = tes3mp.GetMarkRotZ(self.pid)
    }
end

function BasePlayer:LoadSelectedSpell()

    if self.data.miscellaneous == nil then
        self.data.miscellaneous = {}
    end

    if self.data.miscellaneous.selectedSpell ~= nil then
        tes3mp.SetSelectedSpellId(self.pid, self.data.miscellaneous.selectedSpell)
        tes3mp.SendSelectedSpell(self.pid)
    end
end

function BasePlayer:SaveSelectedSpell()

    if self.data.miscellaneous == nil then self.data.miscellaneous = {} end

    self.data.miscellaneous.selectedSpell = tes3mp.GetSelectedSpellId(self.pid)
end

function BasePlayer:GetDifficulty()
    return self.data.settings.difficulty
end

function BasePlayer:GetConsoleAllowed()
    return self.data.settings.consoleAllowed
end

function BasePlayer:GetBedRestAllowed()
    return self.data.settings.bedRestAllowed
end

function BasePlayer:GetWildernessRestAllowed()
    return self.data.settings.wildernessRestAllowed
end

function BasePlayer:GetWaitAllowed()
    return self.data.settings.waitAllowed
end

function BasePlayer:GetEnforcedLogLevel()
    return self.data.settings.enforcedLogLevel
end

function BasePlayer:GetPhysicsFramerate()
    return self.data.settings.physicsFramerate
end

function BasePlayer:SetDifficulty(difficulty)
    if difficulty == nil or difficulty == "default" then
        difficulty = config.difficulty
        self.data.settings.difficulty = "default"
    else
        self.data.settings.difficulty = difficulty
    end

    tes3mp.SetDifficulty(self.pid, difficulty)
    tes3mp.LogMessage(enumerations.log.INFO, "Set difficulty to " .. tostring(difficulty) .. " for " ..
        logicHandler.GetChatName(self.pid))
end

function BasePlayer:SetEnforcedLogLevel(enforcedLogLevel)
    if enforcedLogLevel == nil or enforcedLogLevel == "default" then
        enforcedLogLevel = config.enforcedLogLevel
        self.data.settings.enforcedLogLevel = "default"
    else
        self.data.settings.enforcedLogLevel = enforcedLogLevel
    end

    tes3mp.SetEnforcedLogLevel(self.pid, enforcedLogLevel)
    tes3mp.LogMessage(enumerations.log.INFO, "Set enforced log level to " .. tostring(enforcedLogLevel) ..
        " for " .. logicHandler.GetChatName(self.pid))
end

function BasePlayer:SetPhysicsFramerate(physicsFramerate)
    if physicsFramerate == nil or physicsFramerate == "default" then
        physicsFramerate = config.physicsFramerate
        self.data.settings.physicsFramerate = "default"
    else
        self.data.settings.physicsFramerate = physicsFramerate
    end

    tes3mp.SetPhysicsFramerate(self.pid, physicsFramerate)
    tes3mp.LogMessage(enumerations.log.INFO, "Set physics framerate to " .. tostring(physicsFramerate) ..
        " for " .. logicHandler.GetChatName(self.pid))
end

function BasePlayer:SetConsoleAllowed(state)
    if state == nil or state == "default" then
        state = config.allowConsole
        self.data.settings.consoleAllowed = "default"
    else
        self.data.settings.consoleAllowed = state
    end

    tes3mp.SetConsoleAllowed(self.pid, state)
end

function BasePlayer:SetBedRestAllowed(state)
    if state == nil or state == "default" then
        state = config.allowBedRest
        self.data.settings.bedRestAllowed = "default"
    else
        self.data.settings.bedRestAllowed = state
    end

    tes3mp.SetBedRestAllowed(self.pid, state)
end

function BasePlayer:SetWildernessRestAllowed(state)
    if state == nil or state == "default" then
        state = config.allowWildernessRest
        self.data.settings.wildernessRestAllowed = "default"
    else
        self.data.settings.wildernessRestAllowed = state
    end

    tes3mp.SetWildernessRestAllowed(self.pid, state)
end

function BasePlayer:SetWaitAllowed(state)
    if state == nil or state == "default" then
        state = config.allowWait
        self.data.settings.waitAllowed = "default"
    else
        self.data.settings.waitAllowed = state
    end

    tes3mp.SetWaitAllowed(self.pid, state)
end

function BasePlayer:SetWerewolfState(state)
    self.data.shapeshift.isWerewolf = state

    tes3mp.SetWerewolfState(self.pid, state)
    tes3mp.SendShapeshift(self.pid)
end

function BasePlayer:SetScale(scale)
    self.data.shapeshift.scale = scale

    tes3mp.SetScale(self.pid, scale)
    tes3mp.SendShapeshift(self.pid)
end

function BasePlayer:SetConfiscationState(state)

    self.data.customVariables.isConfiscationTarget = state

    if self:IsLoggedIn() then

        if state == true then
            logicHandler.RunConsoleCommandOnPlayer(self.pid, "tm")
            logicHandler.RunConsoleCommandOnPlayer(self.pid, "disableplayercontrols")
            tes3mp.MessageBox(self.pid, -1, "You are immobilized while an item is being confiscated from you")
        elseif not state then
            self.data.customVariables.isConfiscationTarget = nil
            logicHandler.RunConsoleCommandOnPlayer(self.pid, "tm")
            logicHandler.RunConsoleCommandOnPlayer(self.pid, "enableplayercontrols")
            tes3mp.MessageBox(self.pid, -1, "You are free to move again")
        end
    end
end

function BasePlayer:LoadSettings()

    -- Change admin variable from old player files to the current staffRank
    if self.data.settings.staffRank == nil and self.data.settings.admin ~= nil then
        self.data.settings.staffRank = self.data.settings.admin
        self.data.settings.admin = nil
    end

    self:SetDifficulty(self.data.settings.difficulty)
    self:SetConsoleAllowed(self.data.settings.consoleAllowed)
    self:SetBedRestAllowed(self.data.settings.bedRestAllowed)
    self:SetWildernessRestAllowed(self.data.settings.wildernessRestAllowed)
    self:SetWaitAllowed(self.data.settings.waitAllowed)
    self:SetEnforcedLogLevel(self.data.settings.enforcedLogLevel)
    self:SetPhysicsFramerate(self.data.settings.physicsFramerate)

    tes3mp.ClearGameSettingValues(self.pid)

    for _, settingPairTable in pairs(config.gameSettings) do
        tes3mp.SetGameSettingValue(self.pid, settingPairTable.name, tostring(settingPairTable.value))
    end

    tes3mp.ClearVRSettingValues(self.pid)

    for _, settingPairTable in pairs(config.vrSettings) do
        tes3mp.SetVRSettingValue(self.pid, settingPairTable.name, tostring(settingPairTable.value))
    end

    tes3mp.SendSettings(self.pid)
end

function BasePlayer:LoadSpecialStates()

    if self.data.customVariables.isConfiscationTarget ~= nil then
        self:SetConfiscationState(self.data.customVariables.isConfiscationTarget)
    end
end

function BasePlayer:AddCellLoaded(cellDescription)

    -- Only add new loaded cell if we don't already have it
    if not tableHelper.containsValue(self.cellsLoaded, cellDescription) then
        table.insert(self.cellsLoaded, cellDescription)
    end
end

function BasePlayer:RemoveCellLoaded(cellDescription)

    tableHelper.removeValue(self.cellsLoaded, cellDescription)
end

function BasePlayer:RunPlayerSpecificStartupScripts()
    tes3mp.LogMessage(enumerations.log.INFO, "Running player-specific startup scripts for " ..
        logicHandler.GetChatName(self.pid) .. ":")

    for _, scriptName in pairs(config.playerStartupScripts) do
        tes3mp.LogAppend(enumerations.log.INFO, "- " .. scriptName)
        logicHandler.RunConsoleCommandOnPlayer(self.pid, "startscript " .. scriptName, false)
    end
end

return BasePlayer
