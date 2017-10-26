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
        JsonInterface.save(DataManager.getObjectJsonPath(objectType, objectName), dataTable)

    elseif Config.Core.databaseType == "sqlite3" then
        -- TODO: Fill this in later
    end
end

DataManager.setPlayerFromTable = function(player, playerData)
    logMessage(Log.LOG_INFO, "Setting player from table")
    
end

return DataManager
