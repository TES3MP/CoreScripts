ModInfo = {
    name = "Core",
    author = "tes3mp team",
    version = "0.0.1",
    dependencies = {
    }
}

require("color")
require("utils")
jsonInterface = require("jsonInterface")
tableHelper = require("tableHelper")

Config.Core = dofile(getModFolder() .. "config.lua")
local dataFolder = getDataFolder()

pluginList = {}

function LoadPluginList()
    logMessage(2, "Reading pluginlist.json")

    local jsonPluginList = jsonInterface.load(dataFolder, "pluginlist.json")

    -- Fix numerical keys to print plugins in the correct order
    tableHelper.fixNumericalKeys(jsonPluginList)

    for listIndex, pluginEntry in pairs(jsonPluginList) do
        listIndex = listIndex + 1
        for entryIndex, hashArray in pairs(pluginEntry) do
            pluginList[listIndex] = {entryIndex}
            io.write(("%d, {%s"):format(listIndex, entryIndex))
            for _, hash in ipairs(hashArray) do
                io.write((", %X"):format(tonumber(hash, 16)))
                table.insert(pluginList[listIndex], tonumber(hash, 16))
            end
            table.insert(pluginList[listIndex], "")
            io.write("}\n")
        end
    end
end

function InitializeServer()

    local expectedVersion = "0.7-alpha"

    if Data.Core.VERSION ~= expectedVersion then
        logMessage(3, "Version mismatch between server and Core scripts!")
        logAppend(3, "- The Core scripts require " .. expectedVersion)
        stopServer(1)
    end

    LoadPluginList()
end

InitializeServer()

Event.register(Events.ON_POST_INIT, function()
    local consoleRuleString = "allowed"
    if not Config.Core.allowConsole then
        consoleRuleString = "not " .. consoleRuleString
    end

    setRuleValue("console", consoleRuleString)
    setRuleValue("difficulty", tostring(Config.Core.difficulty))
    setRuleValue("deathPenaltyJailDays", tostring(Config.Core.deathPenaltyJailDays))
    setRuleValue("spawnCell", tostring(Config.Core.defaultSpawnCell))
    setRuleValue("shareJournal", tostring(Config.Core.shareJournal))
    setRuleValue("shareFactionRanks", tostring(Config.Core.shareFactionRanks))
    setRuleValue("shareFactionExpulsion", tostring(Config.Core.shareFactionExpulsion))
    setRuleValue("shareFactionReputation", tostring(Config.Core.shareFactionReputation))

    local respawnCell

    if Config.Core.respawnAtImperialShrine == true then
        respawnCell = "nearest Imperial shrine"

        if Config.Core.respawnAtTribunalTemple == true then
            respawnCell = respawnCell .. " or Tribunal temple"
        end
    elseif Config.Core.respawnAtTribunalTemple == true then
        respawnCell = "nearest Tribunal temple"
    else
        respawnCell = tostring(Config.Core.defaultRespawnCell)
    end

    setRuleValue("respawnCell", respawnCell)

    updateMpNum() -- load mpNum to server
end)

Event.register(Events.ON_PLAYER_CONNECT, function(player)
    return true
end)


Event.register(Events.ON_PLAYER_SENDMESSAGE, function(player, message)
    if Data.overrideChat ~= nil and Data.overrideChat == true then -- you can easily turn off Core behavior via Data.overrideChat = true
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

Event.register(Events.ON_MP_REFNUM, updateMpNum)
