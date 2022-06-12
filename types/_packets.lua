-- PlayerPackets

--
-- OnPlayerAttributeCallback

---@class PlayerAttributePacketAttribute : PlayerDataAttribute
---@field modifier integer

---@class PlayerAttributePacket
---@field attributes PlayerAttributePacketAttribute[]

--
-- OnPlayerCellChangeCallback

---@class PlayerCellChangePacketLocation
---@field cell string
---@field posX number
---@field posY number
---@field posZ number
---@field rotX number
---@field rotZ number

---@class PlayerCellChangePacket
---@field location PlayerCellChangePacketLocation

--
-- OnPlayerCooldownsCallback

---@class PlayerCooldownsPacket
---@field cooldowns PlayerDataCooldown[]

--
-- OnPlayerEquipmentCallback

---@class PlayerEquipmentPacket
---@field equipment PlayerDataEquipmentItem[]

--
-- OnPlayerInventoryCallback

---@class PlayerInventoryPacket
---@field inventory PlayerDataInventoryItem[]
---@field action integer

--
-- OnPlayerJournalCallback

---@class PlayerJournalPacket
---@field journal PlayerDataJournalItem[]

--
-- OnPlayerLevelCallback

---@class PlayerLevelPacketStats
---@field level integer
---@field levelProgress integer

---@class PlayerLevelPacket
---@field stats PlayerLevelPacketStats

--
-- OnPlayerQuickKeysCallback

---@class PlayerQuickKeysPacket
---@field quickKeys PlayerDataQuickKey[]

--
-- OnPlayerShapeshiftCallback

---@class PlayerShapeshiftPacketShapeshift
---@field scale number
---@field isWerewolf boolean

---@class PlayerShapeshiftPacket
---@field shapeshift PlayerShapeshiftPacketShapeshift

--
-- OnPlayerSkillCallback

---@class PlayerAttributePacketSkill : PlayerDataSkill
---@field modifier integer

---@class PlayerSkillPacket
---@field skills PlayerAttributePacketSkill[]

--
-- OnPlayerSpellbookCallback

---@class PlayerSpellbookPacket
---@field spellbook string[]
---@field action integer

--
-- OnPlayerSpellsActiveCallback

---@class PlayerSpellsActivePacket
---@field spellsActive table<string, PlayerDataSpellInstance[]>
---@field action integer

--
-- Other Player Packets

---@class PlayerStatsDynamicPacketStats
---@field healthBase integer
---@field magickaBase integer
---@field fatigueBase integer
---@field healthCurrent integer
---@field magickaCurrent integer
---@field fatigueCurrent integer

---@class PlayerStatsDynamicPacket
---@field stats PlayerStatsDynamicPacketStats

-- ActorPackets

---@class ActorPacket
---@field refId string

--
-- OnActorDeathCallback

---@class ActorDeathActorPacketKiller
---@field refId string
---@field uniqueIndex string
---@field pid integer
---@field playerName string

---@class ActorDeathActorPacket : ActorPacket
---@field deathState integer
---@field killer ActorDeathActorPacketKiller

--
-- OnActorEquipmentCallback

---@class ActorEquipmentActorPacket
---@field equipment PlayerDataEquipmentItem[]

--
-- OnActorSpellsActiveCallback

---@class ActorSpellsActiveActorPacket
---@field spellsActive table<string, PlayerDataSpellInstance[]>

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
---@field variables table<integer, number|integer[]>

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

-- Standalone Packets

--
-- OnWorldMapCallback

---@class MapTilePacket
---@field cellX integer
---@field cellY integer

--
-- OnClientScriptGlobalCallback

---@class VariablePacket
---@field variableType integer
---@field intValue integer
---@field floatValue number

--
-- OnRecordDynamicCallback

---@class RecordDynamicPacketEffect
---@field id integer
---@field attribute integer
---@field skill integer
---@field rangeType integer
---@field area integer
---@field duration integer
---@field magnitudeMin integer
---@field magnitudeMax integer

---@class RecordDynamicPacketEnchantment
---@field name string

---@class RecordDynamicPacketSpell
---@field subtype integer
---@field cost integer
---@field flags integer
---@field effects RecordDynamicPacketEffect[]

---@class RecordDynamicPacketPotion
---@field weight integer
---@field value integer
---@field autoCalc integer
---@field icon string
---@field model string
---@field script string
---@field effects RecordDynamicPacketEffect[]
---@field quantitiy integer

---@class RecordDynamicPacketEnchantment
---@field subtype integer
---@field cost integer
---@field charge integer
---@field flags integer
---@field effects RecordDynamicPacketEffect[]
---@field clientsideEnchantmentId string

---@class RecordDynamicPacketOther
---@field baseId string
---@field enchantmentCharge integer
---@field quantity integer
---@field enchantmentId string

---@alias RecordDynamicPacket RecordDynamicPacketEnchantment|RecordDynamicPacketSpell|RecordDynamicPacketPotion|RecordDynamicPacketEnchantment|RecordDynamicPacketOther