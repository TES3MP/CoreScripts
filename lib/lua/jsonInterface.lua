local json = require("dkjson");

local JsonInterface = {}

function JsonInterface.load(filePath)
    
    local file = assert(io.open(filePath, 'r'), 'Error loading file: ' .. filePath);
    local content = file:read("*all");
    file:close();
    return json.decode(content, 1, nil);
end

function JsonInterface.save(filePath, data, keyOrderArray)

    local content = json.encode(data, { indent = true, keyorder = keyOrderArray });
    local file = io.open(filePath, 'w+b');

    if file ~= nil then
        file:write(content);
        file:close();
        return true
    else
        return false
    end
end

return JsonInterface
