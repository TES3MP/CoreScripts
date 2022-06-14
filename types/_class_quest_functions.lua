---@class TES3MP
local api

---Clear the last recorded journal changes for a player.
---
---This is used to initialize the sending of new PlayerJournal packets.
---@param pid integer @The player ID whose journal changes should be used.
function api.ClearJournalChanges(pid) end

---Get the number of indexes in a player's latest journal changes.
---@param pid integer @The player ID whose journal changes should be used.
---@return integer @The number of indexes.
function api.GetJournalChangesSize(pid) end

---Add a new journal item of type ENTRY to the journal changes for a player, with a specific timestamp.
---@param pid integer @The player ID whose journal changes should be used.
---@param quest string @The quest of the journal item.
---@param index integer @The quest index of the journal item.
---@param actorRefId string @The actor refId of the journal item.
function api.AddJournalEntry(pid, quest, index, actorRefId) end

---Add a new journal item of type ENTRY to the journal changes for a player, with a specific timestamp.
---@param pid integer @The player ID whose journal changes should be used.
---@param quest string @The quest of the journal item.
---@param index integer @The quest index of the journal item.
---@param actorRefId string @The actor refId of the journal item.
---@param daysPassed integer @The daysPassed for the journal item.
---@param month integer @The month for the journal item.
---@param day integer @The day of the month for the journal item.
function api.AddJournalEntryWithTimestamp(pid, quest, index, actorRefId, daysPassed, month, day) end

---Add a new journal item of type INDEX to the journal changes for a player.
---@param pid integer @The player ID whose journal changes should be used.
---@param quest string @The quest of the journal item.
---@param index integer @The quest index of the journal item.
function api.AddJournalIndex(pid, quest, index) end

---Set the reputation of a certain player.
---@param pid integer @The player ID.
---@param value integer @The reputation.
function api.SetReputation(pid, value) end

---Get the quest at a certain index in a player's latest journal changes.
---@param pid integer @The player ID whose journal changes should be used.
---@param index integer @The index of the journalItem.
---@return string @The quest.
function api.GetJournalItemQuest(pid, index) end

---Get the quest index at a certain index in a player's latest journal changes.
---@param pid integer @The player ID whose journal changes should be used.
---@param index integer @The index of the journalItem.
---@return integer @The quest index.
function api.GetJournalItemIndex(pid, index) end

---Get the journal item type at a certain index in a player's latest journal changes.
---@param pid integer @The player ID whose journal changes should be used.
---@param index integer @The index of the journalItem.
---@return integer @The type (0 for ENTRY, 1 for INDEX).
function api.GetJournalItemType(pid, index) end

---Get the actor refId at a certain index in a player's latest journal changes.
---
---Every journal change has an associated actor, which is usually the quest giver.
---@param pid integer @The player ID whose journal changes should be used.
---@param index integer @The index of the journalItem.
---@return string @The actor refId.
function api.GetJournalItemActorRefId(pid, index) end

---Get the a certain player's reputation.
---@param pid integer @The player ID.
---@return integer @The reputation.
function api.GetReputation(pid) end

---Send a PlayerJournal packet with a player's recorded journal changes.
---@param pid integer @The player ID whose journal changes should be used.
---@param sendToOtherPlayers boolean|nil @Whether this packet should be sent to players other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendJournalChanges(pid, sendToOtherPlayers, skipAttachedPlayer) end

---Send a PlayerReputation packet with a player's recorded reputation.
---@param pid integer @The player ID whose reputation should be used.
---@param sendToOtherPlayers boolean|nil @Whether this packet should be sent to players other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendReputation(pid, sendToOtherPlayers, skipAttachedPlayer) end
