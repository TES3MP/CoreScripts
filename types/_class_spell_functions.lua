---@class TES3MP
local api

---Clear the last recorded spellbook changes for a player.
---
---This is used to initialize the sending of new PlayerSpellbook packets.
---@param pid integer @The player ID whose spellbook changes should be used.
function api.ClearSpellbookChanges(pid) end

---Get the number of indexes in a player's latest spellbook changes.
---@param pid integer @The player ID whose spellbook changes should be used.
---@return integer
function api.GetSpellbookChangesSize(pid) end

---Get the action type used in a player's latest spellbook changes.
---@param pid integer @The player ID whose spellbook changes should be used.
---@return integer
function api.GetSpellbookChangesAction(pid) end

---Set the action type in a player's spellbook changes.
---@param pid integer @The player ID whose spellbook changes should be used.
---@param action string @The action (0 for SET, 1 for ADD, 2 for REMOVE).
function api.SetSpellbookChangesAction(pid, action) end

---Add a new spell to the spellbook changes for a player.
---@param pid integer @The player ID whose spellbook changes should be used.
---@param spellId string @The spellId of the spell.
function api.AddSpell(pid, spellId) end

---Get the spellId at a certain index in a player's latest spellbook changes.
---@param pid integer @The player ID whose spellbook changes should be used.
---@param index integer @The index of the spell.
---@return string
function api.GetSpellId(pid, index) end

---Send a PlayerSpellbook packet with a player's recorded spellbook changes.
---@param pid integer @The player ID whose spellbook changes should be used.
---@param sendToOtherPlayers boolean|nil @Whether this packet should be sent to players other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendSpellbookChanges(pid, sendToOtherPlayers, skipAttachedPlayer) end

---@param pid integer
function api.InitializeSpellbookChanges(pid) end
