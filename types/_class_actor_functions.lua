---@class TES3MP
local api

---Use the last actor list received by the server as the one being read.
function api.ReadReceivedActorList() end

---Use the temporary actor list stored for a cell as the one being read.
---
---This type of actor list is used to store actor positions and dynamic stats and is deleted when the cell is unloaded.
---@param cellDescription string @The description of the cell whose actor list should be read.
function api.ReadCellActorList(cellDescription) end

---Clear the data from the actor list stored on the server.
function api.ClearActorList() end

---Set the pid attached to the ActorList.
---@param pid integer @The player ID to whom the actor list should be attached.
function api.SetActorListPid(pid) end

---Take the contents of the read-only actor list last received by the server from a player and move its contents to the stored object list that can be sent by the server.
function api.CopyReceivedActorListToStore() end

---Get the number of indexes in the read actor list.
---@return integer @The number of indexes.
function api.GetActorListSize() end

---Get the action type used in the read actor list.
---@return string @The action type (0 for SET, 1 for ADD, 2 for REMOVE, 3 for REQUEST).
function api.GetActorListAction() end

---Get the cell description of the actor at a certain index in the read actor list.
---@param index integer @The index of the actor.
---@return string @The cell description.
function api.GetActorCell(index) end

---Get the refId of the actor at a certain index in the read actor list.
---@param index integer @The index of the actor.
---@return string @The refId.
function api.GetActorRefId(index) end

---Get the refNum of the actor at a certain index in the read actor list.
---@param index integer @The index of the actor.
---@return integer @The refNum.
function api.GetActorRefNum(index) end

---Get the mpNum of the actor at a certain index in the read actor list.
---@param index integer @The index of the actor.
---@return integer @The mpNum.
function api.GetActorMpNum(index) end

---Get the X position of the actor at a certain index in the read actor list.
---@param index integer @The index of the actor.
---@return number @The X position.
function api.GetActorPosX(index) end

---Get the Y position of the actor at a certain index in the read actor list.
---@param index integer @The index of the actor.
---@return number @The Y position.
function api.GetActorPosY(index) end

---Get the Z position of the actor at a certain index in the read actor list.
---@param index integer @The index of the actor.
---@return number @The Z position.
function api.GetActorPosZ(index) end

---Get the X rotation of the actor at a certain index in the read actor list.
---@param index integer @The index of the actor.
---@return number @The X rotation.
function api.GetActorRotX(index) end

---Get the Y rotation of the actor at a certain index in the read actor list.
---@param index integer @The index of the actor.
---@return number @The Y rotation.
function api.GetActorRotY(index) end

---Get the Z rotation of the actor at a certain index in the read actor list.
---@param index integer @The index of the actor.
---@return number @The Z rotation.
function api.GetActorRotZ(index) end

---Get the base health of the actor at a certain index in the read actor list.
---@param index integer @The index of the actor.
---@return number @The base health.
function api.GetActorHealthBase(index) end

---Get the current health of the actor at a certain index in the read actor list.
---@param index integer @The index of the actor.
---@return number @The current health.
function api.GetActorHealthCurrent(index) end

---Get the modified health of the actor at a certain index in the read actor list.
---@param index integer @The index of the actor.
---@return number @The modified health.
function api.GetActorHealthModified(index) end

---Get the base magicka of the actor at a certain index in the read actor list.
---@param index integer @The index of the actor.
---@return number @The base magicka.
function api.GetActorMagickaBase(index) end

---Get the current magicka of the actor at a certain index in the read actor list.
---@param index integer @The index of the actor.
---@return number @The current magicka.
function api.GetActorMagickaCurrent(index) end

---Get the modified magicka of the actor at a certain index in the read actor list.
---@param index integer @The index of the actor.
---@return number @The modified magicka.
function api.GetActorMagickaModified(index) end

---Get the base fatigue of the actor at a certain index in the read actor list.
---@param index integer @The index of the actor.
---@return number @The base fatigue.
function api.GetActorFatigueBase(index) end

---Get the current fatigue of the actor at a certain index in the read actor list.
---@param index integer @The index of the actor.
---@return number @The current fatigue.
function api.GetActorFatigueCurrent(index) end

---Get the modified fatigue of the actor at a certain index in the read actor list.
---@param index integer @The index of the actor.
---@return number @The modified fatigue.
function api.GetActorFatigueModified(index) end

---Get the refId of the item in a certain slot of the equipment of the actor at a certain index in the read actor list.
---@param index integer @The index of the actor.
---@param slot integer @The slot of the equipment item.
---@return string @The refId.
function api.GetActorEquipmentItemRefId(index, slot) end

---Get the count of the item in a certain slot of the equipment of the actor at a certain index in the read actor list.
---@param index integer @The index of the actor.
---@param slot integer @The slot of the equipment item.
---@return integer @The item count.
function api.GetActorEquipmentItemCount(index, slot) end

---Get the charge of the item in a certain slot of the equipment of the actor at a certain index in the read actor list.
---@param index integer @The index of the actor.
---@param slot integer @The slot of the equipment item.
---@return integer @The charge.
function api.GetActorEquipmentItemCharge(index, slot) end

---Get the enchantment charge of the item in a certain slot of the equipment of the actor at a certain index in the read actor list.
---@param index integer @The index of the actor.
---@param slot integer @The slot of the equipment item.
---@return number @The enchantment charge.
function api.GetActorEquipmentItemEnchantmentCharge(index, slot) end

---Check whether the killer of the actor at a certain index in the read actor list is a player.
---@param index integer @The index of the actor.
---@return boolean @Whether the actor was killed by a player.
function api.DoesActorHavePlayerKiller(index) end

---Get the player ID of the killer of the actor at a certain index in the read actor list.
---@param index integer @The index of the actor.
---@return integer @The player ID of the killer.
function api.GetActorKillerPid(index) end

---Get the refId of the actor killer of the actor at a certain index in the read actor list.
---@param index integer @The index of the actor.
---@return string @The refId of the killer.
function api.GetActorKillerRefId(index) end

---Get the refNum of the actor killer of the actor at a certain index in the read actor list.
---@param index integer @The index of the actor.
---@return integer @The refNum of the killer.
function api.GetActorKillerRefNum(index) end

---Get the mpNum of the actor killer of the actor at a certain index in the read actor list.
---@param index integer @The index of the actor.
---@return integer @The mpNum of the killer.
function api.GetActorKillerMpNum(index) end

---Get the name of the actor killer of the actor at a certain index in the read actor list.
---@param index integer @The index of the actor.
---@return string @The name of the killer.
function api.GetActorKillerName(index) end

---Get the deathState of the actor at a certain index in the read actor list.
---@param index integer @The index of the actor.
---@return integer @The deathState.
function api.GetActorDeathState(index) end

---Get the number of indexes in an actor's latest spells active changes.
---@param actorIndex integer @The index of the actor.
---@return integer @The number of indexes for spells active changes.
function api.GetActorSpellsActiveChangesSize(actorIndex) end

---Get the action type used in an actor's latest spells active changes.
---@param actorIndex integer @The index of the actor.
---@return integer @The action type (0 for SET, 1 for ADD, 2 for REMOVE).
function api.GetActorSpellsActiveChangesAction(actorIndex) end

---Get the spell id at a certain index in an actor's latest spells active changes.
---@param actorIndex integer @The index of the actor.
---@param spellIndex integer @The index of the spell.
---@return string @The spell id.
function api.GetActorSpellsActiveId(actorIndex, spellIndex) end

---Get the spell display name at a certain index in an actor's latest spells active changes.
---@param actorIndex integer @The index of the actor.
---@param spellIndex integer @The index of the spell.
---@return string @The spell display name.
function api.GetActorSpellsActiveDisplayName(actorIndex, spellIndex) end

---Get the spell stacking state at a certain index in an actor's latest spells active changes.
---@param actorIndex integer @The index of the actor.
---@param spellIndex integer @The index of the spell.
---@return boolean @The spell stacking state.
function api.GetActorSpellsActiveStackingState(actorIndex, spellIndex) end

---Get the number of effects at an index in an actor's latest spells active changes.
---@param actorIndex integer @The index of the actor.
---@param spellIndex integer @The index of the spell.
---@return integer @The number of effects.
function api.GetActorSpellsActiveEffectCount(actorIndex, spellIndex) end

---Get the id for an effect index at a spell index in an actor's latest spells active changes.
---@param actorIndex integer @The index of the actor.
---@param spellIndex integer @The index of the spell.
---@param effectIndex integer @The index of the effect.
---@return integer @The id of the effect.
function api.GetActorSpellsActiveEffectId(actorIndex, spellIndex, effectIndex) end

---Get the arg for an effect index at a spell index in an actor's latest spells active changes.
---@param actorIndex integer @The index of the actor.
---@param spellIndex integer @The index of the spell.
---@param effectIndex integer @The index of the effect.
---@return integer @The arg of the effect.
function api.GetActorSpellsActiveEffectArg(actorIndex, spellIndex, effectIndex) end

---Get the magnitude for an effect index at a spell index in an actor's latest spells active changes.
---@param actorIndex integer @The index of the actor.
---@param spellIndex integer @The index of the spell.
---@param effectIndex integer @The index of the effect.
---@return number @The magnitude of the effect.
function api.GetActorSpellsActiveEffectMagnitude(actorIndex, spellIndex, effectIndex) end

---Get the duration for an effect index at a spell index in an actor's latest spells active changes.
---@param actorIndex integer @The index of the actor.
---@param spellIndex integer @The index of the spell.
---@param effectIndex integer @The index of the effect.
---@return number @The duration of the effect.
function api.GetActorSpellsActiveEffectDuration(actorIndex, spellIndex, effectIndex) end

---Get the time left for an effect index at a spell index in an actor's latest spells active changes.
---@param actorIndex integer @The index of the actor.
---@param spellIndex integer @The index of the spell.
---@param effectIndex integer @The index of the effect.
---@return number @The time left for the effect.
function api.GetActorSpellsActiveEffectTimeLeft(actorIndex, spellIndex, effectIndex) end

---Check whether the spell at a certain index in an actor's latest spells active changes has a player as its caster.
---@param actorIndex integer @The index of the actor.
---@param spellIndex integer @The index of the spell.
---@return boolean @Whether a player is the caster of the spell.
function api.DoesActorSpellsActiveHavePlayerCaster(actorIndex, spellIndex) end

---Get the player ID of the caster of the spell at a certain index in an actor's latest spells active changes.
---@param actorIndex integer @The index of the actor.
---@param spellIndex integer @The index of the spell.
---@return integer @The player ID of the caster.
function api.GetActorSpellsActiveCasterPid(actorIndex, spellIndex) end

---Get the refId of the actor caster of the spell at a certain index in an actor's latest spells active changes.
---@param actorIndex integer @The index of the actor.
---@param spellIndex integer @The index of the spell.
---@return string @The refId of the caster.
function api.GetActorSpellsActiveCasterRefId(actorIndex, spellIndex) end

---Get the refNum of the actor caster of the spell at a certain index in an actor's latest spells active changes.
---@param actorIndex integer @The index of the actor.
---@param spellIndex integer @The index of the spell.
---@return integer @The refNum of the caster.
function api.GetActorSpellsActiveCasterRefNum(actorIndex, spellIndex) end

---Get the mpNum of the actor caster of the spell at a certain index in an actor's latest spells active changes.
---@param actorIndex integer @The index of the actor.
---@param spellIndex integer @The index of the spell.
---@return integer @The mpNum of the caster.
function api.GetActorSpellsActiveCasterMpNum(actorIndex, spellIndex) end

---Check whether there is any positional data for the actor at a certain index in the read actor list.
---
---This is only useful when reading the actor list data recorded for a particular cell.
---@param index integer @The index of the actor.
---@return boolean @Whether the read actor list contains positional data.
function api.DoesActorHavePosition(index) end

---Check whether there is any dynamic stats data for the actor at a certain index in the read actor list.
---
---This is only useful when reading the actor list data recorded for a particular cell.
---@param index integer @The index of the actor.
---@return boolean @Whether the read actor list contains dynamic stats data.
function api.DoesActorHaveStatsDynamic(index) end

---Set the cell of the temporary actor list stored on the server.
---
---The cell is determined to be an exterior cell if it fits the pattern of a number followed by a comma followed by another number.
---@param cellDescription string @The description of the cell.
function api.SetActorListCell(cellDescription) end

---Set the action type of the temporary actor list stored on the server.
---@param action string @The action type (0 for SET, 1 for ADD, 2 for REMOVE, 3 for REQUEST).
function api.SetActorListAction(action) end

---Set the cell of the temporary actor stored on the server.
---
---Used for ActorCellChange packets, where a specific actor's cell now differs from that of the actor list.
---
---The cell is determined to be an exterior cell if it fits the pattern of a number followed by a comma followed by another number.
---@param cellDescription string @The description of the cell.
function api.SetActorCell(cellDescription) end

---Set the refId of the temporary actor stored on the server.
---@param refId string @The refId.
function api.SetActorRefId(refId) end

---Set the refNum of the temporary actor stored on the server.
---@param refNum integer @The refNum.
function api.SetActorRefNum(refNum) end

---Set the mpNum of the temporary actor stored on the server.
---@param mpNum integer @The mpNum.
function api.SetActorMpNum(mpNum) end

---Set the position of the temporary actor stored on the server.
---@param x number @The X position.
---@param y number @The Y position.
---@param z number @The Z position.
function api.SetActorPosition(x, y, z) end

---Set the rotation of the temporary actor stored on the server.
---@param x number @The X rotation.
---@param y number @The Y rotation.
---@param z number @The Z rotation.
function api.SetActorRotation(x, y, z) end

---Set the base health of the temporary actor stored on the server.
---@param value number @The new value.
function api.SetActorHealthBase(value) end

---Set the current health of the temporary actor stored on the server.
---@param value number @The new value.
function api.SetActorHealthCurrent(value) end

---Set the modified health of the temporary actor stored on the server.
---@param value number @The new value.
function api.SetActorHealthModified(value) end

---Set the base magicka of the temporary actor stored on the server.
---@param value number @The new value.
function api.SetActorMagickaBase(value) end

---Set the current magicka of the temporary actor stored on the server.
---@param value number @The new value.
function api.SetActorMagickaCurrent(value) end

---Set the modified magicka of the temporary actor stored on the server.
---@param value number @The new value.
function api.SetActorMagickaModified(value) end

---Set the base fatigue of the temporary actor stored on the server.
---@param value number @The new value.
function api.SetActorFatigueBase(value) end

---Set the current fatigue of the temporary actor stored on the server.
---@param value number @The new value.
function api.SetActorFatigueCurrent(value) end

---Set the modified fatigue of the temporary actor stored on the server.
---@param value number @The new value.
function api.SetActorFatigueModified(value) end

---Set the sound of the temporary actor stored on the server.
---@param sound string @The sound.
function api.SetActorSound(sound) end

---Set the deathState of the temporary actor stored on the server.
---@param deathState integer @The deathState.
function api.SetActorDeathState(deathState) end

---Set whether the death of the temporary actor stored on the server should be instant or not.
---@param isInstant boolean @Whether the death should be instant.
function api.SetActorDeathInstant(isInstant) end

---Set the action type in the spells active changes of the temporary actor stored on the server.
---@param action string @The action (0 for SET, 1 for ADD, 2 for REMOVE).
function api.SetActorSpellsActiveAction(action) end

---Set the AI action of the temporary actor stored on the server.
---@param action integer @The new action.
function api.SetActorAIAction(action) end

---Set a player as the AI target of the temporary actor stored on the server.
---@param pid integer @The player ID.
function api.SetActorAITargetToPlayer(pid) end

---Set another object as the AI target of the temporary actor stored on the server.
---@param refNum integer @The refNum of the target object.
---@param mpNum integer @The mpNum of the target object.
function api.SetActorAITargetToObject(refNum, mpNum) end

---Set the coordinates for the AI package associated with the current AI action.
---@param x number @The X coordinate.
---@param y number @The Y coordinate.
---@param z number @The Z coordinate.
function api.SetActorAICoordinates(x, y, z) end

---Set the distance of the AI package associated with the current AI action.
---@param distance integer @The distance of the package.
function api.SetActorAIDistance(distance) end

---Set the duration of the AI package associated with the current AI action.
---@param duration integer @The duration of the package.
function api.SetActorAIDuration(duration) end

---Set whether the current AI package should be repeated.
---
---Note: This only has an effect on the WANDER package.
---@param shouldRepeat boolean @Whether the package should be repeated.
function api.SetActorAIRepetition(shouldRepeat) end

---Equip an item in a certain slot of the equipment of the temporary actor stored on the server.
---@param slot integer @The equipment slot.
---@param refId string @The refId of the item.
---@param count integer @The count of the item.
---@param charge integer @The charge of the item.
---@param enchantmentCharge number @The enchantment charge of the item.
function api.EquipActorItem(slot, refId, count, charge, enchantmentCharge) end

---Unequip the item in a certain slot of the equipment of the temporary actor stored on the server.
---@param slot integer @The equipment slot.
function api.UnequipActorItem(slot) end

---Add a new active spell to the spells active changes for the temporary actor stored, on the server, using the temporary effect values stored so far.
---@param spellId string @The spellId of the spell.
---@param displayName string @The displayName of the spell.
---@param stackingState boolean @Whether the spell should stack with other instances of itself.
function api.AddActorSpellActive(spellId, displayName, stackingState) end

---Add a new effect to the next active spell that will be added to the temporary actor stored on the server.
---@param effectId integer @The id of the effect.
---@param magnitude number @The magnitude of the effect.
---@param duration number @The duration of the effect.
---@param timeLeft number @The timeLeft for the effect.
---@param arg integer @The arg of the effect when applicable, e.g. the skill used for Fortify Skill or the attribute used for Fortify Attribute.
function api.AddActorSpellActiveEffect(effectId, magnitude, duration, timeLeft, arg) end

---Add a copy of the server's temporary actor to the server's temporary actor list.
---
---In the process, the server's temporary actor will automatically be cleared so a new one can be set up.
function api.AddActor() end

---Send an ActorList packet.
---
---It is sent only to the player for whom the current actor list was initialized.
function api.SendActorList() end

---Send an ActorAuthority packet.
---
---The player for whom the current actor list was initialized is recorded in the server memory as the new actor authority for the actor list's cell.
---
---The packet is sent to that player as well as all other players who have the cell loaded.
function api.SendActorAuthority() end

---Send an ActorPosition packet.
---@param sendToOtherVisitors boolean|nil @Whether this packet should be sent to cell visitors other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendActorPosition(sendToOtherVisitors, skipAttachedPlayer) end

---Send an ActorStatsDynamic packet.
---@param sendToOtherVisitors boolean|nil @Whether this packet should be sent to cell visitors other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendActorStatsDynamic(sendToOtherVisitors, skipAttachedPlayer) end

---Send an ActorEquipment packet.
---@param sendToOtherVisitors boolean|nil @Whether this packet should be sent to cell visitors other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendActorEquipment(sendToOtherVisitors, skipAttachedPlayer) end

---Send an ActorSpellsActive packet.
---@param sendToOtherVisitors boolean|nil @Whether this packet should be sent to cell visitors other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendActorSpellsActiveChanges(sendToOtherVisitors, skipAttachedPlayer) end

---Send an ActorSpeech packet.
---@param sendToOtherVisitors boolean|nil @Whether this packet should be sent to cell visitors other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendActorSpeech(sendToOtherVisitors, skipAttachedPlayer) end

---Send an ActorDeath packet.
---@param sendToOtherVisitors boolean|nil @Whether this packet should be sent to cell visitors other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendActorDeath(sendToOtherVisitors, skipAttachedPlayer) end

---Send an ActorAI packet.
---@param sendToOtherVisitors boolean|nil @Whether this packet should be sent to cell visitors other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendActorAI(sendToOtherVisitors, skipAttachedPlayer) end

---Send an ActorCellChange packet.
---@param sendToOtherVisitors boolean|nil @Whether this packet should be sent to cell visitors other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendActorCellChange(sendToOtherVisitors, skipAttachedPlayer) end
