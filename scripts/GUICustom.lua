local idToInstance = {}
setmetatable(idToInstance, {
    __key = "v" -- garbage collect GUICustom objects if they go out of scope
})

local pidToInstances = {}
local function trackForPlayer(pid, instance)
    if not pidToInstances[pid] then
        pidToInstances[pid] = {}
        setmetatable(pidToInstances[pid], {
            __key = "v"
        })
    end
    table.insert(pidToInstances[pid], instance)
end

local GUICustom = class("GUICustom")

GUICustom.EVENTS = {
    disconnect = "disconnect"
}

local resources = {}

function GUICustom.SendResource(pid, name, source)
    tes3mp.GUIResource(pid, name, source)
end

function GUICustom.Resource(name, source)
    resources[name] = source
end

customEventHooks.registerHandler("OnPlayerConnect", function(eventStatus, pid)
    if not eventStatus.validDefaultHandler then return end
    for name, source in pairs(resources) do
        GUICustom.SendResource(pid, name, source)
    end
end)

function GUICustom:__init(pid, layout, background)
    self.pid = pid
    self.id = guiHelper.GetGuiId()
    self.layout = layout
    self.background = background and true or false
    self.visible = false
    self.fields = {}
    self.props = {}

    idToInstance[self.id] = self
    trackForPlayer(pid, self)
end

function GUICustom:Update(props)
    if not self.visible then
        for key, value in pairs(props) do
            self.props[key] = value
        end
        return
    end
    local pid = self.pid
    tes3mp.SetGUILayout(pid, "");
    tes3mp.ClearGUIProperties(pid);
    for key, value in pairs(props) do
        self.props[key] = value
        tes3mp.SetGUIProperty(pid, key, value);
    end
    tes3mp.GUICustom(pid, self.id)
end

function GUICustom:Show(props)
    local pid = self.pid
    local layout = self.layout
    if self.visible then layout = "" end
    tes3mp.SetGUILayout(pid, layout);
    tes3mp.ClearGUIProperties(pid);
    props = props or self.props
    for key, value in pairs(props) do
        self.props[key] = value
        tes3mp.SetGUIProperty(pid, key, value);
    end
    tes3mp.GUICustom(pid, self.id, false, self.background)
    self.visible = true
end

function GUICustom:Hide()
    local pid = self.pid
    tes3mp.SetGUILayout(pid, "");
    tes3mp.ClearGUIProperties(pid);
    tes3mp.GUICustom(pid, self.id, true, self.background)
    self.visible = false
end

function GUICustom:Toggle()
    if self.visible then
        self:Hide()
    else
        self:Show(self.props)
    end
end

function GUICustom:Visible()
    return self.visible
end

function GUICustom:Event(pid, event, data, fields)
    if pid ~= self.pid then
        tes3mp.LogMessage(enumerations.log.ERROR, "[GUICustom] Event from the wrong player!")
        return
    end
    self.fields = fields
    -- TODO: wait for EventBus to merge
end

function GUICustom:Disconnect(pid)
    self:Event(pid, GUICustom.EVENTS.disconnect, "", self.fields)
end

function GUICustom:On(event, callback)
    -- TODO: wait for EventBus to merge
end

function GUICustom:OnAsync(event)
    -- TODO: wait for EventBus to merge
end

function GUICustom:Fields()
    return self.fields
end

customEventHooks.registerHandler("OnGUICustom", function (eventStatus, pid, id, event, data, fields)
    if not eventStatus.validDefaultHandler then return end
    idToInstance[id]:Event(pid, event, data, fields)
end)

customEventHooks.registerHandler("OnPlayerDisconnect", function(eventStatus, pid)
    if not eventStatus.validDefaultHandler then return end
    if pidToInstances[pid] then
        for _, instance in pairs(pidToInstances[pid]) do
            instance:Disconnect(pid)
        end
        pidToInstances[pid] = nil
    end
end)

return GUICustom