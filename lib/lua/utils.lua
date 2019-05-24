--- Utilities
-- @script utils

--- splits string on seperator
-- @string sep
-- @return table of the seperated values
function string:split(sep)
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    self:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end

--- Check for case-insensitive equality
-- @string otherString
-- @return bool true if strings are equal, false if not
function string:ciEqual(otherString)

    if type(otherString) ~= "string" then return false end

    return self:lower() == otherString:lower()
end

--- Prefix string with 0's
-- @string inputString
-- @int desiredLength
-- @return string with 0's prepended
function prefixZeroes(inputString, desiredLength)

    local length = string.len(inputString)

    while length < desiredLength do
        inputString = "0" .. inputString
        length = length + 1
    end

    return inputString
end

--- Require with return status
-- based on <a target="_blank" href="https://stackoverflow.com/a/34965917">this</a>
-- @string string module/filepath
-- @return module if successful else nil
function prequire(...)
    local status, lib = pcall(require, ...)
    if status then return lib end

    return nil
end

--- Check if module exists
-- @string name name of module
-- @return true if module exists if not false
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
