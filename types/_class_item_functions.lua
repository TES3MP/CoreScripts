---@class TES3MP
local api

---Clear the last recorded inventory changes for a player.
---
---This is used to initialize the sending of new PlayerInventory packets.
---@param pid integer @The player ID whose inventory changes should be used.
function api.ClearInventoryChanges(pid) end

---Get the number of slots used for equipment.
---
---The number is 19 before any dehardcoding is done in OpenMW.
---@return integer
function api.GetEquipmentSize() end

---Get the number of indexes in a player's latest inventory changes.
---@param pid integer @The player ID whose inventory changes should be used.
---@return integer
function api.GetInventoryChangesSize(pid) end

---Get the action type used in a player's latest inventory changes.
---@param pid integer @The player ID whose inventory changes should be used.
---@return integer
function api.GetInventoryChangesAction(pid) end

---Set the action type in a player's inventory changes.
---@param pid integer @The player ID whose inventory changes should be used.
---@param action string @The action (0 for SET, 1 for ADD, 2 for REMOVE).
function api.SetInventoryChangesAction(pid, action) end

---Equip an item in a certain slot of the equipment of a player.
---@param pid integer @The player ID.
---@param slot integer @The equipment slot.
---@param refId string @The refId of the item.
---@param count integer @The count of the item.
---@param charge integer @The charge of the item.
---@param enchantmentCharge integer @The enchantment charge of the item.
function api.EquipItem(pid, slot, refId, count, charge, enchantmentCharge) end

---Unequip the item in a certain slot of the equipment of a player.
---@param pid integer @The player ID.
---@param slot integer @The equipment slot.
function api.UnequipItem(pid, slot) end

---Add an item change to a player's inventory changes.
---@param pid integer @The player ID.
---@param refId string @The refId of the item.
---@param count integer @The count of the item.
---@param charge integer @The charge of the item.
---@param enchantmentCharge integer @The enchantment charge of the item.
---@param soul string @The soul of the item.
function api.AddItemChange(pid, refId, count, charge, enchantmentCharge, soul) end

---Check whether a player has equipped an item with a certain refId in any slot.
---@param pid integer @The player ID.
---@param refId string @The refId of the item.
---@return boolean
function api.HasItemEquipped(pid, refId) end

---Get the refId of the item in a certain slot of the equipment of a player.
---@param pid integer @The player ID.
---@param slot integer @The slot of the equipment item.
---@return string
function api.GetEquipmentItemRefId(pid, slot) end

---Get the count of the item in a certain slot of the equipment of a player.
---@param pid integer @The player ID.
---@param slot integer @The slot of the equipment item.
---@return integer
function api.GetEquipmentItemCount(pid, slot) end

---Get the charge of the item in a certain slot of the equipment of a player.
---@param pid integer @The player ID.
---@param slot integer @The slot of the equipment item.
---@return integer
function api.GetEquipmentItemCharge(pid, slot) end

---Get the enchantment charge of the item in a certain slot of the equipment of a player.
---@param pid integer @The player ID.
---@param slot integer @The slot of the equipment item.
---@return integer
function api.GetEquipmentItemEnchantmentCharge(pid, slot) end

---Get the refId of the item at a certain index in a player's latest inventory changes.
---@param pid integer @The player ID whose inventory changes should be used.
---@param index integer @The index of the inventory item.
---@return string
function api.GetInventoryItemRefId(pid, index) end

---Get the count of the item at a certain index in a player's latest inventory changes.
---@param pid integer @The player ID whose inventory changes should be used.
---@param index integer @The index of the inventory item.
---@return integer
function api.GetInventoryItemCount(pid, index) end

---Get the charge of the item at a certain index in a player's latest inventory changes.
---@param pid integer @The player ID whose inventory changes should be used.
---@param index integer @The index of the inventory item.
---@return integer
function api.GetInventoryItemCharge(pid, index) end

---Get the enchantment charge of the item at a certain index in a player's latest inventory changes.
---@param pid integer @The player ID whose inventory changes should be used.
---@param index integer @The index of the inventory item.
---@return integer
function api.GetInventoryItemEnchantmentCharge(pid, index) end

---Get the soul of the item at a certain index in a player's latest inventory changes.
---@param pid integer @The player ID whose inventory changes should be used.
---@param index integer @The index of the inventory item.
---@return string
function api.GetInventoryItemSoul(pid, index) end

---Get the refId of the item last used by a player.
---@param pid integer @The player ID.
---@return string
function api.GetUsedItemRefId(pid) end

---Get the count of the item last used by a player.
---@param pid integer @The player ID.
---@return integer
function api.GetUsedItemCount(pid) end

---Get the charge of the item last used by a player.
---@param pid integer @The player ID.
---@return integer
function api.GetUsedItemCharge(pid) end

---Get the enchantment charge of the item last used by a player.
---@param pid integer @The player ID.
---@return integer
function api.GetUsedItemEnchantmentCharge(pid) end

---Get the soul of the item last used by a player.
---@param pid integer @The player ID.
---@return string
function api.GetUsedItemSoul(pid) end

---Send a PlayerEquipment packet with a player's equipment.
---
---It is always sent to all players.
---@param pid integer @The player ID whose equipment should be sent.
function api.SendEquipment(pid) end

---Send a PlayerInventory packet with a player's recorded inventory changes.
---@param pid integer @The player ID whose inventory changes should be used.
---@param sendToOtherPlayers boolean|nil @Whether this packet should be sent to players other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendInventoryChanges(pid, sendToOtherPlayers, skipAttachedPlayer) end

---Send a PlayerItemUse causing a player to use their recorded usedItem.
---@param pid integer @The player ID affected.
function api.SendItemUse(pid) end

---@param pid integer
function api.InitializeInventoryChanges(pid) end

---@param pid integer
---@param refId string
---@param count integer
---@param charge integer
---@param enchantmentCharge integer
---@param soul string
function api.AddItem(pid, refId, count, charge, enchantmentCharge, soul) end
