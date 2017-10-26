DataManager = dofile(getModFolder() .. "dataManager.lua")
InterfaceManager = dofile(getModFolder() .. "interfaceManager.lua")
BanManager = dofile(getModFolder() .. "banManager.lua")

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
    player:message(messageText, true)

    messageText = "Welcome, " .. player.name .. ".\nYou have " .. tostring(Config.Core.loginTime) .. " seconds to"

    if DataManager.hasObjectEntry("player", player.customData.accountName) then
        messageText = messageText .. " log in.\n"
        InterfaceManager.showLogin(player)
    else
        messageText = messageText .. " register.\n"
        InterfaceManager.showRegistration(player)
    end

    player:message(messageText, false)
    player.customData.loggedIn = true
end

EventHandler.denyPlayerName = function(player)
    local messageText = EventHandler.getChatName(player) .. " joined and tried to use an existing player's name.\n"
    player:message(messageText, true)
end

EventHandler.onGUIAction = function(player, guiId, guiData)

    -- The data can be numerical, but we should convert it to a string
    guiData = tostring(guiData)

    if guiId == InterfaceManager.ID.LOGIN then

        if guiData == nil then
            player:message("Passwords cannot be blank!\n", false)
            InterfaceManager.showLogin(player)
            return true
        end

        local playerData = DataManager.getTableFromEntry("player", player.customData.accountName)

        -- Just in case the password from the data file is a number, make sure to turn it into a string
        if tostring(playerData.login.password) ~= guiData then
            player:message("Incorrect password!\n", false)
            InterfaceManager.showLogin(player)
            return true
        end

        -- Is this player on the banlist? If so, store their new IP and ban them
        if BanManager.isBanned(player) then
            player:message(player.accountName .. " is banned from this server.\n", true)

            if TableHelper.containsValue(playerData.ipAddresses, player.address) == false then
                table.insert(playerData.ipAddresses, player.address)
            end

            DataManager.setEntryFromTable("player", player.accountName, playerData)
            banAddress(player.address)
        else
            DataManager.setPlayerFromTable(player, playerData)
            player:message("You have successfully logged in.\n", false)
        end

    elseif guiId == InterfaceManager.ID.REGISTER then

        if guiData == nil then
            player:message("The password cannot be empty.\n", false)
            InterfaceManager.showRegistration(player)
            return true
        end

        player.customData.login = { password = guiData }
        player:message("You have successfully registered.\nUse Y by default to chat or change it from your client config.\n")
        player:setCharGenStage(1, 4)
    end

    return false
end

return EventHandler
