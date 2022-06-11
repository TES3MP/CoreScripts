local customEventHooks = {}

---@type table<string, EventValidator>
customEventHooks.validators = {}

---@type table<string, EventHandler>
customEventHooks.handlers = {}

---@param validDefaultHandler boolean
---@param validCustomHandlers boolean|nil
---@return EventStatus
function customEventHooks.makeEventStatus(validDefaultHandler, validCustomHandlers)
    return {
        validDefaultHandler = validDefaultHandler,
        validCustomHandlers = validCustomHandlers
    }
end

---@param oldStatus EventStatus
---@param newStatus EventStatus
---@return EventStatus
function customEventHooks.updateEventStatus(oldStatus, newStatus)
    if newStatus == nil then
        return oldStatus
    end
    local result = {}
    if newStatus.validDefaultHandler ~= nil then
        result.validDefaultHandler = newStatus.validDefaultHandler
    else
        result.validDefaultHandler = oldStatus.validDefaultHandler
    end
    
    if newStatus.validCustomHandlers ~= nil then
        result.validCustomHandlers = newStatus.validCustomHandlers
    else
        result.validCustomHandlers = oldStatus.validCustomHandlers
    end
    
    return result
end

---@param event string
---@param callback EventValidator
function customEventHooks.registerValidator(event, callback)
    if customEventHooks.validators[event] == nil then
        customEventHooks.validators[event] = {}
    end
    table.insert(customEventHooks.validators[event], callback)
end

---@param event string
---@param callback EventHandler
function customEventHooks.registerHandler(event, callback)
    if customEventHooks.handlers[event] == nil then
        customEventHooks.handlers[event] = {}
    end
    table.insert(customEventHooks.handlers[event], callback)
end

---@param event string
---@param args any
---@return EventStatus
function customEventHooks.triggerValidators(event, args)
    local eventStatus = customEventHooks.makeEventStatus(true, true)
    if customEventHooks.validators[event] ~= nil then
        for _, callback in ipairs(customEventHooks.validators[event]) do
            eventStatus = customEventHooks.updateEventStatus(eventStatus, callback(eventStatus, unpack(args)))
        end
    end
    return eventStatus
end

---@param event string
---@param eventStatus EventStatus
---@param args any
function customEventHooks.triggerHandlers(event, eventStatus, args)
    if customEventHooks.handlers[event] ~= nil then
        for _, callback in ipairs(customEventHooks.handlers[event]) do
             eventStatus = customEventHooks.updateEventStatus(eventStatus, callback(eventStatus, unpack(args)))
        end
    end
end

return customEventHooks
