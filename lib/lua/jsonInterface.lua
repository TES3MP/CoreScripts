local json = require ("dkjson");

local jsonInterface = {};

function jsonInterface.load(dataFolder, fileName)
    
    local file = assert(io.open(dataFolder .. fileName, 'r'), 'Error loading file: ' .. dataFolder .. fileName);
    local content = file:read("*all");
    file:close();
    return json.decode(content, 1, nil);
end

function jsonInterface.save(dataFolder, fileName, data, keyOrderArray)

    local content = json.encode(data, { indent = true, keyorder = keyOrderArray });
    local file = assert(io.open(dataFolder .. fileName, 'w+b'), 'Error loading file: ' .. dataFolder .. fileName);
    file:write(content);
    file:close();
end

return jsonInterface;
