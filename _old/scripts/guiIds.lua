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
    tes3mp.PasswordDialog(pid, GUI.ID.REGISTER, "Create new password:", "Warning: the server owner will be able to read your password, so you should use a unique one for each server.")
end

local GetConnectedPlayerList = function()

    local lastPid = tes3mp.GetLastPlayerId()
    local list = ""
    local divider = ""

    for i = 0, lastPid do
        if i == lastPid then
            divider = ""
        else
            divider = "\n"
        end
        if Players[i] ~= nil and Players[i]:IsLoggedIn() then
            list = list .. tostring(Players[i].name)
            list = list .. " (ID: " .. tostring(Players[i].pid)
            list = list .. ", Ping: " .. tostring(tes3mp.GetAvgPing(Players[i].pid)) .. ")"
            list = list .. divider
        end
    end

    return list
end

local GetLoadedCellList = function()
    local list = ""
    local divider = ""

    local cellCount = myMod.GetLoadedCellCount()
    local cellIndex = 0

    for key, value in pairs(LoadedCells) do
        cellIndex = cellIndex + 1

        if cellIndex == cellCount then
            divider = ""
        else
            divider = "\n"
        end
        list = list .. key
        list = list .. " (auth: " .. LoadedCells[key]:GetAuthority() .. ", loaded by " .. LoadedCells[key]:GetVisitorCount() .. ")"
        list = list .. divider
    end
    return list
end

GUI.ShowPlayerList = function(pid)

    local playerCount = myMod.GetConnectedPlayerCount()
    local label = playerCount .. " connected "
    if playerCount == 1 then
        label = label .. "player"
    else
        label = label .. "players"
    end
    tes3mp.ListBox(pid, GUI.ID.PLAYERSLIST, label, GetConnectedPlayerList())
end

GUI.ShowCellList = function(pid)

    local cellCount = myMod.GetLoadedCellCount()
    local label = cellCount .. " loaded "
    if cellCount == 1 then
        label = label .. "cell"
    else
        label = label .. "cells"
    end
    tes3mp.ListBox(pid, GUI.ID.CELLSLIST, label, GetLoadedCellList())
end

return GUI
