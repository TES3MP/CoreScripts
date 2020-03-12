-- for backwards compatibility
local customEventHooks = {}

function customEventHooks.makeEventStatus(validDefaultHandler, validCustomHandlers)
    return EventBus.makeStatus(validDefaultHandler, validCustomHandlers)
end

function customEventHooks.registerValidator(event, callback)
    coreEvents:registerValidator(event, callback)
end

function customEventHooks.registerHandler(event, callback)
    coreEvents:registerHandler(event, callback)
end

function customEventHooks.triggerValidators(event, args)
    return coreEvents:triggerValidators(event, args)
end

function customEventHooks.triggerHandlers(event, eventStatus, args)
    coreEvents:triggerHandlers(event, eventStatus, args)
end

return customEventHooks
