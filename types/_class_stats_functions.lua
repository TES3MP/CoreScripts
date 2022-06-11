---@class TES3MP
local api

---Get the number of attributes.
---
---The number is 8 before any dehardcoding is done in OpenMW.
---@return integer
function api.GetAttributeCount() end

---Get the number of skills.
---
---The number is 27 before any dehardcoding is done in OpenMW.
---@return integer
function api.GetSkillCount() end

---Get the numerical ID of an attribute with a certain name.
---
---If an invalid name is used, the ID returned is -1
---@param name string @The name of the attribute.
---@return integer
function api.GetAttributeId(name) end

---Get the numerical ID of a skill with a certain name.
---
---If an invalid name is used, the ID returned is -1
---@param name string @The name of the skill.
---@return integer
function api.GetSkillId(name) end

---Get the name of the attribute with a certain numerical ID.
---
---If an invalid ID is used, "invalid" is returned.
---@param attributeId integer @The ID of the attribute.
---@return string
function api.GetAttributeName(attributeId) end

---Get the name of the skill with a certain numerical ID.
---
---If an invalid ID is used, "invalid" is returned.
---@param skillId integer @The ID of the skill.
---@return string
function api.GetSkillName(skillId) end

---Get the name of a player.
---@param pid integer @The player ID.
---@return string
function api.GetName(pid) end

---Get the race of a player.
---@param pid integer @The player ID.
---@return string
function api.GetRace(pid) end

---Get the head mesh used by a player.
---@param pid integer @The player ID.
---@return string
function api.GetHead(pid) end

---Get the hairstyle mesh used by a player.
---@param pid integer @The player ID.
---@return string
function api.GetHairstyle(pid) end

---Check whether a player is male or not.
---@param pid integer @The player ID.
---@return integer
function api.GetIsMale(pid) end

---Get the birthsign of a player.
---@param pid integer @The player ID.
---@return string
function api.GetBirthsign(pid) end

---Get the character level of a player.
---@param pid integer @The player ID.
---@return integer
function api.GetLevel(pid) end

---Get the player's progress to their next character level.
---@param pid integer @The player ID.
---@return integer
function api.GetLevelProgress(pid) end

---Get the base health of the player.
---@param pid integer @The player ID.
---@return integer
function api.GetHealthBase(pid) end

---Get the current health of the player.
---@param pid integer @The player ID.
---@return integer
function api.GetHealthCurrent(pid) end

---Get the base magicka of the player.
---@param pid integer @The player ID.
---@return integer
function api.GetMagickaBase(pid) end

---Get the current magicka of the player.
---@param pid integer @The player ID.
---@return integer
function api.GetMagickaCurrent(pid) end

---Get the base fatigue of the player.
---@param pid integer @The player ID.
---@return integer
function api.GetFatigueBase(pid) end

---Get the current fatigue of the player.
---@param pid integer @The player ID.
---@return integer
function api.GetFatigueCurrent(pid) end

---Get the base value of a player's attribute.
---@param pid integer @The player ID.
---@param attributeId integer @The attribute ID.
---@return integer
function api.GetAttributeBase(pid, attributeId) end

---Get the modifier value of a player's attribute.
---@param pid integer @The player ID.
---@param attributeId integer @The attribute ID.
---@return integer
function api.GetAttributeModifier(pid, attributeId) end

---Get the base value of a player's skill.
---@param pid integer @The player ID.
---@param skillId integer @The skill ID.
---@return integer
function api.GetSkillBase(pid, skillId) end

---Get the modifier value of a player's skill.
---@param pid integer @The player ID.
---@param skillId integer @The skill ID.
---@return integer
function api.GetSkillModifier(pid, skillId) end

---Get the progress the player has made towards increasing a certain skill by 1.
---@param pid integer @The player ID.
---@param skillId integer @The skill ID.
---@return integer
function api.GetSkillProgress(pid, skillId) end

---Get the bonus applied to a certain attribute at the next level up as a result of associated skill increases.
---
---Although confusing, the term "skill increase" for this is taken from OpenMW itself.
---@param pid integer @The player ID.
---@param attributeId integer
---@return integer
function api.GetSkillIncrease(pid, attributeId) end

---Get the bounty of the player.
---@param pid integer @The player ID.
---@return integer
function api.GetBounty(pid) end

---Set the name of a player.
---@param pid integer @The player ID.
---@param name string @The new name of the player.
function api.SetName(pid, name) end

---Set the race of a player.
---@param pid integer @The player ID.
---@param race string @The new race of the player.
function api.SetRace(pid, race) end

---Set the head mesh used by a player.
---@param pid integer @The player ID.
---@param head string @The new head mesh of the player.
function api.SetHead(pid, head) end

---Set the hairstyle mesh used by a player.
---@param pid integer @The player ID.
---@param hairstyle string @The new hairstyle mesh of the player.
function api.SetHairstyle(pid, hairstyle) end

---Set whether a player is male or not.
---@param pid integer @The player ID.
---@param state integer @Whether the player is male.
function api.SetIsMale(pid, state) end

---Set the birthsign of a player.
---@param pid integer @The player ID.
---@param name string @The new birthsign of the player.
function api.SetBirthsign(pid, name) end

---Set whether the player's stats should be reset based on their current race as the result of a PlayerBaseInfo packet.
---
---This changes the resetState for that player in the server memory, but does not by itself send a packet.
---@param pid integer @The player ID.
---@param resetStats boolean @The stat reset state.
function api.SetResetStats(pid, resetStats) end

---Set the character level of a player.
---@param pid integer @The player ID.
---@param value integer @The new level of the player.
function api.SetLevel(pid, value) end

---Set the player's progress to their next character level.
---@param pid integer @The player ID.
---@param value integer @The new level progress of the player.
function api.SetLevelProgress(pid, value) end

---Set the base health of a player.
---@param pid integer @The player ID.
---@param value integer
function api.SetHealthBase(pid, value) end

---Set the current health of a player.
---@param pid integer @The player ID.
---@param value integer
function api.SetHealthCurrent(pid, value) end

---Set the base magicka of a player.
---@param pid integer @The player ID.
---@param value integer
function api.SetMagickaBase(pid, value) end

---Set the current magicka of a player.
---@param pid integer @The player ID.
---@param value integer
function api.SetMagickaCurrent(pid, value) end

---Set the base fatigue of a player.
---@param pid integer @The player ID.
---@param value integer
function api.SetFatigueBase(pid, value) end

---Set the current fatigue of a player.
---@param pid integer @The player ID.
---@param value integer
function api.SetFatigueCurrent(pid, value) end

---Set the base value of a player's attribute.
---@param pid integer @The player ID.
---@param attributeId integer @The attribute ID.
---@param value integer @The new base value of the player's attribute.
function api.SetAttributeBase(pid, attributeId, value) end

---Clear the modifier value of a player's attribute.
---
---There's no way to set a modifier to a specific value because it can come from multiple different sources, but clearing it is a straightforward process that dispels associated effects on a client and, if necessary, unequips associated items.
---@param pid integer @The player ID.
---@param attributeId integer @The attribute ID.
function api.ClearAttributeModifier(pid, attributeId) end

---Set the base value of a player's skill.
---@param pid integer @The player ID.
---@param skillId integer @The skill ID.
---@param value integer @The new base value of the player's skill.
function api.SetSkillBase(pid, skillId, value) end

---Clear the modifier value of a player's skill.
---
---There's no way to set a modifier to a specific value because it can come from multiple different sources, but clearing it is a straightforward process that dispels associated effects on a client and, if necessary, unequips associated items.
---@param pid integer @The player ID.
---@param skillId integer @The skill ID.
function api.ClearSkillModifier(pid, skillId) end

---Set the progress the player has made towards increasing a certain skill by 1.
---@param pid integer @The player ID.
---@param skillId integer @The skill ID.
---@param value integer @The progress value.
function api.SetSkillProgress(pid, skillId, value) end

---Set the bonus applied to a certain attribute at the next level up as a result of associated skill increases.
---
---Although confusing, the term "skill increase" for this is taken from OpenMW itself.
---@param pid integer @The player ID.
---@param attributeId integer
---@param value integer @The increase in the attribute caused by skills.
function api.SetSkillIncrease(pid, attributeId, value) end

---Set the bounty of a player.
---@param pid integer @The player ID.
---@param value integer @The new bounty.
function api.SetBounty(pid, value) end

---Set the current and ending stages of character generation for a player.
---
---This is used to repeat part of character generation or to only go through part of it.
---@param pid integer @The player ID.
---@param currentStage integer @The new current stage.
---@param endStage integer @The new ending stage.
function api.SetCharGenStage(pid, currentStage, endStage) end

---Send a PlayerBaseInfo packet with a player's name, race, head mesh, hairstyle mesh, birthsign and stat reset state.
---
---It is always sent to all players.
---@param pid integer @The player ID.
function api.SendBaseInfo(pid) end

---Send a PlayerStatsDynamic packet with a player's dynamic stats (health, magicka and fatigue).
---
---It is always sent to all players.
---@param pid integer @The player ID.
function api.SendStatsDynamic(pid) end

---Send a PlayerAttribute packet with a player's attributes and bonuses to those attributes at the next level up (the latter being called "skill increases" as in OpenMW).
---
---It is always sent to all players.
---@param pid integer @The player ID.
function api.SendAttributes(pid) end

---Send a PlayerSkill packet with a player's skills.
---
---It is always sent to all players.
---@param pid integer @The player ID.
function api.SendSkills(pid) end

---Send a PlayerLevel packet with a player's character level and progress towards the next level up.
---
---It is always sent to all players.
---@param pid integer @The player ID.
function api.SendLevel(pid) end

---Send a PlayerBounty packet with a player's bounty.
---
---It is always sent to all players.
---@param pid integer @The player ID.
function api.SendBounty(pid) end
