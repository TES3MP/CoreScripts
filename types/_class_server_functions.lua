---@class TES3MP
local api

---Shut down the server.
---@param code number @The shutdown code.
function api.StopServer(code) end

---Kick a certain player from the server.
---@param pid number @The player ID.
function api.Kick(pid) end

---Ban a certain IP address from the server.
---@param ipAddress string @The IP address.
function api.BanAddress(ipAddress) end

---Unban a certain IP address from the server.
---@param ipAddress string @The IP address.
function api.UnbanAddress(ipAddress) end

---Get the type of the operating system used by the server.
---
---Note: Currently, the type can be "Windows", "Linux", "OS X" or "Unknown OS".
---@return string
function api.GetOperatingSystemType() end

---Get the architecture type used by the server.
---
---Note: Currently, the type can be "64-bit", "32-bit", "ARMv#" or "Unknown architecture".
---@return string
function api.GetArchitectureType() end

---Get the TES3MP version of the server.
---@return string
function api.GetServerVersion() end

---Get the protocol version of the server.
---@return string
function api.GetProtocolVersion() end

---Get the average ping of a certain player.
---@param pid number @The player ID.
---@return number
function api.GetAvgPing(pid) end

---Get the IP address of a certain player.
---@param pid number @The player ID.
---@return string
function api.GetIP(pid) end

---Get the port used by the server.
---@return number
function api.GetPort() end

---Get the maximum number of players.
---@return number
function api.GetMaxPlayers() end

---Checking if the server requires a password to connect.
---@return boolean
function api.HasPassword() end

---Get the plugin enforcement state of the server.
---
---If true, clients are required to use the same plugins as set for the server.
---@return boolean
function api.GetPluginEnforcementState() end

---Get the script error ignoring state of the server.
---
---If true, script errors will not crash the server.
---@return boolean
function api.GetScriptErrorIgnoringState() end

---Set the game mode of the server, as displayed in the server browser.
---@param gameMode string
function api.SetGameMode(gameMode) end

---Set the name of the server, as displayed in the server browser.
---@param name string @The new name.
function api.SetHostname(name) end

---Set the password required to join the server.
---@param password string @The password.
function api.SetServerPassword(password) end

---Set the plugin enforcement state of the server.
---
---If true, clients are required to use the same plugins as set for the server.
---@param state boolean @The new enforcement state.
function api.SetPluginEnforcementState(state) end

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

---Adds plugins to the internal server structure to validate players.
---@param pluginName string @Name with extension of the plugin or master file.
---@param hash string @Hash string
function api.AddPluginHash(pluginName, hash) end

---@return string
function api.GetModDir() end
