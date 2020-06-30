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
            async.Resume(co, data)
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

return guiHelper
