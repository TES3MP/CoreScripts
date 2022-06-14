---@class TES3MP
local api

---Set the difficulty for a player.
---
---This changes the difficulty for that player in the server memory, but does not by itself send a packet.
---@param pid integer @The player ID.
---@param difficulty integer @The difficulty.
function api.SetDifficulty(pid, difficulty) end

---Set the client log level enforced for a player.
---
---This changes the enforced log level for that player in the server memory, but does not by itself send a packet.
---
---Enforcing a certain log level is necessary to prevent players from learning information from their console window that they are otherwise unable to obtain, such as the locations of other players.
---
---If you do not wish to enforce a log level, simply set enforcedLogLevel to -1
---@param pid integer @The player ID.
---@param enforcedLogLevel integer @The enforced log level.
function api.SetEnforcedLogLevel(pid, enforcedLogLevel) end

---Set the physics framerate for a player.
---
---This changes the physics framerate for that player in the server memory, but does not by itself send a packet.
---@param pid integer @The player ID.
---@param physicsFramerate number @The physics framerate.
function api.SetPhysicsFramerate(pid, physicsFramerate) end

---Set whether the console is allowed for a player.
---
---This changes the console permission for that player in the server memory, but does not by itself send a packet.
---@param pid integer @The player ID.
---@param state boolean @The console permission state.
function api.SetConsoleAllowed(pid, state) end

---Set whether resting in beds is allowed for a player.
---
---This changes the resting permission for that player in the server memory, but does not by itself send a packet.
---@param pid integer @The player ID.
---@param state boolean @The resting permission state.
function api.SetBedRestAllowed(pid, state) end

---Set whether resting in the wilderness is allowed for a player.
---
---This changes the resting permission for that player in the server memory, but does not by itself send a packet.
---@param pid integer @The player ID.
---@param state boolean @The resting permission state.
function api.SetWildernessRestAllowed(pid, state) end

---Set whether waiting is allowed for a player.
---
---This changes the waiting permission for that player in the server memory, but does not by itself send a packet.
---@param pid integer @The player ID.
---@param state boolean @The waiting permission state.
function api.SetWaitAllowed(pid, state) end

---Set value for a game setting.
---
---This overrides the setting value set in OpenMW Launcher. Only applies to the Game category.
---@param pid integer @The player ID.
---@param setting string @Name of a setting in the Game category
---@param value string @Value of the setting (as a string)
function api.SetGameSettingValue(pid, setting, value) end

---Clear the Game setting values stored for a player.
---
---Clear any changes done by SetGameSettingValue()
---@param pid integer @The player ID.
function api.ClearGameSettingValues(pid) end

---Set value for a VR setting.
---
---This overrides the setting value set in OpenMW Launcher. Only applies to the VR category.
---@param pid integer @The player ID.
---@param setting string @Name of a setting in the VR category
---@param value string @Value of the setting (as a string)
function api.SetVRSettingValue(pid, setting, value) end

---Clear the VR setting values stored for a player.
---
---Clear any changes done by SetVRSettingValue()
---@param pid integer @The player ID.
function api.ClearVRSettingValues(pid) end

---Send a PlayerSettings packet to the player affected by it.
---@param pid integer @The player ID to send it to.
function api.SendSettings(pid) end
