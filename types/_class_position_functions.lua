---@class TES3MP
local api

---Get the X position of a player.
---@param pid integer @The player ID.
---@return number @The X position.
function api.GetPosX(pid) end

---Get the Y position of a player.
---@param pid integer @The player ID.
---@return number @The Y position.
function api.GetPosY(pid) end

---Get the Z position of a player.
---@param pid integer @The player ID.
---@return number @The Z position.
function api.GetPosZ(pid) end

---Get the X position of a player from before their latest cell change.
---@param pid integer @The player ID.
---@return number @The X position.
function api.GetPreviousCellPosX(pid) end

---Get the Y position of a player from before their latest cell change.
---@param pid integer @The player ID.
---@return number @The Y position.
function api.GetPreviousCellPosY(pid) end

---Get the Z position of a player from before their latest cell change.
---@param pid integer @The player ID.
---@return number @The Z position.
function api.GetPreviousCellPosZ(pid) end

---Get the X rotation of a player.
---@param pid integer @The player ID.
---@return number @The X rotation.
function api.GetRotX(pid) end

---Get the Z rotation of a player.
---@param pid integer @The player ID.
---@return number @The Z rotation.
function api.GetRotZ(pid) end

---Set the position of a player.
---
---This changes the positional coordinates recorded for that player in the server memory, but does not by itself send a packet.
---@param pid integer @The player ID.
---@param x number @The X position.
---@param y number @The Y position.
---@param z number @The Z position.
function api.SetPos(pid, x, y, z) end

---Set the rotation of a player.
---
---This changes the rotational coordinates recorded for that player in the server memory, but does not by itself send a packet.
---
---A player's Y rotation is always 0, which is why there is no Y rotation parameter.
---@param pid integer @The player ID.
---@param x number @The X position.
---@param z number @The Z position.
function api.SetRot(pid, x, z) end

---Set the momentum of a player.
---
---This changes the coordinates recorded for that player's momentum in the server memory, but does not by itself send a packet.
---@param pid integer @The player ID.
---@param x number @The X momentum.
---@param y number @The Y momentum.
---@param z number @The Z momentum.
function api.SetMomentum(pid, x, y, z) end

---Send a PlayerPosition packet about a player.
---
---It is only sent to the affected player.
---@param pid integer @The player ID.
function api.SendPos(pid) end

---Send a PlayerMomentum packet about a player.
---
---It is only sent to the affected player.
---@param pid integer @The player ID.
function api.SendMomentum(pid) end
