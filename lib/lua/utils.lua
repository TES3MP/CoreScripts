---@param sep string|nil
---@return string[]
function string:split(sep)
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    self:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end

---@return string
function string:capitalizeFirstLetter()
    return (self:gsub("^%l", string.upper))
end

---Check for case-insensitive equality
---@param otherString string
---@return boolean
function string:ciEqual(otherString)

    if type(otherString) ~= "string" then return false end

    return self:lower() == otherString:lower()
end

---@return string
function string:trim()
    return (self:gsub("^%s*(.-)%s*$", "%1"))
end

---@param inputString string
---@param desiredLength number
---@return string
function prefixZeroes(inputString, desiredLength)

    local length = string.len(inputString)

    while length < desiredLength do
        inputString = "0" .. inputString
        length = length + 1
    end

    return inputString
end

-- Based on https://stackoverflow.com/a/34965917
---@param ... any
---@return unknown
function prequire(...)
    local status, lib = pcall(require, ...)
    if status then return lib end

    return nil
end

---@param name string
---@return boolean
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
