config = {}
config.dbtype = "file" -- file, sqlite3
config.dbpath = os.getenv("MOD_DIR") .. "/database.db" -- Path where database is stored
config.loginTime = 60 -- Time to login
config.allowConsole = true -- enable or disable in-game "~" console

-- Death and respawn options
config.deathTime = 5 -- Time to stay dead before being respawned
config.defaultRespawnCell = "Pelagiad, Fort Pelagiad"

return config
