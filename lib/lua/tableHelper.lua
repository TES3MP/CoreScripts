--- Table helper
-- @module tableHelper
local tableHelper = {}

-- Swap keys with their values in a table, allowing for the easy creation of tables similar to enums
-- @param inputTable table
-- @return table with keys and values switched
function tableHelper.enum(inputTable)
    local newTable = {}
    for key, value in ipairs(inputTable) do
        newTable[value] = key
    end
    return newTable
end

--- get table length (useful for sparse tables)
-- @param inputTable table
-- @return length of inputTable
function tableHelper.getCount(inputTable)
    local count = 0
    for key in pairs(inputTable) do count = count + 1 end
    return count
end

--- Iterate through a table's indexes and put them into an array table
-- @param inputTable table
-- @return table
function tableHelper.getArrayFromIndexes(inputTable)

    local newTable = {}

    for key, _ in pairs(inputTable) do
        table.insert(newTable, key)
    end

    return newTable
end

--- Return an array with the values that two input tables have in common
-- @param firstTable table
-- @param secondTable table
-- @return table with the matching values
function tableHelper.getValueOverlap(firstTable, secondTable)

    local newTable = {}

    for _, value in pairs(firstTable) do
        if tableHelper.containsValue(secondTable, value) then
            table.insert(newTable, value)
        end
    end

    return newTable
end

--- Iterate through comma-separated values in a string and turn them into table values
-- @string inputString
-- @return table with values from splitting inputString on comma delimiter
function tableHelper.getTableFromCommaSplit(inputString)

    local newTable = {}

    for value in string.gmatch(inputString, patterns.commaSplit) do
        table.insert(newTable, value)
    end

    return newTable
end

--- Concatenate the indexes in a table, useful for printing out all the valid indexes
-- @param inputTable table
-- @string delimiter delimiter
-- @return string of concated table indexes from inputTable delimted by delimiter 
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

--- Concatenate the values in an array, useful for printing out the array's
-- contents, with an optional delimiter between values
-- <br> Optionally can take startIndex to start from
-- @param inputTable table
-- @int startIndex
-- @string delimiter
-- @return string of concated table values from inputTable delimted by delimiter
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

--- Concatenate the values in an array, useful for printing out the array's
-- contents, with an optional delimiter between values
-- @param inputTable table
-- @int startIndex
-- @string delimiter
-- @return string of concated table values from inputTable delimted by delimiter
-- @see tableHelper.concatenateArrayValues()
function tableHelper.concatenateFromIndex(inputTable, startIndex, delimiter)

    return tableHelper.concatenateArrayValues(inputTable, startIndex, delimiter)
end

--- Check whether a table contains a key/value pair, optionally checking inside
-- nested tables
-- @param inputTable table
-- @string keyToFind
-- @string valueToFind
-- @bool checkNestedTables
-- @return true if found, false if not
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

--- Check whether a table contains a set of key/value pairs, optionally checking inside
-- tables nested in the original one
-- @param inputTable table
-- @param keyValuePairsTable table
-- @bool checkNestedTables
-- @return true if found, false if not
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

--- Check whether a table contains a certain value, optionally checking inside
-- nested tables
-- @param inputTable table
-- @string valueToFind
-- @bool checkNestedTables
-- @return true if found, false if not
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

--- Check whether a table contains a certain case insensitive string, optionally
-- checking inside nested tables
-- @param inputTable table
-- @string stringToFind
-- @bool checkNestedTables
-- @return returns true if found, false if not
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

--- Check if table contains a certain value, if not inserts it
-- @param inputTable table
-- @string value
function tableHelper.insertValueIfMissing(inputTable, value)
    if tableHelper.containsValue(inputTable, value, false) == false then
        table.insert(inputTable, value)
    end
end

--- Attempts to get any value from an table
-- @param inputTable table
-- @return The value if found
function tableHelper.getAnyValue(inputTable)
    for key, value in pairs(inputTable) do
        return value
    end
end

--- Attempts to get the first unused numerical index (not counting 0)
-- @param inputTable table
-- @return int first unused numerical index
function tableHelper.getUnusedNumericalIndex(inputTable)
    local i = 1
    
    while inputTable[i] ~= nil do
        i = i + 1
    end

    return i
end

--- pattern matches values of an table (regexp)
-- @param inputTable table
-- @string patternToFind
-- @return index of value if found, if not returns nil
function tableHelper.getIndexByPattern(inputTable, patternToFind)
    for key, value in pairs(inputTable) do
        if string.match(value, patternToFind) ~= nil then
            return key
        end
    end
    return nil
end

--- Searches table and nested tables for key value pair
-- @param inputTable table
-- @string keyToFind
-- @string valueToFind
-- @return key if found, nil if not
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

--- Gets index by the value
-- @param inputTable table
-- @string valueToFind
-- @return key if found, nil if not
function tableHelper.getIndexByValue(inputTable, valueToFind)
    for key, value in pairs(inputTable) do
        if value == valueToFind then
            return key
        end
    end

    return nil
end

--- Iterate through a table and return a new table based on it that has no nil values
-- (useful for numerical arrays because they retain nil values)
-- Based on <a href="http://stackoverflow.com/a/28302975">this</a>
-- @param inputTable table
-- @return inputTable with nil values removed
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

--- Set values to nil here instead of using table.remove(), so this method can be used on
-- a table while iterating through it
-- @param inputTable table
-- @string valueToFind
function tableHelper.removeValue(inputTable, valueToFind)

    tableHelper.replaceValue(inputTable, valueToFind, nil)
end

--- Replace value in table or nested table
-- @param inputTable table
-- @string valueToFind
-- @string newValue
function tableHelper.replaceValue(inputTable, valueToFind, newValue)
    for key, value in pairs(inputTable) do
        if type(value) == "table" then
            tableHelper.replaceValue(value, valueToFind, newValue)
        elseif value == valueToFind then
            inputTable[key] = newValue
        end
    end
end

--- Add a 2nd table's key/value pairs to the 1st table
-- Note: If the two tables share keys, the values of the 2nd table
-- will be used in the final table
-- Based on <a href="http://stackoverflow.com/a/1283608">this</a>
-- @param mainTable table
-- @param addedTable table
-- table with merged data from input tables
function tableHelper.merge(mainTable, addedTable)
    for key, value in pairs(addedTable) do
        if type(value) == "table" then
            if type(mainTable[key] or false) == "table" then
                tableHelper.merge(mainTable[key] or {}, addedTable[key] or {})
            else
                mainTable[key] = value
            end
        else
            mainTable[key] = value
        end
    end
end

--- Insert all the values from the 2nd table into the 1st table
-- @param mainTable table
-- @param addedTable
-- @return mainTable with values from addedTable added to the end
function tableHelper.insertValues(mainTable, addedTable)

    for _, value in pairs(addedTable) do
        table.insert(mainTable, value)
    end
end

--- Convert string keys containing numbers into numerical keys,
-- useful for JSON tables<br/>
-- Because Lua arrays start from index 1, the fixZeroStart argument
-- can be set to true to increment all of the keys by 1 in tables that
-- start from 0
-- @param inputTable table
-- @bool fixZeroStart
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

--- Check whether the table contains only numerical keys, though they
-- don't have to be consecutive
-- @param inputTable table
-- @return true if all indexes are numerical, false if not
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

--- Check whether the table contains only numerical values
-- @param inputTable table
-- @return true if all values are numerical, false if not
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

--- Check whether there are any items in the table
-- @param inputTable table
-- @return true if table is empty, false if not
function tableHelper.isEmpty(inputTable)
    if next(inputTable) == nil then
        return true
    end

    return false
end

-- Check whether the table is an array with only consecutive numerical keys,
-- i.e. without any gaps between keys
-- Based on <a href="http://stackoverflow.com/a/6080274">this</a>
-- @param inputTable table
-- @return true if table is isn't sparse and has numerical keys, false if not
function tableHelper.isArray(inputTable)

    local index = 0

    for _ in pairs(inputTable) do
        index = index + 1
        if inputTable[index] == nil then return false end
    end

    return true
end

--- Check whether the table has the same keys and values as another table, optionally
-- ignoring certain keys
-- @param firstTable table
-- @param secondTable table
-- @string ignoredKeys
-- @return true if tables are equal, false if not
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

--- Copy a table's top level values and direct children to another table
-- Based on <a href="http://lua-users.org/wiki/CopyTable">this</a>
-- @param inputTable table
-- @return shallow copy of inputTable
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

--- Get a compact string with a table's contents
-- @param inputTable table
-- @return string
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
            text = text .. index .. ": " .. value
        end

        shouldPrintComma = true
    end

    return text
end

--- Get a string with a table's contents where every value is on its own row
-- Based on <a href="http://stackoverflow.com/a/13398936">this</a>
-- @param inputTable table
-- @int maxDepth
-- @string indentStr
-- @int indentLevel
-- @return string
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
            if type(value) ~= "string" then
                value = tostring(value)
            end

            value = value .. "\n"
        end

        str = str .. currentIndent .. index .. ": " .. value
    end

    return str
end

--- print an table to console
-- @param inputTable
-- @int maxDepth
-- @string indentStr
-- @int indentLevel
function tableHelper.print(inputTable, maxDepth, indentStr, indentLevel)
    local text = tableHelper.getPrintableTable(inputTable, maxDepth, indentStr, indentLevel)
    tes3mp.LogMessage(2, text)
end

return tableHelper
