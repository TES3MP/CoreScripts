local time = require("time")

DataManager = import(getModFolder() .. "dataManager.lua")
InterfaceManager = import(getModFolder() .. "interfaceManager.lua")

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
            if string.lower(newPlayer.name) == string.lower(existingPlayer.name) then
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

    if DataManager.hasPlayerEntry(player) then
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

return EventHandler
