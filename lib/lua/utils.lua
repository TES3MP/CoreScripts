function string:split(sep)
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    self:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end

function doesModuleExist(name)
    if package.loaded[name] then
        return true
    else
        for _, searcher in ipairs(package.searchers or package.loaders) do
            local loader = searcher(name)
            if type(loader) == 'function' then
                package.preload[name] = loader
                return true
            end
        end
        return false
    end
end

function table.contains(table, valueToFind)
    for key, value in pairs(table) do
        if value == valueToFind then
            return true
        end
    end
    return false
end

function table.getIndexByPattern(table, patternToFind)
    for key, value in pairs(table) do
        if string.match(value, patternToFind) ~= nil then
            return key
        end
    end
    return nil
end

function table.removeValue(table, valueToFind)
    for key, value in pairs(table) do
        if value == valueToFind then
            table[key] = nil
        end
    end
end
