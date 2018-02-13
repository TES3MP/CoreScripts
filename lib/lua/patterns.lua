patterns = {}
patterns.invalidFileCharacters = '[<>:"/\\|*?]' -- characters not allowed in filenames
patterns.commaSplit = "([^, ]+)" -- strings separated by commas
patterns.exteriorCell = "(%-?%d+), ?(%-?%d+)$" -- X coordinate, Y coordinate
patterns.item = "(.+), (%d+), (%-?%d+)$" -- refId, count, charge
patterns.coordinates = "(%-?%d+%.?%d*), (%-?%d+%.?%d*), (%-?%d+%.?%d*)$" -- X coordinate, Y coordinate, Z coordinate

return patterns
