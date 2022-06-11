---@class TES3MP
local api

---Get the scale of a player.
---@param pid integer @The player ID.
---@return integer
function api.GetScale(pid) end

---Check whether a player is a werewolf.
---
---This is based on the last PlayerShapeshift packet received or sent for that player.
---@param pid integer @The player ID.
---@return boolean
function api.IsWerewolf(pid) end

---Get the refId of the creature the player is disguised as.
---@param pid integer @The player ID.
---@return string
function api.GetCreatureRefId(pid) end

---Check whether a player's name is replaced by that of the creature they are disguised as when other players hover over them.
---
---This is based on the last PlayerShapeshift packet received or sent for that player.
---@param pid integer @The player ID.
---@return boolean
function api.GetCreatureNameDisplayState(pid) end

---Set the scale of a player.
---
---This changes the scale recorded for that player in the server memory, but does not by itself send a packet.
---@param pid integer @The player ID.
---@param scale integer @The new scale.
function api.SetScale(pid, scale) end

---Set the werewolf state of a player.
---
---This changes the werewolf state recorded for that player in the server memory, but does not by itself send a packet.
---@param pid integer @The player ID.
---@param isWerewolf boolean @The new werewolf state.
function api.SetWerewolfState(pid, isWerewolf) end

---Set the refId of the creature a player is disguised as.
---
---This changes the creature refId recorded for that player in the server memory, but does not by itself send a packet.
---@param pid integer @The player ID.
---@param refId string @The creature refId.
function api.SetCreatureRefId(pid, refId) end

---Set whether a player's name is replaced by that of the creature they are disguised as when other players hover over them.
---@param pid integer @The player ID.
---@param displayState boolean @The creature name display state.
function api.SetCreatureNameDisplayState(pid, displayState) end

---Send a PlayerShapeshift packet about a player.
---
---This sends the packet to all players connected to the server. It is currently used only to communicate werewolf states.
---@param pid integer @The player ID.
function api.SendShapeshift(pid) end
