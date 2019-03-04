local eventManager = {}

eventManager.validators = {}
eventManager.handlers = {}

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
	local isValid = true
	if(eventManager.validators[event]~=nil) then
		for _,callback in pairs(eventManager.validators[event]) do
			local tempValid = callback(isValid,unpack(args))
			if tempValid~=nil then
				isValid = tempValid
			end
		end
	end
	return isValid
end

function eventManager.triggerHandlers(event,isValid,args)
	if(eventManager.handlers[event]~=nil) then
		for _,callback in pairs(eventManager.handlers[event]) do
			callback(isValid,unpack(args))
		end
	end
end

return eventManager