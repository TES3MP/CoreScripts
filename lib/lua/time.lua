--- Calculate time to/from millisecond
-- @module time
time = {}

--- Calculate milliseconds from seconds
-- @int sec seconds
-- @return milliseconds
time.seconds = function(sec)
    return sec * 1000
end

--- Calculate milliseconds from minutes
-- @int min minutes
-- @return milliseconds
time.minutes = function(min)
    return min * 60000
end

--- Calculate milliseconds from hours
-- @int hours hours
-- @return milliseconds
time.hours = function(hours)
    return hours * 3600000
end

--- Calculate milliseconds from days
-- @int day days
-- @return miliseconds
time.days = function(day)
    return day * 86400000
end

--- Calculate seconds from milliseconds
-- @int msec milliseconds
-- @return seconds
time.toSeconds = function(msec)
    return msec / 1000
end

--- Calculate minutes from milliseconds
-- @int msec milliseconds
-- @return minutes
time.toMinutes = function(msec)
    return msec / 60000
end

--- Calculate hours from milliseconds
-- @int msec milliseconds
-- @return hours
time.toHours = function(msec)
    return msec / 3600000
end

--- Calculate days from milliseconds
-- @int msec milliseconds
-- @return days
time.toDays = function(msec)
    return msec / 86400000
end

return time
