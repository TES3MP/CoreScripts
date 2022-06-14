---@class TES3MP
local api

---Get the number of indexes in a player's latest cell state changes.
---@param pid integer @The player ID whose cell state changes should be used.
---@return integer @The number of indexes.
function api.GetCellStateChangesSize(pid) end

---Get the cell state type at a certain index in a player's latest cell state changes.
---@param pid integer @The player ID whose cell state changes should be used.
---@param index integer @The index of the cell state.
---@return integer @The cell state type (0 for LOAD, 1 for UNLOAD).
function api.GetCellStateType(pid, index) end

---Get the cell description at a certain index in a player's latest cell state changes.
---@param pid integer @The player ID whose cell state changes should be used.
---@param index integer @The index of the cell state.
---@return string @The cell description.
function api.GetCellStateDescription(pid, index) end

---Get the cell description of a player's cell.
---@param pid integer @The player ID.
---@return string @The cell description.
function api.GetCell(pid) end

---Get the X coordinate of the player's exterior cell.
---@param pid integer @The player ID.
---@return integer @The X coordinate of the cell.
function api.GetExteriorX(pid) end

---Get the Y coordinate of the player's exterior cell.
---@param pid integer @The player ID.
---@return integer @The Y coordinate of the cell.
function api.GetExteriorY(pid) end

---Check whether the player is in an exterior cell or not.
---@param pid integer @The player ID.
---@return boolean @Whether the player is in an exterior cell.
function api.IsInExterior(pid) end

---Get the region of the player's exterior cell.
---
---A blank value will be returned if the player is in an interior.
---@param pid integer @The player ID.
---@return string @The region.
function api.GetRegion(pid) end

---Check whether the player's last cell change has involved a region change.
---@param pid integer @The player ID.
---@return boolean @Whether the player has changed their region.
function api.IsChangingRegion(pid) end

---Set the cell of a player.
---
---This changes the cell recorded for that player in the server memory, but does not by itself send a packet.
---
---The cell is determined to be an exterior cell if it fits the pattern of a number followed by a comma followed by another number.
---@param pid integer @The player ID.
---@param cellDescription string @The cell description.
function api.SetCell(pid, cellDescription) end

---Set the cell of a player to an exterior cell.
---
---This changes the cell recorded for that player in the server memory, but does not by itself send a packet.
---@param pid integer @The player ID.
---@param x integer @The X coordinate of the cell.
---@param y integer @The Y coordinate of the cell.
function api.SetExteriorCell(pid, x, y) end

---Send a PlayerCellChange packet about a player.
---
---It is only sent to the affected player.
---@param pid integer @The player ID.
function api.SendCell(pid) end
