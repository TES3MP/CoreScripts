local Config = {}

-- Time to login, in seconds
Config.loginTime = 60

-- Whether players should be allowed to use the ingame tilde (~) console by default
Config.allowConsole = true

-- The difficulty level used by default
-- Note: In OpenMW, the difficulty slider goes between -100 and 100, with 0 as the default,
--       though you can use any integer value here
Config.difficulty = 0

-- Whether journal entries should be shared across the players on the server or not
--
-- Note: Morrowind was designed strictly for singleplayer, which is why disabling journal
--       sharing will break much of its quest logic unless you at least do occasional
--       partial server resets.
Config.shareJournal = true

-- Whether faction ranks should be shared across the players on the server or not
Config.shareFactionRanks = true

-- Whether faction expulsion should be shared across the players on the server or not
Config.shareFactionExpulsion = false

-- Whether faction reputation should be shared across the players on the server or not
Config.shareFactionReputation = true

-- Time to stay dead before being respawned, in seconds
Config.deathTime = 5

-- The cell that newly created players are teleported to
Config.defaultSpawnCell = "-3, -2"

-- The X, Y and Z position that newly created players are teleported to
Config.defaultSpawnPos = {-23980.693359375, -15561.556640625, 505}

-- The X and Z rotation that newly created players are assigned
Config.defaultSpawnRot = {-0.000152587890625, 1.6182196140289}

-- The cell that players respawn in, unless overridden below by other respawn options
Config.defaultRespawnCell = "Balmora, Temple"

-- The X, Y and Z position that players respawn in
Config.defaultRespawnPos = {4700.5673828125, 3874.7416992188, 14758.990234375}

-- The X and Z rotation that respawned players are assigned
Config.defaultRespawnRot = {0.25314688682556, 1.570611000061}

-- Whether the default respawn location should be ignored in favor of respawning the
-- player at the nearest Imperial shrine
Config.respawnAtImperialShrine = true

-- Whether the default respawn location should be ignored in favor of respawning the
-- player at the nearest Tribunal temple
-- Note: When both this and the Imperial shrine option are enabled, there is a 50%
--       chance of the player being respawned at either
Config.respawnAtTribunalTemple = true

-- The number of days spent in jail as a penalty for dying
Config.deathPenaltyJailDays = 5

-- Whether players should be allowed to use the /suicide command
Config.allowSuicideCommand = true

-- The order in which table keys should be saved to JSON files
Config.playerKeyOrder = {"login", "settings", "character", "class", "location", "stats", "shapeshift", "attributes", "attributeSkillIncreases", "skills", "skillProgress", "equipment", "inventory", "spellbook", "books", "factionRanks", "factionReputation", "factionExpulsion", "mapExplored", "ipAddresses", "customVariables", "admin", "consoleAllowed", "difficulty", "gender", "race", "head", "hair", "birthsign", "cell", "posX", "posY", "posZ", "rotX", "rotZ", "healthBase", "healthCurrent", "magickaBase", "magickaCurrent", "fatigueBase", "fatigueCurrent"}
Config.worldKeyOrder = {"general", "topics", "kills", "journal", "customVariables", "type", "index", "quest", "actorRefId"}

-- The type of database or data format used by the server
-- Note: Only "json" is currently implemented, though "sqlite3" will be added later
Config.databaseType = "json"

return Config
