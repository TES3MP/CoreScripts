local LIP = require 'LIP';

local Player = {}
Player.__index = Player

setmetatable(Player, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function Player.new(pid)
    local self = setmetatable({}, Player)
    self.data =
    {
        general = {
            name = "",
            password = "",
            admin = 0,
        },
        character = {
            race = "",
            head = "",
            hair = "",
            sex = 1,
            class = "",
            birthsign = "",
        },
        location = {
            cell = "",
            posX = 0,
            posY = 0,
            posZ = 0,
            angleX = 0,
            angleY = 0,
            angleZ = 0
        },
        stats = {
            level = 1,
            levelProgress = 0,
            healthBase = 1,
            healthCurrent = 1,
            magickaBase = 1,
            magickaCurrent = 1,
            fatigueBase = 1,
            fatigueCurrent = 1,
        },
    };

    self.data.attributes = {}
    self.data.attributeSkillIncreases = {}

    for i = 0, (tes3mp.getAttributeCount() - 1) do
        local attributeName = tes3mp.getAttributeName(i)
        self.data.attributes[attributeName] = 1
        self.data.attributeSkillIncreases[attributeName] = 0
    end

    self.data.skills = {}
    self.data.skillProgress = {}

    for i = 0, (tes3mp.getSkillCount() - 1) do
        local skillName = tes3mp.getSkillName(i)
        self.data.skills[skillName] = 1
        self.data.skillProgress[skillName] = 0
    end

    self.data.equipment = {}

    self.accountName = tes3mp.getName(pid) .. ".txt"
    self.pid = pid
    self.loggedOn = false
    self.tid_login = nil
    self.admin = 0
    self.hasAccount = nil -- TODO Check whether account file exists
    return self
end

function Player:Destroy()
    if self.tid_login ~= nil then
        tes3mp.stopTimer(self.tid_login)
        self.tid_login = nil
    end

    self.loggedOn = false
    self.hasAccount = nil
end

function Player:kick()
    self:Destroy()
    tes3mp.kick(self.pid)
end

function Player:Registered(passw)
    self.loggedOn = true
    self.data.general.password = passw
    if self.hasAccount == false then -- create account
        tes3mp.setCharGenStage(self.pid, 1, 4)
    end
end

function Player:LoggedOn()
    self.loggedOn = true
    if self.hasAccount ~= false then -- load account
        self:LoadCharacter()
        self:LoadClass()
        self:LoadLevel()
        self:LoadAttributes()
        self:LoadSkills()
        self:LoadDynamicStats()
        self:LoadCell()
        self:LoadEquipment()
    end
end

function Player:IsLoggedOn()
    return self.loggedOn
end

function Player:IsAdmin()
    return self.data.general.admin == 2
end

function Player:IsModerator()
    return self.data.general.admin == 1
end

function Player:PromoteModerator(other)
    if self.IsAdmin() then
        other.data.general.admin = 1
        return true
    end
    return false
end

function Player:getHealthCurrent()
    self.data.stats.healthCurrent = tes3mp.getHealthCurrent(self.pid)
    return self.data.stats.healthCurrent
end

function Player:setHealthCurrent(health)
    self.data.stats.healthCurrent = health
    tes3mp.setHealthCurrent(self.pid, health)
end

function Player:getHealthBase()
    self.data.stats.healthBase = tes3mp.getHealthBase(self.pid)
    return self.data.stats.healthBase
end

function Player:setHealthBase(health)
    self.data.stats.healthBase = health
    tes3mp.setHealthBase(self.pid, health)
end

function Player:HasAccount()
    if self.hasAccount == nil then
        local home = os.getenv("MOD_DIR").."/players/"
        local file = io.open(home..self.accountName, "r")
        if file ~= nil then
            io.close()
            self.hasAccount = true
        else
            self.hasAccount = false
        end
    end
    return self.hasAccount
end

function Player:Message(message)
    tes3mp.sendMessage(self.pid, message, 0)
end

function Player:CreateAccount()
    LIP.save("players/" .. self.accountName, self.data)
    self.hasAccount = true
end

function Player:Save()
    if self.hasAccount and self.loggedOn then
        LIP.save("players/" .. self.accountName, self.data)
    end
end

function Player:Load()
    self.data = LIP.load("players/" .. self.accountName)
end

function Player:SaveGeneral()
    self.data.general.name = tes3mp.getName(self.pid)
end

function Player:SaveCharacter()
    self.data.character.race = tes3mp.getRace(self.pid)
    self.data.character.head = tes3mp.getHead(self.pid)
    self.data.character.hair = tes3mp.GetHair(self.pid)
    self.data.character.sex = tes3mp.getIsMale(self.pid)
    self.data.character.birthsign = tes3mp.getBirthsign(self.pid)
end

function Player:LoadCharacter()
    tes3mp.setRace(self.pid, self.data.character.race)
    tes3mp.setHead(self.pid, self.data.character.head)
    tes3mp.SetHair(self.pid, self.data.character.hair)
    tes3mp.setIsMale(self.pid, self.data.character.sex)
    tes3mp.setBirthsign(self.pid, self.data.character.birthsign)

    tes3mp.sendBaseInfo(self.pid)
end

function Player:SaveClass()
    if tes3mp.isClassDefault(self.pid) == 1 then
        self.data.character.class = tes3mp.getDefaultClass(self.pid)
    else
        self.data.character.class = "custom"
        self.data.customClass = {}
        self.data.customClass.name = tes3mp.getClassName(self.pid)
        self.data.customClass.description = tes3mp.getClassDesc(self.pid):gsub("\n", "\\n")
        self.data.customClass.specialization = tes3mp.getClassSpecialization(self.pid)
        majorAttributes = {}
        majorSkills = {}
        minorSkills = {}

        for i = 0, 1, 1 do
            majorAttributes[i + 1] = tes3mp.getAttributeName(tonumber(tes3mp.getClassMajorAttribute(self.pid, i)))
        end

        for i = 0, 4, 1 do
            majorSkills[i + 1] = tes3mp.getSkillName(tonumber(tes3mp.getClassMajorSkill(self.pid, i)))
            minorSkills[i + 1] = tes3mp.getSkillName(tonumber(tes3mp.getClassMinorSkill(self.pid, i)))
        end

        self.data.customClass.majorAttributes = table.concat(majorAttributes, ", ")
        self.data.customClass.majorSkills = table.concat(majorSkills, ", ")
        self.data.customClass.minorSkills = table.concat(minorSkills, ", ")
    end
end

function Player:LoadClass()
    if self.data.character.class ~= "custom" then
        tes3mp.setDefaultClass(self.pid, self.data.character.class)
    elseif self.data.customClass ~= nil then
        tes3mp.setClassName(self.pid, self.data.customClass.name)
        tes3mp.setClassSpecialization(self.pid, self.data.customClass.specialization)

        if self.data.customClass.description ~= nil then
            tes3mp.setClassDesc(self.pid, self.data.customClass.description)
        end

        local commaSplitPattern = "([^, ]+)"

        local i = 0
        for value in string.gmatch(self.data.customClass.majorAttributes, commaSplitPattern) do
            tes3mp.setClassMajorAttribute(self.pid, i, tes3mp.getAttributeId(value))
            i = i + 1
        end

        i = 0
        for value in string.gmatch(self.data.customClass.majorSkills, commaSplitPattern) do
            tes3mp.setClassMajorSkill(self.pid, i, tes3mp.getSkillId(value))
            i = i + 1
        end

        i = 0
        for value in string.gmatch(self.data.customClass.minorSkills, commaSplitPattern) do
            tes3mp.setClassMinorSkill(self.pid, i, tes3mp.getSkillId(value))
            i = i + 1
        end
    end

    tes3mp.sendClass(self.pid)
end

function Player:SaveDynamicStats()
    self.data.stats.healthBase = tes3mp.getHealthBase(self.pid)
    self.data.stats.magickaBase = tes3mp.getMagickaBase(self.pid)
    self.data.stats.fatigueBase = tes3mp.getFatigueBase(self.pid)
    self.data.stats.healthCurrent = tes3mp.getHealthCurrent(self.pid)
    self.data.stats.magickaCurrent = tes3mp.getMagickaCurrent(self.pid)
    self.data.stats.fatigueCurrent = tes3mp.getFatigueCurrent(self.pid)
end

function Player:LoadDynamicStats()
    tes3mp.setHealthBase(self.pid, self.data.stats.healthBase)
    tes3mp.setMagickaBase(self.pid, self.data.stats.magickaBase)
    tes3mp.setFatigueBase(self.pid, self.data.stats.fatigueBase)
    tes3mp.setHealthCurrent(self.pid, self.data.stats.healthCurrent)
    tes3mp.setMagickaCurrent(self.pid, self.data.stats.magickaCurrent)
    tes3mp.setFatigueCurrent(self.pid, self.data.stats.fatigueCurrent)

    tes3mp.sendDynamicStats(self.pid)
end

function Player:SaveAttributes()
    for name in pairs(self.data.attributes) do
        local attributeId = tes3mp.getAttributeId(name)
        self.data.attributes[name] = tes3mp.getAttributeBase(self.pid, attributeId)
    end
end

function Player:LoadAttributes()
    for name, value in pairs(self.data.attributes) do
        tes3mp.setAttributeBase(self.pid, tes3mp.getAttributeId(name), value)
    end

    tes3mp.sendAttributes(self.pid)
end

function Player:SaveSkills()
    for name in pairs(self.data.skills) do
        local skillId = tes3mp.getSkillId(name)
        self.data.skills[name] = tes3mp.getSkillBase(self.pid, skillId)
        self.data.skillProgress[name] = tes3mp.getSkillProgress(self.pid, skillId)
    end

    for name in pairs(self.data.attributeSkillIncreases) do
        local attributeId = tes3mp.getAttributeId(name)
        self.data.attributeSkillIncreases[name] = tes3mp.getSkillIncrease(self.pid, attributeId)
    end

    self.data.stats.levelProgress = tes3mp.getLevelProgress(self.pid)
end

function Player:LoadSkills()
    for name, value in pairs(self.data.skills) do
        tes3mp.setSkillBase(self.pid, tes3mp.getSkillId(name), value)
    end

    for name, value in pairs(self.data.skillProgress) do
        tes3mp.setSkillProgress(self.pid, tes3mp.getSkillId(name), value)
    end

    for name, value in pairs(self.data.attributeSkillIncreases) do
        tes3mp.setSkillIncrease(self.pid, tes3mp.getAttributeId(name), value)
    end

    tes3mp.setLevelProgress(self.pid, self.data.stats.levelProgress)
    tes3mp.sendSkills(self.pid)
end

function Player:SaveLevel()
    self.data.stats.level = tes3mp.getLevel(self.pid)
end

function Player:LoadLevel()
    tes3mp.setLevel(self.pid, self.data.stats.level)
    tes3mp.sendLevel(self.pid)
end

function Player:SaveCell()
    local currentCell = ""

    if tes3mp.isInExterior(self.pid) == 1 then
        currentCell = tes3mp.getExteriorX(self.pid) .. "," .. tes3mp.getExteriorY(self.pid)
    else
        currentCell = tes3mp.getCell(self.pid)
    end

    self.data.location.cell = currentCell
    self.data.location.posX = tes3mp.getPosX(self.pid)
    self.data.location.posY = tes3mp.getPosY(self.pid)
    self.data.location.posZ = tes3mp.getPosZ(self.pid)
    self.data.location.angleX = tes3mp.getAngleX(self.pid)
    self.data.location.angleY = tes3mp.getAngleY(self.pid)
    self.data.location.angleZ = tes3mp.getAngleZ(self.pid)
end

function Player:LoadCell()
    local newCell = self.data.location.cell

    if newCell ~= nil then

        local exteriorCellPattern = "(%-?%d+),(%-?%d+)$"

        if string.match(newCell, exteriorCellPattern) ~= nil then
            for gridX, gridY in string.gmatch(newCell, exteriorCellPattern) do
                tes3mp.setExterior(self.pid, tonumber(gridX), tonumber(gridY))
            end
        else
            tes3mp.setCell(self.pid, newCell)
        end

        local pos = {0, 0, 0}
        local angle = {0, 0, 0}
        pos[0] = self.data.location.posX
        pos[1] = self.data.location.posY
        pos[2] = self.data.location.posZ
        angle[0] = self.data.location.angleX
        angle[1] = self.data.location.angleY
        angle[2] = self.data.location.angleZ

        tes3mp.setPos(self.pid, pos[0], pos[1], pos[2])
        tes3mp.setAngle(self.pid, angle[0], angle[1], angle[2])

        tes3mp.sendCell(self.pid)
        tes3mp.sendPos(self.pid)
    end
end

function Player:LoadEquipment()

    for i = 0, 17 do
        local currentItem = self.data.equipment[i]

        if currentItem == nil then
            currentItem = ""
        end

        tes3mp.equipItem(self.pid, i, currentItem, 1, -1)
    end

    tes3mp.sendEquipment(self.pid)
end

function Player:SaveEquipment()

    for i = 0, 17 do
        local itemId = tes3mp.getItemSlot(self.pid, i)

        if itemId ~= nil then
            self.data.equipment[i] = itemId
        end
    end
end

return Player
