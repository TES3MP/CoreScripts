-- This file is used to track and simplify dealing with all action types
-- currently implemented in packets

actionTypes = {}
actionTypes.container = { SET = 0, ADD = 1, REMOVE = 2 }
actionTypes.spellbook = { SET = 0, ADD = 1, REMOVE = 2 }
actionTypes.faction = { RANK = 0, EXPULSION = 1, REPUTATION = 2 }
actionTypes.journal = { ENTRY = 0, INDEX = 1 }
actionTypes.resurrect = { REGULAR = 0, IMPERIAL_SHRINE = 1, TRIBUNAL_TEMPLE = 2 }

return actionTypes
