---@class TES3MP
local api

---Send a message to a certain player.
---@param pid integer @The player ID.
---@param message string @The contents of the message.
---@param sendToOtherPlayers boolean|nil @Whether this packet should be sent to players other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendMessage(pid, message, sendToOtherPlayers, skipAttachedPlayer) end

---Remove all messages from chat for a certain player.
---@param pid integer @The player ID.
function api.CleanChatForPid(pid) end

---Remove all messages from chat for everyone on the server.
function api.CleanChat() end
