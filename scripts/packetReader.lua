packetReader = {}

packetReader.GetRecordEffects = function(recordIndex)

    local effectTable = {}
    local effectCount = tes3mp.GetRecordEffectCount(recordIndex)

    for effectIndex = 0, effectCount - 1 do

        local effect = {
            id = tes3mp.GetRecordEffectId(recordIndex, effectIndex),
            attribute = tes3mp.GetRecordEffectAttribute(recordIndex, effectIndex),
            skill = tes3mp.GetRecordEffectSkill(recordIndex, effectIndex),
            rangeType = tes3mp.GetRecordEffectRangeType(recordIndex, effectIndex),
            area = tes3mp.GetRecordEffectArea(recordIndex, effectIndex),
            duration = tes3mp.GetRecordEffectDuration(recordIndex, effectIndex),
            magnitudeMin = tes3mp.GetRecordEffectMagnitudeMin(recordIndex, effectIndex),
            magnitudeMax = tes3mp.GetRecordEffectMagnitudeMax(recordIndex, effectIndex)
        }

        table.insert(effectTable, effect)
    end

    return effectTable
end

return packetReader
