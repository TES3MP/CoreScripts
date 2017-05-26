config = {}
config.databaseType = "json" -- json, sqlite3
config.databasePath = os.getenv("MOD_DIR") .. "/database.db" -- Path where database is stored

-- The order in which table keys should be saved to JSON files
config.playerKeyOrder = {"login", "settings", "character", "customClass", "location", "stats", "attributes", "attributeSkillIncreases", "skills", "skillProgress", "equipment", "inventory", "spellbook"}

config.loginTime = 60 -- Time to login
config.allowConsole = true -- Enable or disable in-game "~" console

-- Death and respawn options
config.deathTime = 5 -- Time to stay dead before being respawned
config.defaultRespawnCell = "Pelagiad, Fort Pelagiad"

config.timeSyncMode = 1 -- 0 - No time sync, 1 - Time sync based on server time counter
config.timeServerMult = 1 -- Time multiplier (default is ~120 seconds per hour)
config.timeServerInitTime = 0 -- The initial time on the server

return config
