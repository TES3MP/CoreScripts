---@class TES3MP
local api

---Use the last object list received by the server as the one being read.
function api.ReadReceivedObjectList() end

---Clear the data from the object list stored on the server.
function api.ClearObjectList() end

---Set the pid attached to the ObjectList.
---@param pid number @The player ID to whom the object list should be attached.
function api.SetObjectListPid(pid) end

---Take the contents of the read-only object list last received by the server from a player and move its contents to the stored object list that can be sent by the server.
function api.CopyReceivedObjectListToStore() end

---Get the number of indexes in the read object list.
---@return number
function api.GetObjectListSize() end

---Get the origin of the read object list.
---@return string
function api.GetObjectListOrigin() end

---Get the client script that the read object list originated from.
---
---Note: This is not yet implemented.
---@return string
function api.GetObjectListClientScript() end

---Get the action type used in the read object list.
---@return string
function api.GetObjectListAction() end

---Get the container subaction type used in the read object list.
---@return string
function api.GetObjectListContainerSubAction() end

---Check whether the object at a certain index in the read object list is a player.
---
---Note: Although most player data and events are dealt with in Player packets, object activation is general enough for players themselves to be included as objects in ObjectActivate packets.
---@param index number @The index of the object.
---@return boolean
function api.IsObjectPlayer(index) end

---Get the player ID of the object at a certain index in the read object list, only valid if the object is a player.
---
---Note: Currently, players can only be objects in ObjectActivate and ConsoleCommand packets.
---@param index number @The index of the object.
---@return number
function api.GetObjectPid(index) end

---Get the refId of the object at a certain index in the read object list.
---@param index number @The index of the object.
---@return string
function api.GetObjectRefId(index) end

---Get the refNum of the object at a certain index in the read object list.
---@param index number @The index of the object.
---@return number
function api.GetObjectRefNum(index) end

---Get the mpNum of the object at a certain index in the read object list.
---@param index number @The index of the object.
---@return number
function api.GetObjectMpNum(index) end

---Get the count of the object at a certain index in the read object list.
---@param index number @The index of the object.
---@return number
function api.GetObjectCount(index) end

---Get the charge of the object at a certain index in the read object list.
---@param index number @The index of the object.
---@return number
function api.GetObjectCharge(index) end

---Get the enchantment charge of the object at a certain index in the read object list.
---@param index number @The index of the object.
---@return number
function api.GetObjectEnchantmentCharge(index) end

---Get the soul of the object at a certain index in the read object list.
---@param index number @The index of the object.
---@return string
function api.GetObjectSoul(index) end

---Get the gold value of the object at a certain index in the read object list.
---
---This is used solely to get the gold value of gold. It is not used for other objects.
---@param index number @The index of the object.
---@return number
function api.GetObjectGoldValue(index) end

---Get the object scale of the object at a certain index in the read object list.
---@param index number @The index of the object.
---@return number
function api.GetObjectScale(index) end

---Get the object state of the object at a certain index in the read object list.
---@param index number @The index of the object.
---@return boolean
function api.GetObjectState(index) end

---Get the door state of the object at a certain index in the read object list.
---@param index number @The index of the object.
---@return number
function api.GetObjectDoorState(index) end

---Get the lock level of the object at a certain index in the read object list.
---@param index number @The index of the object.
---@return number
function api.GetObjectLockLevel(index) end

---Check whether the object at a certain index in the read object list has been activated by a player.
---@param index number @The index of the object.
---@return boolean
function api.DoesObjectHavePlayerActivating(index) end

---Get the player ID of the player activating the object at a certain index in the read object list.
---@param index number @The index of the object.
---@return number
function api.GetObjectActivatingPid(index) end

---Get the refId of the actor activating the object at a certain index in the read object list.
---@param index number @The index of the object.
---@return string
function api.GetObjectActivatingRefId(index) end

---Get the refNum of the actor activating the object at a certain index in the read object list.
---@param index number @The index of the object.
---@return number
function api.GetObjectActivatingRefNum(index) end

---Get the mpNum of the actor activating the object at a certain index in the read object list.
---@param index number @The index of the object.
---@return number
function api.GetObjectActivatingMpNum(index) end

---Get the name of the actor activating the object at a certain index in the read object list.
---@param index number @The index of the object.
---@return string
function api.GetObjectActivatingName(index) end

---Check whether the object at a certain index in the read object list is a summon.
---
---Only living actors can be summoned.
---@param index number
---@return boolean
function api.GetObjectSummonState(index) end

---Get the summon duration of the object at a certain index in the read object list.
---
---Note: Returns -1 if indefinite.
---@param index number @The index of the object.
---@return number
function api.GetObjectSummonDuration(index) end

---Check whether the object at a certain index in the read object list has a player as its summoner.
---
---Only living actors can be summoned.
---@param index number @The index of the object.
---@return boolean
function api.DoesObjectHavePlayerSummoner(index) end

---Get the player ID of the summoner of the object at a certain index in the read object list.
---@param index number @The index of the object.
---@return number
function api.GetObjectSummonerPid(index) end

---Get the refId of the actor summoner of the object at a certain index in the read object list.
---@param index number @The index of the object.
---@return string
function api.GetObjectSummonerRefId(index) end

---Get the refNum of the actor summoner of the object at a certain index in the read object list.
---@param index number @The index of the object.
---@return number
function api.GetObjectSummonerRefNum(index) end

---Get the mpNum of the actor summoner of the object at a certain index in the read object list.
---@param index number @The index of the object.
---@return number
function api.GetObjectSummonerMpNum(index) end

---Get the X position of the object at a certain index in the read object list.
---@param index number @The index of the object.
---@return number
function api.GetObjectPosX(index) end

---Get the Y position of the object at a certain index in the read object list.
---@param index number @The index of the object.
---@return number
function api.GetObjectPosY(index) end

---Get the Z position at a certain index in the read object list.
---@param index number @The index of the object.
---@return number
function api.GetObjectPosZ(index) end

---Get the X rotation of the object at a certain index in the read object list.
---@param index number @The index of the object.
---@return number
function api.GetObjectRotX(index) end

---Get the Y rotation of the object at a certain index in the read object list.
---@param index number @The index of the object.
---@return number
function api.GetObjectRotY(index) end

---Get the Z rotation of the object at a certain index in the read object list.
---@param index number @The index of the object.
---@return number
function api.GetObjectRotZ(index) end

---Get the videoFilename of the object at a certain index in the read object list.
---@param index number
---@return string
function api.GetVideoFilename(index) end

---Get the number of container item indexes of the object at a certain index in the read object list.
---@param objectIndex number
---@return number
function api.GetContainerChangesSize(objectIndex) end

---Get the refId of the container item at a certain itemIndex in the container changes of the object at a certain objectIndex in the read object list.
---@param objectIndex number @The index of the object.
---@param itemIndex number @The index of the container item.
---@return string
function api.GetContainerItemRefId(objectIndex, itemIndex) end

---Get the item count of the container item at a certain itemIndex in the container changes of the object at a certain objectIndex in the read object list.
---@param objectIndex number @The index of the object.
---@param itemIndex number @The index of the container item.
---@return number
function api.GetContainerItemCount(objectIndex, itemIndex) end

---Get the charge of the container item at a certain itemIndex in the container changes of the object at a certain objectIndex in the read object list.
---@param objectIndex number @The index of the object.
---@param itemIndex number @The index of the container item.
---@return number
function api.GetContainerItemCharge(objectIndex, itemIndex) end

---Get the enchantment charge of the container item at a certain itemIndex in the container changes of the object at a certain objectIndex in the read object list.
---@param objectIndex number @The index of the object.
---@param itemIndex number @The index of the container item.
---@return number
function api.GetContainerItemEnchantmentCharge(objectIndex, itemIndex) end

---Get the soul of the container item at a certain itemIndex in the container changes of the object at a certain objectIndex in the read object list.
---@param objectIndex number @The index of the object.
---@param itemIndex number @The index of the container item.
---@return string
function api.GetContainerItemSoul(objectIndex, itemIndex) end

---Get the action count of the container item at a certain itemIndex in the container changes of the object at a certain objectIndex in the read object list.
---@param objectIndex number @The index of the object.
---@param itemIndex number @The index of the container item.
---@return number
function api.GetContainerItemActionCount(objectIndex, itemIndex) end

---Check whether the object at a certain index in the read object list has a container.
---
---Note: Only ObjectLists from ObjectPlace packets contain this information. Objects from received ObjectSpawn packets can always be assumed to have a container.
---@param index number @The index of the object.
---@return boolean
function api.DoesObjectHaveContainer(index) end

---Set the cell of the temporary object list stored on the server.
---
---The cell is determined to be an exterior cell if it fits the pattern of a number followed by a comma followed by another number.
---@param cellDescription string @The description of the cell.
function api.SetObjectListCell(cellDescription) end

---Set the action type of the temporary object list stored on the server.
---@param action string @The action type (0 for SET, 1 for ADD, 2 for REMOVE, 3 for REQUEST).
function api.SetObjectListAction(action) end

---Set the console command of the temporary object list stored on the server.
---
---When sent, the command will run once on every object added to the object list. If no objects have been added, it will run once without any object reference.
---@param consoleCommand string @The console command.
function api.SetObjectListConsoleCommand(consoleCommand) end

---Set the refId of the temporary object stored on the server.
---@param refId string @The refId.
function api.SetObjectRefId(refId) end

---Set the refNum of the temporary object stored on the server.
---
---On the other hand, objects placed or spawned via the server should always have a refNum of 0.
---@param refNum number @The refNum.
function api.SetObjectRefNum(refNum) end

---Set the mpNum of the temporary object stored on the server.
---
---Objects loaded from .ESM and .ESP data files should always have an mpNum of 0, because they have unique refNumes instead.
---@param mpNum number @The mpNum.
function api.SetObjectMpNum(mpNum) end

---Set the object count of the temporary object stored on the server.
---
---This determines the quantity of an object, with the exception of gold.
---@param count number @The object count.
function api.SetObjectCount(count) end

---Set the charge of the temporary object stored on the server.
---
---Object durabilities are set through this value.
---@param charge number @The charge.
function api.SetObjectCharge(charge) end

---Set the enchantment charge of the temporary object stored on the server.
---
---Object durabilities are set through this value.
---@param enchantmentCharge number
function api.SetObjectEnchantmentCharge(enchantmentCharge) end

---Set the soul of the temporary object stored on the server.
---@param soul string
function api.SetObjectSoul(soul) end

---Set the gold value of the temporary object stored on the server.
---
---This is used solely to set the gold value for gold. It has no effect on other objects.
---@param goldValue number @The gold value.
function api.SetObjectGoldValue(goldValue) end

---Set the scale of the temporary object stored on the server.
---
---Objects are smaller or larger than their default size based on their scale.
---@param scale number @The scale.
function api.SetObjectScale(scale) end

---Set the object state of the temporary object stored on the server.
---
---Objects are enabled or disabled based on their object state.
---@param objectState boolean @The object state.
function api.SetObjectState(objectState) end

---Set the lock level of the temporary object stored on the server.
---@param lockLevel number @The lock level.
function api.SetObjectLockLevel(lockLevel) end

---Set the summon duration of the temporary object stored on the server.
---@param summonDuration number @The summon duration.
function api.SetObjectSummonDuration(summonDuration) end

---Set the disarm state of the temporary object stored on the server.
---@param disarmState boolean @The disarmState.
function api.SetObjectDisarmState(disarmState) end

---Set the summon state of the temporary object stored on the server.
---
---This only affects living actors and determines whether they are summons of another living actor.
---@param summonState boolean @The summon state.
function api.SetObjectSummonState(summonState) end

---Set the position of the temporary object stored on the server.
---@param x number @The X position.
---@param y number @The Y position.
---@param z number @The Z position.
function api.SetObjectPosition(x, y, z) end

---Set the rotation of the temporary object stored on the server.
---@param x number @The X rotation.
---@param y number @The Y rotation.
---@param z number @The Z rotation.
function api.SetObjectRotation(x, y, z) end

---Set the player ID of the player activating the temporary object stored on the server. Currently only used for ObjectActivate packets.
---@param pid number @The pid of the player.
function api.SetObjectActivatingPid(pid) end

---Set the door state of the temporary object stored on the server.
---
---Doors are open or closed based on their door state.
---@param doorState number @The door state.
function api.SetObjectDoorState(doorState) end

---Set the teleport state of the temporary object stored on the server.
---
---If a door's teleport state is true, interacting with the door teleports a player to its destination. If it's false, it opens and closes like a regular door.
---@param teleportState boolean @The teleport state.
function api.SetObjectDoorTeleportState(teleportState) end

---Set the door destination cell of the temporary object stored on the server.
---
---The cell is determined to be an exterior cell if it fits the pattern of a number followed by a comma followed by another number.
---@param cellDescription string @The description of the cell.
function api.SetObjectDoorDestinationCell(cellDescription) end

---Set the door destination position of the temporary object stored on the server.
---@param x number @The X position.
---@param y number @The Y position.
---@param z number @The Z position.
function api.SetObjectDoorDestinationPosition(x, y, z) end

---Set the door destination rotation of the temporary object stored on the server.
---
---Note: Because this sets the rotation a player will have upon using the door, and rotation on the Y axis has no effect on players, the Y value has been omitted as an argument.
---@param x number @The X rotation.
---@param z number @The Z rotation.
function api.SetObjectDoorDestinationRotation(x, z) end

---Set a player as the object in the temporary object stored on the server. Currently only used for ConsoleCommand packets.
---@param pid number @The pid of the player.
function api.SetPlayerAsObject(pid) end

---Set the refId of the temporary container item stored on the server.
---@param refId string @The refId.
function api.SetContainerItemRefId(refId) end

---Set the item count of the temporary container item stored on the server.
---@param count number @The item count.
function api.SetContainerItemCount(count) end

---Set the charge of the temporary container item stored on the server.
---@param charge number @The charge.
function api.SetContainerItemCharge(charge) end

---Set the enchantment charge of the temporary container item stored on the server.
---@param enchantmentCharge number
function api.SetContainerItemEnchantmentCharge(enchantmentCharge) end

---Set the soul of the temporary container item stored on the server.
---@param soul string
function api.SetContainerItemSoul(soul) end

---Set the action count of the container item at a certain itemIndex in the container changes of the object at a certain objectIndex in the object list stored on the server.
---
---When resending a received Container packet, this allows you to correct the amount of items removed from a container by a player when it conflicts with what other players have already taken.
---@param objectIndex number @The index of the object.
---@param itemIndex number @The index of the container item.
---@param actionCount number @The action count.
function api.SetContainerItemActionCountByIndex(objectIndex, itemIndex, actionCount) end

---Add a copy of the server's temporary object to the server's currently stored object list.
---
---In the process, the server's temporary object will automatically be cleared so a new one can be set up.
function api.AddObject() end

---Add a copy of the server's temporary container item to the container changes of the server's temporary object.
---
---In the process, the server's temporary container item will automatically be cleared so a new one can be set up.
function api.AddContainerItem() end

---Send an ObjectActivate packet.
---@param sendToOtherPlayers boolean|nil @Whether this packet should be sent to players other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendObjectActivate(sendToOtherPlayers, skipAttachedPlayer) end

---Send an ObjectPlace packet.
---@param sendToOtherPlayers boolean|nil @Whether this packet should be sent to players other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendObjectPlace(sendToOtherPlayers, skipAttachedPlayer) end

---Send an ObjectSpawn packet.
---@param sendToOtherPlayers boolean|nil @Whether this packet should be sent to players other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendObjectSpawn(sendToOtherPlayers, skipAttachedPlayer) end

---Send an ObjectDelete packet.
---@param sendToOtherPlayers boolean
---@param skipAttachedPlayer boolean
function api.SendObjectDelete(sendToOtherPlayers, skipAttachedPlayer) end

---Send an ObjectLock packet.
---@param sendToOtherPlayers boolean|nil @Whether this packet should be sent to players other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendObjectLock(sendToOtherPlayers, skipAttachedPlayer) end

---Send an ObjectTrap packet.
---@param sendToOtherPlayers boolean
---@param skipAttachedPlayer boolean
function api.SendObjectTrap(sendToOtherPlayers, skipAttachedPlayer) end

---Send an ObjectScale packet.
---@param sendToOtherPlayers boolean|nil @Whether this packet should be sent to players other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendObjectScale(sendToOtherPlayers, skipAttachedPlayer) end

---Send an ObjectState packet.
---@param sendToOtherPlayers boolean|nil @Whether this packet should be sent to players other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendObjectState(sendToOtherPlayers, skipAttachedPlayer) end

---Send a DoorState packet.
---@param sendToOtherPlayers boolean|nil @Whether this packet should be sent to players other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendDoorState(sendToOtherPlayers, skipAttachedPlayer) end

---Send a DoorDestination packet.
---@param sendToOtherPlayers boolean|nil @Whether this packet should be sent to players other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendDoorDestination(sendToOtherPlayers, skipAttachedPlayer) end

---Send a Container packet.
---@param sendToOtherPlayers boolean|nil @Whether this packet should be sent to players other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendContainer(sendToOtherPlayers, skipAttachedPlayer) end

---Send a VideoPlay packet.
---@param sendToOtherPlayers boolean|nil @Whether this packet should be sent to players other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendVideoPlay(sendToOtherPlayers, skipAttachedPlayer) end

---Send a ConsoleCommand packet.
---@param sendToOtherPlayers boolean|nil @Whether this packet should be sent to players other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendConsoleCommand(sendToOtherPlayers, skipAttachedPlayer) end

function api.ReadLastObjectList() end

function api.ReadLastEvent() end

---@param pid number
function api.InitializeObjectList(pid) end

---@param pid number
function api.InitializeEvent(pid) end

function api.CopyLastObjectListToStore() end

---@return number
function api.GetObjectChangesSize() end

---@return string
function api.GetEventAction() end

---@return string
function api.GetEventContainerSubAction() end

---@param index number
---@return number
function api.GetObjectRefNumIndex(index) end

---@param index number
---@return number
function api.GetObjectSummonerRefNumIndex(index) end

---@param cellDescription string
function api.SetEventCell(cellDescription) end

---@param action string
function api.SetEventAction(action) end

---@param consoleCommand string
function api.SetEventConsoleCommand(consoleCommand) end

---@param refNum number
function api.SetObjectRefNumIndex(refNum) end

function api.AddWorldObject() end
