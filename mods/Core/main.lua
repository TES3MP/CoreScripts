ModInfo = {
    name = "Core",
    author = "tes3mp team",
    version = "0.0.1",
    dependencies = {
    }
}

local dataFolder = getDataFolder()

require("color")
require("utils")
jsonInterface = require("jsonInterface")

Event.register(Events.ON_PLAYER_CONNECT, function(player)
    return true
end)


Event.register(Events.ON_PLAYER_SENDMESSAGE, function(player, message)
    if Data.overrideChat ~= nil and Data.overrideChat == true then -- you can easly turn off Core behavior by Data.overrideChat = true
        return
    end

    local chatMessage = ("%s (%d): %s\n"):format(player.name, player.pid, message)
    io.write(chatMessage)
    player:message(color.White..chatMessage, true) -- send to All
end)

function helpCommand(player, args)
    local helpTable = CommandController.getHelpStrings(); -- returns table with helpStrings (command, helpMsg, command, HelpMsg, ...)
    local helpMsg = {}
    local strFormat = "%s\n"
    for k = 1,#helpTable do
        if k % 2 == 0 and helpTable[k]:len() ~= 0 then
            table.insert(helpMsg, strFormat:format(helpTable[k]))
        end
    end
    helpMsg = table.concat(helpMsg)

    player:message(color.Warning..helpMsg, false)
    --player:messageBox(helpMsg)
    return true
end

CommandController.registerCommand("help", helpCommand, "/help show this info")


pluginList = {}
function LoadPluginList()
    --tes3mp.LogMessage(2, "Reading pluginlist.json")

    local pluginList2 = jsonInterface.load(dataFolder, "pluginlist.json")
    for idx, pl in pairs(pluginList2) do
        idx = tonumber(idx) + 1
        for n, h in pairs(pl) do
            pluginList[idx] = {n}
            io.write(("%d, {%s"):format(idx, n))
            for _, v in ipairs(h) do
                io.write((", %X"):format(tonumber(v, 16)))
                table.insert(pluginList[idx], tonumber(v, 16))
            end
            table.insert(pluginList[idx], "")
            io.write("}\n")
        end
    end
end

LoadPluginList()

Event.register(Events.ON_REQUEST_PLUGIN_LIST, function(id, field)
    id = id + 1
    field = field + 1
    if #pluginList < id then
        return ""
    end
    return pluginList[id][field]
end)

function updateMpNum(mpNum)
    local fileName = "mpNum.json"
    local cfgMpNum = {mpNum = 0}
    if mpNum == nil then
        createFile(dataFolder, fileName)
        cfgMpNum = jsonInterface.load(dataFolder, fileName)
    end
    if cfgMpNum ~= nil  and cfgMpNum["mpNum"] ~= nil then
        if mpNum == nil then
            setCurrentMpNum(cfgMpNum["mpNum"])
            logMessage(0, "mpNum is loaded. Loaded value: " .. cfgMpNum["mpNum"])
        else
            cfgMpNum["mpNum"] = mpNum
            jsonInterface.save(dataFolder, fileName, cfgMpNum)
            logMessage(0, "mpNum is updated. New value: " .. mpNum)
        end
    end
end

Event.register(Events.ON_POST_INIT, function()
    updateMpNum() -- load mpNum to server
end)

Event.register(Events.ON_MP_REFNUM, updateMpNum)
