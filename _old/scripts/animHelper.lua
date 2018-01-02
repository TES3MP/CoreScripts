tableHelper = require("tableHelper")

local animHelper = {};

local defaultAnimNames = { "hit1", "hit2", "hit3", "hit4", "hit5", "idle2", "idle3", "idle4",
    "idle5", "idle6", "idle7", "idle8", "idle9", "pickprobe" }

local generalAnimAliases = { act_impatient = "idle6", check_missing_item = "idle9", examine_hand = "idle7",
    look_behind = "idle3", shift_feet = "idle2", scratch_neck = "idle4", touch_chin = "idle8",
    touch_shoulder = "idle5" }
local femaleAnimAliases = { adjust_hair = "idle4", touch_hip = "idle5" }
local beastAnimAliases = { act_confused = "idle9", look_around = "idle2", touch_hands = "idle6" }

function animHelper.getAnimation(pid, animAlias)

    -- Is this animation included in the default animation names?
    if tableHelper.containsValue(defaultAnimNames, animAlias) then
        return animAlias
    else
        local race = string.lower(Players[pid].data.character.race)
        local gender = Players[pid].data.character.gender

        local isBeast = false
        local isFemale = false

        if race == "khajiit" or race == "argonian" then
            isBeast = true
        elseif gender == 0 then
            isFemale = true
        end

        if generalAnimAliases[animAlias] ~= nil then
            -- Did we use a general alias for something named differently for beasts?
            if isBeast and tableHelper.containsValue(beastAnimAliases, generalAnimAliases[animAlias]) then
                return "invalid"
            -- Did we use a general alias for something named differently for females?
            elseif isFemale and tableHelper.containsValue(femaleAnimAliases, generalAnimAliases[animAlias]) then
                return "invalid"
            else
                return generalAnimAliases[animAlias]
            end
        elseif isBeast and beastAnimAliases[animAlias] ~= nil then
            return beastAnimAliases[animAlias]
        elseif isFemale and femaleAnimAliases[animAlias] ~= nil then
            return femaleAnimAliases[animAlias]
        end
    end

    return "invalid"
end

function animHelper.getValidList(pid)

    local validList = {}

    local race = string.lower(Players[pid].data.character.race)
    local gender = Players[pid].data.character.gender

    local isBeast = false
    local isFemale = false

    if race == "khajiit" or race == "argonian" then
        isBeast = true
    elseif gender == 0 then
        isFemale = true
    end

    for generalAlias, defaultAnim in pairs(generalAnimAliases) do

        if (isBeast == false and isFemale == false) or
           (isBeast and tableHelper.containsValue(beastAnimAliases, defaultAnim) == false) or
           (isFemale and tableHelper.containsValue(femaleAnimAliases, defaultAnim) == false) then
            table.insert(validList, generalAlias)
        end
    end

    if isBeast then
        for beastAlias, defaultAnim in pairs(beastAnimAliases) do
            table.insert(validList, beastAlias)
        end
    end

    if isFemale then
        for femaleAlias, defaultAnim in pairs(femaleAnimAliases) do
            table.insert(validList, femaleAlias)
        end
    end

    return tableHelper.concatenateFromIndex(validList, 1, ", ")
end

function animHelper.playAnimation(pid, animAlias)

    local defaultAnim = animHelper.getAnimation(pid, animAlias)

    if defaultAnim ~= "invalid" then
        tes3mp.PlayAnimation(pid, defaultAnim, 0, 1, false)
        return true
    end

    return false
end

return animHelper
