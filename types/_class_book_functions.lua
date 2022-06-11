---@class TES3MP
local api

---Clear the last recorded book changes for a player.
---
---This is used to initialize the sending of new PlayerBook packets.
---@param pid number @The player ID whose book changes should be used.
function api.ClearBookChanges(pid) end

---Get the number of indexes in a player's latest book changes.
---@param pid number @The player ID whose book changes should be used.
---@return number
function api.GetBookChangesSize(pid) end

---Add a new book to the book changes for a player.
---@param pid number @The player ID whose book changes should be used.
---@param bookId string @The bookId of the book.
function api.AddBook(pid, bookId) end

---Get the bookId at a certain index in a player's latest book changes.
---@param pid number @The player ID whose book changes should be used.
---@param index number @The index of the book.
---@return string
function api.GetBookId(pid, index) end

---Send a PlayerBook packet with a player's recorded book changes.
---@param pid number @The player ID whose book changes should be used.
---@param sendToOtherPlayers boolean|nil @Whether this packet should be sent to players other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendBookChanges(pid, sendToOtherPlayers, skipAttachedPlayer) end

---@param pid number
function api.InitializeBookChanges(pid) end
