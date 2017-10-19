DefaultPatterns = require("defaultPatterns")

local FileUtils = {}

-- Replace characters not allowed in filenames
function FileUtils.convertToFilename(name)

    return string.gsub(name, DefaultPatterns.invalidFileCharacters, "_")
end

function FileUtils.doesFileExist(folderPath, filename)

    if getCaseInsensitiveFilename(folderPath, filename) == "invalid" then
        return false
    end

    return true
end

function FileUtils.doesModuleExist(name)

    if package.loaded[name] then
        return true
    else
        for _, searcher in ipairs(package.searchers or package.loaders) do
            local loader = searcher(name)
            if type(loader) == "function" then
                package.preload[name] = loader
                return true
            end
        end
        return false
    end
end

function FileUtils.createFile(dataFolder, fileName)

    if type(fileName) ~= "string" then return false end

    local file = io.open(dataFolder .. fileName, 'r')
    
    if file == nil then
        file = io.open(dataFolder .. fileName, 'w+')
    end
    file:close()
    return true
end

return FileUtils
