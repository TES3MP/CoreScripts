local dkjson = require("dkjson")
local cjson
local cjsonExists = doesModuleExist("cjson")

if cjsonExists then
    cjson = require("cjson")
    cjson.encode_sparse_array(true)
    cjson.encode_invalid_numbers("null")
    cjson.encode_empty_table_as_object(false)
    cjson.decode_null_as_lightuserdata(false)
else
    tes3mp.LogMessage(enumerations.log.ERROR, "Could not find Lua CJSON! The decoding and encoding of JSON files will always use dkjson and be slower as a result.")
end

local jsonInterface = {}

--
-- private
--

-- Remove all text from before the actual JSON content starts
-- Only used for cjson, dkjson ignores comments on its own
local function removeHeader(content)
    local closestBracketIndex

    local bracketIndex1 = content:find("\n%[")
    local bracketIndex2 = content:find("\n{")

    if bracketIndex1 and bracketIndex2 then
        closestBracketIndex = math.min(bracketIndex1, bracketIndex2)
    else
        closestBracketIndex = bracketIndex1 or bracketIndex2
    end

    return content:sub(closestBracketIndex)
end

--
-- public
--

function jsonInterface.load(fileName)
    local res = fileDrive.LoadAsync(fileName)
    if not res then
        error("Failed to load json file " .. fileName)
    end
    return jsonInterface.decode(res.content, fileName)
end

-- Save data to JSON in a slower but human-readable way, with identation and a specific order
-- to the keys, provided via dkjson
function jsonInterface.save(fileName, data, keyOrderArray)
    local content = jsonInterface.encode(data, keyOrderArray)
    return fileDrive.SaveAsync(fileName, content)
end

-- Save data to JSON in a fast but minimized way, provided via Lua CJSON, ideal for large files
-- that need to be saved over and over
function jsonInterface.quicksave(fileName, data)
    return jsonInterface.save(fileName, data)
end

-- Parse a JSON string and return it as a table
-- fileName is an optional argument, used for logging
function jsonInterface.decode(content, fileName)
    if cjsonExists then
        if content:sub(1, 2) == "//" then
            content = removeHeader(content)
        end
        local decodedContent = nil
        local status, error = pcall(function()
            decodedContent = cjson.decode(content)
        end)

        if status then
            return decodedContent
        else
            fileName = fileName or "string"
            tes3mp.LogMessage(enumerations.log.ERROR, "Could not decode " .. fileName .. " using Lua CJSON " ..
                "due to improperly formatted JSON! Error:\n" .. error .. "\n" .. fileName .. " is being decoded " ..
                "via the slower dkjson instead.")
        end
    end
    return dkjson.decode(content)
end

-- Encode a Lua table as JSON
-- keyOrder is an optional argument, forces use of slower dkjson
function jsonInterface.encode(data, keyOrderArray)
    if keyOrderArray ~= nil or not cjsonExists then
        return dkjson.encode(data, { indent = true, keyorder = keyOrderArray })
    end
    return cjson.encode(data)
end

return jsonInterface
