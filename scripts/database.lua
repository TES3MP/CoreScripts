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

function Database:CreatePlayerTables()

    res = assert(self.connection:execute[[
        CREATE TABLE IF NOT EXISTS players_general(
            name varchar(255),
            password varchar(255),
            admin int,
            consoleAllowed boolean
    )
    ]])
end

return Database
