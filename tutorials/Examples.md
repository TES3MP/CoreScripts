# Use the bell hammer as intended

```Lua
customEventHooks.registerHandler("OnObjectHit", function(eventStatus, pid, cellDescription, objects)
    if not eventStatus.validCustomHandlers then return end
    for uniqueIndex, object in pairs(objects) do
        local _, _, bellId = string.find(object.refId, "active_6th_bell_0(%d)")
        if bellId then
            local consoleCommand = "PlaySound3D \"bell" .. bellId .. "\""
            logicHandler.RunConsoleCommandOnObject(pid, consoleCommand, cellDescription, uniqueIndex, true)
        end
    end
end)
```