local request = {}

request.INIT = 1
request.SAVE = 2
request.LOAD = 3

function request.initiate()
    return {
        type = request.INIT,
        path = config.dataPath .. "/",
        content = tes3mp.GetOperatingSystemType()
    }
end

function request.save(path, content, keyOrder)
    return {
        type = request.SAVE,
        path = path,
        content = content,
        keyOrder = keyOrder
    }
end

function request.load(path)
    return {
        type = request.LOAD,
        path = path
    }
end

return request
