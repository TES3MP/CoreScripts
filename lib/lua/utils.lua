function doesModuleExist(name)
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

function createFile(dataFolder, fileName)
    if type(fileName) ~= "string" then return false end

    local file = io.open(dataFolder .. fileName, 'r')
    
    if file == nil then
        file = io.open(dataFolder .. fileName, 'w+')
    end
    file:close()
    return true
end
