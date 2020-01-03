require("patterns")
tableHelper = require("tableHelper")

local fileHelper = {}

-- Avoid using the following filenames because of their reserved status on operating systems
fileHelper.invalidFilenames = { "CON", "PRN", "AUX", "NUL", "COM1", "COM2", "COM3", "COM4", "COM5",
    "COM6", "COM7", "COM8", "COM9", "LPT1", "LPT2", "LPT3", "LPT4", "LPT5", "LPT6", "LPT7",
    "LPT8", "LPT9" }

-- Turn an invalid filename into a valid one
function fileHelper.fixFilename(filename)

    -- Trim spaces at the start and end of the filename
    filename = filename:trim()
    
    -- Replace characters not allowed in filenames
    filename = string.gsub(filename, ":", ";")
    filename = string.gsub(filename, patterns.invalidFileCharacters, "_")

    -- Also replace periods because of their special meaning, i.e. a file named
    -- AUX.test.json would not get fixed in the loop below, but would still be
    -- invalid on Windows
    filename = string.gsub(filename, "%.", ",")

    -- If the filename itself is invalid, add an underline at the start
    if tableHelper.containsValue(fileHelper.invalidFilenames, filename) then
        filename = "_" .. filename
    end

    return filename
end

return fileHelper
