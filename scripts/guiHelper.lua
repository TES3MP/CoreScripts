tableHelper = require("tableHelper")

guiHelper = {}
guiHelper.names = {"LOGIN", "REGISTER", "PLAYERSLIST", "CELLSLIST"}
guiHelper.ID = tableHelper.enum(guiHelper.names)
guiHelper.currentId = 0
for _, id in pairs(guiHelper.ID) do
    guiHelper.currentId = math.max(guiHelper.currentId, id)
end
guiHelper.coroutines = {}

--
-- public functions
--

function guiHelper.MessageBox(pid, label)
    local id = guiHelper.GetGuiId("GUI_HELPER_MESSAGEBOX")
    tes3mp.MessageBox(pid, id, label)
    return true
end

function guiHelper.CustomMessageBoxAsync(pid, buttons, label)
    local id = guiHelper.GetGuiId()
    guiHelper.SetCoroutine(id)
    label = label or ''
    tes3mp.CustomMessageBox(pid, id, label, table.concat(buttons, ";"))
    return coroutine.yield() + 1 -- Lua tables are 1-numbered
end

function guiHelper.InputDialogAsync(pid, label, note)
    local id = guiHelper.GetGuiId()
    guiHelper.SetCoroutine(id)
    note = note or ''
    label = label or ''
    tes3mp.InputDialog(pid, id, label, note)
    return coroutine.yield()
end

function guiHelper.PasswordDialogAsync(pid, label, note)
    local id = guiHelper.GetGuiId()
    guiHelper.SetCoroutine(id)
    label = label or ''
    note = note or ''
    tes3mp.PasswordDialog(pid, id, label, note)
    return coroutine.yield()
end

function guiHelper.ListBoxAsync(pid, rows, label)
    local id = guiHelper.GetGuiId()
    guiHelper.SetCoroutine(id)
    local items = table.concat(rows, "\n")
    label = label or ''
    tes3mp.ListBox(pid, id, label, items)
    local result = tonumber(coroutine.yield())
    if (result >= #rows) or (result < 0) then -- user didn't select any options
        return nil
    end
    return result + 1 -- Lua tables are 1-numbered
end

function guiHelper.GetGuiId(name)
    if not name then
        guiHelper.currentId = guiHelper.currentId + 1
        return guiHelper.currentId
    elseif guiHelper.ID[name] then
        return guiHelper.ID[name]
    else
        guiHelper.currentId = guiHelper.currentId + 1
        guiHelper.ID[name] = guiHelper.currentId
        return guiHelper.currentId
    end
end

--
-- private functions
--

function guiHelper.SetCoroutine(id)
    guiHelper.coroutines[id] = async.CurrentCoroutine()
end

function guiHelper.OnGUIAction(evenStatus, pid, id, data)
    if evenStatus.validDefaultHandler then
        local co = guiHelper.coroutines[id]
        if co then
            guiHelper.coroutines[id] = nil
            coroutine.resume(co, data)
        end
    end
end
customEventHooks.registerHandler("OnGUIAction", guiHelper.OnGUIAction)

guiHelper.ShowLogin = function(pid)
    tes3mp.PasswordDialog(pid, guiHelper.ID.LOGIN, "Enter your password:", "")
end

guiHelper.ShowRegister = function(pid)
    tes3mp.PasswordDialog(pid, guiHelper.ID.REGISTER, "Create new password:",
        "Warning: there is no guarantee that your password will be stored securely on any game server, so you should use " ..
        "a unique one for each server.")
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

local GetLoadedRegionList = function()
    local list = ""
    local divider = ""

    local regionCount = logicHandler.GetLoadedRegionCount()
    local regionIndex = 0

    for key, value in pairs(WorldInstance.storedRegions) do
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

guiHelper.ShowPlayerList = function(pid)

    local playerCount = logicHandler.GetConnectedPlayerCount()
    local label = playerCount .. " connected player"

    if playerCount ~= 1 then
        label = label .. "s"
    end

    tes3mp.ListBox(pid, guiHelper.ID.PLAYERSLIST, label, GetConnectedPlayerList())
end

guiHelper.ShowCellList = function(pid)

    
end

guiHelper.ShowRegionList = function(pid)

    local regionCount = logicHandler.GetLoadedRegionCount()
    local label = regionCount .. " loaded region"

    if regionCount ~= 1 then
        label = label .. "s"
    end

    tes3mp.ListBox(pid, guiHelper.ID.CELLSLIST, label, GetLoadedRegionList())
end

guiHelper.ShowInventoryList = function(menuId, pid, inventoryPid)

    local inventoryCount = tableHelper.getCount(Players[pid].data.inventory)
    local label = inventoryCount .. " item"

    if inventoryCount ~= 1 then
        label = label .. "s"
    end

    tes3mp.ListBox(pid, menuId, label, GetPlayerInventoryList(inventoryPid))
end

return guiHelper
