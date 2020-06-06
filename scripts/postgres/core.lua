postgresClient.Initiate()
threadHandler.Async(function()
    postgresClient.ConnectAwait(config.postgresConnectionString)

    local function ProcessMigration(id, path)
        tes3mp.LogMessage(enumerations.log.INFO, "[Postgres] Applying migration " .. path)
        local status = require("postgres.migrations." .. path)
        if status ~= 0 then
            error("[Postgres] Fatal migration error!")
        end
        postgresClient.Query([[INSERT INTO migrations(id, processed_at) VALUES(?, TO_TIMESTAMP(?))]], {id, os.time()})
    end

    -- apply necessary migrations
    local migrations = require("postgres.migrations")
    local doneMigrations = postgresClient.QueryAwait([[SELECT * FROM migrations]])
    local doneTable = {}
    if doneMigrations.error then
        tes3mp.LogMessage(enumerations.log.INFO, "[Postgres] Seeding database for the first time, ignore the SQL error above!")
        ProcessMigration(0, "0000_migrations")
    else
        for i = 1, doneMigrations.count do
            local row = doneMigrations.rows[i]
            doneTable[tonumber(row.id)] = true
        end
    end

    for i, path in ipairs(migrations) do
        if not doneTable[i] then
            ProcessMigration(i, path)
        end
    end
end)
customEventHooks.registerHandler("OnServerExit", function()
    threadHandler.Async(function() postgresClient.DisconnectAwait() end)
end)