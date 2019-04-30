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
    daysPassed = 1, dayTimeScale = 30, nightTimeScale = 40 }

-- The chat window instructions that show up when players join the server
config.chatWindowInstructions = "Use " .. color.Yellow .. "Y" .. color.White .. " by default to chat or change it" ..
    " from your client config. Type in " .. color.Yellow .. "/help" .. color.White .. " to see the commands" ..
    " available to you. Use " .. color.Yellow .. "F2" .. color.White .. " by default to hide the chat window.\n"

-- Whether the world time should continue passing when there are no players on the server
config.passTimeWhenEmpty = false

-- The hours at which night is regarded as starting and ending, used to pass time differently
-- when it's night
config.nightStartHour = 20
config.nightEndHour = 6

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
config.defaultSpawnPos = {-23894.0, -15079.0, 505}

-- The X and Z rotation that newly created players are assigned
config.defaultSpawnRot = {0, 1.2}

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
-- Note: If deathPenaltyJailDays is also enabled, that penalty will be added to
--       this one
config.bountyDeathPenalty = false

-- Whether players should be allowed to use the /suicide command
config.allowSuicideCommand = true

-- Whether players should be allowed to use the /fixme command
config.allowFixmeCommand = true

-- How many seconds need to pass between uses of the /fixme command by a player
config.fixmeInterval = 30

-- The colors used for different ranks on the server
config.rankColors = { serverOwner = color.Orange, admin = color.Red, moderator = color.Green }

-- Which numerical IDs should be used by custom menus implemented in the Lua scripts,
-- to prevent other menu inputs from being taken into account for them
config.customMenuIds = { menuHelper = 9001, confiscate = 9002, recordPrint = 9003 }

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

-- Whether players are allowed to interact with containers located in unloaded cells.
config.allowOnContainerForUnloadedCells = false

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

-- The prefix used for automatically generated record IDs
-- Note 1: Records with automatically generated IDs get erased when there are no more instances of
-- them in player inventories/spellbooks or in cells
-- Note 2: By default, records created through regular gameplay (i.e. player-created spells, potions,
-- enchantments and enchanted items) use automatically generated record IDs, as do records created
-- via the /createrecord command when no ID is specified there
config.generatedRecordIdPrefix = "$custom"

-- The types of record stores used on this server in the order in which they should be loaded for
-- players, with the correct order ensuring that enchantments are loaded before items that might be
-- using those enchantments or ensuring that NPCs are loaded after the items they might have in their
-- inventories
config.recordStoreLoadOrder = { "spell", "potion", "enchantment", "armor", "book", "clothing", "weapon",
    "miscellaneous", "creature", "npc" }

-- The types of records that can be enchanted and therefore have links to enchantment records
config.enchantableRecordTypes = { "armor", "book", "clothing", "weapon" }

-- The types of records that can be stored by players and therefore have links to players,
-- listed in the order in which they should be loaded
config.carriableRecordTypes = { "spell", "potion", "armor", "book", "clothing", "weapon", "miscellaneous" }

-- The settings which are accepted as input for different record types when using /storerecord
config.validRecordSettings = {
    armor = { "baseId", "id", "name", "model", "icon", "script", "enchantmentId", "enchantmentCharge",
        "subtype", "weight", "value", "health", "armorRating" },
    book = { "baseId", "id", "name", "model", "icon", "script", "enchantmentId", "enchantmentCharge",
        "text", "weight", "value", "scrollState", "skillId" },
    clothing = { "baseId", "id", "name", "model", "icon", "script", "enchantmentId", "enchantmentCharge",
        "subtype", "weight", "value" },
    creature = { "baseId", "id", "name", "model", "script", "subtype", "level", "health", "magicka",
        "fatigue", "aiFight", "flags" },
    enchantment = { "baseId", "id", "subtype", "cost", "charge", "autoCalc", "effects" },
    miscellaneous = { "baseId", "id", "name", "model", "icon", "script", "weight", "value", "keyState" },
    npc = { "baseId", "inventoryBaseId", "id", "name", "script", "flags", "gender", "race", "model", "hair",
        "head", "class", "faction", "level", "health", "magicka", "fatigue", "aiFight", "autoCalc" },
    potion = { "baseId", "id", "name", "model", "icon", "script", "weight", "value", "autoCalc" },
    spell = { "baseId", "id", "name", "subtype", "cost", "flags", "effects" },
    weapon = { "baseId", "id", "name", "model", "icon", "script", "enchantmentId", "enchantmentCharge",
        "subtype", "weight", "value", "health", "speed", "reach", "damageChop", "damageSlash", "damageThrust",
        "flags" }
}

-- The settings which need to be provided when creating a new record that isn't based at all
-- on an existing one, i.e. a new record that is missing a baseId
config.requiredRecordSettings = {
    armor = { "name", "model" },
    book = { "name", "model" },
    clothing = { "name", "model" },
    creature = { "name", "model" },
    enchantment = {},
    miscellaneous = { "name", "model" },
    npc = { "name", "race", "class" },
    potion = { "name", "model" },
    spell = { "name" },
    weapon = { "name", "model" }
}

-- The record type settings whose input should be converted to numerical values when using /storerecord
config.numericalRecordSettings = { "subtype", "weight", "value", "cost", "charge", "health", "armorRating",
    "speed", "reach", "level", "magicka", "fatigue", "aiFight", "autoCalc", "gender", "flags", "enchantmentCharge" }

-- The record type settings whose input should be converted to booleans when using /storerecord
config.booleanRecordSettings = { "scrollState", "keyState" }

-- The record type settings whose input should be converted to tables with a min and a max numerical value
config.minMaxRecordSettings = { "damageChop", "damageSlash", "damageThrust" }

-- The types of object and actor packets stored in cell data
config.cellPacketTypes = { "delete", "place", "spawn", "lock", "trap", "scale", "state", "doorState",
    "container", "equipment", "ai", "death", "actorList", "position", "statsDynamic", "cellChangeTo",
    "cellChangeFrom" }

-- Whether the server should enforce that all clients connect with a specific list of data files
-- defined in data/requiredDataFiles.json
-- Warning: Only set this to false if you trust the people connecting and are sure they know
--          what they're doing. Otherwise, you risk getting corrupt server data from
--          their usage of unshared plugins.
config.enforceDataFiles = true

-- Whether the server should avoid crashing when Lua script errors occur
-- Warning: Only set this to true if you want to have a highly experimental server where
--          important data can potentially stay unloaded or get overwritten
config.ignoreScriptErrors = false

-- The type of database or data format used by the server
-- Valid values: json, sqlite3
-- Note: The latter is only partially implemented as of now
config.databaseType = "json"

-- The location of the database file
-- Note: Not applicable when using json
config.databasePath = tes3mp.GetDataPath() .. "/database.db" -- Path where database is stored

-- Disallow players from including the following in their own names or the names of their custom items
-- Note: Unfortunately, these are based on real names that trolls have been using on servers
config.disallowedNameStrings = { "bitch", "blowjob", "blow job", "cocksuck", "cunt", "ejaculat",
    "faggot", "fellatio", "fuck", "gas the ", "Hitler", "jizz", "nigga", "nigger", "smegma", "vagina", "whore" }

-- The order in which table keys should be saved to JSON files
config.playerKeyOrder = { "login", "settings", "character", "customClass", "location", "stats",
    "fame", "shapeshift", "attributes", "attributeSkillIncreases", "skills", "skillProgress",
    "recordLinks", "equipment", "inventory", "spellbook", "books", "factionRanks", "factionReputation",
    "factionExpulsion", "mapExplored", "ipAddresses", "customVariables", "admin", "difficulty",
    "enforcedLogLevel", "physicsFramerate", "consoleAllowed", "bedRestAllowed",
    "wildernessRestAllowed", "waitAllowed", "gender", "race", "head", "hair", "class", "birthsign",
    "cell", "posX", "posY", "posZ", "rotX", "rotZ", "healthBase", "healthCurrent", "magickaBase",
    "magickaCurrent", "fatigueBase", "fatigueCurrent" }

config.cellKeyOrder = { "packets", "entry", "lastVisit", "recordLinks", "objectData", "refId", "count",
    "charge", "enchantmentCharge", "location", "actorList", "ai", "summon", "stats", "cellChangeFrom",
    "cellChangeTo", "container", "death", "delete", "doorState", "equipment", "inventory", "lock",
    "place", "position", "scale", "spawn", "state", "statsDynamic", "trap" }

config.recordstoreKeyOrder = { "general", "permanentRecords", "generatedRecords", "recordLinks",
    "id", "baseId", "name", "subtype", "gender", "race", "hair", "head", "class", "faction", "cost",
    "value", "charge", "weight", "autoCalc", "flags", "icon", "model", "script", "attribute", "skill",
    "rangeType", "area", "duration", "magnitudeMax", "magnitudeMin", "effects", "players", "cells", "global" }

config.worldKeyOrder = { "general", "time", "topics", "kills", "journal", "customVariables", "type",
    "index", "quest", "actorRefId", "year", "month", "day", "hour", "daysPassed", "timeScale" }

return config
