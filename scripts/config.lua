config = {}
config.databaseType = "json" -- json, sqlite3
config.databasePath = os.getenv("MOD_DIR") .. "/database.db" -- Path where database is stored

-- The order in which table keys should be saved to JSON files
config.playerKeyOrder = {"login", "settings", "character", "customClass", "location", "stats", "attributes", "attributeSkillIncreases", "skills", "skillProgress", "equipment", "inventory", "spellbook"}
config.worldKeyOrder = {"general", "topics", "kills", "journal", "type", "index", "quest", "actorRefId"}

config.loginTime = 60 -- Time to login
config.allowConsole = false -- Enable or disable the in-game "~" console
config.difficulty = 0 -- The difficulty level used by default, from -100 to 100

-- Death and respawn options
config.deathTime = 5 -- Time to stay dead before being respawned
config.defaultSpawnCell = "-3, -2"
config.defaultSpawnPos = {-23980.693359375, -15561.556640625, 505}
config.defaultSpawnRot = {-0.000152587890625, 1.6182196140289}
config.defaultRespawnCell = "Balmora, Temple"
config.defaultRespawnPos = {4700.5673828125, 3874.7416992188, 14758.990234375}
config.defaultRespawnRot = {0.25314688682556, 1.570611000061}
config.respawnAtLastBed = true

config.timeSyncMode = 1 -- 0 - No time sync, 1 - Time sync based on server time counter
config.timeServerMult = 1 -- Time multiplier (default is ~120 seconds per hour)
config.timeServerInitTime = 7 -- The initial time on the server

return config
