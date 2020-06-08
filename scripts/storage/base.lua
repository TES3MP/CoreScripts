local storage = {}

function storage.Load(key, default)
    error('Not implemented!')
end

function storage.Save(key)
    error('Not implemented!')
end

function storage.SaveAllAsync()
    error('Not implemented!')
end

function storage.SaveAll()
    error('Not implemented!')
end

customEventHooks.registerHandler('OnServerExit', function(eventStatus)
    if eventStatus.validDefaultHandler then
        async.Wrap(function()
            storage.SaveAllAsync()
        end)
    end
end)

return storage
