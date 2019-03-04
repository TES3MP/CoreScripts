local eventManager = {}

eventManager.validators = {}
eventManager.handlers = {}

function eventManager.getEventStatus(validDefaultHandler,validCustomHandlers)
    return {
        validDefaultHandler=validDefaultHandler,
        validCustomHandlers=validCustomHandlers
    }
end

function eventManager.updateEventStatus(oldStatus,newStatus)
    if newStatus==nil then
        return oldStatus
    end
    local result = {}
    if newStatus.validDefaultHandler~=nil then
        result.validDefaultHandler = newStatus.validDefaultHandler
    else
        result.validDefaultHandler = oldStatus.validDefaultHandler
    end
    
    if newStatus.validCustomHandlers~=nil then
        result.validCustomHandlers = newStatus.validCustomHandlers
    else
        result.validCustomHandlers = oldStatus.validCustomHandlers
    end
    
    return result
end

function eventManager.registerValidator(event,callback)
    if(eventManager.validators[event]==nil) then
        eventManager.validators[event]={}
    end
    table.insert(eventManager.validators[event],callback)
end

function eventManager.registerHandler(event,callback)
    if(eventManager.handlers[event]==nil) then
        eventManager.handlers[event]={}
    end
    table.insert(eventManager.handlers[event],callback)
end

function eventManager.triggerValidators(event,args)
    local eventStatus = eventManager.getEventStatus(true,true)
    if eventManager.validators[event]~=nil then
        for _,callback in pairs(eventManager.validators[event]) do
            eventStatus = eventManager.updateEventStatus(eventStatus,callback(eventStatus,unpack(args)))
        end
    end
    return eventStatus
end

function eventManager.triggerHandlers(event,eventStatus,args)
    if eventManager.handlers[event]~=nil then
        for _,callback in pairs(eventManager.handlers[event]) do
             eventStatus = eventManager.updateEventStatus(eventStatus,callback(eventStatus,unpack(args)))
        end
    end
end

return eventManager