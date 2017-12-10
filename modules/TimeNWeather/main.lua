Config.TimeNWeather = import(getModuleFolder() .. "config.lua")

CommandController.registerCommand("setWeather", function(player, args)  
    player:getWeatherMgr():setWeather(tonumber(args[1]))
    return true
end, "/setWeather id")

local regionAuthorities = {}

CommandController.registerCommand("setRegionAuthority", function(player, args)
    local currentRegion = player:getCell():getRegion()
    regionAuthorities[currentRegion] = player
    player:getWeatherMgr():request()
    return true
end, "/setRegionAuthority")

Event.register(Events.ON_PLAYER_DISCONNECT, function(player)
    local currentRegion = player:getCell():getRegion()
    if player == regionAuthorities[currentRegion] then
        regionAuthorities[currentRegion] = nil
    end
end)

local weatherTimer
function weatherTimerCallback(data)
    for region, player in pairs(regionAuthorities) do
        if player ~= nil then
            if player:getCell():getRegion() ~= region then
                regionAuthorities[region] = nil
            else
                player:getWeatherMgr():request()
            end
        end
    end
    weatherTimer:restart(1000)
end

weatherTimer = TimerCtrl.create(weatherTimerCallback, 1000, nil)

weatherTimer:start()

Event.register(Events.ON_PLAYER_WEATHER, function(player)
    local weatherMgr = player:getWeatherMgr()
    local currentRegion = player:getCell():getRegion()
    Players.for_each(function(otherPlayer)
        if otherPlayer == player then return end;
        if currentRegion == otherPlayer:getCell():getRegion() then
            local otherWeatherMgr = otherPlayer:getWeatherMgr()
            otherWeatherMgr:copy(weatherMgr)
        end
    end)
end)

Event.register(Events.ON_PLAYER_CELLCHANGE, function(player)

    local currentRegion = player:getCell():getRegion()
    local regionAuthority = regionAuthorities[currentRegion]
    if regionAuthority == nil then
        regionAuthorities[currentRegion] = player
        player:getWeatherMgr():request()
        return
    end
    regionAuthority:getWeatherMgr():request()
end)

do
    local timeCounter = Config.TimeNWeather.timeServerInitTime
    local timeTimer = nil
    function timeTimerCallback()
        local hour = 0
        if Config.TimeNWeather.timeSyncMode == 1 then
            timeCounter = timeCounter + (0.0083 * Config.TimeNWeather.timeServerMult)
            hour = timeCounter
        elseif Config.TimeNWeather.timeSyncMode == 2 then -- ToDo
        end
        local day = hour/24
        hour = math.fmod(hour, 24)

        setHour(hour)
        setDay(day)

        timeTimer:restart(1000)
    end
    timeTimer = TimerCtrl.create(timeTimerCallback, 1000, nil)

    if Config.TimeNWeather.timeSyncMode ~= 0 then
        timeTimer:start()
    end
    CommandController.registerCommand("time", function(player, args) 
        if player.customData.moderator then
            if type(tonumber(cmd[2])) == "number" then
                timeCounter = tonumber(cmd[2])
            end
        end
    end)
end

