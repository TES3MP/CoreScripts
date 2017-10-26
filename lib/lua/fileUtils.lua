local FileUtils = {}

-- Replace characters not allowed in filenames
function FileUtils.convertToFilename(name)

    return string.gsub(name, DefaultPatterns.invalidFileCharacters, "_")
end

-- Split a file path into its folder path, filename and extension
function FileUtils.splitFilePath(filePath)

    return string.match(filePath, DefaultPatterns.filenameComponents)
end

function FileUtils.doesFileExist(filePath)

    local folderPath, filename = FileUtils.splitFilePath(filePath)

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

function FileUtils.createFile(filePath)

    if type(filePath) ~= "string" then return false end

    local file = io.open(filePath, 'r')
    
    if file == nil then
        file = io.open(filePath, 'w+')
    end

    file:close()

    return true
end

return FileUtils
