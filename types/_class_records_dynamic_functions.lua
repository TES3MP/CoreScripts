---@class TES3MP
local api

---Clear the data from the records stored on the server.
function api.ClearRecords() end

---Get the type of records in the read worldstate's dynamic records.
---@return number
function api.GetRecordType() end

---Get the number of records in the read worldstate's dynamic records.
---@return number
function api.GetRecordCount() end

---Get the number of effects for the record at a certain index in the read worldstate's current records.
---@param recordIndex number @The index of the record.
---@return number
function api.GetRecordEffectCount(recordIndex) end

---Get the id of the record at a certain index in the read worldstate's dynamic records of the current type.
---@param index number @The index of the record.
---@return string
function api.GetRecordId(index) end

---Get the base id (i.e. the id this record should inherit default values from) of the record at a certain index in the read worldstate's dynamic records of the current type.
---@param index number @The index of the record.
---@return string
function api.GetRecordBaseId(index) end

---Get the subtype of the record at a certain index in the read worldstate's dynamic records of the current type.
---@param index number @The index of the record.
---@return number
function api.GetRecordSubtype(index) end

---Get the name of the record at a certain index in the read worldstate's dynamic records of the current type.
---@param index number @The index of the record.
---@return string
function api.GetRecordName(index) end

---Get the model of the record at a certain index in the read worldstate's dynamic records of the current type.
---@param index number @The index of the record.
---@return string
function api.GetRecordModel(index) end

---Get the icon of the record at a certain index in the read worldstate's dynamic records of the current type.
---@param index number @The index of the record.
---@return string
function api.GetRecordIcon(index) end

---Get the script of the record at a certain index in the read worldstate's dynamic records of the current type.
---@param index number @The index of the record.
---@return string
function api.GetRecordScript(index) end

---Get the enchantment id of the record at a certain index in the read worldstate's dynamic records of the current type.
---@param index number @The index of the record.
---@return string
function api.GetRecordEnchantmentId(index) end

---Get the enchantment charge of the record at a certain index in the read worldstate's dynamic records of the current type.
---@param index number @The index of the record.
---@return number
function api.GetRecordEnchantmentCharge(index) end

---Get the auto-calculation flag value of the record at a certain index in the read worldstate's dynamic records of the current type.
---@param index number @The index of the record.
---@return number
function api.GetRecordAutoCalc(index) end

---Get the charge of the record at a certain index in the read worldstate's dynamic records of the current type.
---@param index number @The index of the record.
---@return number
function api.GetRecordCharge(index) end

---Get the cost of the record at a certain index in the read worldstate's dynamic records of the current type.
---@param index number @The index of the record.
---@return number
function api.GetRecordCost(index) end

---Get the flags of the record at a certain index in the read worldstate's dynamic records of the current type.
---@param index number @The index of the record.
---@return number
function api.GetRecordFlags(index) end

---Get the value of the record at a certain index in the read worldstate's dynamic records of the current type.
---@param index number @The index of the record.
---@return number
function api.GetRecordValue(index) end

---Get the weight of the record at a certain index in the read worldstate's dynamic records of the current type.
---@param index number @The index of the record.
---@return number
function api.GetRecordWeight(index) end

---Get the ID of the effect at a certain index in the read worldstate's current records.
---@param recordIndex number @The index of the record.
---@param effectIndex number @The index of the effect.
---@return number
function api.GetRecordEffectId(recordIndex, effectIndex) end

---Get the ID of the attribute modified by the effect at a certain index in the read worldstate's current records.
---@param recordIndex number @The index of the record.
---@param effectIndex number @The index of the effect.
---@return number
function api.GetRecordEffectAttribute(recordIndex, effectIndex) end

---Get the ID of the skill modified by the effect at a certain index in the read worldstate's current records.
---@param recordIndex number @The index of the record.
---@param effectIndex number @The index of the effect.
---@return number
function api.GetRecordEffectSkill(recordIndex, effectIndex) end

---Get the range type of the effect at a certain index in the read worldstate's current records (0 for self, 1 for touch, 2 for target).
---@param recordIndex number @The index of the record.
---@param effectIndex number @The index of the effect.
---@return number
function api.GetRecordEffectRangeType(recordIndex, effectIndex) end

---Get the area of the effect at a certain index in the read worldstate's current records.
---@param recordIndex number @The index of the record.
---@param effectIndex number @The index of the effect.
---@return number
function api.GetRecordEffectArea(recordIndex, effectIndex) end

---Get the duration of the effect at a certain index in the read worldstate's current records.
---@param recordIndex number @The index of the record.
---@param effectIndex number @The index of the effect.
---@return number
function api.GetRecordEffectDuration(recordIndex, effectIndex) end

---Get the maximum magnitude of the effect at a certain index in the read worldstate's current records.
---@param recordIndex number @The index of the record.
---@param effectIndex number @The index of the effect.
---@return number
function api.GetRecordEffectMagnitudeMax(recordIndex, effectIndex) end

---Get the minimum magnitude of the effect at a certain index in the read worldstate's current records.
---@param recordIndex number @The index of the record.
---@param effectIndex number @The index of the effect.
---@return number
function api.GetRecordEffectMagnitudeMin(recordIndex, effectIndex) end

---Set which type of temporary records stored on the server should have their data changed via setter functions.
---@param type number @The type of records.
function api.SetRecordType(type) end

---Set the id of the temporary record stored on the server for the currently specified record type.
---@param id string @The id of the record.
function api.SetRecordId(id) end

---Set the base id (i.e. the id this record should inherit default values from) of the temporary record stored on the server for the currently specified record type.
---@param baseId string @The baseId of the record.
function api.SetRecordBaseId(baseId) end

---Set the inventory base id (i.e. the id this record should inherit its inventory contents from) of the temporary record stored on the server for the currently specified record type.
---@param inventoryBaseId string @The inventoryBaseId of the record.
function api.SetRecordInventoryBaseId(inventoryBaseId) end

---Set the subtype of the temporary record stored on the server for the currently specified record type.
---@param subtype number
function api.SetRecordSubtype(subtype) end

---Set the name of the temporary record stored on the server for the currently specified record type.
---@param name string @The name of the record.
function api.SetRecordName(name) end

---Set the model of the temporary record stored on the server for the currently specified record type.
---@param model string @The model of the record.
function api.SetRecordModel(model) end

---Set the icon of the temporary record stored on the server for the currently specified record type.
---@param icon string @The icon of the record.
function api.SetRecordIcon(icon) end

---Set the script of the temporary record stored on the server for the currently specified record type.
---@param script string @The script of the record.
function api.SetRecordScript(script) end

---Set the enchantment id of the temporary record stored on the server for the currently specified record type.
---@param enchantmentId string @The enchantment id of the record.
function api.SetRecordEnchantmentId(enchantmentId) end

---Set the enchantment charge of the temporary record stored on the server for the currently specified record type.
---@param enchantmentCharge number @The enchantmentCharge of the record.
function api.SetRecordEnchantmentCharge(enchantmentCharge) end

---Set the auto-calculation flag value of the temporary record stored on the server for the currently specified record type.
---@param autoCalc number @The auto-calculation flag value of the record.
function api.SetRecordAutoCalc(autoCalc) end

---Set the charge of the temporary record stored on the server for the currently specified record type.
---@param charge number @The charge of the record.
function api.SetRecordCharge(charge) end

---Set the cost of the temporary record stored on the server for the currently specified record type.
---@param cost number @The cost of the record.
function api.SetRecordCost(cost) end

---Set the flags of the temporary record stored on the server for the currently specified record type.
---@param flags number @The flags of the record.
function api.SetRecordFlags(flags) end

---Set the value of the temporary record stored on the server for the currently specified record type.
---@param value number @The value of the record.
function api.SetRecordValue(value) end

---Set the weight of the temporary record stored on the server for the currently specified record type.
---@param weight number @The weight of the record.
function api.SetRecordWeight(weight) end

---Set the armor rating of the temporary record stored on the server for the currently specified record type.
---@param armorRating number @The armor rating of the record.
function api.SetRecordArmorRating(armorRating) end

---Set the health of the temporary record stored on the server for the currently specified record type.
---@param health number @The health of the record.
function api.SetRecordHealth(health) end

---Set the chop damage of the temporary record stored on the server for the currently specified record type.
---@param minDamage number @The minimum damage of the record.
---@param maxDamage number @The maximum damage of the record.
function api.SetRecordDamageChop(minDamage, maxDamage) end

---Set the slash damage of the temporary record stored on the server for the currently specified record type.
---@param minDamage number @The minimum damage of the record.
---@param maxDamage number @The maximum damage of the record.
function api.SetRecordDamageSlash(minDamage, maxDamage) end

---Set the thrust damage of the temporary record stored on the server for the currently specified record type.
---@param minDamage number @The minimum damage of the record.
---@param maxDamage number @The maximum damage of the record.
function api.SetRecordDamageThrust(minDamage, maxDamage) end

---Set the reach of the temporary record stored on the server for the currently specified record type.
---@param reach number @The reach of the record.
function api.SetRecordReach(reach) end

---Set the speed of the temporary record stored on the server for the currently specified record type.
---@param speed number @The speed of the record.
function api.SetRecordSpeed(speed) end

---Set whether the temporary record stored on the server for the currently specified record type is a key.
---
---Note: This is only applicable to Miscellaneous records.
---@param keyState boolean @Whether the record is a key.
function api.SetRecordKeyState(keyState) end

---Set whether the temporary record stored on the server for the currently specified record type is a scroll.
---
---Note: This is only applicable to Book records.
---@param scrollState boolean @Whether the record is a scroll.
function api.SetRecordScrollState(scrollState) end

---Set the skill ID of the temporary record stored on the server for the currently specified record type.
---@param skillId number @The skill ID of the record.
function api.SetRecordSkillId(skillId) end

---Set the text of the temporary record stored on the server for the currently specified record type.
---@param text string @The text of the record.
function api.SetRecordText(text) end

---Set the hair of the temporary record stored on the server for the currently specified record type.
---@param hair string @The hair of the record.
function api.SetRecordHair(hair) end

---Set the head of the temporary record stored on the server for the currently specified record type.
---@param head string
function api.SetRecordHead(head) end

---Set the gender of the temporary record stored on the server for the currently specified record type (0 for female, 1 for male).
---@param gender number
function api.SetRecordGender(gender) end

---Set the race of the temporary record stored on the server for the currently specified record type.
---@param race string
function api.SetRecordRace(race) end

---Set the character class of the temporary record stored on the server for the currently specified record type.
---@param charClass string
function api.SetRecordClass(charClass) end

---Set the faction of the temporary record stored on the server for the currently specified record type.
---@param faction string @The faction of the record.
function api.SetRecordFaction(faction) end

---Set the level of the temporary record stored on the server for the currently specified record type.
---@param level number @The level of the record.
function api.SetRecordLevel(level) end

---Set the magicka of the temporary record stored on the server for the currently specified record type.
---@param magicka number @The magicka of the record.
function api.SetRecordMagicka(magicka) end

---Set the fatigue of the temporary record stored on the server for the currently specified record type.
---@param fatigue number @The fatigue of the record.
function api.SetRecordFatigue(fatigue) end

---Set the AI fight value of the temporary record stored on the server for the currently specified record type.
---@param aiFight number @The AI fight value of the record.
function api.SetRecordAIFight(aiFight) end

---Set the id of the record at a certain index in the records stored on the server.
---
---When resending a received RecordsDynamic packet, this allows you to set the server-generated id of a record without having to clear and recreate the packet.
---@param index number @The index of the record.
---@param id string @The id of the record.
function api.SetRecordIdByIndex(index, id) end

---Set the enchantment id of the record at a certain index in the records stored on the server.
---
---When resending a received RecordsDynamic packet, this allows you to set the server-generated enchantment id of a record without having to clear and recreate the packet.
---@param index number @The index of the record.
---@param enchantmentId string @The enchantment id of the record.
function api.SetRecordEnchantmentIdByIndex(index, enchantmentId) end

---Set the ID of the temporary effect stored on the server.
---@param effectId number @The ID of the effect.
function api.SetRecordEffectId(effectId) end

---Set the ID of the attribute modified by the temporary effect stored on the server.
---@param attributeId number @The ID of the attribute.
function api.SetRecordEffectAttribute(attributeId) end

---Set the ID of the skill modified by the temporary effect stored on the server.
---@param skillId number @The ID of the skill.
function api.SetRecordEffectSkill(skillId) end

---Set the range type of the temporary effect stored on the server (0 for self, 1 for touch, 2 for target).
---@param rangeType number @The range type of the effect.
function api.SetRecordEffectRangeType(rangeType) end

---Set the area of the temporary effect stored on the server.
---@param area number @The area of the effect.
function api.SetRecordEffectArea(area) end

---Set the duration of the temporary effect stored on the server.
---@param duration number @The duration of the effect.
function api.SetRecordEffectDuration(duration) end

---Set the maximum magnitude of the temporary effect stored on the server.
---@param magnitudeMax number @The maximum magnitude of the effect.
function api.SetRecordEffectMagnitudeMax(magnitudeMax) end

---Set the minimum magnitude of the temporary effect stored on the server.
---@param magnitudeMin number @The minimum magnitude of the effect.
function api.SetRecordEffectMagnitudeMin(magnitudeMin) end

---Set the type of the temporary body part stored on the server.
---@param partType number @The type of the body part.
function api.SetRecordBodyPartType(partType) end

---Set the id of the male version of the temporary body part stored on the server.
---@param partId string @The id of the body part.
function api.SetRecordBodyPartIdForMale(partId) end

---Set the id of the female version of the temporary body part stored on the server.
---@param partId string @The id of the body part.
function api.SetRecordBodyPartIdForFemale(partId) end

---Set the id of the of the temporary inventory item stored on the server.
---@param itemId string
function api.SetRecordInventoryItemId(itemId) end

---Set the count of the of the temporary inventory item stored on the server.
---@param count number @The count of the inventory item.
function api.SetRecordInventoryItemCount(count) end

---Add a copy of the server's temporary record of the current specified type to the stored records.
---
---In the process, the server's temporary record will automatically be cleared so a new one can be set up.
function api.AddRecord() end

---Add a copy of the server's temporary effect to the temporary record of the current specified type.
---
---In the process, the server's temporary effect will automatically be cleared so a new one can be set up.
function api.AddRecordEffect() end

---Add a copy of the server's temporary body part to the temporary record of the current specified type.
---
---In the process, the server's temporary body part will automatically be cleared so a new one can be set up.
function api.AddRecordBodyPart() end

---Add a copy of the server's temporary inventory item to the temporary record of the current specified type.
---
---Note: Any items added this way will be ignored if the record already has a valid inventoryBaseId.
function api.AddRecordInventoryItem() end

---Send a RecordDynamic packet with the current specified record type.
---@param pid number @The player ID attached to the packet.
---@param sendToOtherPlayers boolean|nil @Whether this packet should be sent to players other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendRecordDynamic(pid, sendToOtherPlayers, skipAttachedPlayer) end
