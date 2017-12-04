local PlayerBuilder = {}

    -- Update 0.6 player tables to 0.7's format
PlayerBuilder.getUpdatedTable = function(dataTable)

    if dataTable.character.class ~= nil and dataTable.customClass ~= nil then

        dataTable.class = {}

        if dataTable.character.class == "custom" then
            dataTable.class.isCustom = true
            dataTable.class.name = dataTable.customClass.name
            dataTable.class.description = dataTable.customClass.description
            dataTable.class.specialization = dataTable.customClass.specialization
            dataTable.class.majorAttributes = TableHelper.getTableFromCommaSplit(dataTable.customClass.majorAttributes)
            dataTable.class.majorSkills = TableHelper.getTableFromCommaSplit(dataTable.customClass.majorSkills)
            dataTable.class.minorSkills = TableHelper.getTableFromCommaSplit(dataTable.customClass.minorSkills)
        else
            dataTable.class.isCustom = false
            dataTable.class.name = dataTable.character.class
        end
    end

    return dataTable
end

PlayerBuilder.getCharacter = function(player)

    local characterTable = {}

    characterTable.race = player.race
    characterTable.head = player.head
    characterTable.hair = player.hair
    characterTable.gender = player.gender
    characterTable.birthsign = player.birthsign

    return characterTable
end

PlayerBuilder.getClass = function(player)

    local classTable = {}
    classTable.isCustom = player:getClass():isCustom()

    if classTable.isCustom == true then
        classTable.name = player:getClass().name
        classTable.description = player:getClass().description
        classTable.specialization = player:getClass().specialization
        classTable.majorAttributes, classTable.majorSkills, classTable.minorSkills = {}, {}, {}

        for key, value in pairs({player:getClass():getMajorAttributes()}) do
            table.insert(classTable.majorAttributes, Constants.getAttributeName(value))
        end

        for key, value in pairs({player:getClass():getMajorSkills()}) do
            table.insert(classTable.majorSkills, Constants.getSkillName(value))
        end

        for key, value in pairs({player:getClass():getMinorSkills()}) do
            table.insert(classTable.minorSkills, Constants.getSkillName(value))
        end
    else
        classTable.name = player:getClass().default
    end

    return classTable
end

PlayerBuilder.getStats = function(player)

    local statsTable = {}

    statsTable.level = player.level
    statsTable.levelProgress = player.levelProgress
    statsTable.healthBase, statsTable.healthCurrent = player:getHealth()
    statsTable.magickaBase, statsTable.magickaCurrent = player:getMagicka()
    statsTable.fatigueBase, statsTable.fatigueCurrent = player:getFatigue()
    statsTable.bounty = player.bounty

    return statsTable
end

PlayerBuilder.getAttributes = function(player)

    local attributesTable = {}

    for attributeId = 0, Constants.getAttributeCount() - 1 do
        local attributeName = Constants.getAttributeName(attributeId)
        attributesTable[attributeName] = player:getAttribute(attributeId)
    end

    return attributesTable
end

PlayerBuilder.getSkills = function(player)

    local skillsTable, skillProgressTable, attributeSkillIncreasesTable = {}, {}, {}

    for skillId = 0, Constants.getSkillCount() - 1 do
        local skillName = Constants.getSkillName(skillId)
        skillsTable[skillName], _, skillProgressTable[skillName] = player:getSkill(skillId)
    end

    for attributeId = 0, Constants.getAttributeCount() - 1 do
        local attributeName = Constants.getAttributeName(attributeId)
        attributeSkillIncreasesTable[attributeName] = player:getSkillIncrease(attributeId)
    end

    return skillsTable, skillProgressTable, attributeSkillIncreasesTable
end

PlayerBuilder.getLocation = function(player)
    
    local locationTable = {}

    locationTable.cell = player:getCell().description
    locationTable.posX, locationTable.posY, locationTable.posZ = player:getPosition()
    locationTable.rotX, locationTable.rotZ = player:getRotation()

    return locationTable
end

PlayerBuilder.getEquipment = function(player)

    local equipmentTable = {}

    for slot = 0, Constants.getEquipmentSize() - 1 do

        local itemRefId, itemCount, itemCharge = player:getInventory():getEquipmentItem(slot)

        if itemRefId ~= "" then
            equipmentTable[slot] = {
                refId = itemRefId,
                count = itemCount,
                charge = itemCharge
            }
        end
    end

    return equipmentTable
end

PlayerBuilder.setCharacter = function(player, characterTable)

    player.race = characterTable.race
    player.head = characterTable.head
    player.hair = characterTable.hair
    player.gender = characterTable.gender
    player.birthsign = characterTable.birthsign
end

PlayerBuilder.setClass = function(player, classTable)

    if classTable.isCustom == true then
        player:getClass().name = classTable.name
        player:getClass().description = classTable.description
        player:getClass().specialization = classTable.specialization
        player:getClass():setMajorAttributes(Constants.getAttributeId(classTable.majorAttributes[1]),
            Constants.getAttributeId(classTable.majorAttributes[2]))
        player:getClass():setMajorSkills(Constants.getSkillId(classTable.majorSkills[1]),
            Constants.getSkillId(classTable.majorSkills[2]), Constants.getSkillId(classTable.majorSkills[3]),
            Constants.getSkillId(classTable.majorSkills[4]), Constants.getSkillId(classTable.majorSkills[5]))
        player:getClass():setMinorSkills(Constants.getSkillId(classTable.minorSkills[1]),
            Constants.getSkillId(classTable.minorSkills[2]), Constants.getSkillId(classTable.minorSkills[3]),
            Constants.getSkillId(classTable.minorSkills[4]), Constants.getSkillId(classTable.minorSkills[5]))
    else
        player:getClass().default = classTable.name
    end
end

PlayerBuilder.setStats = function(player, statsTable)

    player.level = statsTable.level
    player.levelProgress = statsTable.levelProgress
    player:setHealth(statsTable.healthBase, statsTable.healthCurrent)
    player:setMagicka(statsTable.magickaBase, statsTable.magickaCurrent)
    player:setFatigue(statsTable.fatigueBase, statsTable.fatigueCurrent)
    player.bounty = statsTable.bounty
end

PlayerBuilder.setAttributes = function(player, attributesTable)

    for attributeName, value in pairs(attributesTable) do
        player:setAttribute(Constants.getAttributeId(attributeName), value, value)
    end
end

PlayerBuilder.setSkills = function(player, skillsTable, skillProgressTable, attributeSkillIncreasesTable)

    for skillName, value in pairs(skillsTable) do
        player:setSkill(Constants.getSkillId(skillName), value, value, skillProgressTable[skillName])
    end

    for attributeName, value in pairs(attributeSkillIncreasesTable) do
        player:setSkillIncrease(Constants.getAttributeId(attributeName), value)
    end
end

PlayerBuilder.setLocation = function(player, locationTable)

    player:getCell().description = locationTable.cell
    player:setPosition(locationTable.posX, locationTable.posY, locationTable.posZ)
    player:setRotation(locationTable.rotX, locationTable.rotZ)
end

PlayerBuilder.setEquipment = function(player, equipmentTable)

    for slot = 0, Constants.getEquipmentSize() - 1 do

        local currentItem = equipmentTable[slot]

        if currentItem ~= nil then
            player:getInventory():equipItem(slot, currentItem.refId, currentItem.count, currentItem.charge)
        else
            player:getInventory():unequipItem(slot)
        end
    end
end

return PlayerBuilder
