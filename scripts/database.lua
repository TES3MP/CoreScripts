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

function Database:CreateTable(tableName, columnList)

    local query = string.format("CREATE TABLE IF NOT EXISTS %s(", tableName)
    
    for index, column in pairs(columnList) do
        for name, datatype in pairs(column) do
            if index > 1 then
                query = query .. ", "
            end

            query = query .. string.format("%s %s", name, datatype)
        end
    end

    query = query .. ")"

    res = assert(self.connection:execute(query))
end

function Database:CreateDefaultTables()

    columnList = {
        {name = "VARCHAR(255)"},
        {password = "VARCHAR(255)"},
        {admin = "INT"},
        {consoleAllowed = "BOOLEAN"}
    }

    Database:CreateTable("player_general", columnList)
end

return Database
