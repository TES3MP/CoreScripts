---@class TES3MP
local api

---Clear the last recorded faction changes for a player.
---
---This is used to initialize the sending of new PlayerFaction packets.
---@param pid number @The player ID whose faction changes should be used.
function api.ClearFactionChanges(pid) end

---Get the number of indexes in a player's latest faction changes.
---@param pid number @The player ID whose faction changes should be used.
---@return number
function api.GetFactionChangesSize(pid) end

---Get the action type used in a player's latest faction changes.
---@param pid number @The player ID whose faction changes should be used.
---@return string
function api.GetFactionChangesAction(pid) end

---Get the factionId at a certain index in a player's latest faction changes.
---@param pid number @The player ID whose faction changes should be used.
---@param index number @The index of the faction.
---@return string
function api.GetFactionId(pid, index) end

---Get the rank at a certain index in a player's latest faction changes.
---@param pid number @The player ID whose faction changes should be used.
---@param index number @The index of the faction.
---@return number
function api.GetFactionRank(pid, index) end

---Get the expulsion state at a certain index in a player's latest faction changes.
---@param pid number @The player ID whose faction changes should be used.
---@param index number @The index of the faction.
---@return boolean
function api.GetFactionExpulsionState(pid, index) end

---Get the reputation at a certain index in a player's latest faction changes.
---@param pid number @The player ID whose faction changes should be used.
---@param index number @The index of the faction.
---@return number
function api.GetFactionReputation(pid, index) end

---Set the action type in a player's faction changes.
---@param pid number @The player ID whose faction changes should be used.
---@param action string @The action (0 for RANK, 1 for EXPULSION, 2 for REPUTATION).
function api.SetFactionChangesAction(pid, action) end

---Set the factionId of the temporary faction stored on the server.
---@param factionId string @The factionId.
function api.SetFactionId(factionId) end

---Set the rank of the temporary faction stored on the server.
---@param rank number @The rank.
function api.SetFactionRank(rank) end

---Set the expulsion state of the temporary faction stored on the server.
---@param expulsionState boolean @The expulsion state.
function api.SetFactionExpulsionState(expulsionState) end

---Set the reputation of the temporary faction stored on the server.
---@param reputation number @The reputation.
function api.SetFactionReputation(reputation) end

---Add the server's temporary faction to the faction changes for a player.
---
---In the process, the server's temporary faction will automatically be cleared so a new one can be set up.
---@param pid number @The player ID whose faction changes should be used.
function api.AddFaction(pid) end

---Send a PlayerFaction packet with a player's recorded faction changes.
---@param pid number @The player ID whose faction changes should be used.
---@param sendToOtherPlayers boolean|nil @Whether this packet should be sent to players other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendFactionChanges(pid, sendToOtherPlayers, skipAttachedPlayer) end

---@param pid number
function api.InitializeFactionChanges(pid) end
