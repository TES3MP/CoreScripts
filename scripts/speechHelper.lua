tableHelper = require("tableHelper")
require("utils")

local speechHelper = {}

local speechTypesToFilePrefixes = { attack = "Atk", flee = "Fle", follower = "Flw", hello = "Hlo", hit = "Hit",
    idle = "Idl", intruder = "int", oppose = "OP", service = "Srv", thief = "Thf", uniform = "uni" }

local speechCollections = {}
speechCollections["argonian"] = {
    default = {
        folderPath = "a",
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
}
speechCollections["breton"] = {
    default = {
        folderPath = "b",
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
}
speechCollections["dark elf"] = {
    default = {
        folderPath = "d",
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
}
speechCollections["high elf"] = {
    default = {
        folderPath = "h",
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
}
speechCollections["imperial"] = {
    default = {
        folderPath = "i",
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
}
speechCollections["khajiit"] = {
    default = {
        folderPath = "k",
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
}
speechCollections["nord"] = {
    default = {
        folderPath = "n",
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
}
speechCollections["orc"] = {
    default = {
        folderPath = "o",
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
}
speechCollections["redguard"] = {
    default = {
        folderPath = "r",
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
}
speechCollections["wood elf"] = {
    default = {
        folderPath = "w",
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
}

function speechHelper.GetSpeechPathFromCollection(speechCollectionTable, speechType, speechIndex, gender)

    if speechCollectionTable == nil or speechTypesToFilePrefixes[speechType] == nil then
        return nil
    end

    local filePrefix = speechTypesToFilePrefixes[speechType]
    local genderTableName

    if gender == 0 then genderTableName = "femaleFiles"
    else genderTableName = "maleFiles" end

    local speechTypeTable = speechCollectionTable[genderTableName][speechType]

    if speechTypeTable == nil then
        return nil
    else
        if speechIndex > speechTypeTable.count then
            return nil
        elseif speechTypeTable.skip ~= nil and tableHelper.containsValue(speechTypeTable.skip, speechIndex) then
            return nil
        end
    end

    local speechPath = "Vo\\" .. speechCollectionTable.folderPath .. "\\"

    -- Assume there are only going to be subfolders for different genders if there are actually
    -- speech files for both genders
    if speechCollectionTable.maleFiles ~= nil and speechCollectionTable.femaleFiles ~= nil then
        if gender == 0 then
            speechPath = speechPath .. "f\\"
        else
            speechPath = speechPath .. "m\\"
        end
    end

    speechPath = speechPath .. filePrefix .. "_"

    local indexPrefix

    if speechTypeTable.prefixOverride ~= nil then
        indexPrefix = speechTypeTable.prefixOverride
    elseif gender == 0 then
        indexPrefix = speechCollectionTable.femalePrefix
    else
        indexPrefix = speechCollectionTable.malePrefix
    end

    speechPath = speechPath .. indexPrefix .. prefixZeroes(speechIndex, 3) .. ".mp3"

    return speechPath
end

function speechHelper.GetSpeechPath(pid, speechInput, speechIndex)

    local speechCollectionKey
    local speechType

    -- Is there a specific folder at the start of the speechInput? If so,
    -- get the speechCollectionKey from it
    local underscoreIndex = string.find(speechInput, "_")

    if underscoreIndex ~= nil and underscoreIndex > 1 then
        speechCollectionKey = string.sub(speechInput, 1, underscoreIndex - 1)
        speechType = string.sub(speechInput, underscoreIndex + 1)
    else
        speechCollectionKey = "default"
        speechType = speechInput
    end

    local race = string.lower(Players[pid].data.character.race)
    local speechCollectionTable = speechCollections[race][speechCollectionKey]

    if speechCollectionTable ~= nil then

        local gender = Players[pid].data.character.gender

        return speechHelper.GetSpeechPathFromCollection(speechCollectionTable, speechType, speechIndex, gender)
    else
        return nil
    end
end

function speechHelper.GetPrintableValidListForSpeechCollection(speechCollectionTable, gender, collectionPrefix)

    local validList = {}
    local genderTableName

    if gender == 0 then
        genderTableName = "femaleFiles"
    else
        genderTableName = "maleFiles"
    end
    
    if speechCollectionTable[genderTableName] ~= nil then
        for speechType, typeDetails in pairs(speechCollectionTable[genderTableName]) do
            local validInput = ""

            if collectionPrefix then
                validInput = collectionPrefix
            end

            validInput = validInput .. speechType .. " 1-" .. typeDetails.count

            if typeDetails.skip ~= nil then
                validInput = validInput .. " (except "
                validInput = validInput .. tableHelper.concatenateFromIndex(typeDetails.skip, 1, ", ") .. ")"
            end

            table.insert(validList, validInput)
        end
    end

    return validList
end

function speechHelper.GetPrintableValidListForPid(pid)

    local validList = {}

    local race = string.lower(Players[pid].data.character.race)
    local gender = Players[pid].data.character.gender

    -- Print the default speech options first
    if speechCollections[race].default ~= nil then
        validList = speechHelper.GetPrintableValidListForSpeechCollection(speechCollections[race].default, gender)
    end

    for speechCollectionKey, speechCollectionTable in pairs(speechCollections[race]) do
        if speechCollectionKey ~= "default" then
            tableHelper.insertValues(validList, speechHelper.GetPrintableValidListForSpeechCollection(speechCollectionTable, gender, speechCollectionKey .. "_"))
        end
    end

    return tableHelper.concatenateFromIndex(validList, 1, ", ")
end

function speechHelper.PlaySpeech(pid, speechInput, speechIndex)

    local speechPath = speechHelper.GetSpeechPath(pid, speechInput, speechIndex)

    if speechPath ~= nil then
        tes3mp.PlaySpeech(pid, speechPath)
        return true
    end

    return false
end

return speechHelper
