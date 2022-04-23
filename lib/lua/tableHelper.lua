local tableHelper = {}

-- Swap keys with their values in a table, allowing for the easy creation of tables similar to enums
function tableHelper.enum(inputTable)
    local newTable = {}
    for key, value in ipairs(inputTable) do
        newTable[value] = key
    end
    return newTable
end

function tableHelper.getCount(inputTable)
    local count = 0
    for key in pairs(inputTable) do count = count + 1 end
    return count
end

-- Iterate through a table's indexes and put them into an array table
function tableHelper.getArrayFromIndexes(inputTable)

    local newTable = {}

    for key, _ in pairs(inputTable) do
        table.insert(newTable, key)
    end

    return newTable
end

-- Return an array with the values that two input tables have in common
function tableHelper.getValueOverlap(firstTable, secondTable)

    local newTable = {}

    for _, value in pairs(firstTable) do
        if tableHelper.containsValue(secondTable, value) then
            table.insert(newTable, value)
        end
    end

    return newTable
end

-- Iterate through values matching a pattern in a string and turn them into table values
function tableHelper.getTableFromSplit(inputString, pattern)

    local newTable = {}

    for value in string.gmatch(inputString, pattern) do
        table.insert(newTable, value)
    end

    return newTable
end

-- Iterate through comma-separated values in a string and turn them into table values
function tableHelper.getTableFromCommaSplit(inputString)
    return tableHelper.getTableFromSplit(inputString, patterns.commaSplit)
end

-- Concatenate the indexes in a table, useful for printing out all the valid
-- indexes
function tableHelper.concatenateTableIndexes(inputTable, delimiter)

    local resultString = ""
    local tableCount = tableHelper.getCount(inputTable)
    local indexesSoFar = 1

    if delimiter == nil then
        delimiter = " "
    end

    for index, value in pairs(inputTable) do

        resultString = resultString .. index

        if indexesSoFar < tableCount then
            resultString = resultString .. delimiter
        end

        indexesSoFar = indexesSoFar + 1
    end

    return resultString
end

-- Concatenate the values in an array, useful for printing out the array's
-- contents, with an optional delimiter between values
function tableHelper.concatenateArrayValues(inputTable, startIndex, delimiter)

    local resultString = ""

    if startIndex == nil then
        startIndex = 1
    end

    if delimiter == nil then
        delimiter = " "
    end

    for i = startIndex, #inputTable do
        resultString = resultString .. inputTable[i]

        if i ~= #inputTable then
            resultString = resultString .. delimiter
        end
    end

    return resultString
end

function tableHelper.concatenateFromIndex(inputTable, startIndex, delimiter)

    return tableHelper.concatenateArrayValues(inputTable, startIndex, delimiter)
end

-- Check whether a table contains a key/value pair, optionally checking inside
-- nested tables
function tableHelper.containsKeyValue(inputTable, keyToFind, valueToFind, checkNestedTables)

    if inputTable[keyToFind] ~= nil then
        if inputTable[keyToFind] == valueToFind then
            return true
        end
    end

    if checkNestedTables then
        for key, value in pairs(inputTable) do
            if type(value) == "table" and tableHelper.containsKeyValue(value, keyToFind, valueToFind, true) then
                return true
            end
        end
    end

    return false
end

-- Check whether a table contains a set of key/value pairs, optionally checking inside
-- tables nested in the original one
function tableHelper.containsKeyValuePairs(inputTable, keyValuePairsTable, checkNestedTables)

    local foundMatches = true

    for keyToFind, valueToFind in pairs(keyValuePairsTable) do
        if inputTable[keyToFind] == nil or inputTable[keyToFind] ~= valueToFind then
            foundMatches = false
            break
        end
    end

    if foundMatches then
        return true
    elseif checkNestedTables then
        for key, value in pairs(inputTable) do
            if type(value) == "table" and tableHelper.containsKeyValuePairs(value, keyValuePairsTable, true) then
                return true
            end
        end
    end

    return false
end

-- Check whether a table contains a certain value, optionally checking inside
-- nested tables
function tableHelper.containsValue(inputTable, valueToFind, checkNestedTables)
    for key, value in pairs(inputTable) do
        if checkNestedTables and type(value) == "table" then
            if tableHelper.containsValue(value, valueToFind, true) then
                return true
            end
        elseif value == valueToFind then
            return true
        end
    end
    return false
end

-- Check whether a table contains a certain case insensitive string, optionally
-- checking inside nested tables
function tableHelper.containsCaseInsensitiveString(inputTable, stringToFind, checkNestedTables)

    if type(stringToFind) ~= "string"  then return false end

    for key, value in pairs(inputTable) do
        if checkNestedTables and type(value) == "table" then
            if tableHelper.containsCaseInsensitiveString(value, stringToFind, true) then
                return true
            end
        elseif type(value) == "string" and string.lower(value) == string.lower(stringToFind) then
            return true
        end
    end
    return false
end

function tableHelper.insertValueIfMissing(inputTable, value)
    if tableHelper.containsValue(inputTable, value, false) == false then
        table.insert(inputTable, value)
    end
end

function tableHelper.getAnyValue(inputTable)
    for key, value in pairs(inputTable) do
        return value
    end
end

function tableHelper.getUnusedNumericalIndex(inputTable)
    local i = 1
    
    while inputTable[i] ~= nil do
        i = i + 1
    end

    return i
end

function tableHelper.getIndexByPattern(inputTable, patternToFind)
    for key, value in pairs(inputTable) do
        if string.match(value, patternToFind) ~= nil then
            return key
        end
    end
    return nil
end

function tableHelper.getIndexByNestedKeyValue(inputTable, keyToFind, valueToFind)
    for key, value in pairs(inputTable) do
        if type(value) == "table" then
            if tableHelper.containsKeyValue(value, keyToFind, valueToFind) == true then
                return key
            end
        end
    end
    return nil
end

function tableHelper.getIndexByValue(inputTable, valueToFind)
    for key, value in pairs(inputTable) do
        if value == valueToFind then
            return key
        end
    end

    return nil
end

-- Iterate through a table and return a new table based on it that has no nil values
-- (useful for numerical arrays because they retain nil values)
--
-- Based on http://stackoverflow.com/a/28302975
function tableHelper.cleanNils(inputTable)

    local newTable = {}
    
    for key, value in pairs(inputTable) do
        if type(value) == "table" then
            tableHelper.cleanNils(value)
        end
        
        if type(key) == "number" then
            newTable[#newTable + 1] = value
            inputTable[key] = nil
        end
    end

    tableHelper.merge(inputTable, newTable)
end

-- Set values to nil here instead of using table.remove(), so this method can be used on
-- a table while iterating through it
function tableHelper.removeValue(inputTable, valueToFind)

    tableHelper.replaceValue(inputTable, valueToFind, nil)
end

function tableHelper.replaceValue(inputTable, valueToFind, newValue)
    for key, value in pairs(inputTable) do
        if type(value) == "table" then
            tableHelper.replaceValue(value, valueToFind, newValue)
        elseif value == valueToFind then
            inputTable[key] = newValue
        end
    end
end

-- Add a 2nd table's key/value pairs to the 1st table
--
-- Note: If they share keys, the values of the 2nd table will overwrite the ones
--       from the 1st table, unless both tables are arrays and combineArrays is true,
--       in which case the non-duplicate values in the 2nd table will be added to the 1st
function tableHelper.merge(mainTable, addedTable, combineArrays)

    if tableHelper.isArray(mainTable) and tableHelper.isArray(addedTable) and combineArrays then
        tableHelper.insertValues(mainTable, addedTable, true)
    else
        for key, value in pairs(addedTable) do
            if mainTable[key] == nil then
                if type(value) == "table" then
                    mainTable[key] = tableHelper.shallowCopy(value)
                else
                    mainTable[key] = value
                end
            elseif type(value) == "table" then
                tableHelper.merge(mainTable[key], value, combineArrays)
            else
                mainTable[key] = value
            end
        end
    end
end

-- Insert all the values from the 2nd table into the 1st table
function tableHelper.insertValues(mainTable, addedTable, skipDuplicates)

    for _, value in pairs(addedTable) do
        if not skipDuplicates or not tableHelper.containsValue(mainTable, value) then
            table.insert(mainTable, value)
        end
    end
end

-- Convert string keys containing numbers into numerical keys,
-- useful for JSON tables
--
-- Because Lua arrays start from index 1, the fixZeroStart argument
-- can be set to true to increment all of the keys by 1 in tables that
-- start from 0
function tableHelper.fixNumericalKeys(inputTable, fixZeroStart)

    local newTable = {}
    local incrementKeys = false

    if inputTable["0"] ~= nil and fixZeroStart then
        incrementKeys = true
    end

    for key, value in pairs(inputTable) do

        if type(value) == "table" then
            tableHelper.fixNumericalKeys(value)
        end

        if type(key) ~= "number" and type(tonumber(key)) == "number" then

            local newKey = tonumber(key)

            if incrementKeys then
                newKey = newKey + 1
            end

            newTable[newKey] = value
            inputTable[key] = nil
        end
    end

    tableHelper.merge(inputTable, newTable)
end

-- Check whether the table contains only numerical keys, though they
-- don't have to be consecutive
function tableHelper.usesNumericalKeys(inputTable)

    if tableHelper.getCount(inputTable) == 0 then
        return false
    end

    for key, value in pairs(inputTable) do
        if type(key) ~= "number" then
            return false
        end
    end

    return true
end

-- Check whether the table contains only numerical values
function tableHelper.usesNumericalValues(inputTable)

    if tableHelper.getCount(inputTable) == 0 then
        return false
    end

    for key, value in pairs(inputTable) do
        if type(value) ~= "number" then
            return false
        end
    end

    return true
end

-- Check whether there are any items in the table
function tableHelper.isEmpty(inputTable)
    if next(inputTable) == nil then
        return true
    end

    return false
end

-- Check whether the table is an array with only consecutive numerical keys,
-- i.e. without any gaps between keys
-- Based on http://stackoverflow.com/a/6080274
function tableHelper.isArray(inputTable)

    local index = 0

    for _ in pairs(inputTable) do
        index = index + 1
        if inputTable[index] == nil then return false end
    end

    return true
end

-- Check whether the table has the same keys and values as another table, optionally
-- ignoring certain keys
function tableHelper.isEqualTo(firstTable, secondTable, ignoredKeys)

    local hasIgnoredKeys = ignoredKeys ~= nil and not tableHelper.isEmpty(ignoredKeys)

    -- Is this the exact same table?
    if firstTable == secondTable then
        return true
    end

    if not hasIgnoredKeys and tableHelper.getCount(firstTable) ~= tableHelper.getCount(secondTable) then
        return false
    end

    for key, value in pairs(firstTable) do

        if not hasIgnoredKeys or not tableHelper.containsValue(ignoredKeys, key) then

            if secondTable[key] == nil then
                return false
            elseif type(value) == "table" and type(secondTable[key]) == "table" then
                if not tableHelper.isEqualTo(value, secondTable[key]) then
                    return false
                end
            elseif value ~= secondTable[key] then
                return false
            end
        end
    end

    return true
end

-- Copy the value of a variable in a naive and simple way, useful for copying a table's top
-- level values and direct children to another table, but still assigning references
-- for deeper children which can cause unexpected behavior
--
-- Note: This is only kept here for the sake of backwards compatibility, with use of the
--       deepCopy() method from below being preferable in any new scripts.
--
-- Based on http://lua-users.org/wiki/CopyTable
function tableHelper.shallowCopy(inputValue)

    local inputType = type(inputValue)

    local newValue

    if inputType == "table" then
        newValue = {}
        for innerKey, innerValue in pairs(inputValue) do
            newValue[innerKey] = innerValue
        end
    else -- number, string, boolean, etc
        newValue = inputValue
    end

    return newValue
end

-- Copy the value of a variable in a deep way, useful for copying a table's top level values
-- and direct children to another table safely, also handling metatables
--
-- Based on http://lua-users.org/wiki/CopyTable
function tableHelper.deepCopy(inputValue)

    local inputType = type(inputValue)

    local newValue

    if inputType == "table" then
        newValue = {}
        for innerKey, innerValue in next, inputValue, nil do
            newValue[tableHelper.deepCopy(innerKey)] = tableHelper.deepCopy(innerValue)
        end
        setmetatable(newValue, tableHelper.deepCopy(getmetatable(inputValue)))
    else -- number, string, boolean, etc
        newValue = inputValue
    end

    return newValue
end

-- Get a compact string with a table's contents
function tableHelper.getSimplePrintableTable(inputTable)

    local text = ""
    local shouldPrintComma = false

    for index, value in pairs(inputTable) do
        if shouldPrintComma then
            text = text .. ", "
        end

        if type(value) == "table" then
            text = text .. "[" .. tableHelper.getSimplePrintableTable(value) .. "]"
        else
            text = text .. index .. ": " .. tostring(value)
        end

        shouldPrintComma = true
    end

    return text
end

-- Get a string with a table's contents where every value is on its own row
--
-- Based on http://stackoverflow.com/a/13398936
function tableHelper.getPrintableTable(inputTable, maxDepth, indentStr, indentLevel)

    if type(inputTable) ~= "table" then
        return type(inputTable)
    end

    local str = ""
    local currentIndent = ""

    if indentLevel == nil then indentLevel = 0 end
    if indentStr == nil then indentStr = "\t" end
    if maxDepth == nil then maxDepth = 50 end

    for i = 0, indentLevel do
        currentIndent = currentIndent .. indentStr
    end

    for index, value in pairs(inputTable) do

        if type(value) == "table" and maxDepth > 0 then
            value = "\n" .. tableHelper.getPrintableTable(value, maxDepth - 1, indentStr, indentLevel + 1)
        else
            value = tostring(value) .. "\n"
        end

        str = str .. currentIndent .. index .. ": " .. value
    end

    return str
end

function tableHelper.print(inputTable, maxDepth, indentStr, indentLevel)
    local text = tableHelper.getPrintableTable(inputTable, maxDepth, indentStr, indentLevel)
    tes3mp.LogMessage(2, text)
end

return tableHelper
