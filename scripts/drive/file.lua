local effil = require('effil')
local request = require("drive.file.request")

local fileClient = {
    thread = nil
}

function fileClient.ThreadWork(input, output)
    local Run = require("drive.file.thread")
    Run(input, output)
end

function fileClient.Initiate()
    fileClient.thread = threadHandler.CreateThread(fileClient.ThreadWork)
    fileClient.ProcessResponse(threadHandler.SendAsync(
        fileClient.thread,
        request.initiate()
    ))
end

function fileClient.ProcessResponse(res)
    if res.log then
        tes3mp.LogMessage(enumerations.log.INFO, "[FileClient] " .. res.log)
    end
    if res.error then
        tes3mp.LogMessage(enumerations.log.ERROR, "[FileClient] " .. res.error)
    end
end

function fileClient.Send(req, callback)
    local res = threadHandler.Send(fileClient.thread, req, function(res)
        fileClient.ProcessResponse(res)
        callback(res)
    end)
    return res
end

function fileClient.SendAsync(req)
    local res = threadHandler.SendAsync(fileClient.thread, req)
    fileClient.ProcessResponse(res)
    return res
end

function fileClient.Save(path, content, callback)
    fileClient.Send(request.save(path, content), callback)
end

function fileClient.SaveAsync(path, content)
    return fileClient.SendAsync(request.save(path, content))
end

function fileClient.Load(path, callback)
    fileClient.Send(request.load(path), callback)
end

function fileClient.LoadAsync(path)
    return fileClient.SendAsync(request.load(path))
end

async.Wrap(function()
    fileClient.Initiate()
end)

return fileClient
