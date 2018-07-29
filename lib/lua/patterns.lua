patterns = {}
patterns.invalidFileCharacters = '[<>:"/\\|*?]' -- characters not allowed in filenames
patterns.commaSplit = "%s*([^,]+)" -- strings separated by commas, with spaces immediately after the commas ignored
patterns.exteriorCell = "(%-?%d+), ?(%-?%d+)$" -- X coordinate, Y coordinate
patterns.item = "(.+), (%d+), (%-?%d+)$" -- refId, count, charge
patterns.coordinates = "(%-?%d+%.?%d*), (%-?%d+%.?%d*), (%-?%d+%.?%d*)$" -- X coordinate, Y coordinate, Z coordinate

return patterns
