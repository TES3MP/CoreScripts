DefaultPatterns = {}
DefaultPatterns.invalidFileCharacters = '[<>:"/\\|*?]' -- characters not allowed in filenames
DefaultPatterns.commaSplit = "([^, ]+)" -- strings separated by commas
DefaultPatterns.exteriorCell = "(%-?%d+), ?(%-?%d+)$" -- X coordinate, Y coordinate
DefaultPatterns.item = "(.+), (%d+), (%-?%d+)$" -- refId, count, charge
DefaultPatterns.coordinates = "(%-?%d+%.?%d*), (%-?%d+%.?%d*), (%-?%d+%.?%d*)$" -- X coordinate, Y coordinate, Z coordinate

return DefaultPatterns
