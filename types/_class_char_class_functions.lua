---@class TES3MP
local api

---Get the default class used by a player.
---@param pid integer @The player ID.
---@return string @The ID of the default class.
function api.GetDefaultClass(pid) end

---Get the name of the custom class used by a player.
---@param pid integer @The player ID.
---@return string @The name of the custom class.
function api.GetClassName(pid) end

---Get the description of the custom class used by a player.
---@param pid integer @The player ID.
---@return string @The description of the custom class.
function api.GetClassDesc(pid) end

---Get the ID of one of the two major attributes of a custom class used by a player.
---@param pid integer @The player ID.
---@param slot string @The slot of the major attribute (0 or 1).
---@return integer @The ID of the major attribute.
function api.GetClassMajorAttribute(pid, slot) end

---Get the specialization ID of the custom class used by a player.
---@param pid integer @The player ID.
---@return integer @The specialization ID of the custom class (0 for Combat, 1 for Magic, 2 for Stealth).
function api.GetClassSpecialization(pid) end

---Get the ID of one of the five major skills of a custom class used by a player.
---@param pid integer @The player ID.
---@param slot string @The slot of the major skill (0 to 4).
---@return integer @The ID of the major skill.
function api.GetClassMajorSkill(pid, slot) end

---Get the ID of one of the five minor skills of a custom class used by a player.
---@param pid integer @The player ID.
---@param slot string @The slot of the minor skill (0 to 4).
---@return integer @The ID of the minor skill.
function api.GetClassMinorSkill(pid, slot) end

---Check whether the player is using a default class instead of a custom one.
---@param pid integer @The player ID.
---@return integer @Whether the player is using a default class.
function api.IsClassDefault(pid) end

---Set the default class used by a player.
---
---If this is left blank, the custom class data set for the player will be used instead.
---@param pid integer @The player ID.
---@param id string @The ID of the default class.
function api.SetDefaultClass(pid, id) end

---Set the name of the custom class used by a player.
---@param pid integer @The player ID.
---@param name string @The name of the custom class.
function api.SetClassName(pid, name) end

---Set the description of the custom class used by a player.
---@param pid integer @The player ID.
---@param desc string @The description of the custom class.
function api.SetClassDesc(pid, desc) end

---Set the ID of one of the two major attributes of the custom class used by a player.
---@param pid integer @The player ID.
---@param slot string @The slot of the major attribute (0 or 1).
---@param attrId integer @The ID to use for the attribute.
function api.SetClassMajorAttribute(pid, slot, attrId) end

---Set the specialization of the custom class used by a player.
---@param pid integer @The player ID.
---@param spec integer @The specialization ID to use (0 for Combat, 1 for Magic, 2 for Stealth).
function api.SetClassSpecialization(pid, spec) end

---Set the ID of one of the five major skills of the custom class used by a player.
---@param pid integer @The player ID.
---@param slot string @The slot of the major skill (0 to 4).
---@param skillId integer @The ID to use for the skill.
function api.SetClassMajorSkill(pid, slot, skillId) end

---Set the ID of one of the five minor skills of the custom class used by a player.
---@param pid integer @The player ID.
---@param slot string @The slot of the minor skill (0 to 4).
---@param skillId integer @The ID to use for the skill.
function api.SetClassMinorSkill(pid, slot, skillId) end

---Send a PlayerCharClass packet about a player.
---
---It is only sent to the affected player.
---@param pid integer @The player ID.
function api.SendClass(pid) end
