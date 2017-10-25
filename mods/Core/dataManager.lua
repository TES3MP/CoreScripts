FileUtils = require("fileUtils")

local DataManager = {}

-- Check if a certain player already has a data entry
DataManager.hasPlayerEntry = function(player)

    if player.customData.accountName == nil then
        player.customData.accountName = FileUtils.convertToFilename(player.name)
    end

    return FileUtils.doesFileExist(getDataFolder() .. "player/", player.customData.accountName .. ".json")
end

return DataManager
