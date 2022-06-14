---@class TES3MP
local api

---Clear the data from the records stored on the server.
function api.ClearRecords() end

---Get the type of records in the read worldstate's dynamic records.
---@return integer @The type of records (0 for SPELL, 1 for POTION, 2 for ENCHANTMENT, 3 for NPC).
function api.GetRecordType() end

---Get the number of records in the read worldstate's dynamic records.
---@return integer @The number of records.
function api.GetRecordCount() end

---Get the number of effects for the record at a certain index in the read worldstate's current records.
---@param recordIndex integer @The index of the record.
---@return integer @The number of effects.
function api.GetRecordEffectCount(recordIndex) end

---Get the id of the record at a certain index in the read worldstate's dynamic records of the current type.
---@param index integer @The index of the record.
---@return string @The id of the record.
function api.GetRecordId(index) end

---Get the base id (i.e. the id this record should inherit default values from) of the record at a certain index in the read worldstate's dynamic records of the current type.
---@param index integer @The index of the record.
---@return string @The base id of the record.
function api.GetRecordBaseId(index) end

---Get the subtype of the record at a certain index in the read worldstate's dynamic records of the current type.
---@param index integer @The index of the record.
---@return integer @The type of the record.
function api.GetRecordSubtype(index) end

---Get the name of the record at a certain index in the read worldstate's dynamic records of the current type.
---@param index integer @The index of the record.
---@return string @The name of the record.
function api.GetRecordName(index) end

---Get the model of the record at a certain index in the read worldstate's dynamic records of the current type.
---@param index integer @The index of the record.
---@return string @The model of the record.
function api.GetRecordModel(index) end

---Get the icon of the record at a certain index in the read worldstate's dynamic records of the current type.
---@param index integer @The index of the record.
---@return string @The icon of the record.
function api.GetRecordIcon(index) end

---Get the script of the record at a certain index in the read worldstate's dynamic records of the current type.
---@param index integer @The index of the record.
---@return string @The script of the record.
function api.GetRecordScript(index) end

---Get the enchantment id of the record at a certain index in the read worldstate's dynamic records of the current type.
---@param index integer @The index of the record.
---@return string @The enchantment id of the record.
function api.GetRecordEnchantmentId(index) end

---Get the enchantment charge of the record at a certain index in the read worldstate's dynamic records of the current type.
---@param index integer @The index of the record.
---@return integer @The enchantment charge of the record.
function api.GetRecordEnchantmentCharge(index) end

---Get the auto-calculation flag value of the record at a certain index in the read worldstate's dynamic records of the current type.
---@param index integer @The index of the record.
---@return integer @The auto-calculation flag value of the record.
function api.GetRecordAutoCalc(index) end

---Get the charge of the record at a certain index in the read worldstate's dynamic records of the current type.
---@param index integer @The index of the record.
---@return integer @The charge of the record.
function api.GetRecordCharge(index) end

---Get the cost of the record at a certain index in the read worldstate's dynamic records of the current type.
---@param index integer @The index of the record.
---@return integer @The cost of the record.
function api.GetRecordCost(index) end

---Get the flags of the record at a certain index in the read worldstate's dynamic records of the current type.
---@param index integer @The index of the record.
---@return integer @The flags of the spell as an integer.
function api.GetRecordFlags(index) end

---Get the value of the record at a certain index in the read worldstate's dynamic records of the current type.
---@param index integer @The index of the record.
---@return integer @The value of the record.
function api.GetRecordValue(index) end

---Get the weight of the record at a certain index in the read worldstate's dynamic records of the current type.
---@param index integer @The index of the record.
---@return number @The weight of the record.
function api.GetRecordWeight(index) end

---Get the quantity of the record at a certain index in the read worldstate's dynamic records of the current type.
---@param index integer @The index of the record.
---@return integer @The brewed count of the record.
function api.GetRecordQuantity(index) end

---Get the ID of the effect at a certain index in the read worldstate's current records.
---@param recordIndex integer @The index of the record.
---@param effectIndex integer @The index of the effect.
---@return integer @The ID of the effect.
function api.GetRecordEffectId(recordIndex, effectIndex) end

---Get the ID of the attribute modified by the effect at a certain index in the read worldstate's current records.
---@param recordIndex integer @The index of the record.
---@param effectIndex integer @The index of the effect.
---@return integer @The attribute ID for the effect.
function api.GetRecordEffectAttribute(recordIndex, effectIndex) end

---Get the ID of the skill modified by the effect at a certain index in the read worldstate's current records.
---@param recordIndex integer @The index of the record.
---@param effectIndex integer @The index of the effect.
---@return integer @The skill ID for the effect.
function api.GetRecordEffectSkill(recordIndex, effectIndex) end

---Get the range type of the effect at a certain index in the read worldstate's current records (0 for self, 1 for touch, 2 for target).
---@param recordIndex integer @The index of the record.
---@param effectIndex integer @The index of the effect.
---@return integer @The range of the effect.
function api.GetRecordEffectRangeType(recordIndex, effectIndex) end

---Get the area of the effect at a certain index in the read worldstate's current records.
---@param recordIndex integer @The index of the record.
---@param effectIndex integer @The index of the effect.
---@return integer @The area of the effect.
function api.GetRecordEffectArea(recordIndex, effectIndex) end

---Get the duration of the effect at a certain index in the read worldstate's current records.
---@param recordIndex integer @The index of the record.
---@param effectIndex integer @The index of the effect.
---@return integer @The duration of the effect.
function api.GetRecordEffectDuration(recordIndex, effectIndex) end

---Get the maximum magnitude of the effect at a certain index in the read worldstate's current records.
---@param recordIndex integer @The index of the record.
---@param effectIndex integer @The index of the effect.
---@return integer @The maximum magnitude of the effect.
function api.GetRecordEffectMagnitudeMax(recordIndex, effectIndex) end

---Get the minimum magnitude of the effect at a certain index in the read worldstate's current records.
---@param recordIndex integer @The index of the record.
---@param effectIndex integer @The index of the effect.
---@return integer @The minimum magnitude of the effect.
function api.GetRecordEffectMagnitudeMin(recordIndex, effectIndex) end

---Set which type of temporary records stored on the server should have their data changed via setter functions.
---@param type integer @The type of records.
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
---@param subtype integer @The spell type.
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
---@param enchantmentCharge integer @The enchantmentCharge of the record.
function api.SetRecordEnchantmentCharge(enchantmentCharge) end

---Set the auto-calculation flag value of the temporary record stored on the server for the currently specified record type.
---@param autoCalc integer @The auto-calculation flag value of the record.
function api.SetRecordAutoCalc(autoCalc) end

---Set the charge of the temporary record stored on the server for the currently specified record type.
---@param charge integer @The charge of the record.
function api.SetRecordCharge(charge) end

---Set the cost of the temporary record stored on the server for the currently specified record type.
---@param cost integer @The cost of the record.
function api.SetRecordCost(cost) end

---Set the flags of the temporary record stored on the server for the currently specified record type.
---@param flags integer @The flags of the record.
function api.SetRecordFlags(flags) end

---Set the value of the temporary record stored on the server for the currently specified record type.
---@param value integer @The value of the record.
function api.SetRecordValue(value) end

---Set the weight of the temporary record stored on the server for the currently specified record type.
---@param weight number @The weight of the record.
function api.SetRecordWeight(weight) end

---Set the item quality of the temporary record stored on the server for the currently specified record type.
---@param quality number @The quality of the record.
function api.SetRecordQuality(quality) end

---Set the number of uses of the temporary record stored on the server for the currently specified record type.
---@param uses integer @The number of uses of the record.
function api.SetRecordUses(uses) end

---Set the time of the temporary record stored on the server for the currently specified record type.
---@param time integer @The time of the record.
function api.SetRecordTime(time) end

---Set the radius of the temporary record stored on the server for the currently specified record type.
---@param radius integer @The radius of the record.
function api.SetRecordRadius(radius) end

---Set the color of the temporary record stored on the server for the currently specified record type.
---@param red integer @The red value of the record.
---@param green integer @The green value of the record.
---@param blue integer @The blue value of the record.
function api.SetRecordColor(red, green, blue) end

---Set the armor rating of the temporary record stored on the server for the currently specified record type.
---@param armorRating integer @The armor rating of the record.
function api.SetRecordArmorRating(armorRating) end

---Set the health of the temporary record stored on the server for the currently specified record type.
---@param health integer @The health of the record.
function api.SetRecordHealth(health) end

---Set the chop damage of the temporary record stored on the server for the currently specified record type.
---@param minDamage integer @The minimum damage of the record.
---@param maxDamage integer @The maximum damage of the record.
function api.SetRecordDamageChop(minDamage, maxDamage) end

---Set the slash damage of the temporary record stored on the server for the currently specified record type.
---@param minDamage integer @The minimum damage of the record.
---@param maxDamage integer @The maximum damage of the record.
function api.SetRecordDamageSlash(minDamage, maxDamage) end

---Set the thrust damage of the temporary record stored on the server for the currently specified record type.
---@param minDamage integer @The minimum damage of the record.
---@param maxDamage integer @The maximum damage of the record.
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
---@param skillId integer @The skill ID of the record.
function api.SetRecordSkillId(skillId) end

---Set the text of the temporary record stored on the server for the currently specified record type.
---@param text string @The text of the record.
function api.SetRecordText(text) end

---Set the hair of the temporary record stored on the server for the currently specified record type.
---@param hair string @The hair of the record.
function api.SetRecordHair(hair) end

---Set the head of the temporary record stored on the server for the currently specified record type.
---@param head string @The head of the record.
function api.SetRecordHead(head) end

---Set the gender of the temporary record stored on the server for the currently specified record type (0 for female, 1 for male).
---@param gender integer @The gender of the record.
function api.SetRecordGender(gender) end

---Set the race of the temporary record stored on the server for the currently specified record type.
---@param race string @The race of the record.
function api.SetRecordRace(race) end

---Set the character class of the temporary record stored on the server for the currently specified record type.
---@param charClass string @The character class of the record.
function api.SetRecordClass(charClass) end

---Set the faction of the temporary record stored on the server for the currently specified record type.
---@param faction string @The faction of the record.
function api.SetRecordFaction(faction) end

---Set the scale of the temporary record stored on the server for the currently specified record type.
---@param scale number @The scale of the record.
function api.SetRecordScale(scale) end

---Set the blood type of the temporary record stored on the server for the currently specified record type.
---@param bloodType integer @The blood type of the record.
function api.SetRecordBloodType(bloodType) end

---Set the vampire state of the temporary record stored on the server for the currently specified record type.
---@param vampireState boolean @The vampire state of the record.
function api.SetRecordVampireState(vampireState) end

---Set the level of the temporary record stored on the server for the currently specified record type.
---@param level integer @The level of the record.
function api.SetRecordLevel(level) end

---Set the magicka of the temporary record stored on the server for the currently specified record type.
---@param magicka integer @The magicka of the record.
function api.SetRecordMagicka(magicka) end

---Set the fatigue of the temporary record stored on the server for the currently specified record type.
---@param fatigue integer @The fatigue of the record.
function api.SetRecordFatigue(fatigue) end

---Set the soul value of the temporary record stored on the server for the currently specified record type.
---@param soulValue integer @The soul value of the record.
function api.SetRecordSoulValue(soulValue) end

---Set the AI fight value of the temporary record stored on the server for the currently specified record type.
---@param aiFight integer @The AI fight value of the record.
function api.SetRecordAIFight(aiFight) end

---Set the AI flee value of the temporary record stored on the server for the currently specified record type.
---@param aiFlee integer @The AI flee value of the record.
function api.SetRecordAIFlee(aiFlee) end

---Set the AI alarm value of the temporary record stored on the server for the currently specified record type.
---@param aiAlarm integer @The AI alarm value of the record.
function api.SetRecordAIAlarm(aiAlarm) end

---Set the AI services value of the temporary record stored on the server for the currently specified record type.
---@param aiServices integer @The AI services value of the record.
function api.SetRecordAIServices(aiServices) end

---Set the sound of the temporary record stored on the server for the currently specified record type.
---@param sound string @The sound of the record.
function api.SetRecordSound(sound) end

---Set the volume of the temporary record stored on the server for the currently specified record type.
---@param volume number @The volume of the record.
function api.SetRecordVolume(volume) end

---Set the minimum range of the temporary record stored on the server for the currently specified record type.
---@param minRange number @The minimum range of the record.
function api.SetRecordMinRange(minRange) end

---Set the maximum range of the temporary record stored on the server for the currently specified record type.
---@param maxRange number @The maximum range of the record.
function api.SetRecordMaxRange(maxRange) end

---Set the opening sound of the temporary record stored on the server for the currently specified record type.
---@param sound string @The opening sound of the record.
function api.SetRecordOpenSound(sound) end

---Set the closing sound of the temporary record stored on the server for the currently specified record type.
---@param sound string @The closing sound of the record.
function api.SetRecordCloseSound(sound) end

---Set the script text of the temporary record stored on the server for the currently specified record type.
---@param scriptText string @The script text of the record.
function api.SetRecordScriptText(scriptText) end

---Set the integer variable of the temporary record stored on the server for the currently specified record type.
---@param intVar integer @The integer variable of the record.
function api.SetRecordIntegerVariable(intVar) end

---Set the float variable of the temporary record stored on the server for the currently specified record type.
---@param floatVar number @The float variable of the record.
function api.SetRecordFloatVariable(floatVar) end

---Set the string variable of the temporary record stored on the server for the currently specified record type.
---@param stringVar string @The string variable of the record.
function api.SetRecordStringVariable(stringVar) end

---Set the id of the record at a certain index in the records stored on the server.
---
---When resending a received RecordsDynamic packet, this allows you to set the server-generated id of a record without having to clear and recreate the packet.
---@param index integer @The index of the record.
---@param id string @The id of the record.
function api.SetRecordIdByIndex(index, id) end

---Set the enchantment id of the record at a certain index in the records stored on the server.
---
---When resending a received RecordsDynamic packet, this allows you to set the server-generated enchantment id of a record without having to clear and recreate the packet.
---@param index integer @The index of the record.
---@param enchantmentId string @The enchantment id of the record.
function api.SetRecordEnchantmentIdByIndex(index, enchantmentId) end

---Set the ID of the temporary effect stored on the server.
---@param effectId integer @The ID of the effect.
function api.SetRecordEffectId(effectId) end

---Set the ID of the attribute modified by the temporary effect stored on the server.
---@param attributeId integer @The ID of the attribute.
function api.SetRecordEffectAttribute(attributeId) end

---Set the ID of the skill modified by the temporary effect stored on the server.
---@param skillId integer @The ID of the skill.
function api.SetRecordEffectSkill(skillId) end

---Set the range type of the temporary effect stored on the server (0 for self, 1 for touch, 2 for target).
---@param rangeType integer @The range type of the effect.
function api.SetRecordEffectRangeType(rangeType) end

---Set the area of the temporary effect stored on the server.
---@param area integer @The area of the effect.
function api.SetRecordEffectArea(area) end

---Set the duration of the temporary effect stored on the server.
---@param duration integer @The duration of the effect.
function api.SetRecordEffectDuration(duration) end

---Set the maximum magnitude of the temporary effect stored on the server.
---@param magnitudeMax integer @The maximum magnitude of the effect.
function api.SetRecordEffectMagnitudeMax(magnitudeMax) end

---Set the minimum magnitude of the temporary effect stored on the server.
---@param magnitudeMin integer @The minimum magnitude of the effect.
function api.SetRecordEffectMagnitudeMin(magnitudeMin) end

---Set the body part type of the temporary body part stored on the server (which then needs to be added to ARMOR or CLOTHING records) or set the body part type of the current record if it's a BODYPART.
---@param partType integer @The type of the body part.
function api.SetRecordBodyPartType(partType) end

---Set the id of the male version of the temporary body part stored on the server.
---@param partId string @The id of the body part.
function api.SetRecordBodyPartIdForMale(partId) end

---Set the id of the female version of the temporary body part stored on the server.
---@param partId string @The id of the body part.
function api.SetRecordBodyPartIdForFemale(partId) end

---Set the id of the of the temporary inventory item stored on the server.
---@param itemId string @The id of the inventory item.
function api.SetRecordInventoryItemId(itemId) end

---Set the count of the of the temporary inventory item stored on the server.
---@param count integer @The count of the inventory item.
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
---In the process, the server's temporary inventory item will automatically be cleared so a new one can be set up.
---
---Note: Any items added this way will be ignored if the record already has a valid inventoryBaseId.
function api.AddRecordInventoryItem() end

---Send a RecordDynamic packet with the current specified record type.
---@param pid integer @The player ID attached to the packet.
---@param sendToOtherPlayers boolean|nil @Whether this packet should be sent to players other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendRecordDynamic(pid, sendToOtherPlayers, skipAttachedPlayer) end
