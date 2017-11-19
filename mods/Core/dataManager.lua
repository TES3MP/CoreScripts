PlayerBuilder = import(getModFolder() .. "playerBuilder.lua")

local DataManager = {}

DataManager.getObjectJsonPath = function(objectType, objectName)
    return getDataFolder() .. objectType .. "/" .. objectName .. ".json"
end

-- Check if a certain player already has a data entry
DataManager.hasObjectEntry = function(objectType, objectName)

    if Config.Core.databaseType == "json" then
        return FileUtils.doesFileExist(DataManager.getObjectJsonPath(objectType, objectName))
    elseif Config.Core.databaseType == "sqlite3" then
        -- TODO: Fill this in later
    end

    return false
end

-- Open up an object entry and return its contents as a table
DataManager.getTableFromEntry = function(objectType, objectName)

    local dataTable = nil

    if Config.Core.databaseType == "json" then
        dataTable = JsonInterface.load(DataManager.getObjectJsonPath(objectType, objectName))

        -- JSON doesn't allow numerical keys, but we use them, so convert
        -- all string number keys into numerical keys
        TableHelper.fixNumericalKeys(dataTable)

    elseif Config.Core.databaseType == "sqlite3" then
        -- TODO: Fill this in later
    end

    return dataTable
end

DataManager.setEntryFromTable = function(objectType, objectName, dataTable)
    
    if Config.Core.databaseType == "json" then
        JsonInterface.save(DataManager.getObjectJsonPath(objectType, objectName), dataTable, Config.Core.playerKeyOrder)

    elseif Config.Core.databaseType == "sqlite3" then
        -- TODO: Fill this in later
    end
end

DataManager.getTableFromPlayer = function(player)

    local dataTable = {}

    dataTable.character = PlayerBuilder.getCharacter(player)
    dataTable.class = PlayerBuilder.getClass(player)
    dataTable.stats = PlayerBuilder.getStats(player)
    dataTable.attributes = PlayerBuilder.getAttributes(player)
    dataTable.skills, dataTable.skillProgress, dataTable.attributeSkillIncreases = PlayerBuilder.getSkills(player)
    dataTable.location = PlayerBuilder.getLocation(player)
    dataTable.equipment = PlayerBuilder.getEquipment(player)

    return dataTable
end

DataManager.setPlayerFromTable = function(player, dataTable)

    logMessage(Log.LOG_INFO, "Setting player from table")

    -- Update 0.6 player tables to new format
    dataTable = PlayerBuilder.getUpdatedTable(dataTable)
    
    PlayerBuilder.setCharacter(player, dataTable.character)
    PlayerBuilder.setClass(player, dataTable.class)
    PlayerBuilder.setStats(player, dataTable.stats)
    PlayerBuilder.setAttributes(player, dataTable.attributes)
    PlayerBuilder.setSkills(player, dataTable.skills, dataTable.skillProgress, dataTable.attributeSkillIncreases)
    PlayerBuilder.setLocation(player, dataTable.location)
    PlayerBuilder.setEquipment(player, dataTable.equipment)
end

return DataManager
