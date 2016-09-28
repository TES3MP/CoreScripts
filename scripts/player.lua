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
            healthBase = 1,
            healthCurrent = 1,
            magickaBase = 1,
            magickaCurrent = 1,
            fatigueBase = 1,
            fatigueCurrent = 1,
        },
    };

    self.data.attributes = {}

    for i = 0, (tes3mp.GetAttributeCount() - 1) do
        self.data.attributes[tes3mp.GetAttributeName(i)] = 1
    end

    self.data.skills = {}
    
    for i = 0, (tes3mp.GetSkillCount() - 1) do
        self.data.skills[tes3mp.GetSkillName(i)] = 1
    end

    self.accountName = tes3mp.GetName(pid)..".txt"
    self.pid = pid
    self.loggedOn = false
    self.tid_login = nil
    self.admin = 0
    self.hasAccount = nil -- TODO Check whether account file exists
    return self
end

function Player:Destroy()
    if self.tid_login ~= nil then
        tes3mp.StopTimer(self.tid_login)
        self.tid_login = nil
    end
    if self.loggedOn and self.hasAccount then
        print("Saving player...")
        self:Save()
    end
    self.loggedOn = false
    self.hasAccount = nil
end

function Player:Kick()
    self:Destroy()
    tes3mp.Kick(self.pid)
end

function Player:Registered(passw)
    self.loggedOn = true
    self.data.general.password = passw
    if self.hasAccount == false then -- create account
        tes3mp.SetCharGenStage(self.pid, 1, 4)
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

function Player:GetHealthCurrent()
    self.data.stats.healthCurrent = tes3mp.GetHealthCurrent(self.pid)
    return self.data.stats.healthCurrent
end

function Player:SetHealthCurrent(health)
    self.data.stats.healthCurrent = health
    tes3mp.SetHealthCurrent(self.pid, health)
end

function Player:GetHealthBase()
    self.data.stats.healthBase = tes3mp.GetHealthBase(self.pid)
    return self.data.stats.healthBase
end

function Player:SetHealthBase(health)
    self.data.stats.healthBase = health
    tes3mp.SetHealthBase(self.pid, health)
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
    tes3mp.SendMessage(self.pid, message, 0)
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
    self.data.general.name = tes3mp.GetName(self.pid)
end

function Player:SaveCharacter()
    self.data.character.race = tes3mp.GetRace(self.pid)
    self.data.character.head = tes3mp.GetHead(self.pid)
    self.data.character.hair = tes3mp.GetHair(self.pid)
    self.data.character.sex = tes3mp.GetIsMale(self.pid)
    self.data.character.birthsign = tes3mp.GetBirthsign(self.pid)
end

function Player:LoadCharacter()
    tes3mp.SetRace(self.pid, self.data.character.race)
    tes3mp.SetHead(self.pid, self.data.character.head)
    tes3mp.SetHair(self.pid, self.data.character.hair)
    tes3mp.SetIsMale(self.pid, self.data.character.sex)
    tes3mp.SetBirthsign(self.pid, self.data.character.birthsign)

    tes3mp.SendBaseInfo(self.pid)
end

function Player:SaveClass()
    if tes3mp.IsClassDefault(self.pid) == 1 then
        self.data.character.class = tes3mp.GetDefaultClass(self.pid)
    else
        self.data.character.class = "custom"
        self.data.customclass = {}
        self.data.customclass.name = tes3mp.GetClassName(self.pid)
        self.data.customclass.description = tes3mp.GetClassDesc(self.pid):gsub("\n", "\\n")
        self.data.customclass.specialization = tes3mp.GetClassSpecialization(self.pid)
        majorattributes = {}
        majorskills = {}
        minorskills = {}

        for i = 0, 1, 1 do
            majorattributes[i + 1] = tes3mp.GetAttributeName(tonumber(tes3mp.GetClassMajorAttribute(self.pid, i)))
        end

        for i = 0, 4, 1 do
            majorskills[i + 1] = tes3mp.GetSkillName(tonumber(tes3mp.GetClassMajorSkill(self.pid, i)))
            minorskills[i + 1] = tes3mp.GetSkillName(tonumber(tes3mp.GetClassMinorSkill(self.pid, i)))
        end

        self.data.customclass.majorattributes = table.concat(majorattributes, ", ")
        self.data.customclass.majorskills = table.concat(majorskills, ", ")
        self.data.customclass.minorskills = table.concat(minorskills, ", ")
    end
end

function Player:LoadClass()
    if self.data.character.class ~= "custom" then
        tes3mp.SetDefaultClass(self.pid, self.data.character.class)
    else
        tes3mp.SetClassName(self.pid, self.data.customclass.name)
        tes3mp.SetClassSpecialization(self.pid, self.data.customclass.specialization)

        if self.data.customclass.description ~= nil then
            tes3mp.SetClassDesc(self.pid, self.data.customclass.description)
        end

        commaSplitPattern = "([^, ]+)"

        local i = 0
        for value in string.gmatch(self.data.customclass.majorattributes, commaSplitPattern) do
            tes3mp.SetClassMajorAttribute(self.pid, i, tes3mp.GetAttributeId(value))
            i = i + 1
        end

        i = 0
        for value in string.gmatch(self.data.customclass.majorskills, commaSplitPattern) do
            tes3mp.SetClassMajorSkill(self.pid, i, tes3mp.GetSkillId(value))
            i = i + 1
        end

        i = 0
        for value in string.gmatch(self.data.customclass.minorskills, commaSplitPattern) do
            tes3mp.SetClassMinorSkill(self.pid, i, tes3mp.GetSkillId(value))
            i = i + 1
        end
    end

    tes3mp.SendClass(self.pid)
end

function Player:SaveDynamicStats()
    self.data.stats.healthBase = tes3mp.GetHealthBase(self.pid)
    self.data.stats.magickaBase = tes3mp.GetMagickaBase(self.pid)
    self.data.stats.fatigueBase = tes3mp.GetFatigueBase(self.pid)
    self.data.stats.healthCurrent = tes3mp.GetHealthCurrent(self.pid)
    self.data.stats.magickaCurrent = tes3mp.GetMagickaCurrent(self.pid)
    self.data.stats.fatigueCurrent = tes3mp.GetFatigueCurrent(self.pid)
end

function Player:LoadDynamicStats()
    tes3mp.SetHealthBase(self.pid, self.data.stats.healthBase)
    tes3mp.SetMagickaBase(self.pid, self.data.stats.magickaBase)
    tes3mp.SetFatigueBase(self.pid, self.data.stats.fatigueBase)
    tes3mp.SetHealthCurrent(self.pid, self.data.stats.healthCurrent)
    tes3mp.SetMagickaCurrent(self.pid, self.data.stats.magickaCurrent)
    tes3mp.SetFatigueCurrent(self.pid, self.data.stats.fatigueCurrent)

    tes3mp.SendDynamicStats(self.pid)
end

function Player:SaveAttributes()
    for name--[[,value--]] in pairs(self.data.attributes) do
        self.data.attributes[name] = tes3mp.GetAttributeBase(self.pid, tes3mp.GetAttributeId(name))
    end
end

function Player:LoadAttributes()
    for name,value in pairs(self.data.attributes) do
        tes3mp.SetAttributeBase(self.pid, tes3mp.GetAttributeId(name), value)
    end

    tes3mp.SendAttributes(self.pid)
end

function Player:SaveSkills()
    for name--[[,value--]] in pairs(self.data.skills) do
        self.data.skills[name] = tes3mp.GetSkillBase(self.pid, tes3mp.GetSkillId(name))
    end
end

function Player:LoadSkills()
    for name,value in pairs(self.data.skills) do
        tes3mp.SetSkillBase(self.pid, tes3mp.GetSkillId(name), value)
    end

    tes3mp.SendSkills(self.pid)
end

function Player:SaveLevel()
    self.data.stats.level = tes3mp.GetLevel(self.pid)
end

function Player:LoadLevel()
    tes3mp.SetLevel(self.pid, self.data.stats.level)
    tes3mp.SendLevel(self.pid)
end

function Player:SaveCell()
    local currentCell = ""

    if tes3mp.IsInExterior(self.pid) == 1 then
        currentCell = tes3mp.GetExteriorX(self.pid) .. "," .. tes3mp.GetExteriorY(self.pid)
    else
        currentCell = tes3mp.GetCell(self.pid)
    end

    self.data.location.cell = currentCell
    self.data.location.posX = tes3mp.GetPosX(self.pid)
    self.data.location.posY = tes3mp.GetPosY(self.pid)
    self.data.location.posZ = tes3mp.GetPosZ(self.pid)
    self.data.location.angleX = tes3mp.GetAngleX(self.pid)
    self.data.location.angleY = tes3mp.GetAngleY(self.pid)
    self.data.location.angleZ = tes3mp.GetAngleZ(self.pid)
end

function Player:LoadCell()
    local newCell = self.data.location.cell

    exteriorCellPattern = "(%-?%d+),(%-?%d+)$"

    if string.match(newCell, exteriorCellPattern) ~= nil then
        for gridX, gridY in string.gmatch(newCell, exteriorCellPattern) do
            tes3mp.SetExterior(self.pid, tonumber(gridX), tonumber(gridY))
        end
    else
        tes3mp.SetCell(self.pid, newCell)
    end

    local pos = {0, 0, 0}
    local angle = {0, 0, 0}
    pos[0] = tonumber(self.data.location.posX)
    pos[1] = tonumber(self.data.location.posY)
    pos[2] = tonumber(self.data.location.posZ)
    angle[0] = tonumber(self.data.location.angleX)
    angle[1] = tonumber(self.data.location.angleY)
    angle[2] = tonumber(self.data.location.angleZ)

    tes3mp.SetPos(self.pid, pos[0], pos[1], pos[2])
    tes3mp.SetAngle(self.pid, angle[0], angle[1], angle[2])
end

return Player
