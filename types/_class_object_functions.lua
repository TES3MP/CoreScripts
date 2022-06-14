---@class TES3MP
local api

---Use the last object list received by the server as the one being read.
function api.ReadReceivedObjectList() end

---Clear the data from the object list stored on the server.
function api.ClearObjectList() end

---Set the pid attached to the ObjectList.
---@param pid integer @The player ID to whom the object list should be attached.
function api.SetObjectListPid(pid) end

---Take the contents of the read-only object list last received by the server from a player and move its contents to the stored object list that can be sent by the server.
function api.CopyReceivedObjectListToStore() end

---Get the number of indexes in the read object list.
---@return integer @The number of indexes.
function api.GetObjectListSize() end

---Get the origin of the read object list.
---@return string @The origin (0 for CLIENT_GAMEPLAY, 1 for CLIENT_CONSOLE, 2 for CLIENT_DIALOGUE, 3 for CLIENT_SCRIPT_LOCAL, 4 for CLIENT_SCRIPT_GLOBAL, 5 for SERVER_SCRIPT).
function api.GetObjectListOrigin() end

---Get the client script that the read object list originated from.
---@return string @The ID of the client script.
function api.GetObjectListClientScript() end

---Get the action type used in the read object list.
---@return string @The action type (0 for SET, 1 for ADD, 2 for REMOVE, 3 for REQUEST).
function api.GetObjectListAction() end

---Get the console command used in the read object list.
---@return string @The console command.
function api.GetObjectListConsoleCommand() end

---Get the container subaction type used in the read object list.
---@return string @The action type (0 for NONE, 1 for DRAG, 2 for DROP, 3 for TAKE_ALL).
function api.GetObjectListContainerSubAction() end

---Check whether the object at a certain index in the read object list is a player.
---
---Note: Although most player data and events are dealt with in Player packets, object activation is general enough for players themselves to be included as objects in ObjectActivate packets.
---@param index integer @The index of the object.
---@return boolean @Whether the object is a player.
function api.IsObjectPlayer(index) end

---Get the player ID of the object at a certain index in the read object list, only valid if the object is a player.
---
---Note: Currently, players can only be objects in ObjectActivate and ConsoleCommand packets.
---@param index integer @The index of the object.
---@return integer @The player ID of the object.
function api.GetObjectPid(index) end

---Get the refId of the object at a certain index in the read object list.
---@param index integer @The index of the object.
---@return string @The refId.
function api.GetObjectRefId(index) end

---Get the refNum of the object at a certain index in the read object list.
---@param index integer @The index of the object.
---@return integer @The refNum.
function api.GetObjectRefNum(index) end

---Get the mpNum of the object at a certain index in the read object list.
---@param index integer @The index of the object.
---@return integer @The mpNum.
function api.GetObjectMpNum(index) end

---Get the count of the object at a certain index in the read object list.
---@param index integer @The index of the object.
---@return integer @The object count.
function api.GetObjectCount(index) end

---Get the charge of the object at a certain index in the read object list.
---@param index integer @The index of the object.
---@return integer @The charge.
function api.GetObjectCharge(index) end

---Get the enchantment charge of the object at a certain index in the read object list.
---@param index integer @The index of the object.
---@return number @The enchantment charge.
function api.GetObjectEnchantmentCharge(index) end

---Get the soul of the object at a certain index in the read object list.
---@param index integer @The index of the object.
---@return string @The soul.
function api.GetObjectSoul(index) end

---Get the gold value of the object at a certain index in the read object list.
---
---This is used solely to get the gold value of gold. It is not used for other objects.
---@param index integer @The index of the object.
---@return integer @The gold value.
function api.GetObjectGoldValue(index) end

---Get the object scale of the object at a certain index in the read object list.
---@param index integer @The index of the object.
---@return number @The object scale.
function api.GetObjectScale(index) end

---Get the object sound ID of the object at a certain index in the read object list.
---@param index integer @The index of the object.
---@return string @The object sound ID.
function api.GetObjectSoundId(index) end

---Get the object state of the object at a certain index in the read object list.
---@param index integer @The index of the object.
---@return boolean @The object state.
function api.GetObjectState(index) end

---Get the door state of the object at a certain index in the read object list.
---@param index integer @The index of the object.
---@return integer @The door state.
function api.GetObjectDoorState(index) end

---Get the lock level of the object at a certain index in the read object list.
---@param index integer @The index of the object.
---@return integer @The lock level.
function api.GetObjectLockLevel(index) end

---Get the dialogue choice type for the object at a certain index in the read object list.
---@param index integer @The index of the object.
---@return integer @The dialogue choice type.
function api.GetObjectDialogueChoiceType(index) end

---Get the dialogue choice topic for the object at a certain index in the read object list.
---@param index integer @The index of the object.
---@return string @The dialogue choice topic.
function api.GetObjectDialogueChoiceTopic(index) end

---Get the gold pool of the object at a certain index in the read object list.
---@param index integer @The index of the object.
---@return integer @The gold pool.
function api.GetObjectGoldPool(index) end

---Get the hour of the last gold restock of the object at a certain index in the read object list.
---@param index integer @The index of the object.
---@return number @The hour of the last gold restock.
function api.GetObjectLastGoldRestockHour(index) end

---Get the day of the last gold restock of the object at a certain index in the read object list.
---@param index integer @The index of the object.
---@return integer @The day of the last gold restock.
function api.GetObjectLastGoldRestockDay(index) end

---Check whether the object at a certain index in the read object list has been activated by a player.
---@param index integer @The index of the object.
---@return boolean @Whether the object has been activated by a player.
function api.DoesObjectHavePlayerActivating(index) end

---Get the player ID of the player activating the object at a certain index in the read object list.
---@param index integer @The index of the object.
---@return integer @The player ID of the activating player.
function api.GetObjectActivatingPid(index) end

---Get the refId of the actor activating the object at a certain index in the read object list.
---@param index integer @The index of the object.
---@return string @The refId of the activating actor.
function api.GetObjectActivatingRefId(index) end

---Get the refNum of the actor activating the object at a certain index in the read object list.
---@param index integer @The index of the object.
---@return integer @The refNum of the activating actor.
function api.GetObjectActivatingRefNum(index) end

---Get the mpNum of the actor activating the object at a certain index in the read object list.
---@param index integer @The index of the object.
---@return integer @The mpNum of the activating actor.
function api.GetObjectActivatingMpNum(index) end

---Get the name of the actor activating the object at a certain index in the read object list.
---@param index integer @The index of the object.
---@return string @The name of the activating actor.
function api.GetObjectActivatingName(index) end

---Check whether the object at a certain index in the read object list has been hit successfully.
---@param index integer @The index of the object.
---@return boolean @The success state.
function api.GetObjectHitSuccess(index) end

---Get the damage caused to the object at a certain index in the read object list in a hit.
---@param index integer @The index of the object.
---@return number @The damage.
function api.GetObjectHitDamage(index) end

---Check whether the object at a certain index in the read object list has blocked the hit on it.
---@param index integer @The index of the object.
---@return boolean @The block state.
function api.GetObjectHitBlock(index) end

---Check whether the object at a certain index in the read object list has been knocked down.
---@param index integer @The index of the object.
---@return boolean @The knockdown state.
function api.GetObjectHitKnockdown(index) end

---Check whether the object at a certain index in the read object list has been hit by a player.
---@param index integer @The index of the object.
---@return boolean @Whether the object has been hit by a player.
function api.DoesObjectHavePlayerHitting(index) end

---Get the player ID of the player hitting the object at a certain index in the read object list.
---@param index integer @The index of the object.
---@return integer @The player ID of the hitting player.
function api.GetObjectHittingPid(index) end

---Get the refId of the actor hitting the object at a certain index in the read object list.
---@param index integer @The index of the object.
---@return string @The refId of the hitting actor.
function api.GetObjectHittingRefId(index) end

---Get the refNum of the actor hitting the object at a certain index in the read object list.
---@param index integer @The index of the object.
---@return integer @The refNum of the hitting actor.
function api.GetObjectHittingRefNum(index) end

---Get the mpNum of the actor hitting the object at a certain index in the read object list.
---@param index integer @The index of the object.
---@return integer @The mpNum of the hitting actor.
function api.GetObjectHittingMpNum(index) end

---Get the name of the actor hitting the object at a certain index in the read object list.
---@param index integer @The index of the object.
---@return string @The name of the hitting actor.
function api.GetObjectHittingName(index) end

---Check whether the object at a certain index in the read object list is a summon.
---
---Only living actors can be summoned.
---@return boolean @The summon state.
function api.GetObjectSummonState() end

---Get the summon effect ID of the object at a certain index in the read object list.
---@param index integer @The index of the object.
---@return number @The summon effect ID.
function api.GetObjectSummonEffectId(index) end

---Get the summon spell ID of the object at a certain index in the read object list.
---@param index integer @The index of the object.
---@return string @The summon spell ID.
function api.GetObjectSummonSpellId(index) end

---Get the summon duration of the object at a certain index in the read object list.
---
---Note: Returns -1 if indefinite.
---@param index integer @The index of the object.
---@return number @The summon duration.
function api.GetObjectSummonDuration(index) end

---Check whether the object at a certain index in the read object list has a player as its summoner.
---
---Only living actors can be summoned.
---@param index integer @The index of the object.
---@return boolean @Whether a player is the summoner of the object.
function api.DoesObjectHavePlayerSummoner(index) end

---Get the player ID of the summoner of the object at a certain index in the read object list.
---@param index integer @The index of the object.
---@return integer @The player ID of the summoner.
function api.GetObjectSummonerPid(index) end

---Get the refId of the actor summoner of the object at a certain index in the read object list.
---@param index integer @The index of the object.
---@return string @The refId of the summoner.
function api.GetObjectSummonerRefId(index) end

---Get the refNum of the actor summoner of the object at a certain index in the read object list.
---@param index integer @The index of the object.
---@return integer @The refNum of the summoner.
function api.GetObjectSummonerRefNum(index) end

---Get the mpNum of the actor summoner of the object at a certain index in the read object list.
---@param index integer @The index of the object.
---@return integer @The mpNum of the summoner.
function api.GetObjectSummonerMpNum(index) end

---Get the X position of the object at a certain index in the read object list.
---@param index integer @The index of the object.
---@return number @The X position.
function api.GetObjectPosX(index) end

---Get the Y position of the object at a certain index in the read object list.
---@param index integer @The index of the object.
---@return number @The Y position.
function api.GetObjectPosY(index) end

---Get the Z position at a certain index in the read object list.
---@param index integer @The index of the object.
---@return number @The Z position.
function api.GetObjectPosZ(index) end

---Get the X rotation of the object at a certain index in the read object list.
---@param index integer @The index of the object.
---@return number @The X rotation.
function api.GetObjectRotX(index) end

---Get the Y rotation of the object at a certain index in the read object list.
---@param index integer @The index of the object.
---@return number @The Y rotation.
function api.GetObjectRotY(index) end

---Get the Z rotation of the object at a certain index in the read object list.
---@param index integer @The index of the object.
---@return number @The Z rotation.
function api.GetObjectRotZ(index) end

---Get the videoFilename of the object at a certain index in the read object list.
---@return string @The videoFilename.
function api.GetVideoFilename() end

---Get the number of client local variables of the object at a certain index in the read object list.
---@param objectIndex integer @The index of the object.
---@return integer @The number of client local variables.
function api.GetClientLocalsSize(objectIndex) end

---Get the internal script index of the client local variable at a certain variableIndex in the client locals of the object at a certain objectIndex in the read object list.
---@param objectIndex integer @The index of the object.
---@param variableIndex integer @The index of the client local.
---@return integer @The internal script index.
function api.GetClientLocalInternalIndex(objectIndex, variableIndex) end

---Get the type of the client local variable at a certain variableIndex in the client locals of the object at a certain objectIndex in the read object list.
---@param objectIndex integer @The index of the object.
---@param variableIndex integer @The index of the client local.
---@return integer @The variable type (0 for INTEGER, 1 for LONG, 2 for FLOAT).
function api.GetClientLocalVariableType(objectIndex, variableIndex) end

---Get the integer value of the client local variable at a certain variableIndex in the client locals of the object at a certain objectIndex in the read object list.
---@param objectIndex integer @The index of the object.
---@param variableIndex integer @The index of the client local.
---@return integer @The integer value.
function api.GetClientLocalIntValue(objectIndex, variableIndex) end

---Get the float value of the client local variable at a certain variableIndex in the client locals of the object at a certain objectIndex in the read object list.
---@param objectIndex integer @The index of the object.
---@param variableIndex integer @The index of the client local.
---@return number @The float value.
function api.GetClientLocalFloatValue(objectIndex, variableIndex) end

---Get the number of container item indexes of the object at a certain index in the read object list.
---@param objectIndex integer @The index of the object.
---@return integer @The number of container item indexes.
function api.GetContainerChangesSize(objectIndex) end

---Get the refId of the container item at a certain itemIndex in the container changes of the object at a certain objectIndex in the read object list.
---@param objectIndex integer @The index of the object.
---@param itemIndex integer @The index of the container item.
---@return string @The refId.
function api.GetContainerItemRefId(objectIndex, itemIndex) end

---Get the item count of the container item at a certain itemIndex in the container changes of the object at a certain objectIndex in the read object list.
---@param objectIndex integer @The index of the object.
---@param itemIndex integer @The index of the container item.
---@return integer @The item count.
function api.GetContainerItemCount(objectIndex, itemIndex) end

---Get the charge of the container item at a certain itemIndex in the container changes of the object at a certain objectIndex in the read object list.
---@param objectIndex integer @The index of the object.
---@param itemIndex integer @The index of the container item.
---@return integer @The charge.
function api.GetContainerItemCharge(objectIndex, itemIndex) end

---Get the enchantment charge of the container item at a certain itemIndex in the container changes of the object at a certain objectIndex in the read object list.
---@param objectIndex integer @The index of the object.
---@param itemIndex integer @The index of the container item.
---@return number @The enchantment charge.
function api.GetContainerItemEnchantmentCharge(objectIndex, itemIndex) end

---Get the soul of the container item at a certain itemIndex in the container changes of the object at a certain objectIndex in the read object list.
---@param objectIndex integer @The index of the object.
---@param itemIndex integer @The index of the container item.
---@return string @The soul.
function api.GetContainerItemSoul(objectIndex, itemIndex) end

---Get the action count of the container item at a certain itemIndex in the container changes of the object at a certain objectIndex in the read object list.
---@param objectIndex integer @The index of the object.
---@param itemIndex integer @The index of the container item.
---@return integer @The action count.
function api.GetContainerItemActionCount(objectIndex, itemIndex) end

---Check whether the object at a certain index in the read object list has a container.
---
---Note: Only ObjectLists from ObjectPlace packets contain this information. Objects from received ObjectSpawn packets can always be assumed to have a container.
---@param index integer @The index of the object.
---@return boolean @Whether the object has a container.
function api.DoesObjectHaveContainer(index) end

---Check whether the object at a certain index in the read object list has been dropped by a player.
---
---Note: Only ObjectLists from ObjectPlace packets contain this information.
---@param index integer @The index of the object.
---@return boolean @Whether the object has been dropped by a player.
function api.IsObjectDroppedByPlayer(index) end

---Set the cell of the temporary object list stored on the server.
---
---The cell is determined to be an exterior cell if it fits the pattern of a number followed by a comma followed by another number.
---@param cellDescription string @The description of the cell.
function api.SetObjectListCell(cellDescription) end

---Set the action type of the temporary object list stored on the server.
---@param action string @The action type (0 for SET, 1 for ADD, 2 for REMOVE, 3 for REQUEST).
function api.SetObjectListAction(action) end

---Set the container subaction type of the temporary object list stored on the server.
---@param subAction string @The action type (0 for NONE, 1 for DRAG, 2 for DROP, 3 for TAKE_ALL, 4 for REPLY_TO_REQUEST, 5 for RESTOCK_RESULT).
function api.SetObjectListContainerSubAction(subAction) end

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
---Every object loaded from .ESM and .ESP data files has a unique refNum which needs to be retained to refer to it in packets.
---
---On the other hand, objects placed or spawned via the server should always have a refNum of 0.
---@param refNum integer @The refNum.
function api.SetObjectRefNum(refNum) end

---Set the mpNum of the temporary object stored on the server.
---
---Every object placed or spawned via the server is assigned an mpNum by incrementing the last mpNum stored on the server. Scripts should take care to ensure that mpNums are kept unique for these objects.
---
---Objects loaded from .ESM and .ESP data files should always have an mpNum of 0, because they have unique refNumes instead.
---@param mpNum integer @The mpNum.
function api.SetObjectMpNum(mpNum) end

---Set the object count of the temporary object stored on the server.
---
---This determines the quantity of an object, with the exception of gold.
---@param count integer @The object count.
function api.SetObjectCount(count) end

---Set the charge of the temporary object stored on the server.
---
---Object durabilities are set through this value.
---@param charge integer @The charge.
function api.SetObjectCharge(charge) end

---Set the enchantment charge of the temporary object stored on the server.
---
---Object durabilities are set through this value.
---@param enchantmentCharge number @The enchantment charge.
function api.SetObjectEnchantmentCharge(enchantmentCharge) end

---Set the soul of the temporary object stored on the server.
---@param soul string @The ID of the soul.
function api.SetObjectSoul(soul) end

---Set the gold value of the temporary object stored on the server.
---
---This is used solely to set the gold value for gold. It has no effect on other objects.
---@param goldValue integer @The gold value.
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
---@param lockLevel integer @The lock level.
function api.SetObjectLockLevel(lockLevel) end

---Set the dialogue choice type of the temporary object stored on the server.
---@param dialogueChoiceType integer @The dialogue choice type.
function api.SetObjectDialogueChoiceType(dialogueChoiceType) end

---Set the dialogue choice topic for the temporary object stored on the server.
---@param topic string @The dialogue choice topic.
function api.SetObjectDialogueChoiceTopic(topic) end

---Set the gold pool of the temporary object stored on the server.
---@param goldPool integer @The gold pool.
function api.SetObjectGoldPool(goldPool) end

---Set the hour of the last gold restock of the temporary object stored on the server.
---@param hour number @The hour of the last gold restock.
function api.SetObjectLastGoldRestockHour(hour) end

---Set the day of the last gold restock of the temporary object stored on the server.
---@param day integer @The day of the last gold restock.
function api.SetObjectLastGoldRestockDay(day) end

---Set the disarm state of the temporary object stored on the server.
---@param disarmState boolean @The disarmState.
function api.SetObjectDisarmState(disarmState) end

---Set the droppedByPlayer state of the temporary object stored on the server.
---@param dropedByPlayerState boolean @Whether the object has been dropped by a player or not.
function api.SetObjectDroppedByPlayerState(dropedByPlayerState) end

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

---Set the summon state of the temporary object stored on the server.
---
---This only affects living actors and determines whether they are summons of another living actor.
---@param summonState boolean @The summon state.
function api.SetObjectSummonState(summonState) end

---Set the summon effect ID of the temporary object stored on the server.
---@param summonEffectId integer @The summon effect ID.
function api.SetObjectSummonEffectId(summonEffectId) end

---Set the summon spell ID of the temporary object stored on the server.
---@param summonSpellId string @The summon spell ID.
function api.SetObjectSummonSpellId(summonSpellId) end

---Set the summon duration of the temporary object stored on the server.
---@param summonDuration number @The summon duration.
function api.SetObjectSummonDuration(summonDuration) end

---Set the player ID of the summoner of the temporary object stored on the server.
---@param pid integer @The player ID of the summoner.
function api.SetObjectSummonerPid(pid) end

---Set the refNum of the actor summoner of the temporary object stored on the server.
---@param refNum integer @The refNum of the summoner.
function api.SetObjectSummonerRefNum(refNum) end

---Set the mpNum of the actor summoner of the temporary object stored on the server.
---@param mpNum integer @The mpNum of the summoner.
function api.SetObjectSummonerMpNum(mpNum) end

---Set the player ID of the player activating the temporary object stored on the server. Currently only used for ObjectActivate packets.
---@param pid integer @The pid of the player.
function api.SetObjectActivatingPid(pid) end

---Set the door state of the temporary object stored on the server.
---
---Doors are open or closed based on their door state.
---@param doorState integer @The door state.
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
---@param pid integer @The pid of the player.
function api.SetPlayerAsObject(pid) end

---Set the refId of the temporary container item stored on the server.
---@param refId string @The refId.
function api.SetContainerItemRefId(refId) end

---Set the item count of the temporary container item stored on the server.
---@param count integer @The item count.
function api.SetContainerItemCount(count) end

---Set the charge of the temporary container item stored on the server.
---@param charge integer @The charge.
function api.SetContainerItemCharge(charge) end

---Set the enchantment charge of the temporary container item stored on the server.
---@param enchantmentCharge number @The enchantment charge.
function api.SetContainerItemEnchantmentCharge(enchantmentCharge) end

---Set the soul of the temporary container item stored on the server.
---@param soul string @The soul.
function api.SetContainerItemSoul(soul) end

---Set the action count of the container item at a certain itemIndex in the container changes of the object at a certain objectIndex in the object list stored on the server.
---
---When resending a received Container packet, this allows you to correct the amount of items removed from a container by a player when it conflicts with what other players have already taken.
---@param objectIndex integer @The index of the object.
---@param itemIndex integer @The index of the container item.
---@param actionCount integer @The action count.
function api.SetContainerItemActionCountByIndex(objectIndex, itemIndex, actionCount) end

---Add a copy of the server's temporary object to the server's currently stored object list.
---
---In the process, the server's temporary object will automatically be cleared so a new one can be set up.
function api.AddObject() end

---Add a client local variable with an integer value to the client locals of the server's temporary object.
---@param internalIndex integer @The internal script index of the client local.
---@param variableType integer @The variable type (0 for SHORT, 1 for LONG).
---@param intValue integer @The integer value of the client local.
function api.AddClientLocalInteger(internalIndex, variableType, intValue) end

---Add a client local variable with a float value to the client locals of the server's temporary object.
---@param internalIndex integer @The internal script index of the client local.
---@param floatValue number @The float value of the client local.
function api.AddClientLocalFloat(internalIndex, floatValue) end

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
---@param sendToOtherPlayers boolean|nil @Whether this packet should be sent to players other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendObjectDelete(sendToOtherPlayers, skipAttachedPlayer) end

---Send an ObjectLock packet.
---@param sendToOtherPlayers boolean|nil @Whether this packet should be sent to players other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendObjectLock(sendToOtherPlayers, skipAttachedPlayer) end

---Send an ObjectDialogueChoice packet.
---@param sendToOtherPlayers boolean|nil @Whether this packet should be sent to players other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendObjectDialogueChoice(sendToOtherPlayers, skipAttachedPlayer) end

---Send an ObjectMiscellaneous packet.
---@param sendToOtherPlayers boolean|nil @Whether this packet should be sent to players other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendObjectMiscellaneous(sendToOtherPlayers, skipAttachedPlayer) end

---Send an ObjectRestock packet.
---@param sendToOtherPlayers boolean|nil @Whether this packet should be sent to players other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendObjectRestock(sendToOtherPlayers, skipAttachedPlayer) end

---Send an ObjectTrap packet.
---@param sendToOtherPlayers boolean|nil @Whether this packet should be sent to players other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendObjectTrap(sendToOtherPlayers, skipAttachedPlayer) end

---Send an ObjectScale packet.
---@param sendToOtherPlayers boolean|nil @Whether this packet should be sent to players other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendObjectScale(sendToOtherPlayers, skipAttachedPlayer) end

---Send an ObjectSound packet.
---@param sendToOtherPlayers boolean|nil @Whether this packet should be sent to players other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendObjectSound(sendToOtherPlayers, skipAttachedPlayer) end

---Send an ObjectState packet.
---@param sendToOtherPlayers boolean|nil @Whether this packet should be sent to players other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendObjectState(sendToOtherPlayers, skipAttachedPlayer) end

---Send an ObjectMove packet.
---@param sendToOtherPlayers boolean|nil @Whether this packet should be sent to players other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendObjectMove(sendToOtherPlayers, skipAttachedPlayer) end

---Send an ObjectRotate packet.
---@param sendToOtherPlayers boolean|nil @Whether this packet should be sent to players other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendObjectRotate(sendToOtherPlayers, skipAttachedPlayer) end

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

---Send a ClientScriptLocal packet.
---@param sendToOtherPlayers boolean|nil @Whether this packet should be sent to players other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendClientScriptLocal(sendToOtherPlayers, skipAttachedPlayer) end

---Send a ConsoleCommand packet.
---@param sendToOtherPlayers boolean|nil @Whether this packet should be sent to players other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendConsoleCommand(sendToOtherPlayers, skipAttachedPlayer) end
