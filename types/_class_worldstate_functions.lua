---@class TES3MP
local api

---@return unknown
function api.readWorldstate() end

---@return unknown
function api.writeWorldstate() end

---Use the last worldstate received by the server as the one being read.
function api.ReadReceivedWorldstate() end

---Take the contents of the read-only worldstate last received by the server from a player and move its contents to the stored worldstate that can be sent by the server.
function api.CopyReceivedWorldstateToStore() end

---Clear the map changes for the write-only worldstate.
---
---This is used to initialize the sending of new WorldMap packets.
function api.ClearMapChanges() end

---Get the number of indexes in the read worldstate's map changes.
---@return number
function api.GetMapChangesSize() end

---Get the weather region in the read worldstate.
---@return string
function api.GetWeatherRegion() end

---Get the current weather in the read worldstate.
---@return number
function api.GetWeatherCurrent() end

---Get the next weather in the read worldstate.
---@return number
function api.GetWeatherNext() end

---Get the queued weather in the read worldstate.
---@return number
function api.GetWeatherQueued() end

---Get the transition factor of the weather in the read worldstate.
---@return number
function api.GetWeatherTransitionFactor() end

---Get the X coordinate of the cell corresponding to the map tile at a certain index in the read worldstate's map tiles.
---@param index number @The index of the map tile.
---@return number
function api.GetMapTileCellX(index) end

---Get the Y coordinate of the cell corresponding to the map tile at a certain index in the read worldstate's map tiles.
---@param index number @The index of the map tile.
---@return number
function api.GetMapTileCellY(index) end

---Set the region affected by the next WorldRegionAuthority packet sent.
---@param authorityRegion string
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
---@param currentWeather number @The current weather.
function api.SetWeatherCurrent(currentWeather) end

---Set the next weather in the write-only worldstate stored on the server.
---@param nextWeather number @The next weather.
function api.SetWeatherNext(nextWeather) end

---Set the queued weather in the write-only worldstate stored on the server.
---@param queuedWeather number @The queued weather.
function api.SetWeatherQueued(queuedWeather) end

---Set the transition factor for the weather in the write-only worldstate stored on the server.
---@param transitionFactor number @The transition factor.
function api.SetWeatherTransitionFactor(transitionFactor) end

---Set the world's hour in the write-only worldstate stored on the server.
---@param hour number @The hour.
function api.SetHour(hour) end

---Set the world's day in the write-only worldstate stored on the server.
---@param day number @The day.
function api.SetDay(day) end

---Set the world's month in the write-only worldstate stored on the server.
---@param month number @The month.
function api.SetMonth(month) end

---Set the world's year in the write-only worldstate stored on the server.
---@param year number @The year.
function api.SetYear(year) end

---Set the world's days passed in the write-only worldstate stored on the server.
---@param daysPassed number @The days passed.
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

---Add a refId to the list of refIds for which collision should be enforced irrespective of other settings.
---@param refId string @The refId.
function api.AddEnforcedCollisionRefId(refId) end

---Clear the list of refIdsd for which collision should be enforced irrespective of other settings.
function api.ClearEnforcedCollisionRefIds() end

---Save the .png image data of the map tile at a certain index in the read worldstate's map changes.
---@param index number @The index of the map tile.
---@param filePath string @The file path of the resulting file.
function api.SaveMapTileImageFile(index, filePath) end

---Load a .png file as the image data for a map tile and add it to the write-only worldstate stored on the server.
---@param cellX number @The X coordinate of the cell corresponding to the map tile.
---@param cellY number @The Y coordinate of the cell corresponding to the map tile.
---@param filePath string @The file path of the loaded file.
function api.LoadMapTileImageFile(cellX, cellY, filePath) end

---Send a WorldRegionAuthority packet establishing a certain player as the only one who should process certain region-specific events (such as weather changes).
---
---It is always sent to all players.
---@param pid number @The player ID attached to the packet.
function api.SendWorldRegionAuthority(pid) end

---Send a WorldMap packet with the current set of map changes in the write-only worldstate.
---@param pid number @The player ID attached to the packet.
---@param sendToOtherPlayers boolean
---@param skipAttachedPlayer boolean
function api.SendWorldMap(pid, sendToOtherPlayers, skipAttachedPlayer) end

---Send a WorldTime packet with the current time and time scale in the write-only worldstate.
---@param pid number @The player ID attached to the packet.
---@param sendToOtherPlayers boolean|nil @Whether this packet should be sent to players other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendWorldTime(pid, sendToOtherPlayers, skipAttachedPlayer) end

---Send a WorldWeather packet with the current weather in the write-only worldstate.
---@param pid number @The player ID attached to the packet.
---@param sendToOtherPlayers boolean|nil @Whether this packet should be sent to players other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendWorldWeather(pid, sendToOtherPlayers, skipAttachedPlayer) end

---Send a WorldCollisionOverride packet with the current collision overrides in the write-only worldstate.
---@param pid number @The player ID attached to the packet.
---@param sendToOtherPlayers boolean|nil @Whether this packet should be sent to players other than the player attached to the packet (false by default).
---@param skipAttachedPlayer boolean|nil @Whether the packet should skip being sent to the player attached to the packet (false by default).
function api.SendWorldCollisionOverride(pid, sendToOtherPlayers, skipAttachedPlayer) end

function api.ReadLastWorldstate() end

function api.CopyLastWorldstateToStore() end
