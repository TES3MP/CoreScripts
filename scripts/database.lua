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

return Database
