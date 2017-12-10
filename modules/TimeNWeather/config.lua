local Config = {}

-- Whether time should be synchronized across clients
-- Valid values: 0, 1
-- Note: 0 for no time sync, 1 for time sync based on the server's time counter
Config.timeSyncMode = 1 -- 0 - No time sync, 1 - Time sync based on server time counter

-- The time multiplier used by the server
-- Note: The default value of 1 is roughly 120 seconds per ingame hour
Config.timeServerMult = 1

-- The initial ingame time on the server
Config.timeServerInitTime = 7

return Config
