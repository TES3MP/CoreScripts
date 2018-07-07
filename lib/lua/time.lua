time = {}
time.seconds = function(sec)
    return sec * 1000
end

time.minutes = function(min)
    return min * 60000
end

time.hours = function(hours)
    return hours * 3600000
end

time.days = function(day)
    return day * 86400000
end

time.toSeconds = function(msec)
    return msec / 1000
end

time.toMinutes = function(msec)
    return msec / 60000
end

time.toHours = function(msec)
    return msec / 3600000
end

time.toDays = function(msec)
    return msec / 86400000
end

return time
