---@class TES3MP
local api

---Get the type of a PlayerMiscellaneous packet.
---@param pid number @The player ID.
---@return string
function api.GetMiscellaneousChangeType(pid) end

---Get the cell description of a player's Mark cell.
---@param pid number @The player ID.
---@return string
function api.GetMarkCell(pid) end

---Get the X position of a player's Mark.
---@param pid number @The player ID.
---@return number
function api.GetMarkPosX(pid) end

---Get the Y position of a player's Mark.
---@param pid number @The player ID.
---@return number
function api.GetMarkPosY(pid) end

---Get the Z position of a player's Mark.
---@param pid number @The player ID.
---@return number
function api.GetMarkPosZ(pid) end

---Get the X rotation of a player's Mark.
---@param pid number @The player ID.
---@return number
function api.GetMarkRotX(pid) end

---Get the Z rotation of a player's Mark.
---@param pid number @The player ID.
---@return number
function api.GetMarkRotZ(pid) end

---Get the ID of a player's selected spell.
---@param pid number @The player ID.
---@return string
function api.GetSelectedSpellId(pid) end

---Check whether the killer of a certain player is also a player.
---@param pid number @The player ID of the killed player.
---@return boolean
function api.DoesPlayerHavePlayerKiller(pid) end

---Get the player ID of the killer of a certain player.
---@param pid number @The player ID of the killed player.
---@return number
function api.GetPlayerKillerPid(pid) end

---Get the refId of the actor killer of a certain player.
---@param pid number @The player ID of the killed player.
---@return string
function api.GetPlayerKillerRefId(pid) end

---Get the refNum of the actor killer of a certain player.
---@param pid number @The player ID of the killed player.
---@return number
function api.GetPlayerKillerRefNum(pid) end

---Get the mpNum of the actor killer of a certain player.
---@param pid number @The player ID of the killed player.
---@return number
function api.GetPlayerKillerMpNum(pid) end

---Get the name of the actor killer of a certain player.
---@param pid number @The player ID of the killed player.
---@return string
function api.GetPlayerKillerName(pid) end

---Get the draw state of a player (0 for nothing, 1 for drawn weapon, 2 for drawn spell).
---@param pid number @The player ID.
---@return number
function api.GetDrawState(pid) end

---Get the sneak state of a player.
---@param pid number @The player ID.
---@return boolean
function api.GetSneakState(pid) end

---Set the Mark cell of a player.
---
---The cell is determined to be an exterior cell if it fits the pattern of a number followed by a comma followed by another number.
---@param pid number @The player ID.
---@param cellDescription string @The cell description.
function api.SetMarkCell(pid, cellDescription) end

---Set the Mark position of a player.
---
---This changes the Mark positional coordinates recorded for that player in the server memory, but does not by itself send a packet.
---@param pid number @The player ID.
---@param x number @The X position.
---@param y number @The Y position.
---@param z number @The Z position.
function api.SetMarkPos(pid, x, y, z) end

---Set the Mark rotation of a player.
---
---This changes the Mark positional coordinates recorded for that player in the server memory, but does not by itself send a packet.
---@param pid number @The player ID.
---@param x number @The X rotation.
---@param z number @The Z rotation.
function api.SetMarkRot(pid, x, z) end

---Set the ID of a player's selected spell.
---
---This changes the spell ID recorded for that player in the server memory, but does not by itself send a packet.
---@param pid number @The player ID.
---@param spellId string @The spell ID.
function api.SetSelectedSpellId(pid, spellId) end

---Send a PlayerMiscellaneous packet with a Mark location to a player.
---@param pid number @The player ID.
function api.SendMarkLocation(pid) end

---Send a PlayerMiscellaneous packet with a selected spell ID to a player.
---@param pid number @The player ID.
function api.SendSelectedSpell(pid) end

---Send a PlayerJail packet about a player.
---
---It is only sent to the player being jailed, as the other players will be informed of the jailing's actual consequences via other packets sent by the affected client.
---@param pid number @The player ID.
---@param jailDays number @The number of days to spend jailed, where each day affects one skill point.
---@param ignoreJailTeleportation boolean @Whether the player being teleported to the nearest jail marker should be overridden.
---@param ignoreJailSkillIncreases boolean
---@param jailProgressText string @The text that should be displayed while jailed.
---@param jailEndText string @The text that should be displayed once the jailing period is over.
function api.Jail(pid, jailDays, ignoreJailTeleportation, ignoreJailSkillIncreases, jailProgressText, jailEndText) end

---Send a PlayerResurrect packet about a player.
---
---This sends the packet to all players connected to the server.
---@param pid number @The player ID.
---@param type number @The type of resurrection (0 for REGULAR, 1 for IMPERIAL_SHRINE, 2 for TRIBUNAL_TEMPLE).
function api.Resurrect(pid, type) end

---@param pid number
---@return string
function api.GetDeathReason(pid) end

---@param pid number
---@return number
function api.GetPlayerKillerRefNumIndex(pid) end
