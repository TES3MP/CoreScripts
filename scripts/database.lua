local Database = class("Database")

print("Creating Database")

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

    res = assert(self.connection:execute(query))
end

--- Create a table if it does not already exist
--@param tableName The name of the table. [string]
--@param columnArray An array (to keep column ordering) of key/value pairs. [table]
function Database:CreateTable(tableName, columnArray)

    local query = string.format("CREATE TABLE IF NOT EXISTS %s(", tableName)
    
    for index, column in pairs(columnArray) do
        for name, datatype in pairs(column) do
            if index > 1 then
                query = query .. ", "
            end

            query = query .. string.format("%s %s", name, datatype)
        end
    end

    query = query .. ")"
    self:Execute(query)
end

--- Insert a row into a table
--@param tableName The name of the table. [string]
--@param valueTable A key/value table where the keys are the names of columns. [table]
function Database:InsertRow(tableName, valueTable)

    local query = string.format("INSERT INTO %s", tableName)
    local queryColumns = ""
    local queryValues = ""
    local count = 1

    for column, value in pairs(valueTable) do
        if count > 1 then
            queryColumns = queryColumns .. ", "
            queryValues = queryValues .. ", "
        end

        queryColumns = queryColumns .. tostring(column)
        queryValues = queryValues .. '\'' .. tostring(value) .. '\''
        count = count + 1
    end

    query = query .. string.format("(%s) VALUES(%s)", queryColumns, queryValues)
    self:Execute(query)
end

function Database:CreateDefaultTables()

    columnList = {
        {dbPid = "INTEGER PRIMARY KEY ASC"},
        {name = "TEXT"},
        {password = "TEXT"},
        {admin = "INTEGER"},
        {consoleAllowed = "BOOLEAN NOT NULL CHECK (consoleAllowed IN (0,1))"}
    }

    self:CreateTable("player_general", columnList)

    valueTable = {
        name = "David", password = "test", admin = 2, consoleAllowed = 0
    }

    self:InsertRow("player_general", valueTable)
end

return Database
