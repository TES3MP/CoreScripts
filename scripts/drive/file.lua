local request = require("drive.file.request")

local fileDrive = {
    thread = nil
}

--
-- private
--

local function ThreadWork(input, output)
    local Run = require("drive.file.thread")
    Run(input, output)
end

local function ProcessResponse(res)
    if res.log then
        tes3mp.LogMessage(enumerations.log.INFO, "[FileClient] " .. res.log)
    end
    if res.error then
        tes3mp.LogMessage(enumerations.log.ERROR, "[FileClient] " .. res.error)
    end
end

local function Initiate()
    fileDrive.thread = threadHandler.CreateThread(ThreadWork)
    ProcessResponse(threadHandler.SendAsync(
        fileDrive.thread,
        request.initiate()
    ))
end

local function Send(req, callback)
    local res = threadHandler.Send(fileDrive.thread, req, function(res)
        ProcessResponse(res)
        callback(res)
    end)
    return res
end

local function SendAsync(req)
    local res = threadHandler.SendAsync(fileDrive.thread, req)
    ProcessResponse(res)
    return res
end

--
-- public
--

function fileDrive.Save(path, content, callback)
    Send(request.save(path, content), callback)
end

function fileDrive.SaveAsync(path, content)
    return SendAsync(request.save(path, content))
end

function fileDrive.Load(path, callback)
    Send(request.load(path), callback)
end

function fileDrive.LoadAsync(path)
    return SendAsync(request.load(path))
end

async.RunBlocking(function()
    Initiate()
end)

return fileDrive
