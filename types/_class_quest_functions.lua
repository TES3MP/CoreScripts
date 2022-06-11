---@class TES3MP
local api

---Clear the last recorded journal changes for a player.
---
---This is used to initialize the sending of new PlayerJournal packets.
---@param pid number @The player ID whose journal changes should be used.
function api.ClearJournalChanges(pid) end

---Clear the last recorded kill count changes for a player.
---
---This is used to initialize the sending of new WorldKillCount packets.
---@param pid number @The player ID whose kill count changes should be used.
function api.ClearKillChanges(pid) end

---Get the number of indexes in a player's latest journal changes.
---@param pid number @The player ID whose journal changes should be used.
---@return number
function api.GetJournalChangesSize(pid) end

---Get the number of indexes in a player's latest kill count changes.
---@param pid number @The player ID whose kill count changes should be used.
---@return number
function api.GetKillChangesSize(pid) end

---Add a new journal item of type ENTRY to the journal changes for a player, with a specific timestamp.
---@param pid number @The player ID whose journal changes should be used.
---@param quest string @The quest of the journal item.
---@param index number @The quest index of the journal item.
---@param actorRefId string @The actor refId of the journal item.
function api.AddJournalEntry(pid, quest, index, actorRefId) end

---Add a new journal item of type ENTRY to the journal changes for a player, with a specific timestamp.
---@param pid number @The player ID whose journal changes should be used.
---@param quest string @The quest of the journal item.
---@param index number @The quest index of the journal item.
---@param actorRefId string @The actor refId of the journal item.
---@param daysPassed number
---@param month number
---@param day number
function api.AddJournalEntryWithTimestamp(pid, quest, index, actorRefId, daysPassed, month, day) end

---Add a new journal item of type INDEX to the journal changes for a player.
---@param pid number @The player ID whose journal changes should be used.
---@param quest string @The quest of the journal item.
---@param index number @The quest index of the journal item.
function api.AddJournalIndex(pid, quest, index) end

---Add a new kill count to the kill count changes for a player.
---@param pid number @The player ID whose kill count changes should be used.
---@param refId string @The refId of the kill count.
---@param number number @The number of kills in the kill count.
function api.AddKill(pid, refId, number) end

---Set the reputation of a certain player.
---@param pid number @The player ID.
---@param value number @The reputation.
function api.SetReputation(pid, value) end

---Get the quest at a certain index in a player's latest journal changes.
---@param pid number @The player ID whose journal changes should be used.
---@param index number @The index of the journalItem.
---@return string
function api.GetJournalItemQuest(pid, index) end

---Get the quest index at a certain index in a player's latest journal changes.
---@param pid number @The player ID whose journal changes should be used.
---@param index number @The index of the journalItem.
---@return number
function api.GetJournalItemIndex(pid, index) end

---Get the journal item type at a certain index in a player's latest journal changes.
---@param pid number @The player ID whose journal changes should be used.
---@param index number @The index of the journalItem.
---@return number
function api.GetJournalItemType(pid, index) end

---Get the actor refId at a certain index in a player's latest journal changes.
---
---Every journal change has an associated actor, which is usually the quest giver.
---@param pid number @The player ID whose journal changes should be used.
---@param index number @The index of the journalItem.
---@return string
function api.GetJournalItemActorRefId(pid, index) end

---Get the refId at a certain index in a player's latest kill count changes.
---@param pid number @The player ID whose kill count changes should be used.
---@param index number @The index of the kill count.
---@return string
function api.GetKillRefId(pid, index) end

---Get the number of kills at a certain index in a player's latest kill count changes.
---@param pid number @The player ID whose kill count changes should be used.
---@param index number @The index of the kill count.
---@return number
function api.GetKillNumber(pid, index) end

---Get the a certain player's reputation.
---@param pid number @The player ID.
---@return number
function api.GetReputation(pid) end

---Send a PlayerJournal packet with a player's recorded journal changes.
---@param pid number @The player ID whose journal changes should be used.
---@param sendToOtherPlayers boolean|nil @Whether this packet should be sent to players other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendJournalChanges(pid, sendToOtherPlayers, skipAttachedPlayer) end

---Send a WorldKillCount packet with a player's recorded kill count changes.
---@param pid number @The player ID whose kill count changes should be used.
---@param sendToOtherPlayers boolean|nil @Whether this packet should be sent to players other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendKillChanges(pid, sendToOtherPlayers, skipAttachedPlayer) end

---Send a PlayerReputation packet with a player's recorded reputation.
---@param pid number @The player ID whose reputation should be used.
---@param sendToOtherPlayers boolean|nil @Whether this packet should be sent to players other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendReputation(pid, sendToOtherPlayers, skipAttachedPlayer) end

---@param pid number
function api.InitializeJournalChanges(pid) end

---@param pid number
function api.InitializeKillChanges(pid) end
