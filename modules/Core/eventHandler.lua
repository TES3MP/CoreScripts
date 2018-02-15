DataManager = import(getModuleFolder() .. "dataManager.lua")
InterfaceManager = import(getModuleFolder() .. "interfaceManager.lua")
BanManager = import(getModuleFolder() .. "banManager.lua")

local EventHandler = {}

-- Get the "Name (pid)" representation of a player used in chat
EventHandler.getChatName = function(player)
    return player.name .. " (" .. player.pid .. ")"
end

-- Check if there is already a player with this name on the server
EventHandler.isPlayerDuplicate = function(newPlayer)

    -- Use this variable because we can't return a value for this function from
    -- inside Players.for_each()
    local isDuplicate = false

    Players.for_each(function(existingPlayer)
        if existingPlayer.customData.loggedIn == true and isDuplicate == false then
            if string.lower(newPlayer.customData.accountName) == string.lower(existingPlayer.customData.accountName) then
                isDuplicate = true
            end
        end
    end)

    return isDuplicate
end

EventHandler.allowPlayerConnection = function(player)
    
    local messageText = EventHandler.getChatName(player) .. " joined the server.\n"
    player:message(0, messageText, true)

    messageText = "Welcome, " .. player.name .. ".\nYou have " .. tostring(Config.Core.loginTime) .. " seconds to"

    if DataManager.hasObjectEntry("player", player.customData.accountName) then
        messageText = messageText .. " log in.\n"
        InterfaceManager.showLogin(OnGUILogin, player)
    else
        messageText = messageText .. " register.\n"
        InterfaceManager.showRegistration(OnGUIRegister, player)
    end

    player:message(0, messageText, false)
    player.customData.loggedIn = true
end

EventHandler.denyPlayerName = function(player)
    local messageText = EventHandler.getChatName(player) .. " joined and tried to use an existing player's name.\n"
    player:message(0, messageText, true)
end

EventHandler.onPlayerDisconnect = function(player)

    if player.customData.loggedIn == true then
        local dataTable = DataManager.getTableFromPlayer(player)

        DataManager.setEntryFromTable("player", player.customData.accountName .. "-test", dataTable)
    end
end


function OnGUILogin(player, data)
    if data == nil then
        InterfaceManager.showLogin(OnGUILogin, player)
    end

    local playerData = DataManager.getTableFromEntry("player", player.customData.accountName)

    -- Just in case the password from the data file is a number, make sure to turn it into a string
    if tostring(playerData.login.password) ~= data then
        player:message(0, "Incorrect password!\n", false)
        InterfaceManager.showLogin(OnGUILogin, player)
        return
    end

    -- Is this player on the banlist? If so, store their new IP and ban them
    if BanManager.isBanned(player) then
        player:message(0, player.accountName .. " is banned from this server.\n", true)

        if TableHelper.containsValue(playerData.ipAddresses, player.address) == false then
            table.insert(playerData.ipAddresses, player.address)
        end

        DataManager.setEntryFromTable("player", player.customData.accountName, playerData)
        banAddress(player.address)
    else
        DataManager.setPlayerFromTable(player, playerData)
        player:message(0, "You have successfully logged in.\n", false)
    end
end

function OnGUIRegister(player, data)
    if data == nil then
        player:message(0, "The password cannot be empty.\n", false)
        InterfaceManager.showRegistration(OnGUIRegister, player)
        return
    end

    player.customData.login = { password = data }
    player:message(0, "You have successfully registered.\nUse Y by default to chat or change it from your client config.\n")
    player:setCharGenStages(1, 4)
end

return EventHandler
