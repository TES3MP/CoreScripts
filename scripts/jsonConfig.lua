local jsonConfig = {}

local function GetFileName(name)
    return 'custom/config__' .. name .. '.json'
end

function jsonConfig.Load(name, default, keyOrderArray)
    local filename = GetFileName(name)
    local existingFile = fileDrive.LoadAsync(filename)
    local result = nil
    if not existingFile.content then
        fileDrive.SaveAsync(filename, jsonInterface.encode(default, keyOrderArray))
        result = tableHelper.deepCopy(default)
    else
        result = jsonInterface.decode(existingFile.content)
    end
    return result
end

return jsonConfig
