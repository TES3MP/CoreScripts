systemChannel = 0
generalChannel = nil
Event.register(Events.ON_POST_INIT, function()
    generalChannel = createChannel()
end)

Event.register(Events.ON_PLAYER_CONNECT, function(player)
    player:renameChannel(systemChannel, "System")
    player:joinToChannel(generalChannel, "General")
    return true
end)

function invite(player, invitedPID, channelId, thisChannel)
    if tonumber(invitedPID) == nil then
        player:message(thisChannel, color.Error.."Error. player id should be numeric value.\n")
        return false
    end    

    local invitedPl = Players.getByPID(invitedPID)
        
    if invitedPl == nil then
        player:message(thisChannel, color.Error.."Error. Incorrect player id.\n")
        return false
    end
    
    if tonumber(channelId) == nil then
        player:message(thisChannel, color.Error.."Error. channel id should be numeric value.\n")
        return false
    end    

    
    local channelStr = tostring(channelId)
    if player.customData[channelStr] == nil then
        player:message(thisChannel, color.Error.."Error."..channelStr.." not found.\n")
    end
    local channelName = player.customData[channelStr][1]

    invitedPl.customData[channelStr] = {channelName, "invited"}

    invitedPl:message(systemChannel, (color.Green.."You has been invited to \"%s\" channel. Type /channel accept \"%d\" to join\n"):format(channelName, thisChannel))
    return true
end


CommandController.registerCommand("channel", function(player, args, thisChannel)
    local command = args[1]
    if command == "create" then
        if args[2] == nil then
            player:message(thisChannel, color.Error.."Error. incorrect channel name.\n")
            return false
        end
        local channelId = createChannel()
        player.customData[tostring(channelId)] = {args[2], "owner"}
        player:joinToChannel(channelId, args[2])
        player:setChannel(channelId)
        return true
    elseif command == "invite" then
        if #args == 3 then -- /channel invite channelId playerId
            return invite(player, args[2], args[3], thisChannel)
        elseif #args == 2 then -- /channel invite playerId
            return invite(player, args[2], thisChannel, thisChannel)
        else
            player:message(thisChannel, color.Error.."Error. incorrect arguments.\n")
            return false
        end
    elseif command == "accept" then
        if #args ~= 2 then
            player:message(0, color.Error.."Error")
            return false
        end

        local channelId = tonumber(args[2])
        if channelId == nil then
            player:message(thisChannel, color.Error.."Error. incorrect channel id.\n")
            return false
        end

        local channel = player.customData[tostring(channelId)]

        if channel == nil or channel[2] ~= "invited" then
            player:message(thisChannel, (color.Error.."Error. You are not invited to %d channel.\n"):format(channelId))
            return true
        end

        player.customData[tostring(channelId)][2] = "member"
        player:joinToChannel(channelId, channel[1])
        player:setChannel(channelId)
        player:message(channelId, (color.Green.."%s joined to channel.\n"):format(player.name), true)
        return true
    elseif command == "leave" then
            local thisChStr = tostring(thisChannel)
            if thisChannel == systemChannel or thisChannel == generalChannel or player.customData[thisChStr] == nil
                or player.customData[thisChStr][2] ~= "member" then
                player:message(thisChannel, color.Warning.."Warning. Cannot leave this channel.\n")
                return true
            end
            player.customData[thisChStr] = nil
            player:message(thisChannel, (color.Green.."%s leaved channel.\n"):format(player.name), true)
            player:leaveChannel(thisChannel)
            return true
    else
        player:message(thisChannel, color.Error.."Error. incorrect command id.\n")
        return false
    end
end, "/channel")

Event.register(Events.ON_CHANNEL_ACTION, function(player, chId, action)
    
end)
