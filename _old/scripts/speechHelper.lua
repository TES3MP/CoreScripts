tableHelper = require("tableHelper")
require("utils")

local speechHelper = {};

local speechTypeAliases = { attack = "Atk", flee = "Fle", follower = "Flw", hello = "Hlo", hit = "Hit",
    idle = "Idl", intruder = "int", oppose = "OP", service = "Srv", thief = "Thf", uniform = "uni" }

local speechFolders = {}
speechFolders["argonian"] = {
    folder = "a",
    malePrefix = "AM",
    femalePrefix = "AF",
    maleFiles = {
        attack = { count = 15 },
        flee = { count = 5 },
        follower = { count = 3 },
        hello = { count = 139 },
        hit = { count = 16, skip = { 11 } },
        idle = { count = 8 },
        intruder = { count = 9, skip = { 7 }, prefixOverride = "OP" },
        service = { count = 12 },
        thief = { count = 5 }
    },
    femaleFiles = {
        attack = { count = 17, skip = { 11, 15, 16 } },
        flee = { count = 5 },
        follower = { count = 6 },
        hello = { count = 139 },
        hit = { count = 16 },
        idle = { count = 8 },
        oppose = { count = 8 },
        service = { count = 12 },
        thief = { count = 5 }
    }
}
speechFolders["breton"] = {
    folder = "b",
    malePrefix = "BM",
    femalePrefix = "BF",
    maleFiles = {
        attack = { count = 15, skip = { 11 } },
        flee = { count = 5 },
        follower = { count = 6 },
        hello = { count = 138, skip = { 126 } },
        hit = { count = 15 },
        idle = { count = 8 },
        intruder = { count = 9, skip = { 7 }, prefixOverride = "OP" },
        service = { count = 12 },
        thief = { count = 5 }
    },
    femaleFiles = {
        attack = { count = 15, skip = { 11 } },
        flee = { count = 5 },
        follower = { count = 6 },
        hello = { count = 138 },
        hit = { count = 15 },
        idle = { count = 9 },
        oppose = { count = 8 },
        service = { count = 15 },
        thief = { count = 5 }
    }
}
speechFolders["dark elf"] = {
    folder = "d",
    malePrefix = "DM",
    femalePrefix = "DF",
    maleFiles = {
        attack = { count = 14 },
        flee = { count = 6 },
        follower = { count = 4 },
        hello = { count = 233 },
        hit = { count = 14 },
        idle = { count = 9 },
        oppose = { count = 8 },
        service = { count = 52 },
        thief = { count = 5 }
    },
    femaleFiles = {
        attack = { count = 13 },
        flee = { count = 5 },
        follower = { count = 6 },
        hello = { count = 233 },
        hit = { count = 14, skip = { 7 } },
        idle = { count = 9, skip = { 7, 8 } },
        oppose = { count = 8 },
        service = { count = 51 },
        thief = { count = 3, skip = { 1, 2 } }
    }
}
speechFolders["high elf"] = {
    folder = "h",
    malePrefix = "HM",
    femalePrefix = "HF",
    maleFiles = {
        attack = { count = 15 },
        flee = { count = 5 },
        follower = { count = 6 },
        hello = { count = 138 },
        hit = { count = 15, skip = { 14 } },
        idle = { count = 9 },
        oppose = { count = 8 },
        service = { count = 25 },
        thief = { count = 5 }
    },
    femaleFiles = {
        attack = { count = 15 },
        flee = { count = 5 },
        follower = { count = 6 },
        hello = { count = 138 },
        hit = { count = 15 },
        idle = { count = 8 },
        oppose = { count = 8 },
        service = { count = 18 },
        thief = { count = 5 }
    }
}
speechFolders["imperial"] = {
    folder = "i",
    malePrefix = "IM",
    femalePrefix = "IF",
    maleFiles = {
        attack = { count = 14 },
        flee = { count = 4 },
        follower = { count = 3 },
        hello = { count = 179, skip = { 1, 27, 47, 69, 70, 71, 72, 80, 81, 82, 83, 84, 85, 86,
            100, 101, 102, 103, 104, 105, 106, 107, 128, 129, 143, 144, 145, 171, 173, 174, 176 } },
        hit = { count = 10 },
        idle = { count = 9 },
        oppose = { count = 8 },
        service = { count = 34 },
        thief = { count = 5 },
        uniform = { count = 7 }
    },
    femaleFiles = {
        attack = { count = 15, skip = { 11 } },
        flee = { count = 5 },
        follower = { count = 6 },
        hello = { count = 173, skip = { 159, 163 } },
        hit = { count = 15 },
        idle = { count = 9 },
        oppose = { count = 8 },
        service = { count = 21 },
        thief = { count = 5 }
    }
}
speechFolders["khajiit"] = {
    folder = "k",
    malePrefix = "KM",
    femalePrefix = "KF",
    maleFiles = {
        attack = { count = 15, skip = { 11 } },
        flee = { count = 5 },
        follower = { count = 3 },
        hello = { count = 139 },
        hit = { count = 16 },
        idle = { count = 9 },
        intruder = { count = 9, skip = { 7 }, prefixOverride = "OP" },
        service = { count = 9 },
        thief = { count = 5 }
    },
    femaleFiles = {
        attack = { count = 15, skip = { 11 } },
        flee = { count = 5 },
        follower = { count = 6 },
        hello = { count = 139 },
        hit = { count = 16 },
        idle = { count = 9 },
        oppose = { count = 8 },
        service = { count = 12 },
        thief = { count = 5 }
    }
}
speechFolders["nord"] = {
    folder = "n",
    malePrefix = "NM",
    femalePrefix = "NF",
    maleFiles = {
        attack = { count = 20, skip = { 14, 15, 16, 17, 18, 19 } },
        flee = { count = 5 },
        follower = { count = 4 },
        hello = { count = 138 },
        hit = { count = 14 },
        idle = { count = 9 },
        intruder = { count = 9, skip = { 7 }, prefixOverride = "OP" },
        service = { count = 6 },
        thief = { count = 5 }
    },
    femaleFiles = {
        attack = { count = 15, skip = { 11 } },
        flee = { count = 5 },
        follower = { count = 6 },
        hello = { count = 138 },
        hit = { count = 15 },
        idle = { count = 9 },
        oppose = { count = 8 },
        service = { count = 11 },
        thief = { count = 5 }
    }
}
speechFolders["orc"] = {
    folder = "o",
    malePrefix = "OM",
    femalePrefix = "OF",
    maleFiles = {
        attack = { count = 15 },
        flee = { count = 5 },
        follower = { count = 6 },
        hello = { count = 138 },
        hit = { count = 15 },
        idle = { count = 9 },
        oppose = { count = 8 },
        service = { count = 12 },
        thief = { count = 5 }
    },
    femaleFiles = {
        attack = { count = 15 },
        flee = { count = 5 },
        follower = { count = 6 },
        hello = { count = 138 },
        hit = { count = 21 },
        idle = { count = 9 },
        oppose = { count = 8 },
        service = { count = 3 },
        thief = { count = 5 }
    }
}
speechFolders["redguard"] = {
    folder = "r",
    malePrefix = "RM",
    femalePrefix = "RF",
    maleFiles = {
        attack = { count = 18 },
        flee = { count = 5 },
        follower = { count = 3 },
        hello = { count = 138 },
        hit = { count = 15 },
        idle = { count = 9 },
        intruder = { count = 9, skip = { 7 }, prefixOverride = "OP" },
        service = { count = 12 },
        thief = { count = 5 }
    },
    femaleFiles = {
        attack = { count = 15, skip = { 1, 11 } },
        flee = { count = 5 },
        follower = { count = 6 },
        hello = { count = 138 },
        hit = { count = 14 },
        idle = { count = 9 },
        oppose = { count = 8 },
        service = { count = 6 },
        thief = { count = 5 }
    }
}
speechFolders["wood elf"] = {
    folder = "w",
    malePrefix = "WM",
    femalePrefix = "WF",
    maleFiles = {
        attack = { count = 18, skip = { 14, 15, 16, 17 } },
        flee = { count = 5 },
        follower = { count = 3 },
        hello = { count = 138 },
        hit = { count = 15 },
        idle = { count = 9 },
        intruder = { count = 9, skip = { 7 }, prefixOverride = "OP" },
        service = { count = 6 },
        thief = { count = 5 }
    },
    femaleFiles = {
        attack = { count = 14 },
        flee = { count = 5 },
        follower = { count = 6 },
        hello = { count = 138 },
        hit = { count = 15 },
        idle = { count = 9 },
        oppose = { count = 8 },
        service = { count = 9 },
        thief = { count = 5 }
    }
}

function speechHelper.getSpeech(pid, speechTypeAlias, speechIndex)

    local speechType

    -- Accept only type aliases (as in "hello"), not original names for types (as in "Hlo")
    if speechTypeAliases[speechTypeAlias] ~= nil then
        speechType = speechTypeAliases[speechTypeAlias]
    else
        return "invalid"
    end

    local race = string.lower(Players[pid].data.character.race)
    local gender = Players[pid].data.character.gender

    if speechFolders[race] ~= nil then

        local genderTableName

        if gender == 0 then
            genderTableName = "femaleFiles"
        else
            genderTableName = "maleFiles"
        end

        local speechTypeTable = speechFolders[race][genderTableName][speechTypeAlias]

        if speechTypeTable == nil then
            return "invalid"
        else
            if speechIndex > speechTypeTable.count then
                return "invalid"
            elseif speechTypeTable.skip ~= nil and tableHelper.containsValue(speechTypeTable.skip, speechIndex) then
                return "invalid"
            end
        end

        local raceFolder = speechFolders[race].folder
        local speechPath = "Vo\\" .. raceFolder

        if gender == 0 then
            speechPath = speechPath .. "\\f\\"
        else
            speechPath = speechPath .. "\\m\\"
        end

        speechPath = speechPath .. speechType .. "_"

        local indexPrefix

        if speechTypeTable.prefixOverride ~= nil then
            indexPrefix = speechTypeTable.prefixOverride
        elseif gender == 0 then
            indexPrefix = speechFolders[race].femalePrefix
        else
            indexPrefix = speechFolders[race].malePrefix
        end

        speechPath = speechPath .. indexPrefix .. prefixZeroes(speechIndex, 3) .. ".mp3"

        return speechPath
    end

    return "invalid"
end

function speechHelper.getValidList(pid)

    local validList = {}

    local race = string.lower(Players[pid].data.character.race)
    local gender = Players[pid].data.character.gender
    local genderTableName

    if gender == 0 then
        genderTableName = "femaleFiles"
    else
        genderTableName = "maleFiles"
    end

    local validSpeechTable = speechFolders[race][genderTableName]

    for speechTypeAlias, typeDetails in pairs(validSpeechTable) do
        local validInput = speechTypeAlias .. " 1-" .. typeDetails.count

        if typeDetails.skip ~= nil then
            validInput = validInput .. " (except "
            validInput = validInput .. tableHelper.concatenateFromIndex(typeDetails.skip, 1, ", ") .. ")"
        end

        table.insert(validList, validInput)
    end

    return tableHelper.concatenateFromIndex(validList, 1, ", ")
end

function speechHelper.playSpeech(pid, speechTypeAlias, speechIndex)

    local speechPath = speechHelper.getSpeech(pid, speechTypeAlias, speechIndex)

    if speechPath ~= "invalid" then
        tes3mp.PlaySpeech(pid, speechPath)
        return true
    end

    return false
end

return speechHelper
