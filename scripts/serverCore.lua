require("config")
class = require("classy")
tableHelper = require("tableHelper")
require("utils")
require("guiIds")
require("color")
require("time")

logicHandler = require("logicHandler")
eventHandler = require("eventHandler")
animHelper = require("animHelper")
speechHelper = require("speechHelper")
menuHelper = require("menuHelper")
commandHandler = require("commandHandler")

Database = nil
Player = nil
Cell = nil
World = nil

hourCounter = nil
frametimeMultiplier = nil
updateTimerId = nil

banList = {}
pluginList = {}

if (config.databaseType ~= nil and config.databaseType ~= "json") and doesModuleExist("luasql." .. config.databaseType) then

    Database = require("database")
    Database:LoadDriver(config.databaseType)

    tes3mp.LogMessage(1, "Using " .. Database.driver._VERSION .. " with " .. config.databaseType .. " driver")

    Database:Connect(config.databasePath)

    -- Make sure we enable foreign keys
    Database:Execute("PRAGMA foreign_keys = ON;")

    Database:CreatePlayerTables()
    Database:CreateWorldTables()

    Player = require("player.sql")
    Cell = require("cell.sql")
    World = require("world.sql")
else
    Player = require("player.json")
    Cell = require("cell.json")
    World = require("world.json")
end

function LoadBanList()
    tes3mp.LogMessage(2, "Reading banlist.json")
    banList = jsonInterface.load("banlist.json")

    if banList.playerNames == nil then
        banList.playerNames = {}
    elseif banList.ipAddresses == nil then
        banList.ipAddresses = {}
    end

    if #banList.ipAddresses > 0 then
        local message = "- Banning manually-added IP addresses:\n"

        for index, ipAddress in pairs(banList.ipAddresses) do
            message = message .. ipAddress

            if index < #banList.ipAddresses then
                message = message .. ", "
            end

            tes3mp.BanAddress(ipAddress)
        end

        tes3mp.LogAppend(2, message)
    end

    if #banList.playerNames > 0 then
        local message = "- Banning all IP addresses stored for players:\n"

        for index, targetName in pairs(banList.playerNames) do
            message = message .. targetName

            if index < #banList.playerNames then
                message = message .. ", "
            end

            local targetPlayer = logicHandler.GetPlayerByName(targetName)

            if targetPlayer ~= nil then

                for index, ipAddress in pairs(targetPlayer.data.ipAddresses) do
                    tes3mp.BanAddress(ipAddress)
                end
            end
        end

        tes3mp.LogAppend(2, message)
    end
end

function SaveBanList()
    jsonInterface.save("banlist.json", banList)
end

function LoadPluginList()
    tes3mp.LogMessage(2, "Reading pluginlist.json")

    local jsonPluginList = jsonInterface.load("pluginlist.json")

    -- Fix numerical keys to print plugins in the correct order
    tableHelper.fixNumericalKeys(jsonPluginList, true)

    for listIndex, pluginEntry in ipairs(jsonPluginList) do
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

do
    local adminsCounter = 0
    function IncrementAdminCounter()
        adminsCounter = adminsCounter + 1
        tes3mp.SetRuleValue("adminsOnline", adminsCounter)
    end
    function DecrementAdminCounter()
        adminsCounter = adminsCounter - 1
        tes3mp.SetRuleValue("adminsOnline", adminsCounter)
    end
    function ResetAdminCounter()
        adminsCounter = 0
        tes3mp.SetRuleValue("adminsOnline", adminsCounter)
    end
end

do
    local previousHourFloor = nil

    function UpdateTime()

        if config.passTimeWhenEmpty or tableHelper.getCount(Players) > 0 then

            hourCounter = hourCounter + (0.0083 * frametimeMultiplier)

            local hourFloor = math.floor(hourCounter)

            if previousHourFloor == nil then
                previousHourFloor = hourFloor

            elseif hourFloor > previousHourFloor then

                if hourFloor >= 24 then

                    hourCounter = hourCounter - hourFloor
                    hourFloor = 0

                    tes3mp.LogMessage(2, "The world time day has been incremented")
                    WorldInstance:IncrementDay()
                end

                tes3mp.LogMessage(2, "The world time hour is now " .. hourFloor)
                WorldInstance.data.time.hour = hourCounter

                WorldInstance:Save()

                if tableHelper.getCount(Players) > 0 then
                    WorldInstance:LoadTime(tableHelper.getAnyValue(Players).pid, true)
                end

                previousHourFloor = hourFloor
            end
        end

        tes3mp.RestartTimer(updateTimerId, time.seconds(1))
    end
end

function OnServerInit()

    tes3mp.LogMessage(1, "Called \"OnServerInit\"")

    local expectedVersionPrefix = "0.6.3"
    local serverVersion = tes3mp.GetServerVersion()

    if string.sub(serverVersion, 1, string.len(expectedVersionPrefix)) ~= expectedVersionPrefix then
        tes3mp.LogAppend(3, "- Version mismatch between server and Core scripts!")
        tes3mp.LogAppend(3, "- The Core scripts require a server version that starts with " .. expectedVersionPrefix)
        tes3mp.StopServer(1)
    end

    logicHandler.InitializeWorld()
    hourCounter = WorldInstance.data.time.hour
    frametimeMultiplier = WorldInstance.data.time.timeScale / WorldInstance.defaultTimeScale

    updateTimerId = tes3mp.CreateTimer("UpdateTime", time.seconds(1))
    tes3mp.StartTimer(updateTimerId)

    logicHandler.PushPlayerList(Players)

    LoadBanList()
    LoadPluginList()

    tes3mp.SetPluginEnforcementState(config.enforcePlugins)
end

function OnServerPostInit()

    tes3mp.LogMessage(1, "Called \"OnServerPostInit\"")

    tes3mp.SetGameMode(config.gameMode)

    local consoleRuleString = "allowed"
    if not config.allowConsole then
        consoleRuleString = "not " .. consoleRuleString
    end

    local bedRestRuleString = "allowed"
    if not config.allowBedRest then
        bedRestRuleString = "not " .. bedRestRuleString
    end

    local wildRestRuleString = "allowed"
    if not config.allowWildernessRest then
        wildRestRuleString = "not " .. wildRestRuleString
    end

    local waitRuleString = "allowed"
    if not config.allowWait then
        waitRuleString = "not " .. waitRuleString
    end

    tes3mp.SetRuleString("enforcePlugins", tostring(config.enforcePlugins))
    tes3mp.SetRuleValue("difficulty", config.difficulty)
    tes3mp.SetRuleValue("deathPenaltyJailDays", config.deathPenaltyJailDays)
    tes3mp.SetRuleString("console", consoleRuleString)
    tes3mp.SetRuleString("bedResting", bedRestRuleString)
    tes3mp.SetRuleString("wildernessResting", wildRestRuleString)
    tes3mp.SetRuleString("waiting", waitRuleString)
    tes3mp.SetRuleValue("enforcedLogLevel", config.enforcedLogLevel)
    tes3mp.SetRuleValue("physicsFramerate", config.physicsFramerate)
    tes3mp.SetRuleString("spawnCell", tostring(config.defaultSpawnCell))
    tes3mp.SetRuleString("shareJournal", tostring(config.shareJournal))
    tes3mp.SetRuleString("shareFactionRanks", tostring(config.shareFactionRanks))
    tes3mp.SetRuleString("shareFactionExpulsion", tostring(config.shareFactionExpulsion))
    tes3mp.SetRuleString("shareFactionReputation", tostring(config.shareFactionReputation))
    tes3mp.SetRuleString("shareTopics", tostring(config.shareTopics))
    tes3mp.SetRuleString("shareBounty", tostring(config.shareBounty))
    tes3mp.SetRuleString("shareReputation", tostring(config.shareReputation))
    tes3mp.SetRuleString("shareMapExploration", tostring(config.shareMapExploration))
    tes3mp.SetRuleString("enablePlacedObjectCollision", tostring(config.enablePlacedObjectCollision))

    local respawnCell

    if config.respawnAtImperialShrine == true then
        respawnCell = "nearest Imperial shrine"

        if config.respawnAtTribunalTemple == true then
            respawnCell = respawnCell .. " or Tribunal temple"
        end
    elseif config.respawnAtTribunalTemple == true then
        respawnCell = "nearest Tribunal temple"
    else
        respawnCell = tostring(config.defaultRespawnCell)
    end

    tes3mp.SetRuleString("respawnCell", respawnCell)
    ResetAdminCounter()
end

function OnServerExit(error)
    tes3mp.LogMessage(1, "Called \"OnServerExit\"")
    tes3mp.LogMessage(3, tostring(error))
end

function OnRequestPluginList(id, field)
    id = id + 1
    field = field + 1
    if #pluginList < id then
        return ""
    end
    return pluginList[id][field]
end

function OnPlayerConnect(pid)

    tes3mp.LogMessage(1, "Called \"OnPlayerConnect\" for pid " .. pid)

    local playerName = tes3mp.GetName(pid)

    if string.len(playerName) > 35 then
        playerName = string.sub(playerName, 0, 35)
    end

    if logicHandler.IsPlayerNameAllowed(playerName) == false then
        local message = playerName .. " (" .. pid .. ") " .. "joined and tried to use a disallowed name.\n"
        tes3mp.SendMessage(pid, message, true)
        return false -- deny player        
    elseif logicHandler.IsPlayerNameLoggedIn(playerName) then
        local message = playerName .. " (" .. pid .. ") " .. "joined and tried to use an existing player's name.\n"
        tes3mp.SendMessage(pid, message, true)
        return false -- deny player
    else
        tes3mp.LogAppend(1, "- New player is named " .. playerName)
        eventHandler.OnPlayerConnect(pid, playerName)
        return true -- accept player
    end
end

function OnLoginTimeExpiration(pid) -- timer-based event, see eventHandler.OnPlayerConnect
    if logicHandler.AuthCheck(pid) then
        if Players[pid]:IsModerator() then
            IncrementAdminCounter()
        end
    end
end

function OnPlayerDisconnect(pid)

    tes3mp.LogMessage(1, "Called \"OnPlayerDisconnect\" for pid " .. pid)
    local message = logicHandler.GetChatName(pid) .. " left the server.\n"

    tes3mp.SendMessage(pid, message, true)

    if Players[pid] ~= nil then

        Players[pid]:DeleteSummons()

        -- Was this player confiscating from someone? If so, clear that
        if Players[pid].confiscationTargetName ~= nil then
            local targetName = Players[pid].confiscationTargetName
            local targetPlayer = logicHandler.GetPlayerByName(targetName)
            targetPlayer:SetConfiscationState(false)
        end
    end

    -- Trigger any necessary script events useful for saving state
    eventHandler.OnPlayerCellChange(pid)

    eventHandler.OnPlayerDisconnect(pid)
    DecrementAdminCounter()
end

function OnPlayerResurrect(pid)
end

function OnPlayerSendMessage(pid, message)
    local playerName = tes3mp.GetName(pid)
    tes3mp.LogMessage(1, logicHandler.GetChatName(pid) .. ": " .. message)

    if eventHandler.OnPlayerMessage(pid, message) == false then
        return false
    end

    if message:sub(1,1) == '/' then

        local command = (message:sub(2, #message)):split(" ")
        commandHandler.ProcessCommand(pid, command)
        return false -- commands should be hidden

    -- Check for chat overrides that add extra text
    else
        if admin then
            local message = "[Admin] " .. logicHandler.GetChatName(pid) .. ": " .. message .. "\n"
            tes3mp.SendMessage(pid, message, true)
            return false
        elseif moderator then
            local message = "[Mod] " .. logicHandler.GetChatName(pid) .. ": " .. message .. "\n"
            tes3mp.SendMessage(pid, message, true)
            return false
        end
    end

    return true -- default behavior, regular chat messages should not be overridden
end

function OnObjectLoopTimeExpiration(loopIndex)
    eventHandler.OnObjectLoopTimeExpiration(loopIndex)
end

function OnDeathTimeExpiration(pid)
    eventHandler.OnDeathTimeExpiration(pid)
end

function OnPlayerDeath(pid)
    tes3mp.LogMessage(0, "Called \"OnPlayerDeath\" for pid " .. pid)
    eventHandler.OnPlayerDeath(pid)
end

function OnPlayerAttribute(pid)
    tes3mp.LogMessage(0, "Called \"OnPlayerAttribute\" for pid " .. pid)
    eventHandler.OnPlayerAttribute(pid)
end

function OnPlayerSkill(pid)
    eventHandler.OnPlayerSkill(pid)
end

function OnPlayerLevel(pid)
    tes3mp.LogMessage(0, "Called \"OnPlayerLevel\" for pid " .. pid)
    eventHandler.OnPlayerLevel(pid)
end

function OnPlayerShapeshift(pid)
    tes3mp.LogMessage(0, "Called \"OnPlayerShapeshift\" for pid " .. pid)
    eventHandler.OnPlayerShapeshift(pid)
end

function OnPlayerCellChange(pid)
    tes3mp.LogMessage(0, "Called \"OnPlayerCellChange\" for pid " .. pid)
    eventHandler.OnPlayerCellChange(pid)
end

function OnPlayerEquipment(pid)
    eventHandler.OnPlayerEquipment(pid)
end

function OnPlayerInventory(pid)
    eventHandler.OnPlayerInventory(pid)
end

function OnPlayerSpellbook(pid)
    tes3mp.LogMessage(0, "Called \"OnPlayerSpellbook\" for pid " .. pid)
    eventHandler.OnPlayerSpellbook(pid)
end

function OnPlayerQuickKeys(pid)
    tes3mp.LogMessage(0, "Called \"OnPlayerQuickKeys\" for pid " .. pid)
    eventHandler.OnPlayerQuickKeys(pid)
end

function OnPlayerJournal(pid)
    tes3mp.LogMessage(0, "Called \"OnPlayerJournal\" for pid " .. pid)
    eventHandler.OnPlayerJournal(pid)
end

function OnPlayerFaction(pid)
    tes3mp.LogMessage(0, "Called \"OnPlayerFaction\" for pid " .. pid)
    eventHandler.OnPlayerFaction(pid)
end

function OnPlayerTopic(pid)
    tes3mp.LogMessage(0, "Called \"OnPlayerTopic\" for pid " .. pid)
    eventHandler.OnPlayerTopic(pid)
end

function OnPlayerBounty(pid)
    tes3mp.LogMessage(0, "Called \"OnPlayerBounty\" for pid " .. pid)
    eventHandler.OnPlayerBounty(pid)
end

function OnPlayerReputation(pid)
    tes3mp.LogMessage(0, "Called \"OnPlayerReputation\" for pid " .. pid)
    eventHandler.OnPlayerReputation(pid)
end

function OnPlayerKillCount(pid)
    tes3mp.LogMessage(0, "Called \"OnPlayerKillCount\" for pid " .. pid)
    eventHandler.OnPlayerKillCount(pid)
end

function OnPlayerBook(pid)
    tes3mp.LogMessage(0, "Called \"OnPlayerBook\" for pid " .. pid)
    eventHandler.OnPlayerBook(pid)
end

function OnPlayerMiscellaneous(pid)
    tes3mp.LogMessage(0, "Called \"OnPlayerMiscellaneous\" for pid " .. pid)
    eventHandler.OnPlayerMiscellaneous(pid)
end

function OnPlayerEndCharGen(pid)
    tes3mp.LogMessage(0, "Called \"OnPlayerEndCharGen\" for pid " .. pid)
    eventHandler.OnPlayerEndCharGen(pid)
end

function OnCellLoad(pid, cellDescription)
    tes3mp.LogMessage(0, "Called \"OnCellLoad\" for pid " .. pid .. " and cell " .. cellDescription)
    eventHandler.OnCellLoad(pid, cellDescription)
end

function OnCellUnload(pid, cellDescription)
    tes3mp.LogMessage(0, "Called \"OnCellUnload\" for pid " .. pid .. " and cell " .. cellDescription)
    eventHandler.OnCellUnload(pid, cellDescription)
end

function OnCellDeletion(cellDescription)
    tes3mp.LogMessage(0, "Called \"OnCellDeletion\" for cell " .. cellDescription)
    eventHandler.OnCellDeletion(cellDescription)
end

function OnActorList(pid, cellDescription)
    tes3mp.LogMessage(0, "Called \"OnActorList\" for pid " .. pid .. " and cell " .. cellDescription)
    eventHandler.OnActorList(pid, cellDescription)
end

function OnActorEquipment(pid, cellDescription)
    tes3mp.LogMessage(0, "Called \"OnActorEquipment\" for pid " .. pid .. " and cell " .. cellDescription)
    eventHandler.OnActorEquipment(pid, cellDescription)
end

function OnActorDeath(pid, cellDescription)
    tes3mp.LogMessage(0, "Called \"OnActorDeath\" for pid " .. pid .. " and cell " .. cellDescription)
    eventHandler.OnActorDeath(pid, cellDescription)
end

function OnActorCellChange(pid, cellDescription)
    tes3mp.LogMessage(0, "Called \"OnActorCellChange\" for pid " .. pid .. " and cell " .. cellDescription)
    eventHandler.OnActorCellChange(pid, cellDescription)
end

function OnObjectPlace(pid, cellDescription)
    tes3mp.LogMessage(0, "Called \"OnObjectPlace\" for pid " .. pid .. " and cell " .. cellDescription)
    eventHandler.OnObjectPlace(pid, cellDescription)
end

function OnObjectSpawn(pid, cellDescription)
    tes3mp.LogMessage(0, "Called \"OnObjectSpawn\" for pid " .. pid .. " and cell " .. cellDescription)
    eventHandler.OnObjectSpawn(pid, cellDescription)
end

function OnObjectDelete(pid, cellDescription)
    tes3mp.LogMessage(0, "Called \"OnObjectDelete\" for pid " .. pid .. " and cell " .. cellDescription)
    eventHandler.OnObjectDelete(pid, cellDescription)
end

function OnObjectLock(pid, cellDescription)
    tes3mp.LogMessage(0, "Called \"OnObjectLock\" for pid " .. pid .. " and cell " .. cellDescription)
    eventHandler.OnObjectLock(pid, cellDescription)
end

function OnObjectTrap(pid, cellDescription)
    tes3mp.LogMessage(0, "Called \"OnObjectTrap\" for pid " .. pid .. " and cell " .. cellDescription)
    eventHandler.OnObjectTrap(pid, cellDescription)
end

function OnObjectScale(pid, cellDescription)
    tes3mp.LogMessage(0, "Called \"OnObjectScale\" for pid " .. pid .. " and cell " .. cellDescription)
    eventHandler.OnObjectScale(pid, cellDescription)
end

function OnObjectState(pid, cellDescription)
    tes3mp.LogMessage(0, "Called \"OnObjectState\" for pid " .. pid .. " and cell " .. cellDescription)
    eventHandler.OnObjectState(pid, cellDescription)
end

function OnDoorState(pid, cellDescription)
    tes3mp.LogMessage(0, "Called \"OnDoorState\" for pid " .. pid .. " and cell " .. cellDescription)
    eventHandler.OnDoorState(pid, cellDescription)
end

function OnContainer(pid, cellDescription)
    tes3mp.LogMessage(0, "Called \"OnContainer\" for pid " .. pid .. " and cell " .. cellDescription)
    eventHandler.OnContainer(pid, cellDescription)
end

function OnVideoPlay(pid)
    tes3mp.LogMessage(0, "Called \"OnVideoPlay\" for pid " .. pid)
    eventHandler.OnVideoPlay(pid)
end

function OnWorldMap(pid)
    tes3mp.LogMessage(0, "Called \"OnWorldMap\" for pid " .. pid)
    eventHandler.OnWorldMap(pid)
end

function OnGUIAction(pid, idGui, data)
    tes3mp.LogMessage(0, "Called \"OnGUIAction\" for pid " .. pid)
    if eventHandler.OnGUIAction(pid, idGui, data) then return end -- if eventHandler.OnGUIAction is called
end

function OnMpNumIncrement(currentMpNum)
    eventHandler.OnMpNumIncrement(currentMpNum)
end
