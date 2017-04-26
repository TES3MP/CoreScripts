local json = require ("dkjson");

local jsonInterface = {};

function jsonInterface.load(fileName)
    local home = os.getenv("MOD_DIR") .. "/"
    local file = assert(io.open(home .. fileName, 'r'), 'Error loading file: ' .. fileName);
    local content = file:read("*all");
    file:close();
    return json.decode(content, 1, nil);
end

function jsonInterface.save(fileName, data, keyOrderArray)
    local home = os.getenv("MOD_DIR") .. "/"
    local content = json.encode(data, { indent = true, keyorder = keyOrderArray });
    local file = assert(io.open(home .. fileName, 'w+b'), 'Error loading file: ' .. fileName);
    file:write(content);
    file:close();
end

return jsonInterface;
