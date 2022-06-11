---@class TES3MP
local api

---Clear the last recorded topic changes for a player.
---
---This is used to initialize the sending of new PlayerTopic packets.
---@param pid integer @The player ID whose topic changes should be used.
function api.ClearTopicChanges(pid) end

---Get the number of indexes in a player's latest topic changes.
---@param pid integer @The player ID whose topic changes should be used.
---@return integer
function api.GetTopicChangesSize(pid) end

---Add a new topic to the topic changes for a player.
---@param pid integer @The player ID whose topic changes should be used.
---@param topicId string @The topicId of the topic.
function api.AddTopic(pid, topicId) end

---Get the topicId at a certain index in a player's latest topic changes.
---@param pid integer @The player ID whose topic changes should be used.
---@param index integer @The index of the topic.
---@return string
function api.GetTopicId(pid, index) end

---Send a PlayerTopic packet with a player's recorded topic changes.
---@param pid integer @The player ID whose topic changes should be used.
---@param sendToOtherPlayers boolean|nil @Whether this packet should be sent to players other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendTopicChanges(pid, sendToOtherPlayers, skipAttachedPlayer) end

---Play a certain animation on a player's character by sending a PlayerAnimation packet.
---@param pid integer @The player ID of the character playing the animation.
---@param groupname string @The groupname of the animation.
---@param mode integer @The mode of the animation.
---@param count integer @The number of times the animation should be played.
---@param persist boolean
function api.PlayAnimation(pid, groupname, mode, count, persist) end

---Play a certain sound for a player as spoken by their character by sending a PlayerSpeech packet.
---@param pid integer @The player ID of the character playing the sound.
---@param sound string @The path of the sound file.
function api.PlaySpeech(pid, sound) end

---@param pid integer
function api.InitializeTopicChanges(pid) end
