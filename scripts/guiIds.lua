tableHelper = require("tableHelper")

GUI = {}

function enum(en)
    local _enum = {}
    for i, v in ipairs(en) do
        _enum[v] = i
    end
    return _enum
end

GUI.ID = enum {
    "LOGIN",
    "REGISTER",
    "PLAYERSLIST",
    "CELLSLIST"
}

GUI.ShowLogin = function(pid)
    tes3mp.PasswordDialog(pid, GUI.ID.LOGIN, "Enter your password:", "")
end

GUI.ShowRegister = function(pid)
    tes3mp.PasswordDialog(pid, GUI.ID.REGISTER, "Create new password:",
        "Warning: the server owner will be able to read your password, so you should use a unique one for each server.")
end

local GetConnectedPlayerList = function()

    local lastPid = tes3mp.GetLastPlayerId()
    local list = ""
    local divider = ""

    for playerIndex = 0, lastPid do
        if playerIndex == lastPid then
            divider = ""
        else
            divider = "\n"
        end
        if Players[playerIndex] ~= nil and Players[playerIndex]:IsLoggedIn() then

            list = list .. tostring(Players[playerIndex].name) .. " (pid: " .. tostring(Players[playerIndex].pid) .. 
                ", ping: " .. tostring(tes3mp.GetAvgPing(Players[playerIndex].pid)) .. ")" .. divider
        end
    end

    return list
end

local GetLoadedCellList = function()
    local list = ""
    local divider = ""

    local cellCount = logicHandler.GetLoadedCellCount()
    local cellIndex = 0

    for key, value in pairs(LoadedCells) do
        cellIndex = cellIndex + 1

        if cellIndex == cellCount then
            divider = ""
        else
            divider = "\n"
        end

        list = list .. key .. " (auth: " .. LoadedCells[key]:GetAuthority() .. ", loaded by " ..
            LoadedCells[key]:GetVisitorCount() .. ")" .. divider
    end

    return list
end

local GetLoadedRegionList = function()
    local list = ""
    local divider = ""

    local regionCount = logicHandler.GetLoadedRegionCount()
    local regionIndex = 0

    for key, value in pairs(WorldInstance.loadedRegions) do
        local visitorCount = WorldInstance:GetRegionVisitorCount(key)

        if visitorCount > 0 then
            regionIndex = regionIndex + 1

            if regionIndex == regionCount then
                divider = ""
            else
                divider = "\n"
            end

            list = list .. key .. " (auth: " .. WorldInstance:GetRegionAuthority(key) .. ", loaded by " ..
                visitorCount .. ")" .. divider
        end
    end

    return list
end

local GetPlayerInventoryList = function(pid)

    local list = ""
    local divider = ""
    local lastItemIndex = tableHelper.getCount(Players[pid].data.inventory)

    for index, currentItem in ipairs(Players[pid].data.inventory) do

        if index == lastItemIndex then
            divider = ""
        else
            divider = "\n"
        end

        list = list .. index .. ": " .. currentItem.refId .. " (count: " .. currentItem.count .. ")" .. divider
    end

    return list
end

GUI.ShowPlayerList = function(pid)

    local playerCount = logicHandler.GetConnectedPlayerCount()
    local label = playerCount .. " connected player"

    if playerCount ~= 1 then
        label = label .. "s"
    end

    tes3mp.ListBox(pid, GUI.ID.PLAYERSLIST, label, GetConnectedPlayerList())
end

GUI.ShowCellList = function(pid)

    local cellCount = logicHandler.GetLoadedCellCount()
    local label = cellCount .. " loaded cell"

    if cellCount ~= 1 then
        label = label .. "s"
    end

    tes3mp.ListBox(pid, GUI.ID.CELLSLIST, label, GetLoadedCellList())
end

GUI.ShowRegionList = function(pid)

    local regionCount = logicHandler.GetLoadedRegionCount()
    local label = regionCount .. " loaded region"

    if regionCount ~= 1 then
        label = label .. "s"
    end

    tes3mp.ListBox(pid, GUI.ID.CELLSLIST, label, GetLoadedRegionList())
end

GUI.ShowInventoryList = function(menuId, pid, inventoryPid)

    local inventoryCount = tableHelper.getCount(Players[pid].data.inventory)
    local label = inventoryCount .. " item"

    if inventoryCount ~= 1 then
        label = label .. "s"
    end

    tes3mp.ListBox(pid, menuId, label, GetPlayerInventoryList(inventoryPid))
end

return GUI
