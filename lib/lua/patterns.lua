--- Usefull patterns that can be used
-- @module patterns

--- Usefull patterns
-- @table patterns
patterns = {
    invalidFileCharacters = '[<>:"/\\|*?\r\n]', -- characters not allowed in filenames
    commaSplit = "%s*([^,]+)", -- strings separated by commas, with spaces immediately after the commas ignored
    periodSplit = "%s*([^%.]+)", -- as in commaSplit, but with periods
    exteriorCell = "(%-?%d+), ?(%-?%d+)$", -- X coordinate, Y coordinate
    item = "(.+), (%d+), (%-?%d+)$", -- refId, count, charge
    coordinates = "(%-?%d+%.?%d*), (%-?%d+%.?%d*), (%-?%d+%.?%d*)$"  -- X coordinate, Y coordinate, Z coordinate
}

return patterns
