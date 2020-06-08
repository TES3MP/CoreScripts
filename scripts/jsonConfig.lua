local jsonConfig = {}

jsonConfig.data = {}

--
-- public functions
--

function jsonConfig.Load(name, default, keyOrderArray)
    local filename = jsonConfig.GetFileName(name)
    local result = fileClient.LoadAsync(filename)
    if not result.content then
        fileClient.SaveAsync(filename, jsonInterface.encode(default, keyOrderArray))
        jsonConfig.data[name] = default
    else
        jsonConfig.data[name] = jsonInterface.decode(result.content)
    end
    return jsonConfig.data[name]
end

--
-- private functions
--

function jsonConfig.GetFileName(name)
    return 'custom/config__' .. name .. '.json'
end

return jsonConfig
