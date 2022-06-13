---@class Timestamp
---@field daysPassed number
---@field month number
---@field day number

---@class JournalItem
---@field type number
---@field index number
---@field quest string
---@field timestamp Timestamp

---@class EventStatus
---@field validDefaultHandler boolean
---@field validCustomHandlers boolean|nil

---@alias EventHandler fun(eventStatus: EventStatus, pid: number)
---@alias EventValidator fun(eventStatus: EventStatus, pid: number)

---@alias CommandCallback fun(pid: integer, cmd: string)

---@class Damage
---@field min integer
---@field max integer

---@class Location
---@field posX number
---@field posY number
---@field posZ number

---@class AIData : Location
---@field action integer
---@field distance number
---@field duration number
---@field shouldRepeat boolean
---@field targetPlayer integer|nil
---@field targetUniqueIndex integer|nil

---@class ObjectData
---@field refId integer
---@field count integer
---@field charge integer
---@field enchantmentCharge number
---@field soul string

---@class Item
---@field refId string
---@field count integer
---@field charge integer
---@field enchantmentCharge integer

---@class InventoryItem : Item
---@field soul string

---@class Effect
---@field id string
---@field magnitude integer
---@field duration integer
---@field timeLeft integer
---@field arg unknown

---@class SpellInstance
---@field effects Effect[]
---@field displayName string
---@field stackingState integer
