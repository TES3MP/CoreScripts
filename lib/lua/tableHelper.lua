DefaultPatterns = require("defaultPatterns")

local TableHelper = {}

-- Swap keys with their values in a table, allowing for the easy creation of tables similar to enums
function TableHelper.enum(inputTable)
    local newTable = {}
    for key, value in ipairs(inputTable) do
        newTable[value] = key
    end
    return newTable
end

function TableHelper.getCount(inputTable)
    local count = 0
    for key in pairs(inputTable) do count = count + 1 end
    return count
end

-- Iterate through comma-separated values in a string and turn them into table values
function TableHelper.getTableFromCommaSplit(inputString)

    local newTable = {}

    for value in string.gmatch(inputString, DefaultPatterns.commaSplit) do
        table.insert(newTable, value)
    end

    return newTable
end

-- Check whether a table contains a key/value pair, optionally checking inside
-- nested tables
function TableHelper.containsKeyValue(inputTable, keyToFind, valueToFind, checkNestedTables)
    if inputTable[keyToFind] ~= nil then
        if inputTable[keyToFind] == valueToFind then
            return true
        end
    elseif checkNestedTables == true then
        for key, value in pairs(inputTable) do
            if type(value) == "table" and TableHelper.containsKeyValue(value, keyToFind, valueToFind, true) then
                return true
            end
        end
    end
    return false
end

-- Check whether a table contains a certain value, optionally checking inside
-- nested tables
function TableHelper.containsValue(inputTable, valueToFind, checkNestedTables)
    for key, value in pairs(inputTable) do
        if checkNestedTables == true and type(value) == "table" then
            if TableHelper.containsValue(value, valueToFind, true) == true then
                return true
            end
        elseif value == valueToFind then
            return true
        end
    end
    return false
end

function TableHelper.insertValueIfMissing(inputTable, value)
    if TableHelper.containsValue(inputTable, value, false) == false then
        table.insert(inputTable, value)
    end
end

function TableHelper.getIndexByPattern(inputTable, patternToFind)
    for key, value in pairs(inputTable) do
        if string.match(value, patternToFind) ~= nil then
            return key
        end
    end
    return nil
end

function TableHelper.getIndexByNestedKeyValue(inputTable, keyToFind, valueToFind)
    for key, value in pairs(inputTable) do
        if type(value) == "table" then
            if TableHelper.containsKeyValue(value, keyToFind, valueToFind) == true then
                return key
            end
        end
    end
    return nil
end

-- Iterate through a table and return a new table based on it that has no nil values
-- (useful for numerical arrays because they retain nil values)
--
-- Based on http://stackoverflow.com/a/28302975
function TableHelper.cleanNils(inputTable)

    local newTable = {}
    
    for key, value in pairs(inputTable) do
        if type(value) == "table" then
            TableHelper.cleanNils(value)
        end
        
        if type(key) == "number" then
            newTable[#newTable + 1] = value
            inputTable[key] = nil
        end
    end

    TableHelper.merge(inputTable, newTable)
end

-- Set values to nil here instead of using table.remove(), so this method can be used on
-- a table while iterating through it
function TableHelper.removeValue(inputTable, valueToFind)

    TableHelper.replaceValue(inputTable, valueToFind, nil)
end

function TableHelper.replaceValue(inputTable, valueToFind, newValue)
    for key, value in pairs(inputTable) do
        if type(value) == "table" then
            TableHelper.replaceValue(value, valueToFind, newValue)
        elseif value == valueToFind then
            inputTable[key] = newValue
        end
    end
end

-- Add a 2nd table's key/value pairs to the 1st table
--
-- Based on http://stackoverflow.com/a/1283608
function TableHelper.merge(t1, t2)
    for key, value in pairs(t2) do
        if type(value) == "table" then
            if type(t1[key] or false) == "table" then
                TableHelper.merge(t1[key] or {}, t2[key] or {})
            else
                t1[key] = value
            end
        else
            t1[key] = value
        end
    end
end

-- Converts string keys containing numbers into numerical keys,
-- useful for JSON tables
function TableHelper.fixNumericalKeys(inputTable)

    local newTable = {}

    for key, value in pairs(inputTable) do

        if type(value) == "table" then
            TableHelper.fixNumericalKeys(value)
        end

        if type(key) ~= "number" and type(tonumber(key)) == "number" then
            newTable[tonumber(key)] = value
            inputTable[key] = nil
        end
    end

    TableHelper.merge(inputTable, newTable)
end

-- Checks whether the table contains only numerical keys, though they
-- don't have to be consecutive
function TableHelper.usesNumericalKeys(inputTable)

    if TableHelper.getCount(inputTable) == 0 then
        return false
    end

    for key, value in pairs(inputTable) do
        if type(key) ~= "number" then
            return false
        end
    end

    return true
end

-- Checks whether the table contains only numerical values
function TableHelper.usesNumericalValues(inputTable)

    if TableHelper.getCount(inputTable) == 0 then
        return false
    end

    for key, value in pairs(inputTable) do
        if type(value) ~= "number" then
            return false
        end
    end

    return true
end

-- Checks whether there are any items in the table
function TableHelper.isEmpty(inputTable)
    if next(inputTable) == nil then
        return true
    end

    return false
end

-- Checks whether the table is an array with only consecutive numerical keys,
-- i.e. without any gaps between keys
-- Based on http://stackoverflow.com/a/6080274
function TableHelper.isArray(inputTable)
    local index = 0
    for _ in pairs(inputTable) do
        index = index + 1
        if inputTable[index] == nil then return false end
    end
    return true
end

-- Based on http://lua-users.org/wiki/CopyTable
function TableHelper.shallowCopy(inputTable)
    local inputType = type(inputTable)
    local newTable
    if inputType == 'table' then
        newTable = {}
        for key, value in pairs(inputTable) do
            newTable[key] = value
        end
    else -- number, string, boolean, etc
        newTable = inputTable
    end
    return newTable
end

-- Based on http://stackoverflow.com/a/13398936
function TableHelper.print(inputTable, indentLevel)
    local str = ""
    local indentStr = "#"

    if (inputTable == nil) then
        return
    end

    if (indentLevel == nil) then
        logMessage(Log.LOG_INFO, TableHelper.print(inputTable, 0))
        return
    end

    for i = 0, indentLevel do
        indentStr = indentStr .. "\t"
    end

    for index, value in pairs(inputTable) do
        str = str .. indentStr .. index

        if type(value) == "boolean" then
            if value == true then
                value = "true"
            else
                value = "false"
            end
        end

        if type(value) == "table" then
            str = str .. ": \n" .. TableHelper.print(value, (indentLevel + 1))
        else
            str = str .. ": " .. value .. "\n"
        end
    end

    return str
end

return TableHelper
