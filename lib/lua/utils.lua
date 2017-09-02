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

function createFile(filename)
    if type(filename) ~= "string" then return false end

    local home = getDataFolder()

    local file = io.open(home .. filename, 'r')
    
    if file == nil  then
        file = io.open(home .. filename, 'w+')
    end
    file:close()
    return true
end
