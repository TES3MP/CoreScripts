---@class TES3MP
local api

---Use the last worldstate received by the server as the one being read.
function api.ReadReceivedWorldstate() end

---Take the contents of the read-only worldstate last received by the server from a player and move its contents to the stored worldstate that can be sent by the server.
function api.CopyReceivedWorldstateToStore() end

---Clear the kill count changes for the write-only worldstate.
---
---This is used to initialize the sending of new WorldKillCount packets.
function api.ClearKillChanges() end

---Clear the map changes for the write-only worldstate.
---
---This is used to initialize the sending of new WorldMap packets.
function api.ClearMapChanges() end

---Clear the client globals for the write-only worldstate.
---
---This is used to initialize the sending of new ClientScriptGlobal packets.
function api.ClearClientGlobals() end

---Get the number of indexes in the read worldstate's kill changes.
---@return integer @The number of indexes.
function api.GetKillChangesSize() end

---Get the number of indexes in the read worldstate's map changes.
---@return integer @The number of indexes.
function api.GetMapChangesSize() end

---Get the number of indexes in the read worldstate's client globals.
---@return integer @The number of indexes.
function api.GetClientGlobalsSize() end

---Get the refId at a certain index in the read worldstate's kill count changes.
---@param index integer @The index of the kill count.
---@return string @The refId.
function api.GetKillRefId(index) end

---Get the number of kills at a certain index in the read worldstate's kill count changes.
---@param index integer @The index of the kill count.
---@return integer @The number of kills.
function api.GetKillNumber(index) end

---Get the weather region in the read worldstate.
---@return string @The weather region.
function api.GetWeatherRegion() end

---Get the current weather in the read worldstate.
---@return integer @The current weather.
function api.GetWeatherCurrent() end

---Get the next weather in the read worldstate.
---@return integer @The next weather.
function api.GetWeatherNext() end

---Get the queued weather in the read worldstate.
---@return integer @The queued weather.
function api.GetWeatherQueued() end

---Get the transition factor of the weather in the read worldstate.
---@return number @The transition factor of the weather.
function api.GetWeatherTransitionFactor() end

---Get the X coordinate of the cell corresponding to the map tile at a certain index in the read worldstate's map tiles.
---@param index integer @The index of the map tile.
---@return integer @The X coordinate of the cell.
function api.GetMapTileCellX(index) end

---Get the Y coordinate of the cell corresponding to the map tile at a certain index in the read worldstate's map tiles.
---@param index integer @The index of the map tile.
---@return integer @The Y coordinate of the cell.
function api.GetMapTileCellY(index) end

---Get the id of the global variable at a certain index in the read worldstate's client globals.
---@param index integer @The index of the client global.
---@return string @The id.
function api.GetClientGlobalId(index) end

---Get the type of the global variable at a certain index in the read worldstate's client globals.
---@param index integer @The index of the client global.
---@return integer @The variable type (0 for INTEGER, 1 for LONG, 2 for FLOAT).
function api.GetClientGlobalVariableType(index) end

---Get the integer value of the global variable at a certain index in the read worldstate's client globals.
---@param index integer @The index of the client global.
---@return integer @The integer value.
function api.GetClientGlobalIntValue(index) end

---Get the float value of the global variable at a certain index in the read worldstate's client globals.
---@param index integer @The index of the client global.
---@return number @The float value.
function api.GetClientGlobalFloatValue(index) end

---Set the region affected by the next WorldRegionAuthority packet sent.
---@param authorityRegion string @The region.
function api.SetAuthorityRegion(authorityRegion) end

---Set the weather region in the write-only worldstate stored on the server.
---@param region string @The region.
function api.SetWeatherRegion(region) end

---Set the weather forcing state in the write-only worldstate stored on the server.
---
---Players who receive a packet with forced weather will switch to that weather immediately.
---@param forceState boolean @The weather forcing state.
function api.SetWeatherForceState(forceState) end

---Set the current weather in the write-only worldstate stored on the server.
---@param currentWeather integer @The current weather.
function api.SetWeatherCurrent(currentWeather) end

---Set the next weather in the write-only worldstate stored on the server.
---@param nextWeather integer @The next weather.
function api.SetWeatherNext(nextWeather) end

---Set the queued weather in the write-only worldstate stored on the server.
---@param queuedWeather integer @The queued weather.
function api.SetWeatherQueued(queuedWeather) end

---Set the transition factor for the weather in the write-only worldstate stored on the server.
---@param transitionFactor number @The transition factor.
function api.SetWeatherTransitionFactor(transitionFactor) end

---Set the world's hour in the write-only worldstate stored on the server.
---@param hour number @The hour.
function api.SetHour(hour) end

---Set the world's day in the write-only worldstate stored on the server.
---@param day integer @The day.
function api.SetDay(day) end

---Set the world's month in the write-only worldstate stored on the server.
---@param month integer @The month.
function api.SetMonth(month) end

---Set the world's year in the write-only worldstate stored on the server.
---@param year integer @The year.
function api.SetYear(year) end

---Set the world's days passed in the write-only worldstate stored on the server.
---@param daysPassed integer @The days passed.
function api.SetDaysPassed(daysPassed) end

---Set the world's time scale in the write-only worldstate stored on the server.
---@param timeScale number @The time scale.
function api.SetTimeScale(timeScale) end

---Set the collision state for other players in the write-only worldstate stored on the server.
---@param state boolean @The collision state.
function api.SetPlayerCollisionState(state) end

---Set the collision state for actors in the write-only worldstate stored on the server.
---@param state boolean @The collision state.
function api.SetActorCollisionState(state) end

---Set the collision state for placed objects in the write-only worldstate stored on the server.
---@param state boolean @The collision state.
function api.SetPlacedObjectCollisionState(state) end

---Whether placed objects with collision turned on should use actor collision, i.e. whether they should be slippery and prevent players from standing on them.
---@param useActorCollision boolean @Whether to use actor collision.
function api.UseActorCollisionForPlacedObjects(useActorCollision) end

---Add a new kill count to the kill count changes.
---@param refId string @The refId of the kill count.
---@param number integer @The number of kills in the kill count.
function api.AddKill(refId, number) end

---Add a new client global integer to the client globals.
---@param id string @The id of the client global.
---@param variableType integer @The variable type (0 for SHORT, 1 for LONG).
---@param intValue integer @The integer value of the client global.
function api.AddClientGlobalInteger(id, variableType, intValue) end

---Add a new client global float to the client globals.
---@param id string @The id of the client global.
---@param floatValue number @The float value of the client global.
function api.AddClientGlobalFloat(id, floatValue) end

---Add an ID to the list of script IDs whose variable changes should be sent to the the server by clients.
---@param scriptId string @The ID.
function api.AddSynchronizedClientScriptId(scriptId) end

---Add an ID to the list of global IDs whose value changes should be sent to the server by clients.
---@param globalId string @The ID.
function api.AddSynchronizedClientGlobalId(globalId) end

---Add a refId to the list of refIds for which collision should be enforced irrespective of other settings.
---@param refId string @The refId.
function api.AddEnforcedCollisionRefId(refId) end

---Add a cell with given cellDescription to the list of cells that should be reset on the client.
function api.AddCellToReset() end

---Add a destination override containing the cell description for the old cell and the new cell.
---@param oldCellDescription string @The old cell description.
---@param newCellDescription string @The new cell description.
function api.AddDestinationOverride(oldCellDescription, newCellDescription) end

---Clear the list of script IDs whose variable changes should be sent to the the server by clients.
function api.ClearSynchronizedClientScriptIds() end

---Clear the list of global IDs whose value changes should be sent to the the server by clients.
function api.ClearSynchronizedClientGlobalIds() end

---Clear the list of refIds for which collision should be enforced irrespective of other settings.
function api.ClearEnforcedCollisionRefIds() end

---Clear the list of cells which should be reset on the client.
function api.ClearCellsToReset() end

---Clear the list of destination overrides.
function api.ClearDestinationOverrides() end

---Save the .png image data of the map tile at a certain index in the read worldstate's map changes.
---@param index integer @The index of the map tile.
---@param filePath string @The file path of the resulting file.
function api.SaveMapTileImageFile(index, filePath) end

---Load a .png file as the image data for a map tile and add it to the write-only worldstate stored on the server.
---@param cellX integer @The X coordinate of the cell corresponding to the map tile.
---@param cellY integer @The Y coordinate of the cell corresponding to the map tile.
---@param filePath string @The file path of the loaded file.
function api.LoadMapTileImageFile(cellX, cellY, filePath) end

---Send a ClientScriptGlobal packet with the current client script globals in the write-only worldstate.
---@param pid integer @The player ID attached to the packet.
---@param sendToOtherPlayers boolean|nil @Whether this packet should be sent to players other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendClientScriptGlobal(pid, sendToOtherPlayers, skipAttachedPlayer) end

---Send a ClientScriptSettings packet with the current client script settings in the write-only worldstate.
---@param pid integer @The player ID attached to the packet.
---@param sendToOtherPlayers boolean|nil @Whether this packet should be sent to players other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendClientScriptSettings(pid, sendToOtherPlayers, skipAttachedPlayer) end

---Send a WorldKillCount packet with the current set of kill count changes in the write-only worldstate.
---@param pid integer @The player ID attached to the packet.
---@param sendToOtherPlayers boolean|nil @Whether this packet should be sent to players other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendWorldKillCount(pid, sendToOtherPlayers, skipAttachedPlayer) end

---Send a WorldRegionAuthority packet establishing a certain player as the only one who should process certain region-specific events (such as weather changes).
---
---It is always sent to all players.
---@param pid integer @The player ID attached to the packet.
function api.SendWorldRegionAuthority(pid) end

---Send a WorldMap packet with the current set of map changes in the write-only worldstate.
---@param pid integer @The player ID attached to the packet.
---@param sendToOtherPlayers boolean|nil @Whether this packet should be sent to players other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendWorldMap(pid, sendToOtherPlayers, skipAttachedPlayer) end

---Send a WorldTime packet with the current time and time scale in the write-only worldstate.
---@param pid integer @The player ID attached to the packet.
---@param sendToOtherPlayers boolean|nil @Whether this packet should be sent to players other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendWorldTime(pid, sendToOtherPlayers, skipAttachedPlayer) end

---Send a WorldWeather packet with the current weather in the write-only worldstate.
---@param pid integer @The player ID attached to the packet.
---@param sendToOtherPlayers boolean|nil @Whether this packet should be sent to players other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendWorldWeather(pid, sendToOtherPlayers, skipAttachedPlayer) end

---Send a WorldCollisionOverride packet with the current collision overrides in the write-only worldstate.
---@param pid integer @The player ID attached to the packet.
---@param sendToOtherPlayers boolean|nil @Whether this packet should be sent to players other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendWorldCollisionOverride(pid, sendToOtherPlayers, skipAttachedPlayer) end

---Send a CellReset packet with a list of cells,
---@param pid integer @The player ID attached to the packet.
function api.SendCellReset(pid) end

---Send a WorldDestinationOverride packet with the current destination overrides in the write-only worldstate.
---@param pid integer @The player ID attached to the packet.
---@param sendToOtherPlayers boolean|nil @Whether this packet should be sent to players other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendWorldDestinationOverride(pid, sendToOtherPlayers, skipAttachedPlayer) end
