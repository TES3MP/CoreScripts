-- This file is used to track and simplify dealing with all enumerations
-- currently implemented in packets

enumerations = {}
enumerations.ai = { CANCEL = 0, ACTIVATE = 1, COMBAT = 2, ESCORT = 3, FOLLOW = 4, TRAVEL = 5, WANDER = 6 }
enumerations.aiPrintableAction = { CANCEL = "cancelling current AI", ACTIVATE = "activating",
    COMBAT = "initiating combat with", ESCORT = "escorting", FOLLOW = "following", TRAVEL = "travelling to",
    WANDER = "wandering" }
enumerations.container = { SET = 0, ADD = 1, REMOVE = 2 }
enumerations.containerSub = { NONE = 0, DRAG = 1, DROP = 2, TAKE_ALL = 3, REPLY_TO_REQUEST = 4 }
enumerations.faction = { RANK = 0, EXPULSION = 1, REPUTATION = 2 }
enumerations.inventory = { SET = 0, ADD = 1, REMOVE = 2 }
enumerations.journal = { ENTRY = 0, INDEX = 1 }
enumerations.log = { VERBOSE = 0, INFO = 1, WARN = 2, ERROR = 3, FATAL = 4 }
enumerations.miscellaneous = { MARK_LOCATION = 0, SELECTED_SPELL = 1 }
enumerations.objectCategories = { PLAYER = 0, ACTOR = 1, PLACED_OBJECT = 2 }
enumerations.packetOrigin = { CLIENT_GAMEPLAY = 0, CLIENT_CONSOLE = 1, CLIENT_DIALOGUE = 2,
    CLIENT_SCRIPT_LOCAL = 3, CLIENT_SCRIPT_GLOBAL = 4, SERVER_SCRIPT = 5 }
enumerations.recordType = { ARMOR = 0, BOOK = 1, CLOTHING = 2, CREATURE = 3, ENCHANTMENT = 4, MISCELLANEOUS = 5,
    NPC = 6, POTION = 7, SPELL = 8, WEAPON = 9 }
enumerations.resurrect = { REGULAR = 0, IMPERIAL_SHRINE = 1, TRIBUNAL_TEMPLE = 2 }
enumerations.spellbook = { SET = 0, ADD = 1, REMOVE = 2 }

return enumerations
