---@class TES3MP
local api

---Write a log message with its own timestamp.
---
---It will have "[Script]:" prepended to it so as to mark it as a script-generated log message.
---@param level integer @The logging level used (0 for LOG_VERBOSE, 1 for LOG_INFO, 2 for LOG_WARN, 3 for LOG_ERROR, 4 for LOG_FATAL).
---@param message string @The message logged.
function api.LogMessage(level, message) end

---Write a log message without its own timestamp.
---
---It will have "[Script]:" prepended to it so as to mark it as a script-generated log message.
---@param level integer @The logging level used (0 for LOG_VERBOSE, 1 for LOG_INFO, 2 for LOG_WARN, 3 for LOG_ERROR, 4 for LOG_FATAL).
---@param message string @The message logged.
function api.LogAppend(level, message) end

---Shut down the server.
---@param code integer @The shutdown code.
function api.StopServer(code) end

---Kick a certain player from the server.
---@param pid integer @The player ID.
function api.Kick(pid) end

---Ban a certain IP address from the server.
---@param ipAddress string @The IP address.
function api.BanAddress(ipAddress) end

---Unban a certain IP address from the server.
---@param ipAddress string @The IP address.
function api.UnbanAddress(ipAddress) end

---Check whether a certain file path exists.
---
---This will be a case sensitive check on case sensitive filesystems.
---
---Whenever you want to enforce case insensitivity, use GetCaseInsensitiveFilename() instead.
---@return boolean @Whether the file exists or not.
function api.DoesFilePathExist() end

---Get the first filename in a folder that has a case insensitive match with the filename argument.
---
---This is used to retain case insensitivity when opening data files on Linux.
---@return string @The filename that matches.
function api.GetCaseInsensitiveFilename() end

---Get the path of the server's data folder.
---@return string @The data path.
function api.GetDataPath() end

---Get the milliseconds elapsed since the server was started.
---@return integer @The time since the server's startup in milliseconds.
function api.GetMillisecondsSinceServerStart() end

---Get the type of the operating system used by the server.
---
---Note: Currently, the type can be "Windows", "Linux", "OS X" or "Unknown OS".
---@return string @The type of the operating system.
function api.GetOperatingSystemType() end

---Get the architecture type used by the server.
---
---Note: Currently, the type can be "64-bit", "32-bit", "ARMv#" or "Unknown architecture".
---@return string @The architecture type.
function api.GetArchitectureType() end

---Get the TES3MP version of the server.
---@return string @The server version.
function api.GetServerVersion() end

---Get the protocol version of the server.
---@return string @The protocol version.
function api.GetProtocolVersion() end

---Get the average ping of a certain player.
---@param pid integer @The player ID.
---@return integer @The average ping.
function api.GetAvgPing(pid) end

---Get the IP address of a certain player.
---@param pid integer @The player ID.
---@return string @The IP address.
function api.GetIP(pid) end

---Get the port used by the server.
---@return integer @The port.
function api.GetPort() end

---Get the maximum number of players.
---@return integer @Max players
function api.GetMaxPlayers() end

---Checking if the server requires a password to connect.
---
---@return boolean
function api.HasPassword() end

---Get the data file enforcement state of the server.
---
---If true, clients are required to use the same data files as set for the server.
---@return boolean @The enforcement state.
function api.GetDataFileEnforcementState() end

---Get the script error ignoring state of the server.
---
---If true, script errors will not crash the server.
---@return boolean @The script error ignoring state.
function api.GetScriptErrorIgnoringState() end

---Set the game mode of the server, as displayed in the server browser.
---@param gameMode string @The new game mode.
function api.SetGameMode(gameMode) end

---Set the name of the server, as displayed in the server browser.
---@param name string @The new name.
function api.SetHostname(name) end

---Set the password required to join the server.
---@param password string @The password.
function api.SetServerPassword(password) end

---Set the data file enforcement state of the server.
---
---If true, clients are required to use the same data files as set for the server.
---@param state boolean @The new enforcement state.
function api.SetDataFileEnforcementState(state) end

---Set whether script errors should be ignored or not.
---
---If true, script errors will not crash the server, but could have any number of unforeseen consequences, which is why this is a highly experimental setting.
---@param state boolean @The new script error ignoring state.
function api.SetScriptErrorIgnoringState(state) end

---Set a rule string for the server details displayed in the server browser.
---@param key string @The name of the rule.
---@param value string @The string value of the rule.
function api.SetRuleString(key, value) end

---Set a rule value for the server details displayed in the server browser.
---@param key string @The name of the rule.
---@param value number @The numerical value of the rule.
function api.SetRuleValue(key, value) end

---Add a data file and a corresponding CRC32 checksum to the data file loadout that connecting clients need to match.
---
---It can be used multiple times to set multiple checksums for the same data file.
---
---Note: If an empty string is provided for the checksum, a checksum will not be required for that data file.
---
---@param dataFilename string @The filename of the data file.
---@param checksumString string @A string with the CRC32 checksum required.
function api.AddDataFileRequirement(dataFilename, checksumString) end
