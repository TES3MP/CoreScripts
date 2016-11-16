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
}

GUI.ShowLogin = function(pid)
    tes3mp.InputDialog(pid, GUI.ID.LOGIN, "Enter your password:")
end

GUI.ShowRegister = function(pid)
    tes3mp.InputDialog(pid, GUI.ID.REGISTER, "Create new password:")
end

local GetConnectedPlayerList = function()
    local list = ""
    local divider = ""
    for i=0,#Players do
        if i == #Players then
            divider = ""
        else
            divider = "\n"
        end
        if Players[i]:IsLoggedOn() then
            list = list .. tostring(Players[i].name)
            list = list .. " (ID: " .. tostring(Players[i].pid)
            list = list .. " Ping: " .. tostring(tes3mp.GetAvgPing(Players[i].pid)) .. ")"
            list = list .. divider
        end
    end
    return list
end

GUI.ShowPlayersList = function(pid)
    -- myMod.GetConnectedPlayerList()
    local label = myMod.GetConnectedPlayerNumber() .. " connected "
    if myMod.GetConnectedPlayerNumber() == 1 then
        label = label .. "player"
    else
        label = label .. "players"
    end
    tes3mp.ListBox(pid, GUI.ID.PLAYERSLIST, label, GetConnectedPlayerList())
end

return GUI
