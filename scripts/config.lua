config = {}
config.databaseType = "json" -- json, sqlite3
config.databasePath = os.getenv("MOD_DIR") .. "/database.db" -- Path where database is stored

-- The order in which table keys should be saved to JSON files
config.playerKeyOrder = {"login", "settings", "character", "customClass", "location", "stats", "attributes", "attributeSkillIncreases", "skills", "skillProgress", "equipment", "inventory", "spellbook"}

config.loginTime = 60 -- Time to login
config.allowConsole = true -- enable or disable in-game "~" console

-- Death and respawn options
config.deathTime = 5 -- Time to stay dead before being respawned
config.defaultRespawnCell = "Pelagiad, Fort Pelagiad"

config.timeSyncMode = 1 -- 0 Do not sync, 1 Use server side counter, 2 use time of frist joined client (not implemented)
config.timeServerMult = 1 -- multiply seconds to this value (default ~120 seconds per hour)
config.timeServerInitTime = 7 -- You can init the time like with ingame command -  "Set GameHour"

return config
