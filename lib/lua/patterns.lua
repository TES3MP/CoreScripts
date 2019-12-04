patterns = {}
patterns.invalidFileCharacters = '[<>:"/\\|*?\r\n]' -- characters not allowed in filenames
patterns.commaSplit = "%s*([^,]+)" -- strings separated by commas, with spaces immediately after the commas ignored
patterns.periodSplit = "%s*([^%.]+)" -- as in commaSplit, but with periods
patterns.quoteSplit = '".-"' -- strings separated by quotation marks
patterns.exteriorCell = "(%-?%d+), ?(%-?%d+)$" -- X coordinate, Y coordinate
patterns.item = "(.+), (%d+), (%-?%d+)$" -- refId, count, charge
patterns.coordinates = "(%-?%d+%.?%d*), (%-?%d+%.?%d*), (%-?%d+%.?%d*)$" -- X coordinate, Y coordinate, Z coordinate

return patterns
