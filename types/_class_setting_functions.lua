---@class TES3MP
local api

---Set the difficulty for a player.
---
---This changes the difficulty for that player in the server memory, but does not by itself send a packet.
---@param pid number @The player ID.
---@param difficulty number @The difficulty.
function api.SetDifficulty(pid, difficulty) end

---Set the client log level enforced for a player.
---
---If you do not wish to enforce a log level, simply set enforcedLogLevel to -1
---@param pid number @The player ID.
---@param enforcedLogLevel number @The enforced log level.
function api.SetEnforcedLogLevel(pid, enforcedLogLevel) end

---Set the physics framerate for a player.
---
---This changes the physics framerate for that player in the server memory, but does not by itself send a packet.
---@param pid number @The player ID.
---@param physicsFramerate number @The physics framerate.
function api.SetPhysicsFramerate(pid, physicsFramerate) end

---Set whether the console is allowed for a player.
---
---This changes the console permission for that player in the server memory, but does not by itself send a packet.
---@param pid number @The player ID.
---@param state boolean @The console permission state.
function api.SetConsoleAllowed(pid, state) end

---Set whether resting in beds is allowed for a player.
---
---This changes the resting permission for that player in the server memory, but does not by itself send a packet.
---@param pid number @The player ID.
---@param state boolean @The resting permission state.
function api.SetBedRestAllowed(pid, state) end

---Set whether resting in the wilderness is allowed for a player.
---
---This changes the resting permission for that player in the server memory, but does not by itself send a packet.
---@param pid number @The player ID.
---@param state boolean @The resting permission state.
function api.SetWildernessRestAllowed(pid, state) end

---Set whether waiting is allowed for a player.
---
---This changes the waiting permission for that player in the server memory, but does not by itself send a packet.
---@param pid number @The player ID.
---@param state boolean @The waiting permission state.
function api.SetWaitAllowed(pid, state) end

---Send a PlayerSettings packet to the player affected by it.
---@param pid number @The player ID to send it to.
function api.SendSettings(pid) end
