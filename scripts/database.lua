require('utils')
local Database = class("Database")

function Database:LoadDriver(driver)

    self.driver = require("luasql." .. driver)

    -- Create environment object
    self.env = nil

    if driver == "sqlite3" then
        self.env = self.driver.sqlite3()
    end
end

function Database:Connect(databasePath)

    self.connection = assert(self.env:connect(databasePath))
end

function Database:Execute(query)

    local response = self.connection:execute(query)

    if response == nil then
        print("Could not execute query: " .. query)
    end

    return response
end

function Database:Escape(string)

    string = self.connection:escape(string)
    return string
end

--- Create a table if it does not already exist
--@param tableName The name of the table. [string]
--@param columnArray An array (to keep column ordering) of key/value pairs. [table]
function Database:CreateTable(tableName, columnArray)

    local query = string.format("CREATE TABLE IF NOT EXISTS %s(", tableName)
    
    for index, column in pairs(columnArray) do
        for name, definition in pairs(column) do
            if index > 1 then
                query = query .. ", "
            end

            -- If this is a constraint, only add its definition to the query
            if name == "constraint" then
                query = query .. definition
            else
                query = query .. string.format("%s %s", name, definition)
            end
        end
    end

    query = query .. ")"
    self:Execute(query)
end

function Database:DeleteRows(tableName, condition)

    local query = string.format("DELETE FROM %s %s", tableName, condition)
    self:Execute(query)
end

--- Insert a row into a table
--@param tableName The name of the table. [string]
--@param valueTable A key/value table where the keys are the names of columns. [table]
function Database:InsertRow(tableName, valueTable)

    local query = string.format("INSERT OR REPLACE INTO %s", tableName)
    local queryColumns = ""
    local queryValues = ""
    local count = 0

    for column, value in pairs(valueTable) do

        count = count + 1

        if count > 1 then
            queryColumns = queryColumns .. ", "
            queryValues = queryValues .. ", "
        end

        queryColumns = queryColumns .. tostring(column)
        queryValues = queryValues .. '\'' .. self:Escape(tostring(value)) .. '\''
    end

    if count > 0 then

        query = query .. string.format("(%s) VALUES(%s)", queryColumns, queryValues)
        self:Execute(query)
    end
end

function Database:SelectRow(tableName, condition)

    local query = string.format("SELECT * FROM %s %s", tableName, condition)
    local cursor = self:Execute(query)
    local row = cursor:fetch({}, "a")

    return row
end

function Database:GetSingleValue(tableName, column, condition)

    local query = string.format("SELECT %s FROM %s %s", column, tableName, condition)
    local cursor = self:Execute(query)
    local row = cursor:fetch({}, "a")

    if row == nil or row[column] == nil then
        return nil
    else
        return row[column]
    end
end

function Database:SavePlayer(dbPid, data)

    for category, categoryTable in pairs(data) do
        if table.usesNumericalKeys(categoryTable) then
            print(category .. " was array!")
        elseif category ~= "login" then
            print("Saving category " .. category)
            local tempTable = table.shallowCopy(categoryTable)
            tempTable.dbPid = dbPid
            self:InsertRow("player_" .. category, tempTable)
        end
    end
end

function Database:LoadPlayer(dbPid)

    local validCategories = { "login", "settings", "character", "location", "stats", "attributes", "attributeSkillIncreases", "skills", "skillProgress" }
    local data = {}

    for index, category in pairs(validCategories) do
        data[category] = self:SelectRow("player_" .. category, string.format("WHERE dbPid = '%s'", dbPid))

        -- Set dbPid to nil just in case we want to save the data again to a different format
        data[category].dbPid = nil
    end

    return data
end

function Database:CreateDefaultTables()

    local columnList, valueTable

    local dbPidRow = {dbPid = "INTEGER PRIMARY KEY ASC"}
    local constraintRow = {constraint = "FOREIGN KEY(dbPid) REFERENCES player_login(dbPid)" }

    columnList = {
        dbPidRow,
        {name = "TEXT UNIQUE"},
        {password = "TEXT"}
    }

    self:CreateTable("player_login", columnList)

    columnList = {
        dbPidRow,
        {admin = "INTEGER"},
        {consoleAllowed = "TEXT NOT NULL CHECK (consoleAllowed IN ('true', 'false', 'default'))"},
        constraintRow
    }

    self:CreateTable("player_settings", columnList)

    columnList = {
        dbPidRow,
        {race = "TEXT"},
        {head = "TEXT"},
        {hair = "TEXT"},
        {gender = "BOOLEAN NOT NULL CHECK (gender IN (0, 1))"},
        {class = "TEXT"},
        {birthsign = "TEXT"},
        constraintRow
    }

    self:CreateTable("player_character", columnList)

    columnList = {
        dbPidRow,
        {cell = "TEXT"},
        {posX = "NUMERIC"},
        {posY = "NUMERIC"},
        {posZ = "NUMERIC"},
        {rotX = "NUMERIC"},
        {rotY = "NUMERIC"},
        {rotZ = "NUMERIC"},
        constraintRow
    }

    self:CreateTable("player_location", columnList)

    columnList = {
        dbPidRow,
        {level = "INTEGER"},
        {levelProgress = "INTEGER"},
        {healthBase = "NUMERIC"},
        {healthCurrent = "NUMERIC"},
        {magickaBase = "NUMERIC"},
        {magickaCurrent = "NUMERIC"},
        {fatigueBase = "NUMERIC"},
        {fatigueCurrent = "NUMERIC"},
        constraintRow
    }

    self:CreateTable("player_stats", columnList)

    columnList = { dbPidRow }

    for i = 0, (tes3mp.GetAttributeCount() - 1) do
        local attributePair = {}
        attributePair[tes3mp.GetAttributeName(i)] = "INTEGER"
        table.insert(columnList, attributePair)
    end

    table.insert(columnList, constraintRow)
    self:CreateTable("player_attributes", columnList)
    self:CreateTable("player_attributeSkillIncreases", columnList)

    columnList = { dbPidRow }

    for i = 0, (tes3mp.GetSkillCount() - 1) do
        local skillPair = {}
        skillPair[tes3mp.GetSkillName(i)] = "INTEGER"
        table.insert(columnList, skillPair)
    end

    table.insert(columnList, constraintRow)
    self:CreateTable("player_skills", columnList)

    -- Turn INTEGER into NUMERIC for skillProgress
    table.replaceValue(columnList, "INTEGER", "NUMERIC")

    self:CreateTable("player_skillProgress", columnList)

    columnList = {
        {dbPid = "INTEGER"},
        {slot = "INTEGER"},
        {refId = "TEXT"},
        {refNum = "INTEGER"},
        {health = "INTEGER"},
        constraintRow
    }

    self:CreateTable("player_slots_equipment", columnList)
    self:CreateTable("player_slots_inventory", columnList)

    columnList = {
        {dbPid = "INTEGER"},
        {slot = "INTEGER"},
        {spellId = "TEXT"},
        constraintRow
    }

    self:CreateTable("player_slots_spellbook", columnList)
end

return Database
