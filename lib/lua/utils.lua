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

    return table.replaceValue(t, valueToFind, nil)
end

function table.replaceValue(t, valueToFind, newValue)
    for key, value in pairs(t) do
        if type(value) == "table" then
            t[key] = table.replaceValue(value, valueToFind, newValue)
        elseif value == valueToFind then
            t[key] = newValue
        end
    end

    return t
end

-- Based on http://stackoverflow.com/a/13398936
function table.print(t, indentLevel)
    local str = ""
    local indentStr = "#"

    if (indentLevel == nil) then
        print(table.print(t, 0))
        return
    end

    for i = 0, indentLevel do
        indentStr = indentStr .. "\t"
    end

    for index, value in pairs(t) do
        str = str .. indentStr .. index

        if type(value) == "table" then
            str = str .. ": \n" .. table.print(value, (indentLevel + 1))
        else
            str = str .. ": " .. value .. "\n"
        end
    end

    return str
end
