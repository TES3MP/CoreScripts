---@class TES3MP
local api

---Clear the last recorded spellbook changes for a player.
---
---This is used to initialize the sending of new PlayerSpellbook packets.
---@param pid integer @The player ID whose spellbook changes should be used.
function api.ClearSpellbookChanges(pid) end

---Clear the last recorded spells active changes for a player.
---
---This is used to initialize the sending of new PlayerSpellsActive packets.
---@param pid integer @The player ID whose spells active changes should be used.
function api.ClearSpellsActiveChanges(pid) end

---Clear the last recorded cooldown changes for a player.
---
---This is used to initialize the sending of new PlayerCooldown packets.
---@param pid integer @The player ID whose cooldown changes should be used.
function api.ClearCooldownChanges(pid) end

---Get the number of indexes in a player's latest spellbook changes.
---@param pid integer @The player ID whose spellbook changes should be used.
---@return integer @The number of indexes.
function api.GetSpellbookChangesSize(pid) end

---Get the action type used in a player's latest spellbook changes.
---@param pid integer @The player ID whose spellbook changes should be used.
---@return integer @The action type (0 for SET, 1 for ADD, 2 for REMOVE).
function api.GetSpellbookChangesAction(pid) end

---Get the number of indexes in a player's latest spells active changes.
---@param pid integer @The player ID whose spells active changes should be used.
---@return integer @The number of indexes for spells active changes.
function api.GetSpellsActiveChangesSize(pid) end

---Get the action type used in a player's latest spells active changes.
---@param pid integer @The player ID whose spells active changes should be used.
---@return integer @The action type (0 for SET, 1 for ADD, 2 for REMOVE).
function api.GetSpellsActiveChangesAction(pid) end

---Get the number of indexes in a player's latest cooldown changes.
---@param pid integer @The player ID whose cooldown changes should be used.
---@return integer @The number of indexes.
function api.GetCooldownChangesSize(pid) end

---Set the action type in a player's spellbook changes.
---@param pid integer @The player ID whose spellbook changes should be used.
---@param action string @The action (0 for SET, 1 for ADD, 2 for REMOVE).
function api.SetSpellbookChangesAction(pid, action) end

---Set the action type in a player's spells active changes.
---@param pid integer @The player ID whose spells active changes should be used.
---@param action string @The action (0 for SET, 1 for ADD, 2 for REMOVE).
function api.SetSpellsActiveChangesAction(pid, action) end

---Add a new spell to the spellbook changes for a player.
---@param pid integer @The player ID whose spellbook changes should be used.
---@param spellId string @The spellId of the spell.
function api.AddSpell(pid, spellId) end

---Add a new active spell to the spells active changes for a player, using the temporary effect values stored so far.
---@param pid integer @The player ID whose spells active changes should be used.
---@param spellId string @The spellId of the spell.
---@param displayName string @The displayName of the spell.
---@param stackingState boolean @Whether the spell should stack with other instances of itself.
function api.AddSpellActive(pid, spellId, displayName, stackingState) end

---Add a new effect to the next active spell that will be added to a player.
---@param pid integer @The player ID whose spells active changes should be used.
---@param effectId integer @The id of the effect.
---@param magnitude number @The magnitude of the effect.
---@param duration number @The duration of the effect.
---@param timeLeft number @The timeLeft for the effect.
---@param arg integer @The arg of the effect when applicable, e.g. the skill used for Fortify Skill or the attribute used for Fortify Attribute.
function api.AddSpellActiveEffect(pid, effectId, magnitude, duration, timeLeft, arg) end

---Add a new cooldown spell to the cooldown changes for a player.
---@param pid integer @The player ID whose cooldown changes should be used.
---@param spellId string @The spellId of the spell.
---@param startDay integer @The day on which the cooldown starts.
---@param startHour number @The hour at which the cooldown starts.
function api.AddCooldownSpell(pid, spellId, startDay, startHour) end

---Get the spell id at a certain index in a player's latest spellbook changes.
---@param pid integer @The player ID whose spellbook changes should be used.
---@param index integer @The index of the spell.
---@return string @The spell id.
function api.GetSpellId(pid, index) end

---Get the spell id at a certain index in a player's latest spells active changes.
---@param pid integer @The player ID whose spells active changes should be used.
---@param index integer @The index of the spell.
---@return string @The spell id.
function api.GetSpellsActiveId(pid, index) end

---Get the spell display name at a certain index in a player's latest spells active changes.
---@param pid integer @The player ID whose spells active changes should be used.
---@param index integer @The index of the spell.
---@return string @The spell display name.
function api.GetSpellsActiveDisplayName(pid, index) end

---Get the spell stacking state at a certain index in a player's latest spells active changes.
---@param pid integer @The player ID whose spells active changes should be used.
---@param index integer @The index of the spell.
---@return boolean @The spell stacking state.
function api.GetSpellsActiveStackingState(pid, index) end

---Get the number of effects at an index in a player's latest spells active changes.
---@param pid integer @The player ID whose spells active changes should be used.
---@param index integer @The index of the spell.
---@return integer @The number of effects.
function api.GetSpellsActiveEffectCount(pid, index) end

---Get the id for an effect index at a spell index in a player's latest spells active changes.
---@param pid integer @The player ID whose spells active changes should be used.
---@param spellIndex integer @The index of the spell.
---@param effectIndex integer @The index of the effect.
---@return integer @The id of the effect.
function api.GetSpellsActiveEffectId(pid, spellIndex, effectIndex) end

---Get the arg for an effect index at a spell index in a player's latest spells active changes.
---@param pid integer @The player ID whose spells active changes should be used.
---@param spellIndex integer @The index of the spell.
---@param effectIndex integer @The index of the effect.
---@return integer @The arg of the effect.
function api.GetSpellsActiveEffectArg(pid, spellIndex, effectIndex) end

---Get the magnitude for an effect index at a spell index in a player's latest spells active changes.
---@param pid integer @The player ID whose spells active changes should be used.
---@param spellIndex integer @The index of the spell.
---@param effectIndex integer @The index of the effect.
---@return number @The magnitude of the effect.
function api.GetSpellsActiveEffectMagnitude(pid, spellIndex, effectIndex) end

---Get the duration for an effect index at a spell index in a player's latest spells active changes.
---@param pid integer @The player ID whose spells active changes should be used.
---@param spellIndex integer @The index of the spell.
---@param effectIndex integer @The index of the effect.
---@return number @The duration of the effect.
function api.GetSpellsActiveEffectDuration(pid, spellIndex, effectIndex) end

---Get the time left for an effect index at a spell index in a player's latest spells active changes.
---@param pid integer @The player ID whose spells active changes should be used.
---@param spellIndex integer @The index of the spell.
---@param effectIndex integer @The index of the effect.
---@return number @The time left for the effect.
function api.GetSpellsActiveEffectTimeLeft(pid, spellIndex, effectIndex) end

---Check whether the spell at a certain index in a player's latest spells active changes has a player as its caster.
---@param pid integer @The player ID whose spells active changes should be used.
---@param index integer @The index of the spell.
---@return boolean @Whether a player is the caster of the spell.
function api.DoesSpellsActiveHavePlayerCaster(pid, index) end

---Get the player ID of the caster of the spell at a certain index in a player's latest spells active changes.
---@param pid integer @The player ID whose spells active changes should be used.
---@param index integer @The index of the spell.
---@return integer @The player ID of the caster.
function api.GetSpellsActiveCasterPid(pid, index) end

---Get the refId of the actor caster of the spell at a certain index in a player's latest spells active changes.
---@param pid integer @The player ID whose spells active changes should be used.
---@param index integer @The index of the spell.
---@return string @The refId of the caster.
function api.GetSpellsActiveCasterRefId(pid, index) end

---Get the refNum of the actor caster of the spell at a certain index in a player's latest spells active changes.
---@param pid integer @The player ID whose spells active changes should be used.
---@param index integer @The index of the spell.
---@return integer @The refNum of the caster.
function api.GetSpellsActiveCasterRefNum(pid, index) end

---Get the mpNum of the actor caster of the spell at a certain index in a player's latest spells active changes.
---@param pid integer @The player ID whose spells active changes should be used.
---@param index integer @The index of the spell.
---@return integer @The mpNum of the caster.
function api.GetSpellsActiveCasterMpNum(pid, index) end

---Get the spell id at a certain index in a player's latest cooldown changes.
---@param pid integer @The player ID whose cooldown changes should be used.
---@param index integer @The index of the cooldown spell.
---@return string @The spell id.
function api.GetCooldownSpellId(pid, index) end

---Get the starting day of the cooldown at a certain index in a player's latest cooldown changes.
---@param pid integer @The player ID whose cooldown changes should be used.
---@param index integer @The index of the cooldown spell.
---@return integer @The starting day of the cooldown.
function api.GetCooldownStartDay(pid, index) end

---Get the starting hour of the cooldown at a certain index in a player's latest cooldown changes.
---@param pid integer @The player ID whose cooldown changes should be used.
---@param index integer @The index of the cooldown spell.
---@return number @The starting hour of the cooldown.
function api.GetCooldownStartHour(pid, index) end

---Send a PlayerSpellbook packet with a player's recorded spellbook changes.
---@param pid integer @The player ID whose spellbook changes should be used.
---@param sendToOtherPlayers boolean|nil @Whether this packet should be sent to players other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendSpellbookChanges(pid, sendToOtherPlayers, skipAttachedPlayer) end

---Send a PlayerSpellsActive packet with a player's recorded spells active changes.
---@param pid integer @The player ID whose spells active changes should be used.
---@param sendToOtherPlayers boolean|nil @Whether this packet should be sent to players other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendSpellsActiveChanges(pid, sendToOtherPlayers, skipAttachedPlayer) end

---Send a PlayerCooldowns packet with a player's recorded cooldown changes.
---@param pid integer @The player ID whose cooldown changes should be used.
function api.SendCooldownChanges(pid) end
