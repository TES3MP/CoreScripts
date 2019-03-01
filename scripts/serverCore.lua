jsonInterface = require("jsonInterface")

-- Lua's default io library for input/output can't open Unicode filenames on Windows,
-- which is why on Windows it's replaced by TES3MP's io2 (https://github.com/TES3MP/Lua-io2)
if tes3mp.GetOperatingSystemType() == "Windows" then
    jsonInterface.setLibrary(require("io2"))
else
    jsonInterface.setLibrary(io)
end

require("color")
require("config")
class = require("classy")
tableHelper = require("tableHelper")
require("utils")
require("time")

logicHandler = require("logicHandler")
eventManager = require("eventManager")
eventHandler = require("eventHandler")
guiHelper = require("guiHelper")
animHelper = require("animHelper")
speechHelper = require("speechHelper")
menuHelper = require("menuHelper")
plugins = require("plugins")

Database = nil
Player = nil
Cell = nil
RecordStore = nil
World = nil

hourCounter = nil
frametimeMultiplier = nil
updateTimerId = nil

banList = {}

if (config.databaseType ~= nil and config.databaseType ~= "json") and doesModuleExist("luasql." .. config.databaseType) then

    Database = require("database")
    Database:LoadDriver(config.databaseType)

    tes3mp.LogMessage(enumerations.log.INFO, "Using " .. Database.driver._VERSION .. " with " .. config.databaseType ..
        " driver")

    Database:Connect(config.databasePath)

    -- Make sure we enable foreign keys
    Database:Execute("PRAGMA foreign_keys = ON;")

    Database:CreatePlayerTables()
    Database:CreateWorldTables()

    Player = require("player.sql")
    Cell = require("cell.sql")
    RecordStore = require("recordstore.sql")
    World = require("world.sql")
else
    Player = require("player.json")
    Cell = require("cell.json")
    RecordStore = require("recordstore.json")
    World = require("world.json")
end

function LoadBanList()
    tes3mp.LogMessage(enumerations.log.WARN, "Reading banlist.json")
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

        tes3mp.LogAppend(enumerations.log.WARN, message)
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

        tes3mp.LogAppend(enumerations.log.WARN, message)
    end
end

function SaveBanList()
    jsonInterface.save("banlist.json", banList)
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

                    tes3mp.LogMessage(enumerations.log.WARN, "The world time day has been incremented")
                    WorldInstance:IncrementDay()
                end

                tes3mp.LogMessage(enumerations.log.WARN, "The world time hour is now " .. hourFloor)
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

    tes3mp.LogMessage(enumerations.log.INFO, "Called \"OnServerInit\"")

    local expectedVersionPrefix = "0.7.0"
    local serverVersion = tes3mp.GetServerVersion()

    if string.sub(serverVersion, 1, string.len(expectedVersionPrefix)) ~= expectedVersionPrefix then
        tes3mp.LogAppend(enumerations.log.ERROR, "- Version mismatch between server and Core scripts!")
        tes3mp.LogAppend(enumerations.log.ERROR, "- The Core scripts require a server version that starts with " ..
            expectedVersionPrefix)
        tes3mp.StopServer(1)
    end
	
	local isValid = eventManager.triggerValidators("OnServerInit",{})
	if isValid then
		logicHandler.InitializeWorld()

		for _, storeType in ipairs(config.recordStoreLoadOrder) do
			logicHandler.LoadRecordStore(storeType)
		end

		hourCounter = WorldInstance.data.time.hour
		frametimeMultiplier = WorldInstance.data.time.timeScale / WorldInstance.defaultTimeScale

		updateTimerId = tes3mp.CreateTimer("UpdateTime", time.seconds(1))
		tes3mp.StartTimer(updateTimerId)

		logicHandler.PushPlayerList(Players)

		LoadBanList()

		tes3mp.SetPluginEnforcementState(config.enforcePlugins)
		tes3mp.SetScriptErrorIgnoringState(config.ignoreScriptErrors)
		end
	eventManager.triggerHandlers("OnServerInit",isValid,{})
end

function OnServerPostInit()
	tes3mp.LogMessage(enumerations.log.INFO, "Called \"OnServerPostInit\"")
	local isValid = eventManager.triggerValidators("OnServerPostInit",{})
	if isValid then
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
		tes3mp.SetRuleString("ignoreScriptErrors", tostring(config.ignoreScriptErrors))
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
	eventManager.triggerHandlers("OnServerPostInit",isValid,{})
end

function OnServerExit(error)
    tes3mp.LogMessage(enumerations.log.INFO, "Called \"OnServerExit\"")
    tes3mp.LogMessage(enumerations.log.ERROR, tostring(error))
	eventManager.triggerHandlers("OnServerExit",isValid,{error})
end


function LoadPluginList()
    local pluginList = {}
    tes3mp.LogMessage(enumerations.log.WARN, "Reading pluginlist.json")

    local jsonPluginList = jsonInterface.load("pluginlist.json")

    -- Fix numerical keys to print plugins in the correct order
    tableHelper.fixNumericalKeys(jsonPluginList, true)

    for listIndex, pluginEntry in ipairs(jsonPluginList) do
        for entryIndex, hashArray in pairs(pluginEntry) do

            pluginList[listIndex] = {}
            pluginList[listIndex].name = entryIndex

            local hashes = {}
            local debugMessage = ("- %d: \"%s\": ["):format(listIndex, entryIndex)

            for _, hash in ipairs(hashArray) do

                debugMessage = debugMessage .. ("%X, "):format(tonumber(hash, 16))
                table.insert(hashes, tonumber(hash, 16))
            end
            pluginList[listIndex].hashes = hashes
            table.insert(pluginList[listIndex], "")

            debugMessage = debugMessage .. "\b\b]"
            tes3mp.LogAppend(enumerations.log.WARN, debugMessage)
        end
    end
    return pluginList
end

function OnRequestPluginList()
    local pluginList = LoadPluginList()

    for _, entry in ipairs(pluginList) do
        local name = entry.name

        if tableHelper.isEmpty(entry.hashes) then
            tes3mp.AddPluginHash(name, "")
        else
            for _, hash in ipairs(entry.hashes) do
                tes3mp.AddPluginHash(name, hash)
            end
        end
    end
end

function OnPlayerConnect(pid)

    tes3mp.LogMessage(enumerations.log.INFO, "Called \"OnPlayerConnect\" for pid " .. pid)

    local playerName = tes3mp.GetName(pid)

    if string.len(playerName) > 35 then
        playerName = string.sub(playerName, 0, 35)
    end

    if not logicHandler.IsNameAllowed(playerName) then
        local message = playerName .. " (" .. pid .. ") " .. "joined and tried to use a disallowed name.\n"
        tes3mp.SendMessage(pid, message, true)
        tes3mp.Kick(pid)
    elseif logicHandler.IsPlayerNameLoggedIn(playerName) then
        local message = playerName .. " (" .. pid .. ") " .. "joined and tried to use an existing player's name.\n"
        tes3mp.SendMessage(pid, message, true)
        tes3mp.Kick(pid)
    else
        tes3mp.LogAppend(enumerations.log.INFO, "- New player is named " .. playerName)
        eventHandler.OnPlayerConnect(pid, playerName)
    end
end

function OnLoginTimeExpiration(pid) -- timer-based event, see eventHandler.OnPlayerConnect
	local isValid = eventManager.triggerValidators("OnLoginTimeExpiration",{pid})
	if isValid then
		if logicHandler.AuthCheck(pid) then
			if Players[pid]:IsModerator() then
				IncrementAdminCounter()
			end
		end
	end
	eventManager.triggerHandlers("OnLoginTimeExpiration",isValid,{pid})
end

function OnPlayerDisconnect(pid)

    tes3mp.LogMessage(enumerations.log.INFO, "Called \"OnPlayerDisconnect\" for " .. logicHandler.GetChatName(pid))
    local message = logicHandler.GetChatName(pid) .. " left the server.\n"

    tes3mp.SendMessage(pid, message, true)

    eventHandler.OnPlayerDisconnect(pid)
    DecrementAdminCounter()
end

function OnPlayerResurrect(pid)
	eventManager.triggerHandlers("OnPlayerResurrect",isValid,{pid})
end

function OnPlayerSendMessage(pid, message)
    eventHandler.OnPlayerSendMessage(pid, message)
end

function OnObjectLoopTimeExpiration(loopIndex)
    eventHandler.OnObjectLoopTimeExpiration(loopIndex)
end

function OnDeathTimeExpiration(pid)
    eventHandler.OnDeathTimeExpiration(pid)
end

function OnPlayerDeath(pid)
    tes3mp.LogMessage(enumerations.log.INFO, "Called \"OnPlayerDeath\" for " .. logicHandler.GetChatName(pid))
    eventHandler.OnPlayerDeath(pid)
end

function OnPlayerAttribute(pid)
    tes3mp.LogMessage(enumerations.log.INFO, "Called \"OnPlayerAttribute\" for " .. logicHandler.GetChatName(pid))
    eventHandler.OnPlayerAttribute(pid)
end

function OnPlayerSkill(pid)
    eventHandler.OnPlayerSkill(pid)
end

function OnPlayerLevel(pid)
    tes3mp.LogMessage(enumerations.log.INFO, "Called \"OnPlayerLevel\" for " .. logicHandler.GetChatName(pid))
    eventHandler.OnPlayerLevel(pid)
end

function OnPlayerShapeshift(pid)
    tes3mp.LogMessage(enumerations.log.INFO, "Called \"OnPlayerShapeshift\" for " .. logicHandler.GetChatName(pid))
    eventHandler.OnPlayerShapeshift(pid)
end

function OnPlayerCellChange(pid)
    tes3mp.LogMessage(enumerations.log.INFO, "Called \"OnPlayerCellChange\" for " .. logicHandler.GetChatName(pid))
    eventHandler.OnPlayerCellChange(pid)
end

function OnPlayerEquipment(pid)
    tes3mp.LogMessage(enumerations.log.INFO, "Called \"OnPlayerEquipment\" for " .. logicHandler.GetChatName(pid))
    eventHandler.OnPlayerEquipment(pid)
end

function OnPlayerInventory(pid)
    tes3mp.LogMessage(enumerations.log.INFO, "Called \"OnPlayerInventory\" for " .. logicHandler.GetChatName(pid))
    eventHandler.OnPlayerInventory(pid)
end

function OnPlayerSpellbook(pid)
    tes3mp.LogMessage(enumerations.log.INFO, "Called \"OnPlayerSpellbook\" for " .. logicHandler.GetChatName(pid))
    eventHandler.OnPlayerSpellbook(pid)
end

function OnPlayerQuickKeys(pid)
    tes3mp.LogMessage(enumerations.log.INFO, "Called \"OnPlayerQuickKeys\" for " .. logicHandler.GetChatName(pid))
    eventHandler.OnPlayerQuickKeys(pid)
end

function OnPlayerJournal(pid)
    tes3mp.LogMessage(enumerations.log.INFO, "Called \"OnPlayerJournal\" for " .. logicHandler.GetChatName(pid))
    eventHandler.OnPlayerJournal(pid)
end

function OnPlayerFaction(pid)
    tes3mp.LogMessage(enumerations.log.INFO, "Called \"OnPlayerFaction\" for " .. logicHandler.GetChatName(pid))
    eventHandler.OnPlayerFaction(pid)
end

function OnPlayerTopic(pid)
    tes3mp.LogMessage(enumerations.log.INFO, "Called \"OnPlayerTopic\" for " .. logicHandler.GetChatName(pid))
    eventHandler.OnPlayerTopic(pid)
end

function OnPlayerBounty(pid)
    tes3mp.LogMessage(enumerations.log.INFO, "Called \"OnPlayerBounty\" for " .. logicHandler.GetChatName(pid))
    eventHandler.OnPlayerBounty(pid)
end

function OnPlayerReputation(pid)
    tes3mp.LogMessage(enumerations.log.INFO, "Called \"OnPlayerReputation\" for " .. logicHandler.GetChatName(pid))
    eventHandler.OnPlayerReputation(pid)
end

function OnPlayerBook(pid)
    tes3mp.LogMessage(enumerations.log.INFO, "Called \"OnPlayerBook\" for " .. logicHandler.GetChatName(pid))
    eventHandler.OnPlayerBook(pid)
end

function OnPlayerItemUse(pid)
    tes3mp.LogMessage(enumerations.log.INFO, "Called \"OnPlayerItemUse\" for " .. logicHandler.GetChatName(pid))
    eventHandler.OnPlayerItemUse(pid)
end

function OnPlayerMiscellaneous(pid)
    tes3mp.LogMessage(enumerations.log.INFO, "Called \"OnPlayerMiscellaneous\" for " .. logicHandler.GetChatName(pid))
    eventHandler.OnPlayerMiscellaneous(pid)
end

function OnPlayerEndCharGen(pid)
    tes3mp.LogMessage(enumerations.log.INFO, "Called \"OnPlayerEndCharGen\" for " .. logicHandler.GetChatName(pid))
    eventHandler.OnPlayerEndCharGen(pid)
end

function OnCellLoad(pid, cellDescription)
    tes3mp.LogMessage(enumerations.log.INFO, "Called \"OnCellLoad\" for " .. logicHandler.GetChatName(pid) ..
        " and cell " .. cellDescription)
    eventHandler.OnCellLoad(pid, cellDescription)
end

function OnCellUnload(pid, cellDescription)
    tes3mp.LogMessage(enumerations.log.INFO, "Called \"OnCellUnload\" for " .. logicHandler.GetChatName(pid) ..
        " and cell " .. cellDescription)
    eventHandler.OnCellUnload(pid, cellDescription)
end

function OnCellDeletion(cellDescription)
    tes3mp.LogMessage(enumerations.log.INFO, "Called \"OnCellDeletion\" for cell " .. cellDescription)
    eventHandler.OnCellDeletion(cellDescription)
end

function OnActorList(pid, cellDescription)
    tes3mp.LogMessage(enumerations.log.INFO, "Called \"OnActorList\" for " .. logicHandler.GetChatName(pid) ..
        " and cell " .. cellDescription)
    eventHandler.OnActorList(pid, cellDescription)
end

function OnActorEquipment(pid, cellDescription)
    tes3mp.LogMessage(enumerations.log.INFO, "Called \"OnActorEquipment\" for " .. logicHandler.GetChatName(pid) ..
        " and cell " .. cellDescription)
    eventHandler.OnActorEquipment(pid, cellDescription)
end

function OnActorAI(pid, cellDescription)
    tes3mp.LogMessage(enumerations.log.INFO, "Called \"OnActorAI\" for " .. logicHandler.GetChatName(pid) ..
        " and cell " .. cellDescription)
    eventHandler.OnActorAI(pid, cellDescription)
end

function OnActorDeath(pid, cellDescription)
    tes3mp.LogMessage(enumerations.log.INFO, "Called \"OnActorDeath\" for " .. logicHandler.GetChatName(pid) ..
        " and cell " .. cellDescription)
    eventHandler.OnActorDeath(pid, cellDescription)
end

function OnActorCellChange(pid, cellDescription)
    tes3mp.LogMessage(enumerations.log.INFO, "Called \"OnActorCellChange\" for " .. logicHandler.GetChatName(pid) ..
        " and cell " .. cellDescription)
    eventHandler.OnActorCellChange(pid, cellDescription)
end

function OnObjectActivate(pid, cellDescription)
    tes3mp.LogMessage(enumerations.log.INFO, "Called \"OnObjectActivate\" for " .. logicHandler.GetChatName(pid) ..
        " and cell " .. cellDescription)
    eventHandler.OnObjectActivate(pid, cellDescription)
end

function OnObjectPlace(pid, cellDescription)
    tes3mp.LogMessage(enumerations.log.INFO, "Called \"OnObjectPlace\" for " .. logicHandler.GetChatName(pid) ..
        " and cell " .. cellDescription)
    eventHandler.OnObjectPlace(pid, cellDescription)
end

function OnObjectSpawn(pid, cellDescription)
    tes3mp.LogMessage(enumerations.log.INFO, "Called \"OnObjectSpawn\" for " .. logicHandler.GetChatName(pid) ..
        " and cell " .. cellDescription)
    eventHandler.OnObjectSpawn(pid, cellDescription)
end

function OnObjectDelete(pid, cellDescription)
    tes3mp.LogMessage(enumerations.log.INFO, "Called \"OnObjectDelete\" for " .. logicHandler.GetChatName(pid) ..
        " and cell " .. cellDescription)
    eventHandler.OnObjectDelete(pid, cellDescription)
end

function OnObjectLock(pid, cellDescription)
    tes3mp.LogMessage(enumerations.log.INFO, "Called \"OnObjectLock\" for " .. logicHandler.GetChatName(pid) ..
        " and cell " .. cellDescription)
    eventHandler.OnObjectLock(pid, cellDescription)
end

function OnObjectTrap(pid, cellDescription)
    tes3mp.LogMessage(enumerations.log.INFO, "Called \"OnObjectTrap\" for " .. logicHandler.GetChatName(pid) ..
        " and cell " .. cellDescription)
    eventHandler.OnObjectTrap(pid, cellDescription)
end

function OnObjectScale(pid, cellDescription)
    tes3mp.LogMessage(enumerations.log.INFO, "Called \"OnObjectScale\" for " .. logicHandler.GetChatName(pid) ..
        " and cell " .. cellDescription)
    eventHandler.OnObjectScale(pid, cellDescription)
end

function OnObjectState(pid, cellDescription)
    tes3mp.LogMessage(enumerations.log.INFO, "Called \"OnObjectState\" for " .. logicHandler.GetChatName(pid) ..
        " and cell " .. cellDescription)
    eventHandler.OnObjectState(pid, cellDescription)
end

function OnDoorState(pid, cellDescription)
    tes3mp.LogMessage(enumerations.log.INFO, "Called \"OnDoorState\" for " .. logicHandler.GetChatName(pid) ..
        " and cell " .. cellDescription)
    eventHandler.OnDoorState(pid, cellDescription)
end

function OnContainer(pid, cellDescription)
    tes3mp.LogMessage(enumerations.log.INFO, "Called \"OnContainer\" for " .. logicHandler.GetChatName(pid) ..
        " and cell " .. cellDescription)
    eventHandler.OnContainer(pid, cellDescription)
end

function OnVideoPlay(pid)
    tes3mp.LogMessage(enumerations.log.INFO, "Called \"OnVideoPlay\" for " .. logicHandler.GetChatName(pid))
    eventHandler.OnVideoPlay(pid)
end

function OnRecordDynamic(pid)
    tes3mp.LogMessage(enumerations.log.INFO, "Called \"OnRecordDynamic\" for " .. logicHandler.GetChatName(pid))
    eventHandler.OnRecordDynamic(pid)
end

function OnWorldKillCount(pid)
    tes3mp.LogMessage(enumerations.log.INFO, "Called \"OnWorldKillCount\" for " .. logicHandler.GetChatName(pid))
    eventHandler.OnWorldKillCount(pid)
end

function OnWorldMap(pid)
    tes3mp.LogMessage(enumerations.log.INFO, "Called \"OnWorldMap\" for " .. logicHandler.GetChatName(pid))
    eventHandler.OnWorldMap(pid)
end

function OnWorldWeather(pid)
    tes3mp.LogMessage(enumerations.log.INFO, "Called \"OnWorldWeather\" for " .. logicHandler.GetChatName(pid))
    eventHandler.OnWorldWeather(pid)
end

function OnGUIAction(pid, idGui, data)
    tes3mp.LogMessage(enumerations.log.INFO, "Called \"OnGUIAction\" for " .. logicHandler.GetChatName(pid))
    if eventHandler.OnGUIAction(pid, idGui, data) then return end -- if eventHandler.OnGUIAction is called
end

function OnMpNumIncrement(currentMpNum)
    eventHandler.OnMpNumIncrement(currentMpNum)
end
