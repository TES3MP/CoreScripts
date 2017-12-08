systemChannel = 0
generalChannel = nil
Event.register(Events.ON_POST_INIT, function()
    generalChannel = createChannel()
end)

Event.register(Events.ON_PLAYER_CONNECT, function(player)
    player:renameChannel(systemChannel, "System")
    player:joinChannel(generalChannel, "General")
    return true
end)

function invite(player, invitedPID, channelId, thisChannel)
    if tonumber(invitedPID) == nil then
        player:message(thisChannel, color.Error.."Error: player ID should be a numerical value.\n")
        return false
    end    

    local invitedPl = Players.getByPID(invitedPID)
        
    if invitedPl == nil then
        player:message(thisChannel, color.Error.."Error: incorrect player ID.\n")
        return false
    end
    
    if tonumber(channelId) == nil then
        player:message(thisChannel, color.Error.."Error: channel ID should be a numerical value.\n")
        return false
    end    

    
    local channelStr = tostring(channelId)
    if player.customData[channelStr] == nil then
        player:message(thisChannel, color.Error.."Error:"..channelStr.." not found.\n")
    end
    local channelName = player.customData[channelStr][1]

    invitedPl.customData[channelStr] = {channelName, "invited"}

    invitedPl:message(systemChannel, (color.Green.."You have been invited to channel \"%s\". To join, type /channel accept \"%d\"\n"):format(channelName, thisChannel))
    return true
end


CommandController.registerCommand("channel", function(player, args, thisChannel)
    local command = args[1]
    if command == "create" then
        if args[2] == nil then
            player:message(thisChannel, color.Error.."Error: incorrect channel name.\n")
            return false
        end
        local channelId = createChannel()
        player.customData[tostring(channelId)] = {args[2], "owner"}
        player:joinChannel(channelId, args[2])
        player:setChannel(channelId)
        return true
    elseif command == "invite" then
        if #args == 3 then -- /channel invite channelId playerId
            return invite(player, args[2], args[3], thisChannel)
        elseif #args == 2 then -- /channel invite playerId
            return invite(player, args[2], thisChannel, thisChannel)
        else
            player:message(thisChannel, color.Error.."Error: incorrect arguments.\n")
            return false
        end
    elseif command == "accept" then
        if #args ~= 2 then
            player:message(0, color.Error.."Error")
            return false
        end

        local channelId = tonumber(args[2])
        if channelId == nil then
            player:message(thisChannel, color.Error.."Error: incorrect channel ID.\n")
            return false
        end

        local channel = player.customData[tostring(channelId)]

        if channel == nil or channel[2] ~= "invited" then
            player:message(thisChannel, (color.Error.."Error: you are not invited to channel %d.\n"):format(channelId))
            return true
        end

        player.customData[tostring(channelId)][2] = "member"
        player:joinChannel(channelId, channel[1])
        player:setChannel(channelId)
        player:message(channelId, (color.Green.."%s has joined the channel.\n"):format(player.name), true)
        return true
    elseif command == "leave" then
            local thisChStr = tostring(thisChannel)
            if thisChannel == systemChannel or thisChannel == generalChannel or player.customData[thisChStr] == nil
                or player.customData[thisChStr][2] ~= "member" then
                player:message(thisChannel, color.Warning.."Warning: cannot leave this channel.\n")
                return true
            end
            player.customData[thisChStr] = nil
            player:message(thisChannel, (color.Green.."%s has left the channel.\n"):format(player.name), true)
            player:leaveChannel(thisChannel)
            return true
    else
        player:message(thisChannel, color.Error.."Error: incorrect command ID.\n")
        return false
    end
end, "/channel")

Event.register(Events.ON_CHANNEL_ACTION, function(player, chId, action)
    
end)
