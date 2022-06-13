---@class PlayerAttributePacketAttribute : PlayerDataAttribute
---@field modifier integer

---@class PlayerAttributePacket
---@field attributes PlayerAttributePacketAttribute[]

---@class PlayerCellChangePacketLocation
---@field cell string
---@field posX number
---@field posY number
---@field posZ number
---@field rotX number
---@field rotZ number

---@class PlayerCellChangePacket
---@field location PlayerCellChangePacketLocation

---@class PlayerClassPacketCharacter
---@field class string
---@field defaultClassState integer

---@class PlayerClassPacket
---@field character PlayerClassPacketCharacter
---@field customClass PlayerDataCustomClass

---@class PlayerCooldownsPacket
---@field cooldowns PlayerDataCooldown[]

---@class PlayerEquipmentPacket
---@field equipment PlayerDataEquipmentItem[]

---@class PlayerInventoryPacket
---@field inventory PlayerDataInventoryItem[]
---@field action integer

---@class PlayerJournalPacket
---@field journal PlayerDataJournalItem[]

---@class PlayerLevelPacketStats
---@field level integer
---@field levelProgress integer

---@class PlayerLevelPacket
---@field stats PlayerLevelPacketStats

---@class PlayerQuickKeysPacket
---@field quickKeys PlayerDataQuickKey[]

---@class PlayerShapeshiftPacketShapeshift
---@field scale number
---@field isWerewolf boolean

---@class PlayerShapeshiftPacket
---@field shapeshift PlayerShapeshiftPacketShapeshift

---@class PlayerAttributePacketSkill : PlayerDataSkill
---@field modifier integer

---@class PlayerSkillPacket
---@field skills PlayerAttributePacketSkill[]

---@class PlayerSpellbookPacket
---@field spellbook string[]
---@field action integer

---@class PlayerSpellsActivePacket
---@field spellsActive table<string, PlayerDataSpellInstance[]>
---@field action integer

---@class PlayerStatsDynamicPacketStats
---@field healthBase integer
---@field magickaBase integer
---@field fatigueBase integer
---@field healthCurrent integer
---@field magickaCurrent integer
---@field fatigueCurrent integer

---@class PlayerStatsDynamicPacket
---@field stats PlayerStatsDynamicPacketStats

---@alias PlayerPacket PlayerAttributePacketAttribute|PlayerAttributePacket|PlayerCellChangePacket|PlayerClassPacket|PlayerCooldownsPacket|PlayerEquipmentPacket|PlayerInventoryPacket|PlayerJournalPacket|PlayerLevelPacket|PlayerQuickKeysPacket|PlayerShapeshiftPacket|PlayerSkillPacket|PlayerSpellbookPacket|PlayerSpellsActivePacket|PlayerStatsDynamicPacket

---@class ActorDeathActorPacketKiller
---@field refId string
---@field uniqueIndex string
---@field pid integer
---@field playerName string

---@class ActorDeathActorPacket
---@field refId string
---@field deathState integer
---@field killer ActorDeathActorPacketKiller

---@class ActorEquipmentActorPacket
---@field refId string
---@field equipment PlayerDataEquipmentItem[]

---@class ActorSpellsActiveActorPacket
---@field refId string
---@field spellsActive table<string, PlayerDataSpellInstance[]>
---@field spellActiveChangesAction integer

---@alias ActorPacket ActorDeathActorPacketKiller|ActorDeathActorPacket|ActorEquipmentActorPacket|ActorSpellsActiveActorPacket

---@class ObjectObjectPacket
---@field refId string
---@field uniqueIndex string

---@class ObjectPlayerPacket
---@field pid integer
---@field player Player

---@class ClientScriptLocalObjectPacket : ObjectObjectPacket
---@field variables table<integer, number|integer[]>

---@class DoorStateObjectPacket : ObjectObjectPacket
---@field doorState integer

---@class ObjectActivatePacket
---@field activatingPid integer
---@field activatingRefId string
---@field activatingUniqueIndex string

---@class ObjectActivateObjectPacket : ObjectObjectPacket, ObjectActivatePacket

---@class ObjectActivatePlayerPacket : ObjectPlayerPacket, ObjectActivatePacket
---@field drawState integer

---@class ObjectDeleteObjectPacket : ObjectObjectPacket

---@class ObjectDialogueChoiceObjectPacket : ObjectObjectPacket
---@field dialogueChoiceType integer
---@field dialogueTopic unknown

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

---@class ObjectLockObjectPacket : ObjectObjectPacket
---@field lockLevel integer

---@class ObjectMiscellaneousObjectPacket : ObjectObjectPacket
---@field goldPool integer
---@field lastGoldRestockHour integer
---@field lastGoldRestockDay integer

---@class ObjectPlaceObjectPacket : ObjectObjectPacket
---@field count integer
---@field charge integer
---@field enchantmentCharge integer
---@field soul string
---@field goldValue integer
---@field hasContainer boolean
---@field droppedByPlayer boolean

---@class ObjectRestockObjectPacket : ObjectObjectPacket

---@class ObjectScaleObjectPacket : ObjectObjectPacket
---@field scale number

---@class ObjectSoundPacket
---@field soundId string

---@class ObjectSoundObjectPacket : ObjectObjectPacket, ObjectSoundPacket

---@class ObjectSoundPlayerPacket : ObjectPlayerPacket, ObjectSoundPacket

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

---@class ObjectStateObjectPacket : ObjectObjectPacket
---@field state number

---@class ObjectTrapObjectPacket : ObjectObjectPacket

---@alias ObjectPacket ClientScriptLocalObjectPacket|DoorStateObjectPacket|ObjectActivateObjectPacket|ObjectDeleteObjectPacket|ObjectDialogueChoiceObjectPacket|ObjectHitObjectPacket|ObjectLockObjectPacket|ObjectMiscellaneousObjectPacket|ObjectPlaceObjectPacket|ObjectRestockObjectPacket|ObjectScaleObjectPacket|ObjectSoundObjectPacket|ObjectSpawnObjectPacket|ObjectStateObjectPacket|ObjectTrapObjectPacket

---@class MapTilePacket
---@field cellX integer
---@field cellY integer

---@class VariablePacket
---@field variableType integer
---@field intValue integer
---@field floatValue number

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

-- Placeholder stuff

---@class Container
---@field inventory InventoryItem[]
---@field refId string

---@class ActorPositionLocation : Location
---@field rotX number
---@field rotY number
---@field rotZ number

---@class ActorPosition
---@field location ActorPositionLocation

---@class ActorStatsDynamicStats : PlayerStatsDynamicPacketStats
---@field healthModified integer
---@field magickaModified integer
---@field fatigueModified integer

---@class ActorStatsDynamic
---@field stats ActorStatsDynamicStats

---@class Actor
---@field ai AIData

---@class ActorCellChange
---@field cellChangeTo string
---@field cellChangeFrom string