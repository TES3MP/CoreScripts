JsonInterface = require("jsonInterface")
FileUtils = require("fileUtils")

local BanManager = {}

BanManager.banList = { accountNames = {}, ipAddresses = {} }

BanManager.isBanned = function(player)
    return TableHelper.containsValue(BanManager.banList.accountNames, player.customData.accountName)
end

BanManager.loadBanList = function(filePath)

    if FileUtils.doesFileExist(filePath) == false then
        logMessage(Log.LOG_INFO, "Could not find banlist at " .. filePath)
        logAppend(Log.LOG_INFO, "- Creating new banlist")
        BanManager.saveBanList()
        return
    end

    logMessage(Log.LOG_INFO, "Loading banlist at " .. filePath)

    local banList = JsonInterface.load(filePath)

    if banList.accountNames == nil then
        -- Convert rename playerNames from old banlists into accountNames
        if banList.playerNames ~= nil then
            banList.accountNames = banList.playerNames
        else
            banList.accountNames = {}
        end
    end
    
    if banList.ipAddresses == nil then
        banList.ipAddresses = {}
    end

    if #banList.ipAddresses > 0 then
        local message = "- Banning manually-added IP addresses:\n"

        for index, ipAddress in pairs(banList.ipAddresses) do
            message = message .. ipAddress

            if index < #banList.ipAddresses then
                message = message .. ", "
            end

            banAddress(ipAddress)
        end

        logAppend(Log.LOG_INFO, message)
    end

    if #banList.accountNames > 0 then
        local message = "- Banning all IP addresses stored for players:\n"

        for index, targetName in pairs(banList.accountNames) do
            message = message .. targetName

            if index < #banList.accountNames then
                message = message .. ", "
            end

            local playerData = DataManager.getTableFromEntry("player", targetName)

            if playerData ~= nil then

                for index, ipAddress in pairs(playerData.ipAddresses) do
                    banAddress(ipAddress)
                end
            end
        end

        logAppend(Log.LOG_INFO, message)
    end

    BanManager.banList = banList
end

BanManager.saveBanList = function()
    JsonInterface.save(getDataFolder() .. "banlist.json", BanManager.banList)
end

return BanManager
