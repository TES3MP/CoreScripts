time = {}

---@param sec number
---@return number
time.seconds = function(sec)
    return sec * 1000
end

---@param min number
---@return number
time.minutes = function(min)
    return min * 60000
end

---@param hours number
---@return number
time.hours = function(hours)
    return hours * 3600000
end

---@param day number
---@return number
time.days = function(day)
    return day * 86400000
end

---@param msec number
---@return number
time.toSeconds = function(msec)
    return msec / 1000
end

---@param msec number
---@return number
time.toMinutes = function(msec)
    return msec / 60000
end

---@param msec number
---@return number
time.toHours = function(msec)
    return msec / 3600000
end

---@param msec number
---@return number
time.toDays = function(msec)
    return msec / 86400000
end

return time
