-- ObjectPackets

---@class ObjectObjectPacket
---@field refId string
---@field uniqueIndex string

---@class ObjectPlayerPacket
---@field pid integer
---@field player Player

--
-- OnClientScriptLocalCallback

---@class ClientScriptLocalObjectPacket : ObjectObjectPacket
---@field variables table<unknown, unknown[]>

--
-- OnDoorStateCallback

---@class DoorStateObjectPacket : ObjectObjectPacket
---@field doorState integer

--
-- OnObjectActivateCallback

---@class ObjectActivatePacket
---@field activatingPid integer
---@field activatingRefId string
---@field activatingUniqueIndex string

---@class ObjectActivateObjectPacket : ObjectObjectPacket, ObjectActivatePacket

---@class ObjectActivatePlayerPacket : ObjectPlayerPacket, ObjectActivatePacket
---@field drawState integer

--
-- OnObjectDeleteCallback

---@class ObjectDeleteObjectPacket : ObjectObjectPacket

--
-- OnObjectDialogueChoiceCallback

---@class ObjectDialogueChoiceObjectPacket : ObjectObjectPacket
---@field dialogueChoiceType integer
---@field dialogueTopic unknown

--
-- OnObjectHitCallback

---@class ObjectHitPacketHit
---@field success boolean
---@field damage integer
---@field block boolean
---@field knockdown boolean

---@class ObjectHitPacket
---@field hit ObjectHitPacketHit
---@field hittingPid integer
---@field hittingRefId string
---@field hittingUniqueIndex string

---@class ObjectHitObjectPacket : ObjectObjectPacket, ObjectHitPacket

---@class ObjectHitPlayerPacket : ObjectPlayerPacket, ObjectHitPacket

--
-- OnObjectLockCallback

---@class ObjectLockObjectPacket : ObjectObjectPacket
---@field lockLevel integer

--
-- OnObjectMiscellaneousCallback

---@class ObjectMiscellaneousObjectPacket : ObjectObjectPacket
---@field goldPool integer
---@field lastGoldRestockHour integer
---@field lastGoldRestockDay integer

--
-- OnObjectPlaceCallback

---@class ObjectPlaceObjectPacket : ObjectObjectPacket
---@field count integer
---@field charge integer
---@field enchantmentCharge integer
---@field soul string
---@field goldValue integer
---@field hasContainer boolean
---@field droppedByPlayer boolean

--
-- OnObjectRestockCallback

---@class ObjectRestockObjectPacket : ObjectObjectPacket

--
-- OnObjectScaleCallback

---@class ObjectScaleObjectPacket : ObjectObjectPacket
---@field scale number

--
-- OnObjectSoundCallback

---@class ObjectSoundPacket
---@field soundId string

---@class ObjectSoundObjectPacket : ObjectObjectPacket, ObjectSoundPacket

---@class ObjectSoundPlayerPacket : ObjectPlayerPacket, ObjectSoundPacket


--
-- OnObjectSpawnCallback

---@class ObjectSummonSummonerPacket
---@field refId string
---@field uniqueIndex string
---@field pid integer
---@field playerName string

---@class ObjectSummonPacket
---@field effectId string
---@field spellId string
---@field duration integer
---@field startTime integer
---@field summoner ObjectSummonSummonerPacket
---@field hasPlayerSummoner boolean

---@class ObjectSpawnObjectPacket : ObjectObjectPacket
---@field summon ObjectSummonPacket

--
-- OnObjectStateCallback

---@class ObjectStateObjectPacket : ObjectObjectPacket
---@field state number

--
-- OnObjectTrapCallback

---@class ObjectTrapObjectPacket : ObjectObjectPacket