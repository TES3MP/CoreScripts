local json = require ("dkjson");

local jsonInterface = {};

function jsonInterface.load(fileName)
    local home = getDataFolder()
    
    local file = assert(io.open(home .. fileName, 'r'), 'Error loading file: ' .. home .. fileName);
    local content = file:read("*all");
    file:close();
    return json.decode(content, 1, nil);
end

function jsonInterface.save(fileName, data, keyOrderArray)
    local home = getDataFolder()
    local content = json.encode(data, { indent = true, keyorder = keyOrderArray });
    local file = assert(io.open(home .. fileName, 'w+b'), 'Error loading file: ' .. home .. fileName);
    file:write(content);
    file:close();
end

return jsonInterface;
