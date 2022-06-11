---@class Timestamp
---@field daysPassed number
---@field month number
---@field day number

---@class JournalItem
---@field type number
---@field index number
---@field quest string
---@field timestamp Timestamp

---@TODO pending definition
---@class PlayerPacket
---@field journal JournalItem[]

---@class EventStatus
---@field validDefaultHandler boolean
---@field validCustomHandlers boolean|nil

---@alias EventHandler fun(eventStatus: EventStatus, pid: number)
---@alias EventValidator fun(eventStatus: EventStatus, pid: number)

---@alias CommandCallback fun(pid: integer, cmd: string)

---@class AIData
---@field action integer
---@field distance number
---@field duration number
---@field posX number
---@field posY number
---@field posZ number
---@field shouldRepeat boolean
---@field targetPlayer integer|nil
---@field targetUniqueIndex integer|nil

---@class ObjectData
---@field refId integer
---@field count integer
---@field charge integer
---@field enchantmentCharge number
---@field soul string
