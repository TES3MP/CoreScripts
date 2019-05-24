--- Custom event hooks
-- @module customEventHooks
local customEventHooks = {}

--- Validators
customEventHooks.validators = {}
--- Handlers
customEventHooks.handlers = {}

--- Make event status
-- @param validDefaultHandler
-- @param validCustomHandlers
-- @return table = { bool, bool }
function customEventHooks.makeEventStatus(validDefaultHandler, validCustomHandlers)
    return {
        validDefaultHandler = validDefaultHandler,
        validCustomHandlers = validCustomHandlers
    }
end

--- Update event status
-- @param oldStatus
-- @param newStatus
-- @return the updated event status
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

--- Register validator
-- @param event
-- @param callback
function customEventHooks.registerValidator(event, callback)
    if customEventHooks.validators[event] == nil then
        customEventHooks.validators[event] = {}
    end
    table.insert(customEventHooks.validators[event], callback)
end

--- Register handler
-- @param event
-- @param callback
function customEventHooks.registerHandler(event, callback)
    if customEventHooks.handlers[event] == nil then
        customEventHooks.handlers[event] = {}
    end
    table.insert(customEventHooks.handlers[event], callback)
end

--- Trigger validators
-- @param event
-- @param args
-- @return event status
function customEventHooks.triggerValidators(event, args)
    local eventStatus = customEventHooks.makeEventStatus(true, true)
    if customEventHooks.validators[event] ~= nil then
        for _,callback in ipairs(customEventHooks.validators[event]) do
            eventStatus = customEventHooks.updateEventStatus(eventStatus, callback(eventStatus, unpack(args)))
        end
    end
    return eventStatus
end

--- Trigger handlers
-- @param event
-- @param eventStatus
-- @param args
function customEventHooks.triggerHandlers(event, eventStatus, args)
    if customEventHooks.handlers[event] ~= nil then
        for _,callback in ipairs(customEventHooks.handlers[event]) do
             eventStatus = customEventHooks.updateEventStatus(eventStatus, callback(eventStatus, unpack(args)))
        end
    end
end

return customEventHooks