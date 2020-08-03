stateHelper = require("stateHelper")
local BaseWorld = class("BaseWorld")

-- Keep this here because it's required in mathematical operations
BaseWorld.defaultTimeScale = 30

BaseWorld.monthLengths = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }

BaseWorld.storedRegions = {}

function BaseWorld:__init()

    self.coreVariables =
    {
        currentMpNum = 0,
        hasRunStartupScripts = false
    }

    self.data =
    {
        fame = {
            bounty = 0,
            reputation = 0
        },
        journal = {},
        factionRanks = {},
        factionExpulsion = {},
        factionReputation = {},
        topics = {},
        kills = {},
        time = config.defaultTimeTable,
        mapExplored = {},
        destinationOverrides = {},
        customVariables = {}
    }
end

function BaseWorld:HasEntry()
    return self.hasEntry
end

function BaseWorld:EnsureCoreVariablesExist()

    if self.coreVariables == nil then
        self.coreVariables = {}
    end

    if self.coreVariables.currentMpNum == nil then
        if self.data.general.currentMpNum ~= nil then
            self.coreVariables.currentMpNum = self.data.general.currentMpNum
            self.data.general.currentMpNum = nil
        else
            self.coreVariables.currentMpNum = 0
        end
    end

    if self.coreVariables.hasRunStartupScripts == nil then
        self.coreVariables.hasRunStartupScripts = false
    end
end

function BaseWorld:EnsureTimeDataExists()

    if self.data.time == nil then
        self.data.time = config.defaultTimeTable
    end
end

function BaseWorld:HasRunStartupScripts()
    return self.coreVariables.hasRunStartupScripts
end

function BaseWorld:GetRegionVisitorCount(regionName)

    if self.storedRegions[regionName] == nil then return 0 end

    return tableHelper.getCount(self.storedRegions[regionName].visitors)
end

function BaseWorld:AddRegionVisitor(pid, regionName)

    if self.storedRegions[regionName] == nil then
        self.storedRegions[regionName] = { visitors = {}, forcedWeatherUpdatePids = {} }
    end

    -- Only add new visitor if we don't already have them
    if not tableHelper.containsValue(self.storedRegions[regionName].visitors, pid) then
        table.insert(self.storedRegions[regionName].visitors, pid)
    end
end

function BaseWorld:RemoveRegionVisitor(pid, regionName)

    local loadedRegion = self.storedRegions[regionName]

    -- Only remove visitor if they are actually recorded as one
    if tableHelper.containsValue(loadedRegion.visitors, pid) then
        tableHelper.removeValue(loadedRegion.visitors, pid)
    end

    -- Additionally, remove the visitor from the forcedWeatherUpdatePids if they
    -- are still in there
    self:RemoveForcedWeatherUpdatePid(pid, regionName)
end

function BaseWorld:AddForcedWeatherUpdatePid(pid, regionName)

    local loadedRegion = self.storedRegions[regionName]
    table.insert(loadedRegion.forcedWeatherUpdatePids, pid)
end

function BaseWorld:RemoveForcedWeatherUpdatePid(pid, regionName)

    local loadedRegion = self.storedRegions[regionName]
    tableHelper.removeValue(loadedRegion.forcedWeatherUpdatePids, pid)
end

function BaseWorld:IsForcedWeatherUpdatePid(pid, regionName)

    local loadedRegion = self.storedRegions[regionName]

    if tableHelper.containsValue(loadedRegion.forcedWeatherUpdatePids, pid) then
        return true
    end

    return false
end

function BaseWorld:GetRegionAuthority(regionName)

    if self.storedRegions[regionName] ~= nil then
        return self.storedRegions[regionName].authority
    end

    return nil
end

function BaseWorld:SetRegionAuthority(pid, regionName)

    self.storedRegions[regionName].authority = pid
    tes3mp.LogMessage(enumerations.log.INFO, "Authority of region " .. regionName .. " is now " ..
        logicHandler.GetChatName(pid))

    tes3mp.SetAuthorityRegion(regionName)
    tes3mp.SendWorldRegionAuthority(pid)
end

function BaseWorld:IncrementDay()

    self.data.time.daysPassed = self.data.time.daysPassed + 1

    local day = self.data.time.day
    local month = self.data.time.month

    -- Is the new day higher than the number of days in the current month?
    if day + 1 > self.monthLengths[month] then

        -- Is the new month higher than the number of months in a year?
        if month + 1 > 12 then
            self.data.time.year = self.data.time.year + 1
            self.data.time.month = 1
        else
            self.data.time.month = month + 1
        end

        self.data.time.day = 1
    else

        self.data.time.day = day + 1
    end
end

function BaseWorld:GetCurrentTimeScale()

    if self.data.time.dayTimeScale == nil then self.data.time.dayTimeScale = self.defaultTimeScale end
    if self.data.time.nightTimeScale == nil then self.data.time.nightTimeScale = self.defaultTimeScale end

    if self.data.time.hour >= config.nightStartHour or self.data.time.hour <= config.nightEndHour then
        return self.data.time.nightTimeScale
    else
        return self.data.time.dayTimeScale
    end
end

function BaseWorld:UpdateFrametimeMultiplier()
    self.frametimeMultiplier = WorldInstance:GetCurrentTimeScale() / WorldInstance.defaultTimeScale
end

function BaseWorld:GetCurrentMpNum()
    return self.coreVariables.currentMpNum
end

function BaseWorld:SetCurrentMpNum(currentMpNum)
    self.coreVariables.currentMpNum = currentMpNum
    self:QuicksaveCoreVariablesToDrive()
end

function BaseWorld:LoadJournal(pid)
    stateHelper:LoadJournal(pid, self)
end

function BaseWorld:LoadFactionRanks(pid)
    stateHelper:LoadFactionRanks(pid, self)
end

function BaseWorld:LoadFactionExpulsion(pid)
    stateHelper:LoadFactionExpulsion(pid, self)
end

function BaseWorld:LoadFactionReputation(pid)
    stateHelper:LoadFactionReputation(pid, self)
end

function BaseWorld:LoadTopics(pid)
    stateHelper:LoadTopics(pid, self)
end

function BaseWorld:LoadBounty(pid)
    stateHelper:LoadBounty(pid, self)
end

function BaseWorld:LoadReputation(pid)
    stateHelper:LoadReputation(pid, self)
end

function BaseWorld:LoadClientScriptVariables(pid)
    stateHelper:LoadClientScriptVariables(pid, self)
end

function BaseWorld:LoadDestinationOverrides(pid)
    stateHelper:LoadDestinationOverrides(pid, self)
end

function BaseWorld:LoadMap(pid)
    stateHelper:LoadMap(pid, self)
end

function BaseWorld:LoadKills(pid, forEveryone)

    tes3mp.ClearKillChanges()

    for refId, killCount in pairs(self.data.kills) do

        tes3mp.AddKill(refId, killCount)
    end

    tes3mp.SendWorldKillCount(pid, forEveryone)
end

function BaseWorld:LoadRegionWeather(regionName, pid, forEveryone, forceState)

    local region = self.storedRegions[regionName]

    if region.currentWeather ~= nil then

        tes3mp.SetWeatherRegion(regionName)
        tes3mp.SetWeatherCurrent(region.currentWeather)
        tes3mp.SetWeatherNext(region.nextWeather)
        tes3mp.SetWeatherQueued(region.queuedWeather)
        tes3mp.SetWeatherTransitionFactor(region.transitionFactor)
        tes3mp.SetWeatherForceState(forceState)
        tes3mp.SendWorldWeather(pid, forEveryone)
    else
        tes3mp.LogMessage(enumerations.log.INFO, "Could not load weather in region " .. regionName ..
            " for " .. logicHandler.GetChatName(pid) .. " because we have no weather information for it")
    end
end

function BaseWorld:LoadWeather(pid, forEveryone, forceState)

    for regionName, region in pairs(self.storedRegions) do

        if region.currentWeather ~= nil then
            self:LoadRegionWeather(regionName, pid, forEveryone, forceState)
        end
    end
end

function BaseWorld:LoadTime(pid, forEveryone)

    tes3mp.SetHour(self.data.time.hour)
    tes3mp.SetDay(self.data.time.day)

    -- The first month has an index of 0 in the C++ code, but
    -- table values should be intuitive and range from 1 to 12,
    -- so adjust for that by just going down by 1
    tes3mp.SetMonth(self.data.time.month - 1)

    tes3mp.SetYear(self.data.time.year)

    tes3mp.SetDaysPassed(self.data.time.daysPassed)

    tes3mp.SetTimeScale(self:GetCurrentTimeScale())

    tes3mp.SendWorldTime(pid, forEveryone)
end

function BaseWorld:SaveJournal(journalItemArray)
    stateHelper:SaveJournal(self, journalItemArray)
end

function BaseWorld:SaveFactionRanks(pid)
    stateHelper:SaveFactionRanks(pid, self)
end

function BaseWorld:SaveFactionExpulsion(pid)
    stateHelper:SaveFactionExpulsion(pid, self)
end

function BaseWorld:SaveFactionReputation(pid)
    stateHelper:SaveFactionReputation(pid, self)
end

function BaseWorld:SaveTopics(pid)
    stateHelper:SaveTopics(pid, self)
end

function BaseWorld:SaveBounty(pid)
    stateHelper:SaveBounty(pid, self)
end

function BaseWorld:SaveReputation(pid)
    stateHelper:SaveReputation(pid, self)
end

function BaseWorld:SaveClientScriptGlobal(variables)
    stateHelper:SaveClientScriptGlobal(self, variables)
end

function BaseWorld:SaveKills(pid)

    tes3mp.ReadReceivedWorldstate()

    for index = 0, tes3mp.GetKillChangesSize() - 1 do

        local refId = tes3mp.GetKillRefId(index)
        local number = tes3mp.GetKillNumber(index)
        self.data.kills[refId] = number
    end

    self:QuicksaveToDrive()
end

function BaseWorld:SaveRegionWeather(regionName)

    local loadedRegion = self.storedRegions[regionName]
    loadedRegion.currentWeather = tes3mp.GetWeatherCurrent()
    loadedRegion.nextWeather = tes3mp.GetWeatherNext()
    loadedRegion.queuedWeather = tes3mp.GetWeatherQueued()
    loadedRegion.transitionFactor = tes3mp.GetWeatherTransitionFactor()
end

function BaseWorld:SaveMapExploration(pid)
    stateHelper:SaveMapExploration(pid, self)
end

function BaseWorld:SaveMapTiles(mapTiles)

    for index, mapTile in ipairs(mapTiles) do
        -- We need to save the image file using the original index in the packet
        tes3mp.SaveMapTileImageFile(index - 1, config.dataPath .. "/map/" .. mapTile.filename)
    end
end

return BaseWorld
