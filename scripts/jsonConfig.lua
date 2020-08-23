local jsonConfig = {}

jsonConfig.data = {}

--
-- private
--

local function GetFileName(name)
    return 'custom/config__' .. name .. '.json'
end

--
-- public
--

function jsonConfig.Load(name, default, keyOrderArray)
    local filename = GetFileName(name)
    local result = fileDrive.LoadAsync(filename)
    if not result.content then
        fileDrive.SaveAsync(filename, jsonInterface.encode(default, keyOrderArray))
        jsonConfig.data[name] = default
    else
        jsonConfig.data[name] = jsonInterface.decode(result.content)
    end
    return jsonConfig.data[name]
end

return jsonConfig
