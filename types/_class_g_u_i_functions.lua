---@class TES3MP
local api

---Display a simple messagebox at the bottom of the screen that vanishes after a few seconds.
---
---Note for C++ programmers: do not rename into MessageBox so as to not conflict with WINAPI's MessageBox.
---@param pid number @The player ID for whom the messagebox should appear.
---@param id number @The numerical ID of the messagebox.
---@param label string @The text in the messagebox.
function api._MessageBox(pid, id, label) end

---Display an interactive messagebox at the center of the screen that vanishes only when one of its buttons is clicked.
---@param pid number @The player ID for whom the messagebox should appear.
---@param id number @The numerical ID of the messagebox.
---@param label string @The text in the messagebox.  buttons The captions of the buttons, separated by semicolons (e.g. "Yes;No;Maybe").
---@param buttons string
function api.CustomMessageBox(pid, id, label, buttons) end

---Display an input dialog at the center of the screen.
---@param pid number @The player ID for whom the input dialog should appear.
---@param id number @The numerical ID of the input dialog.
---@param label string @The text at the top of the input dialog.  note The text at the bottom of the input dialog.
---@param note string
function api.InputDialog(pid, id, label, note) end

---Display a password dialog at the center of the screen.
---
---Although similar to an input dialog, the password dialog replaces all input characters with asterisks.
---@param pid number @The player ID for whom the password dialog should appear.
---@param id number @The numerical ID of the password dialog.
---@param label string @The text at the top of the password dialog.  note The text at the bottom of the password dialog.
---@param note string
function api.PasswordDialog(pid, id, label, note) end

---Display a listbox at the center of the screen where each item takes up a row and is selectable, with the listbox only vanishing once the Ok button is pressed.
---@param pid number @The player ID for whom the listbox should appear.
---@param id number @The numerical ID of the listbox.
---@param label string @The text at the top of the listbox.  items The items in the listbox, separated by newlines (e.g. "Item 1\nItem 2").
---@param items string
function api.ListBox(pid, id, label, items) end

---Clear the last recorded quick key changes for a player.
---
---This is used to initialize the sending of new PlayerQuickKeys packets.
---@param pid number @The player ID whose quick key changes should be used.
function api.ClearQuickKeyChanges(pid) end

---Get the number of indexes in a player's latest quick key changes.
---@param pid number @The player ID whose quick key changes should be used.
---@return number
function api.GetQuickKeyChangesSize(pid) end

---Add a new quick key to the quick key changes for a player.
---@param pid number @The player ID whose quick key changes should be used.
---@param slot number @The type of the quick key (0 for ITEM, 1 for ITEM_MAGIC, 2 for MAGIC, 3 for UNASSIGNED).
---@param type number
---@param itemId string @The itemId of the item.
function api.AddQuickKey(pid, slot, type, itemId) end

---Get the slot of the quick key at a certain index in a player's latest quick key changes.
---@param pid number @The player ID whose quick key changes should be used.
---@param index number @The index of the quick key in the quick key changes vector.
---@return number
function api.GetQuickKeySlot(pid, index) end

---Get the type of the quick key at a certain index in a player's latest quick key changes.
---@param pid number @The player ID whose quick key changes should be used.
---@param index number @The index of the quick key in the quick key changes vector.
---@return number
function api.GetQuickKeyType(pid, index) end

---Get the itemId at a certain index in a player's latest quick key changes.
---@param pid number @The player ID whose quick key changes should be used.
---@param index number @The index of the quick key in the quick key changes vector.
---@return string
function api.GetQuickKeyItemId(pid, index) end

---Send a PlayerQuickKeys packet with a player's recorded quick key changes.
---@param pid number @The player ID whose quick key changes should be used.
function api.SendQuickKeyChanges(pid) end

---Determine whether a player can see the map marker of another player.
---
---Note: This currently has no effect, and is just an unimplemented stub.
---@param targetPid number @The player ID whose map marker should be hidden or revealed.
---@param affectedPid number @The player ID for whom the map marker will be hidden or revealed.
---@param state number @The state of the map marker (false to hide, true to reveal).
function api.SetMapVisibility(targetPid, affectedPid, state) end

---Determine whether a player's map marker can be seen by all other players.
---
---Note: This currently has no effect, and is just an unimplemented stub.
---@param targetPid number @The player ID whose map marker should be hidden or revealed.
---@param state number @The state of the map marker (false to hide, true to reveal).
function api.SetMapVisibilityAll(targetPid, state) end

---@param pid number
function api.InitializeQuickKeyChanges(pid) end
