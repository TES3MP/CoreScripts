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

function table.contains(t, valueToFind)
    for key, value in pairs(t) do
        if value == valueToFind then
            return true
        end
    end
    return false
end

function table.getIndexByPattern(t, patternToFind)
    for key, value in pairs(t) do
        if string.match(value, patternToFind) ~= nil then
            return key
        end
    end
    return nil
end

function table.removeValue(t, valueToFind)
    for key, value in pairs(t) do
        if value == valueToFind then
            t[key] = nil
        end
    end
end
