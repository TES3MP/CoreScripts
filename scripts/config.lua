config = {}

-- The game mode displayed for this server in the server browser
config.gameMode = "Default"

-- Time to login, in seconds
config.loginTime = 60

-- The difficulty level used by default
-- Note: In OpenMW, the difficulty slider goes between -100 and 100, with 0 as the default,
--       though you can use any integer value here
config.difficulty = 0

-- The world time used for a newly created world
config.defaultTimeTable = { year = 427, month = 7, day = 16, hour = 9,
    daysPassed = 1, timeScale = 30 }

-- Whether the world time should continue passing when there are no players on the server
config.passTimeWhenEmpty = false

-- Whether players should be allowed to use the ingame tilde (~) console by default
config.allowConsole = false

-- Whether players should be allowed to rest in bed by default
config.allowBedRest = true

-- Whether players should be allowed to rest in the wilderness by default
config.allowWildernessRest = true

-- Whether players should be allowed to wait by default
config.allowWait = true

-- Whether journal entries should be shared across the players on the server or not
config.shareJournal = true

-- Whether faction ranks should be shared across the players on the server or not
config.shareFactionRanks = true

-- Whether faction expulsion should be shared across the players on the server or not
config.shareFactionExpulsion = false

-- Whether faction reputation should be shared across the players on the server or not
config.shareFactionReputation = true

-- Whether dialogue topics should be shared across the players on the server or not
config.shareTopics = true

-- Whether crime bounties should be shared across players on the server or not
config.shareBounty = false

-- Whether reputation should be shared across players on the server or not
config.shareReputation = true

-- Whether map exploration should be shared across players on the server or not
config.shareMapExploration = false

-- Whether ingame videos should be played for other players when triggered by one player
config.shareVideos = true

-- The cell that newly created players are teleported to
config.defaultSpawnCell = "-3, -2"

-- The X, Y and Z position that newly created players are teleported to
config.defaultSpawnPos = {-23980.693359375, -15561.556640625, 505}

-- The X and Z rotation that newly created players are assigned
config.defaultSpawnRot = {-0.000152587890625, 1.6182196140289}

-- The cell that players respawn in, unless overridden below by other respawn options
config.defaultRespawnCell = "Balmora, Temple"

-- The X, Y and Z position that players respawn in
config.defaultRespawnPos = {4700.5673828125, 3874.7416992188, 14758.990234375}

-- The X and Z rotation that respawned players are assigned
config.defaultRespawnRot = {0.25314688682556, 1.570611000061}

-- Whether the default respawn location should be ignored in favor of respawning the
-- player at the nearest Imperial shrine
config.respawnAtImperialShrine = true

-- Whether the default respawn location should be ignored in favor of respawning the
-- player at the nearest Tribunal temple
-- Note: When both this and the Imperial shrine option are enabled, there is a 50%
--       chance of the player being respawned at either
config.respawnAtTribunalTemple = true

-- The maximum value that any attribute except Speed is allowed to have
config.maxAttributeValue = 200

-- The maximum value that Speed is allowed to have
-- Note: Speed is given special treatment because of the Boots of Blinding Speed
config.maxSpeedValue = 365

-- The maximum value that any skill except Acrobatics is allowed to have
config.maxSkillValue = 200

-- The maximum value that Acrobatics is allowed to have
-- Note: Acrobatics is given special treatment because of the Scroll of Icarian Flight
config.maxAcrobaticsValue = 1200

-- The refIds of items that players are not allowed to equip for balancing reasons
config.bannedEquipmentItems = { "helseth's ring" }

-- Whether players should respawn when dying
config.playersRespawn = true

-- Time to stay dead before being respawned, in seconds
config.deathTime = 5

-- The number of days spent in jail as a penalty for dying, when respawning
config.deathPenaltyJailDays = 5

-- Whether players' bounties are reset to 0 after dying
config.bountyResetOnDeath = false

-- Whether players spend time in jail proportional to their bounty after dying
-- Note: Requires bountyResetOnDeath to be enabled
config.bountyDeathPenalty = false

-- Whether players should be allowed to use the /suicide command
config.allowSuicideCommand = true

-- Whether players should be allowed to use the /fixme command
config.allowFixmeCommand = true

-- How many seconds need to pass between uses of the /fixme command by a player
config.fixmeInterval = 30

-- Which numerical IDs should be used by custom menus implemented in the Lua scripts,
-- to prevent other menu inputs from being taken into account for them
config.customMenuIds = { menuHelper = 9001, confiscate = 9002 }

-- The menu files that should be loaded for menuHelper, from the scripts/menu subfolder
config.menuHelperFiles = { "help", "defaultCrafting", "advancedExample" }

-- What the difference in ping needs to be in favor of a new arrival to a cell or region
-- compared to that cell or region's current player authority for the new arrival to become
-- the authority there
-- Note: Setting this too low will lead to constant authority changes which cause more lag
config.pingDifferenceRequiredForAuthority = 40

-- The log level enforced on clients by default, determining how much debug information
-- is displayed in their debug window and logs
-- Note 1: Set this to -1 to allow clients to use whatever log level they have set in
--         their client settings
-- Note 2: If you set this to 0 or 1, clients will be able to read about the movements
--         and actions of other players that they would otherwise not know about,
--         while also incurring a framerate loss on highly populated servers
config.enforcedLogLevel = -1

-- The physics framerate used by default
-- Note: In OpenMW, the physics framerate is 60 by default, but TES3MP has slightly higher
--       system requirements that make a default of 30 more appropriate.
config.physicsFramerate = 30

-- Whether players should collide with other actors
config.enablePlayerCollision = true

-- Whether actors should collide with other actors
config.enableActorCollision = true

-- Whether placed objects should collide with actors
config.enablePlacedObjectCollision = false

-- Enforce collision for certain placed object refIds even when enablePlacedObjectCollision
-- is false
config.enforcedCollisionRefIds = { "misc_uni_pillow_01", "misc_uni_pillow_02" }

-- Whether placed object collision (when turned on) resembles actor collision, in that it
-- prevents players from standing on top of the placed objects without slipping
config.useActorCollisionForPlacedObjects = false

-- Prevent certain object refIds from being deleted as a result of player-sent packets
config.disallowedDeleteRefIds = { "m'aiq" }

-- Prevent certain object refIds from being placed or spawned as a result of player-sent packets
config.disallowedCreateRefIds = {}

-- Prevent certain object refIds from being locked or unlocked as a result of player-sent packets
config.disallowedLockRefIds = {}

-- Prevent certain object refIds from being trapped or untrapped as a result of player-sent packets
config.disallowedTrapRefIds = {}

-- Prevent certain object refIds from being enabled or disabled as a result of player-sent packets
config.disallowedStateRefIds = {}

-- Prevent object scales from being set this high
config.maximumObjectScale = 20

-- Whether the server should enforce that all clients connect with a specific list of plugins
-- defined in data/pluginlist.json
-- Warning: Only set this to false if you trust the people connecting and are sure they know
--          what they're doing. Otherwise, you risk getting corrupt server data from
--          their usage of unshared plugins.
config.enforcePlugins = true

-- The type of database or data format used by the server
-- Valid values: json, sqlite3
-- Note: The latter is only partially implemented as of now
config.databaseType = "json"

-- The location of the database file
-- Note: Not applicable when using json
config.databasePath = os.getenv("MOD_DIR") .. "/database.db" -- Path where database is stored

-- Disallow players from including the following in their names
-- Note: Unfortunately, these are based on real names that trolls have been using on servers
config.disallowedNameStrings = { "bitch", "blowjob", "blow job", "cocksuck", "cunt", "ejaculat",
"fag", "fellatio", "fuck", "gas the ", "Hitler", "nigga", "nigger", "smegma", "vagina", "whore", 
"Malseph", "terrabyte25", "terabyte25", "Trap", "ты гей", "Soy", "Bitch", "Daddy", "Nazi", "Socialis", 
"race war", "Retard", "Rape", "Kas Gikes", "Gook", "Pooplord", "boner", "jew", "juden", "furry", "qt", "cunt", "pedo", "nig"
"cracker", "lenin", "communis", "capitalis", "libtard", "conservetard", "tard", "cuck", "stalin", "nationalis"}

-- The order in which table keys should be saved to JSON files
config.playerKeyOrder = { "login", "settings", "character", "customClass", "location", "stats",
    "fame", "shapeshift", "attributes", "attributeSkillIncreases", "skills", "skillProgress",
    "equipment", "inventory", "spellbook", "books", "factionRanks", "factionReputation",
    "factionExpulsion", "mapExplored", "ipAddresses", "customVariables", "admin", "difficulty",
    "enforcedLogLevel", "physicsFramerate", "consoleAllowed", "bedRestAllowed",
    "wildernessRestAllowed", "waitAllowed", "gender", "race", "head", "hair", "class", "birthsign",
    "cell", "posX", "posY", "posZ", "rotX", "rotZ", "healthBase", "healthCurrent", "magickaBase",
    "magickaCurrent", "fatigueBase", "fatigueCurrent" }

config.cellKeyOrder = { "packets", "entry", "lastVisit", "objectData", "refId", "count", "charge",
    "enchantmentCharge", "location", "actorList", "ai", "summon", "stats", "cellChangeFrom",
    "cellChangeTo", "container", "death", "delete", "doorState", "equipment", "inventory", "lock",
    "place", "position", "scale", "spawn", "state", "statsDynamic", "trap" }

config.worldKeyOrder = { "general", "time", "topics", "kills", "journal", "customVariables", "type",
    "index", "quest", "actorRefId", "year", "month", "day", "hour", "daysPassed", "timeScale" }

return config
