local json = require ("dkjson")

local jsonInterface = {}

jsonInterface.libraryMissingMessage = "No input/output library selected for JSON interface!"

function jsonInterface.setLibrary(ioLibrary)
    jsonInterface.ioLibrary = ioLibrary
end

function jsonInterface.load(fileName)

    if jsonInterface.ioLibrary == nil then
        print(jsonInterface.libraryMissingMessage)
        return nil
    end

    local home = tes3mp.GetModDir() .. "/"
    local file = jsonInterface.ioLibrary.open(home .. fileName, 'r')

    if file ~= nil then
        local content = file:read("*all")
        file:close()
        return json.decode(content, 1, nil)
    else
        return nil
    end
end

function jsonInterface.save(fileName, data, keyOrderArray)

    if jsonInterface.ioLibrary == nil then
        print(jsonInterface.libraryMissingMessage)
        return false
    end

    local home = tes3mp.GetModDir() .. "/"
    local content = json.encode(data, { indent = true, keyorder = keyOrderArray })
    local file = jsonInterface.ioLibrary.open(home .. fileName, 'w+b')

    if file ~= nil then
        file:write(content)
        file:close()
        return true
    else
        return false
    end
end

return jsonInterface
