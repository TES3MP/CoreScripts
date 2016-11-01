reasons = {}

reasons.unknown = 0
reasons.killed = 1
reasons.suicide = 2
-- reasons.drowned = 3

reasons.GetReasonName = function(reason)
   if reason == reasons.killed then
        return "was killed"
    elseif reason == reasons.suicide then
        return "committed suicide"
    -- elseif reason == reasons.drowned then
    --    return "drowned"
    else
        return "died through unknown means"
    end
end

return reasons
