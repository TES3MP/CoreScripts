local EventBus = class("EventBus")

function EventBus:__init()
    self.validators = {}
    self.handlers = {}
end

function EventBus.makeStatus(validDefaultHandler, validCustomHandlers)
    return {
        validDefaultHandler = validDefaultHandler,
        validCustomHandlers = validCustomHandlers
    }
end

local function updateStatus(oldStatus, newStatus)
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

function EventBus:registerValidator(event, callback)
    if self.validators[event] == nil then
        self.validators[event] = {}
    end
    table.insert(self.validators[event], callback)
end

function EventBus:registerHandler(event, callback)
    if self.handlers[event] == nil then
        self.handlers[event] = {}
    end
    table.insert(self.handlers[event], callback)
end

function EventBus:triggerValidators(event, args)
    local eventStatus = EventBus.makeStatus(true, true)
    if self.validators[event] == nil then return eventStatus end
    for _, callback in ipairs(self.validators[event]) do
        eventStatus = updateStatus(eventStatus, callback(eventStatus, unpack(args)))
    end
    return eventStatus
end

function EventBus:triggerHandlers(event, eventStatus, args)
    if self.handlers[event] == nil then return end
    for _, callback in ipairs(self.handlers[event]) do
        eventStatus = updateStatus(eventStatus, callback(eventStatus, unpack(args)))
    end
end

return EventBus
