Menus["help player"] = {
    text = color.Orange .. "Player command list:\n" ..
        color.Yellow .. "/invite <pid>\n" ..
            color.White .. "Invite a player to become your ally, with your AI followers being more forgiving towards " ..
            "your allies\n" ..
        color.Yellow .. "/join <pid>\n" ..
            color.White .. "Accept an invitation to become a player's ally\n" ..
        color.Yellow .. "/leave <pid>\n" ..
            color.White .. "Leave an alliance with a player\n" ..
        color.Yellow .. "/message <pid> <text>\n" ..
            color.White .. "Send a private message to a player " ..
            color.Yellow .. "(/msg)\n" ..
        color.Yellow .. "/me <text>\n" ..
            color.White .. "Send a message written in the third person\n" ..
        color.Yellow .. "/local <text>\n" ..
            color.White .. "Send a message that only players in your area can read " ..
            color.Yellow .. "(/l)\n" ..
        color.Yellow .. "/list\n" ..
            color.White .. "List all players on the server\n" ..
        color.Yellow .. "/anim <animation>\n" ..
            color.White .. "Play an animation on yourself, with a list of valid inputs being provided " ..
            "if you use an invalid one " ..
            color.Yellow .. "(/a)\n" ..
        color.Yellow .. "/speech <type> <index>\n" ..
            color.White .. "Play a certain speech on yourself, with a list of valid inputs being provided " ..
            "if you use invalid ones " ..
            color.Yellow .. "(/s)\n" ..
        color.Yellow .. "/craft\n" ..
            color.White .. "Open up a small crafting menu used as a scripting example\n" ..
        color.Yellow .. "/help\n" ..
            color.White .. "Get the list of available commands",
    buttons = {
        { caption = "Admin help",
            displayConditions = {
                menuHelper.conditions.requireStaffRank(2)
            },
            destinations = {
                menuHelper.destinations.setDefault("help admin page 1")
            }
        },
        { caption = "Moderator help",
            displayConditions = {
                menuHelper.conditions.requireStaffRank(1)
            },
            destinations = {
                menuHelper.destinations.setDefault("help moderator page 1")
            }
        },
        { caption = "Exit", destinations = nil }
    }
}

-- Handle commands that only exist based on config options
if config.allowSuicideCommand == true then
    Menus["help player"].text = Menus["help player"].text .. "\n" .. color.Yellow .. "/suicide\n" ..
        color.White .. "Commit suicide"
end

if config.allowFixmeCommand == true then
    Menus["help player"].text = Menus["help player"].text .. "\n" .. color.Yellow .. "/fixme\n" ..
        color.White .. "Get unstuck from your current location; can only be used once every " ..
        config.fixmeInterval .. " seconds"
end

Menus["help moderator page 1"] = {
    text = color.Orange .. "Moderator command list page 1:\n" ..
        color.Yellow .. "/kick <pid>\n" ..
            color.White .. "Kick player\n" ..
        color.Yellow .. "/ban ip <ip>\n" ..
            color.White .. "Ban an IP address\n" ..
        color.Yellow .. "/ban name <name>\n" ..
            color.White .. "Ban a player and all IP addresses stored for them\n" ..
        color.Yellow .. "/ban <pid>\n" ..
            color.White .. "Same as above, but using a pid as the argument\n" ..
        color.Yellow .. "/unban ip <ip>\n" ..
            color.White .. "Unban an IP address\n" ..
        color.Yellow .. "/unban name <name>\n" ..
            color.White .. "Unban a player name and all IP addresses stored for them\n" ..
        color.Yellow .. "/banlist ips/names\n" ..
            color.White .. "Print all banned IPs or all banned player names\n" ..
        color.Yellow .. "/ipaddresses <name>\n" ..
            color.White .. "Print all the IP addresses used by a player " ..
            color.Yellow .. "(/ips)\n" ..
        color.Yellow .. "/confiscate <pid>\n" ..
            color.White .. "Open up a window where you can confiscate an item from a player\n" ..
        color.Yellow .. "/sethour <value>\n" ..
            color.White .. "Set the current hour in the world's time\n" ..
        color.Yellow .. "/setday <value>\n" ..
            color.White .. "Set the current day of the month in the world's time\n" ..
        color.Yellow .. "/setmonth <value>\n" ..
            color.White .. "Set the current month in the world's time\n" ..
        color.Yellow .. "/settimescale day/night/both <value>\n" ..
            color.White .. "Set the timescale in the world's time (30 by default, which is 120 real seconds " ..
            "per ingame hour)\n",
    buttons = {
        { caption = "Moderator help page 2",
            displayConditions = {
                menuHelper.conditions.requireStaffRank(1)
            },
            destinations = {
                menuHelper.destinations.setDefault("help moderator page 2")
            }
        },
        { caption = "Admin help",
            displayConditions = {
                menuHelper.conditions.requireStaffRank(2)
            },
            destinations = {
                menuHelper.destinations.setDefault("help admin page 1")
            }
        },
        { caption = "Player help",
            destinations = {
                menuHelper.destinations.setDefault("help player")
            }
        },
        { caption = "Exit", destinations = nil }
    }
}

Menus["help moderator page 2"] = {
    text = color.Orange .. "Moderator command list page 2:\n" ..
        color.Yellow .. "/resetkills\n" ..
            color.White .. "Reset the kill counts for NPCs and creatures, to allow quests requiring a specific number of kills to be done again\n" ..
        color.Yellow .. "/teleport <pid>/all\n" ..
            color.White .. "Teleport another player to your position " ..
            color.Yellow .. "(/tp)\n" ..
        color.Yellow .. "/teleportto <pid>\n" ..
            color.White .. "Teleport yourself to another player " ..
            color.Yellow .. "(/tpto)\n" ..
        color.Yellow .. "/cells\n" ..
            color.White .. "List all loaded cells on the server\n" ..
        color.Yellow .. "/getpos <pid>\n" ..
            color.White .. "Get player position and cell\n" ..
        color.Yellow .. "/setattr <pid> <attribute> <value>\n" ..
            color.White .. "Set a player's attribute to a certain value\n" ..
        color.Yellow .. "/setskill <pid> <skill> <value>\n" ..
            color.White .. "Set a player's skill to a certain value\n" ..
        color.Yellow .. "/setmomentum <pid> <x> <y> <z>\n" ..
            color.White .. "Set a player's momentum to certain values\n" ..
        color.Yellow .. "/setauthority <pid> <cell>\n" ..
            color.White .. "Forcibly set a certain player as the authority of a cell " ..
            color.Yellow .. "(/setauth)\n" ..
        color.Yellow .. "/advancedexample\n" ..
            color.White .. "Display an example of an advanced menu using menuHelper " ..
            color.Yellow .. "(/advex)",
    buttons = {
        { caption = "Moderator help page 1",
            displayConditions = {
                menuHelper.conditions.requireStaffRank(1)
            },
            destinations = {
                menuHelper.destinations.setDefault("help moderator page 1")
            }
        },
        { caption = "Admin help",
            displayConditions = {
                menuHelper.conditions.requireStaffRank(2)
            },
            destinations = {
                menuHelper.destinations.setDefault("help admin page 1")
            }
        },
        { caption = "Player help",
            destinations = {
                menuHelper.destinations.setDefault("help player")
            }
        },
        { caption = "Exit", destinations = nil }
    }
}

Menus["help admin page 1"] = {
    text = color.Orange .. "Admin command list page 1:\n" ..
        color.Yellow .. "/runstartup\n" ..
            color.White .. "Run the ingame startup scripts that set the correct states for some quest-related actors and objects\n" ..
        color.Yellow .. "/load <scriptName>\n" ..
            color.White .. "Load or reload a script file on the fly\n" ..
        color.Yellow .. "/setai <uniqueIndex> activate/combat/follow <pid>/<uniqueIndex>\n" ..
            color.White .. "Make the actor with a certain uniqueIndex target a player or another uniqueIndex\n" ..
        color.Yellow .. "/setai <uniqueIndex> cancel\n" ..
            color.White .. "Make the actor with a certain uniqueIndex cancel its AI sequence\n" ..
        color.Yellow .. "/setai <uniqueIndex> travel <x> <y> <z>\n" ..
            color.White .. "Make the actor with a certain uniqueIndex travel to certain X, Y and Z coordinates\n" ..
        color.Yellow .. "/setai <uniqueIndex> wander <distance> <duration> true/false\n" ..
            color.White .. "Make the actor with a certain uniqueIndex wander for the specified distance and duration, with repetition being true or false\n" ..
        color.Yellow .. "/setrace <pid> <race>\n" ..
            color.White .. "Change a player's race\n" ..
        color.Yellow .. "/sethead <pid> <body part id>\n" ..
            color.White .. "Change a player's head\n" ..
        color.Yellow .. "/sethair <pid> <body part id>\n" ..
            color.White .. "Change a player's hairstyle\n" ..
        color.Yellow .. "/disguise <pid> <refId>\n" ..
            color.White .. "Set a player's creature disguise, or remove it by using an invalid refId\n" ..
        color.Yellow .. "/usecreaturename <pid> on/off\n" ..
            color.White .. "Set whether a player disguised as a creature shows up as having that creature's " ..
            "name when hovered over\n" ..
        color.Yellow .. "/addmoderator <pid>\n" ..
            color.White .. "Promote player to moderator\n" ..
        color.Yellow .. "/removemoderator <pid>\n" ..
            color.White .. "Demote player from moderator\n" ..
        color.Yellow .. "/setdifficulty <pid> <value>/default\n" ..
            color.White .. "Set the difficulty for a particular player\n" ..
        color.Yellow .. "/setconsole <pid> on/off/default\n" ..
            color.White .. "Enable/disable in-game console for player\n",
    buttons = {
        { caption = "Admin help page 2",
            displayConditions = {
                menuHelper.conditions.requireStaffRank(2)
            },
            destinations = {
                menuHelper.destinations.setDefault("help admin page 2")
            }
        },
        { caption = "Custom record help",
            displayConditions = {
                menuHelper.conditions.requireStaffRank(2)
            },
            destinations = {
                menuHelper.destinations.setDefault("help record origin")
            }
        },
        { caption = "Moderator help",
            displayConditions = {
                menuHelper.conditions.requireStaffRank(1)
            },
            destinations = {
                menuHelper.destinations.setDefault("help moderator page 1")
            }
        },
        { caption = "Player help",
            destinations = {
                menuHelper.destinations.setDefault("help player")
            }
        },
        { caption = "Exit", destinations = nil }
    }
}

Menus["help admin page 2"] = {
    text = color.Orange .. "Admin command list page 2:\n" ..
        color.Yellow .. "/setbedrest <pid> on/off/default\n" ..
            color.White .. "Enable/disable bed resting for player\n" ..
        color.Yellow .. "/setwildrest <pid> on/off/default\n" ..
            color.White .. "Enable/disable wilderness resting for player\n" ..
        color.Yellow .. "/setwait <pid> on/off/default\n" ..
            color.White .. "Enable/disable waiting for player\n" ..
        color.Yellow .. "/setscale <pid> <value>\n" ..
            color.White .. "Sets a player's scale\n" ..
        color.Yellow .. "/setwerewolf <pid> on/off\n" ..
            color.White .. "Set the werewolf state of a particular player\n" ..
        color.Yellow .. "/storeconsole <pid> <command>\n" ..
            color.White .. "Store a certain console command for a player\n" ..
        color.Yellow .. "/runconsole <pid> (<count>) (<interval>)\n" ..
            color.White .. "Run a stored console command on a player, with optional count and interval in miliseconds\n" ..
        color.Yellow .. "/placeat <pid> <refId>\n" ..
            color.White .. "Place a certain non-living object at a player's location\n" ..
        color.Yellow .. "/spawnat <pid> <refId>\n" ..
            color.White .. "Spawn a certain creature or NPC at a player's location\n" ..
        color.Yellow .. "/storerecord <type> <setting> <value>\n" ..
            color.White .. "Store a setting value for a custom record in your player data before creating it;" ..
            "check the help page for custom records for more information\n" ..
        color.Yellow .. "/createrecord <type>\n" ..
            color.White .. "Create a custom record based on what is stored for that record type in your player " ..
            "data\n" ..
        color.Yellow .. "/setloglevel <pid> <value>/default\n" ..
            color.White .. "Set the enforced log level for a particular player\n" ..
        color.Yellow .. "/setphysicsfps <pid> <value>/default\n" ..
            color.White .. "Set the physics framerate for a particular player\n" ..
        color.Yellow .. "/setcollision <category> on/off\n" ..
            color.White .. "Set the collision state for an object category (PLAYER, ACTOR or PLACED_OBJECT), " ..
            "with the third optional argument affecting whether placed objects use actor-like collision\n" ..
        color.Yellow .. "/overridecollision <refId> on/off\n" ..
            color.White .. "Turn a collision-enabling override on and off for a specific refId until the " ..
            " next server restart",
    buttons = {
        { caption = "Admin help page 1",
            displayConditions = {
                menuHelper.conditions.requireStaffRank(2)
            },
            destinations = {
                menuHelper.destinations.setDefault("help admin page 1")
            }
        },
        { caption = "Custom record help",
            displayConditions = {
                menuHelper.conditions.requireStaffRank(2)
            },
            destinations = {
                menuHelper.destinations.setDefault("help record origin")
            }
        },
        { caption = "Moderator help",
            displayConditions = {
                menuHelper.conditions.requireStaffRank(1)
            },
            destinations = {
                menuHelper.destinations.setDefault("help moderator page 1")
            }
        },
        { caption = "Player help",
            destinations = {
                menuHelper.destinations.setDefault("help player")
            }
        },
        { caption = "Exit", destinations = nil }
    }
}

Menus["help record origin"] = {
    text = color.White .. "To create a record, you first fill in its values using this command:\n" ..
        color.Yellow .. "/storerecord <type> <setting> <value>\n" ..
        color.White .. "To see the values you've filled in for a certain type of record, use this:\n" ..
        color.Yellow .. "/storerecord <type> print\n" ..
        color.White .. "To clear the values you've filled in, use this:\n" ..
        color.Yellow .. "/storerecord <type> clear\n" ..
        color.White .. "As of now, you can use the following for the " .. color.Yellow .. "<type>" ..
            color.White .. " argument:\n" ..
        color.Yellow .. tableHelper.concatenateTableIndexes(config.validRecordSettings, ", ") .. "\n" ..
        color.White .. "To see what you can use for the " .. color.Yellow .. "<setting>" .. color.White ..
            " argument, simply put in an invalid setting and the valid ones will be displayed for that record " ..
            "type.\nOnce you've filled in the various settings, use this command to create your record:\n" ..
        color.Yellow .. "/createrecord <type>\n\n" ..
        color.White .. "Your record can be:\n" ..
        color.Yellow .. "1) " .. color.White .. "A record created entirely from scratch, when not " ..
            "setting a baseId for it and either not setting an id for it or setting an unused one\n" ..
        color.Yellow .. "2) " .. color.White .. "A record that uses an existing record's values as " ..
            "its starting values without modifying anything in that existing record, when setting a "..
            "baseId for it and either not setting an id for it or setting an unused one\n" ..
        color.Yellow .. "3) " .. color.White .. "A record created from scratch that replaces an " ..
            "existing record in the game, when not setting a baseId and setting an id that " ..
            "is already used in the game\n" ..
        color.Yellow .. "4) " .. color.White .. "A record that uses an existing record's values as " ..
            "its starting values and replaces an existing record, when setting both a baseId for it " ..
            "and an id that is already used in the game, with the baseId and id potentially " ..
            "being the same if you want to replace an existing record with a modified version of itself\n",
    buttons = {
        { caption = "Back to admin help",
            displayConditions = { menuHelper.conditions.requireStaffRank(2) },
            destinations = { menuHelper.destinations.setDefault("help admin page 1") }
        },
        { caption = "Examples of record creation",
            destinations = { menuHelper.destinations.setDefault("help record examples") }
        },
        { caption = "Exit", destinations = nil }
    }
}

Menus["help record examples"] = {
    text = color.White .. "Pick one of the following examples.",
    buttons = {
        { caption = "Create a new NPC entirely from scratch",
            destinations = { menuHelper.destinations.setDefault("help record example npc 1") }
        },
        { caption = "Create a new NPC using another as a starting point",
            destinations = { menuHelper.destinations.setDefault("help record example npc 2") }
        },
        { caption = "Replace an existing NPC with one created from scratch",
            destinations = { menuHelper.destinations.setDefault("help record example npc 3") }
        },
        { caption = "Replace an existing NPC with a modified version of itself",
            destinations = { menuHelper.destinations.setDefault("help record example npc 4") }
        },
        { caption = "Replace an existing creature with another existing creature",
            destinations = { menuHelper.destinations.setDefault("help record example creature 1") }
        },
        { caption = "Create a new enchantment entirely from scratch",
            destinations = { menuHelper.destinations.setDefault("help record example enchantment 1") }
        },
        { caption = "Create a new armor item entirely from scratch",
            destinations = { menuHelper.destinations.setDefault("help record example armor 1") }
        },
        { caption = "Create a new book entirely from scratch",
            destinations = { menuHelper.destinations.setDefault("help record example book 1") }
        },
        { caption = "Create a new clothing item entirely from scratch",
            destinations = { menuHelper.destinations.setDefault("help record example clothing 1") }
        },
        { caption = "Create a new miscellaneous item entirely from scratch",
            destinations = { menuHelper.destinations.setDefault("help record example miscellaneous 1") }
        },
        { caption = "Create a new weapon entirely from scratch",
            destinations = { menuHelper.destinations.setDefault("help record example weapon 1") }
        },
        { caption = "Back to record introduction",
            destinations = { menuHelper.destinations.setDefault("help record origin") }
        },
        { caption = "Exit", destinations = nil }
    }
}

Menus["help record example npc 1"] = {
    text = color.White .. "Use the following commands to create a custom NPC record entirely from scratch:\n" ..
        color.Yellow .. "/storerecord npc clear\n" ..
        color.Yellow .. "/storerecord npc name <name>\n" ..
        color.Yellow .. "/storerecord npc gender male/female\n" ..
        color.Yellow .. "/storerecord npc race <race>\n" ..
        color.Yellow .. "/storerecord npc head <head>\n" ..
        color.Yellow .. "/storerecord npc hair <hair>\n" ..
        color.Yellow .. "/storerecord npc class <class>\n\n" ..
        color.Yellow .. "/storerecord npc level <level>\n\n" ..
        color.Yellow .. "/storerecord npc add item <itemId>\n\n" ..
        color.White .. "When you're done, type in:\n" ..
        color.Yellow .. "/createrecord npc\n\n" ..
        color.White .. "Example series of commands:\n" ..
        color.Yellow .. "/storerecord npc clear\n" ..
        color.Yellow .. "/storerecord npc name Eldaen\n" ..
        color.Yellow .. "/storerecord npc gender male\n" ..
        color.Yellow .. "/storerecord npc race high elf\n" ..
        color.Yellow .. "/storerecord npc head b_n_high elf_m_head_05\n" ..
        color.Yellow .. "/storerecord npc hair b_n_high elf_m_hair_04\n" ..
        color.Yellow .. "/storerecord npc class battlemage\n" ..
        color.Yellow .. "/storerecord npc level 20\n" ..
        color.Yellow .. "/storerecord npc add item extravagant_shirt_01, 1\n\n" ..
        color.Yellow .. "/storerecord npc add item extravagant_pants_01, 1\n\n" ..
        color.Yellow .. "/storerecord npc add item extravagant_shoes_01, 1\n\n" ..
        color.Yellow .. "/createrecord npc",
    buttons = {
        { caption = "Back to examples page",
            destinations = { menuHelper.destinations.setDefault("help record examples") }
        },
        { caption = "Exit", destinations = nil }
    }
}

Menus["help record example npc 2"] = {
    text = color.White .. "Use the following commands to start creating a custom NPC record based on an existing one:\n" ..
        color.Yellow .. "/storerecord npc clear\n" ..
        color.Yellow .. "/storerecord npc baseId <baseId>\n" ..
        color.White .. "Next, put in what you want to be different for this NPC compared to the original. For " ..
            "instance, suppose you want to have female Imperial Guards separately from the male Imperial Guards. " ..
            "Here's a series of commands for that:\n" ..
        color.Yellow .. "/storerecord npc clear\n" ..
        color.Yellow .. "/storerecord npc baseId imperial guard\n" ..
        color.Yellow .. "/storerecord npc gender female\n" ..
        color.Yellow .. "/storerecord npc head b_n_imperial_f_head_01\n" ..
        color.Yellow .. "/storerecord npc hair b_n_imperial_f_hair_03\n" ..
        color.Yellow .. "/createrecord npc",
    buttons = {
        { caption = "Back to examples page",
            destinations = { menuHelper.destinations.setDefault("help record examples") }
        },
        { caption = "Exit", destinations = nil }
    }
}

Menus["help record example npc 3"] = {
    text = color.White .. "To replace an existing NPC record with an entirely new one, get the id of your " ..
        "existing NPC and put it in:\n" ..
        color.Yellow .. "/storerecord npc clear\n" ..
        color.Yellow .. "/storerecord npc id <id>\n" ..
        color.White .. "Next, set up the details of your NPC like you normally would. For instance, suppose you " ..
            "want to replace Teleri Helvi (from Seyda Neen) with the Argonian Im-Leet. Here's a series of " ..
            "commands for that:\n" ..
        color.Yellow .. "/storerecord npc clear\n" ..
        color.Yellow .. "/storerecord npc id teleri helvi\n" ..
        color.Yellow .. "/storerecord npc name Im-Leet\n" ..
        color.Yellow .. "/storerecord npc gender male\n" ..
        color.Yellow .. "/storerecord npc race argonian\n" ..
        color.Yellow .. "/storerecord npc head b_n_argonian_m_head_03\n" ..
        color.Yellow .. "/storerecord npc hair b_n_argonian_m_hair05\n" ..
        color.Yellow .. "/storerecord npc class knight\n" ..
        color.Yellow .. "/storerecord npc add item glass_greaves, 1\n\n" ..
        color.Yellow .. "/createrecord npc",
    buttons = {
        { caption = "Back to examples page",
            destinations = { menuHelper.destinations.setDefault("help record examples") }
        },
        { caption = "Exit", destinations = nil }
    }
}

Menus["help record example npc 4"] = {
    text = color.White .. "To replace an existing NPC record with a modified version of itself, get the id of " ..
        "your existing NPC and put it in as both the id and baseId:\n" ..
        color.Yellow .. "/storerecord npc clear\n" ..
        color.Yellow .. "/storerecord npc id <id>\n" ..
        color.Yellow .. "/storerecord npc baseId <id>\n" ..
        color.White .. "Next, set up what should be different compared to the original record. For instance, suppose " ..
            "you want to turn Fargoth into a Guard who chases down law-breakers while wearing the equipment typical " ..
            "of an Imperial Guard. Here's a series of commands for that:\n" ..
        color.Yellow .. "/storerecord npc clear\n" ..
        color.Yellow .. "/storerecord npc id fargoth\n" ..
        color.Yellow .. "/storerecord npc baseId fargoth\n" ..
        color.Yellow .. "/storerecord npc class guard\n" ..
        color.Yellow .. "/storerecord npc inventoryBaseId imperial guard\n" ..
        color.Yellow .. "/createrecord npc",
    buttons = {
        { caption = "Back to examples page",
            destinations = { menuHelper.destinations.setDefault("help record examples") }
        },
        { caption = "Exit", destinations = nil }
    }
}

Menus["help record example creature 1"] = {
    text = color.White .. "To replace an existing creature record with another existing creature, set the id of " ..
        "the creature you want to replace:\n" ..
        color.Yellow .. "/storerecord creature clear\n" ..
        color.Yellow .. "/storerecord creature id <id>\n" ..
        color.White .. "Then use the id of the creature you want to replace it with as the baseId:\n" ..
        color.Yellow .. "/storerecord creature baseId <baseId>\n" ..
        color.White .. "When you're done, type in:\n" ..
        color.Yellow .. "/createrecord creature\n\n" ..
        color.White .. "For example, suppose you want to replace the Mudcrab Merchant with a regular Mudcrab, " ..
            "to throw players off. You can do that using this series of commands:\n" ..
        color.Yellow .. "/storerecord creature clear\n" ..
        color.Yellow .. "/storerecord creature id mudcrab_unique\n" ..
        color.Yellow .. "/storerecord creature baseId mudcrab\n" ..
        color.Yellow .. "/createrecord creature",
    buttons = {
        { caption = "Back to examples page",
            destinations = { menuHelper.destinations.setDefault("help record examples") }
        },
        { caption = "Exit", destinations = nil }
    }
}

Menus["help record example enchantment 1"] = {
    text = color.White .. "Use the following commands to create a custom enchantment record entirely from scratch:\n" ..
        color.Yellow .. "/storerecord enchantment clear\n" ..
        color.Yellow .. "/storerecord enchantment subtype <subtype>\n" ..
        color.Yellow .. "/storerecord enchantment cost <cost>\n" ..
        color.Yellow .. "/storerecord enchantment charge <charge>\n" ..
        color.Yellow .. "/storerecord enchantment add effect <id>, <rangeType>, <duration>, <area>, <magnitudeMin>, " ..
            "<magnitudeMax>, <attribute>, <skill>\n" ..
        color.White .. "When you're done, type in:\n" ..
        color.Yellow .. "/createrecord enchantment\n\n" ..
        color.White .. "Example series of commands:\n" ..
        color.Yellow .. "/storerecord enchantment clear\n" ..
        color.Yellow .. "/storerecord enchantment subtype 1\n" ..
        color.Yellow .. "/storerecord enchantment cost 30\n" ..
        color.Yellow .. "/storerecord enchantment charge 400\n" ..
        color.Yellow .. "/storerecord enchantment add effect 14, 2, 5, 5, 20, 50, -1, -1\n" ..
        color.Yellow .. "/createrecord enchantment",
    buttons = {
        { caption = "Back to examples page",
            destinations = { menuHelper.destinations.setDefault("help record examples") }
        },
        { caption = "Exit", destinations = nil }
    }
}

Menus["help record example armor 1"] = {
    text = color.White .. "Use the following commands to create a custom armor record entirely from scratch:\n" ..
        color.Yellow .. "/storerecord armor clear\n" ..
        color.Yellow .. "/storerecord armor name <name>\n" ..
        color.Yellow .. "/storerecord armor model <model>\n" ..
        color.Yellow .. "/storerecord armor icon <icon>\n" ..
        color.Yellow .. "/storerecord armor subtype <subtype>\n" ..
        color.Yellow .. "/storerecord armor add part <partType>, <malePart>, <femalePart>\n" ..
        color.Yellow .. "/storerecord armor weight <weight>\n" ..
        color.Yellow .. "/storerecord armor value <value>\n" ..
        color.Yellow .. "/storerecord armor health <health>\n" ..
        color.Yellow .. "/storerecord armor armorRating <armorRating>\n" ..
        color.White .. "When you're done, type in:\n" ..
        color.Yellow .. "/createrecord armor\n\n" ..
        color.White .. "Example series of commands:\n" ..
        color.Yellow .. "/storerecord armor clear\n" ..
        color.Yellow .. "/storerecord armor name Khajiit Mask\n" ..
        color.Yellow .. "/storerecord armor model b\\B_V_Khajiit_M_Head_01.nif\n" ..
        color.Yellow .. "/storerecord armor icon a\\Tx_dustAdept_helm.tga\n" ..
        color.Yellow .. "/storerecord armor subtype 0\n" ..
        color.Yellow .. "/storerecord armor add part 0, b_v_khajiit_m_head_01, b_v_khajiit_f_head_01\n" ..
        color.Yellow .. "/storerecord armor add part 1, b_n_khajiit_m_hair01, b_n_khajiit_f_hair01\n" ..
        color.Yellow .. "/storerecord armor weight 3\n" ..
        color.Yellow .. "/storerecord armor value 5\n" ..
        color.Yellow .. "/storerecord armor health 20\n" ..
        color.Yellow .. "/storerecord armor armorRating 3\n" ..
        color.Yellow .. "/createrecord armor",
    buttons = {
        { caption = "Back to examples page",
            destinations = { menuHelper.destinations.setDefault("help record examples") }
        },
        { caption = "Exit", destinations = nil }
    }
}

Menus["help record example book 1"] = {
    text = color.White .. "Use the following commands to create a custom book record entirely from scratch:\n" ..
        color.Yellow .. "/storerecord book clear\n" ..
        color.Yellow .. "/storerecord book name <name>\n" ..
        color.Yellow .. "/storerecord book model <model>\n" ..
        color.Yellow .. "/storerecord book icon <icon>\n" ..
        color.Yellow .. "/storerecord book text <text>\n" ..
        color.Yellow .. "/storerecord book scrollState true/false\n" ..
        color.White .. "When you're done, type in:\n" ..
        color.Yellow .. "/createrecord book\n\n" ..
        color.White .. "Example series of commands:\n" ..
        color.Yellow .. "/storerecord book clear\n" ..
        color.Yellow .. "/storerecord book name Tattered note\n" ..
        color.Yellow .. "/storerecord book model m\\Text_Note_02.nif\n" ..
        color.Yellow .. "/storerecord book icon m\\Tx_note_02.tga\n" ..
        color.Yellow .. "/storerecord book text Someone has stolen all my pillows.<p>Life has no meaning now.<p>\n" ..
        color.Yellow .. "/storerecord book scrollState true\n" ..
        color.Yellow .. "/createrecord book\n" ..
        color.White .. "There is a limit to how much text you can input in the chat window, so – for longer text " ..
            "– you'll have to edit the record's text manually in data/recordstore/book.json",
    buttons = {
        { caption = "Back to examples page",
            destinations = { menuHelper.destinations.setDefault("help record examples") }
        },
        { caption = "Exit", destinations = nil }
    }
}

Menus["help record example clothing 1"] = {
    text = color.White .. "Use the following commands to create a custom clothing record entirely from scratch:\n" ..
        color.Yellow .. "/storerecord clothing clear\n" ..
        color.Yellow .. "/storerecord clothing name <name>\n" ..
        color.Yellow .. "/storerecord clothing model <model>\n" ..
        color.Yellow .. "/storerecord clothing icon <icon>\n" ..
        color.Yellow .. "/storerecord clothing subtype <subtype>\n" ..
        color.Yellow .. "/storerecord clothing add part <partType>, <malePart>, <femalePart>\n" ..
        color.Yellow .. "/storerecord clothing weight <weight>\n" ..
        color.Yellow .. "/storerecord clothing value <value>\n" ..
        color.White .. "When you're done, type in:\n" ..
        color.Yellow .. "/createrecord clothing\n\n" ..
        color.White .. "Example series of commands:\n" ..
        color.Yellow .. "/storerecord clothing clear\n" ..
        color.Yellow .. "/storerecord clothing name Robe of Blinding Speed\n" ..
        color.Yellow .. "/storerecord clothing model c\\C_M_Robe_common_03b_GND.NIF\n" ..
        color.Yellow .. "/storerecord clothing icon c\\tx_Robe_com03b.tga\n" ..
        color.Yellow .. "/storerecord clothing subtype 4\n" ..
        color.Yellow .. "/storerecord clothing add part 3, c_m_robe_common_03b\n" ..
        color.Yellow .. "/storerecord clothing weight 3\n" ..
        color.Yellow .. "/storerecord clothing value 500\n" ..
        color.Yellow .. "/storerecord clothing enchantmentId blinding speed\n" ..
        color.Yellow .. "/createrecord clothing",
    buttons = {
        { caption = "Back to examples page",
            destinations = { menuHelper.destinations.setDefault("help record examples") }
        },
        { caption = "Exit", destinations = nil }
    }
}

Menus["help record example miscellaneous 1"] = {
    text = color.White .. "Use the following commands to create a custom miscellaneous record entirely from scratch:\n" ..
        color.Yellow .. "/storerecord miscellaneous clear\n" ..
        color.Yellow .. "/storerecord miscellaneous name <name>\n" ..
        color.Yellow .. "/storerecord miscellaneous model <model>\n" ..
        color.Yellow .. "/storerecord miscellaneous icon <icon>\n" ..
        color.Yellow .. "/storerecord miscellaneous weight <weight>\n" ..
        color.Yellow .. "/storerecord miscellaneous value <value>\n" ..
        color.White .. "When you're done, type in:\n" ..
        color.Yellow .. "/createrecord miscellaneous\n\n" ..
        color.White .. "Example series of commands:\n" ..
        color.Yellow .. "/storerecord miscellaneous clear\n" ..
        color.Yellow .. "/storerecord miscellaneous name Placeable Crate\n" ..
        color.Yellow .. "/storerecord miscellaneous model o\\Contain_crate_01.NIF\n" ..
        color.Yellow .. "/storerecord miscellaneous icon m\\misc_dwrv_gear00.tga\n" ..
        color.Yellow .. "/storerecord miscellaneous weight 20\n" ..
        color.Yellow .. "/storerecord miscellaneous value 10\n" ..
        color.Yellow .. "/createrecord miscellaneous",
    buttons = {
        { caption = "Back to examples page",
            destinations = { menuHelper.destinations.setDefault("help record examples") }
        },
        { caption = "Exit", destinations = nil }
    }
}

Menus["help record example weapon 1"] = {
    text = color.White .. "Use the following commands to create a custom weapon record entirely from scratch:\n" ..
        color.Yellow .. "/storerecord weapon clear\n" ..
        color.Yellow .. "/storerecord weapon name <name>\n" ..
        color.Yellow .. "/storerecord weapon model <model>\n" ..
        color.Yellow .. "/storerecord weapon icon <icon>\n" ..
        color.Yellow .. "/storerecord weapon subtype <subtype>\n" ..
        color.Yellow .. "/storerecord weapon weight <weight>\n" ..
        color.Yellow .. "/storerecord weapon value <value>\n" ..
        color.Yellow .. "/storerecord weapon health <health>\n" ..
        color.Yellow .. "/storerecord weapon speed <speed>\n" ..
        color.Yellow .. "/storerecord weapon reach <reach>\n" ..
        color.Yellow .. "/storerecord weapon damageChop <min> <max>\n" ..
        color.Yellow .. "/storerecord weapon damageSlash <min> <max>\n" ..
        color.Yellow .. "/storerecord weapon damageThrust <min> <max>\n" ..
        color.Yellow .. "/storerecord weapon enchantmentId <enchantmentId>\n" ..
        color.White .. "When you're done, type in:\n" ..
        color.Yellow .. "/createrecord weapon\n\n" ..
        color.White .. "Example series of commands:\n" ..
        color.Yellow .. "/storerecord weapon clear\n" ..
        color.Yellow .. "/storerecord weapon name Combat Pillow\n" ..
        color.Yellow .. "/storerecord weapon model m\\Misc_Com_Pillow_01.nif\n" ..
        color.Yellow .. "/storerecord weapon icon m\\Misc_Com_Pillow_01.tga\n" ..
        color.Yellow .. "/storerecord weapon weight 1\n" ..
        color.Yellow .. "/storerecord weapon value 1\n" ..
        color.Yellow .. "/storerecord weapon health 10\n" ..
        color.Yellow .. "/storerecord weapon speed 1.1\n" ..
        color.Yellow .. "/storerecord weapon reach 1.1\n" ..
        color.Yellow .. "/storerecord weapon damageChop 0 2\n" ..
        color.White .. "Finally, for your pillow to be a two-handed blunt weapon, use these lines:\n" ..
        color.Yellow .. "/storerecord weapon subtype 5\n" ..
        color.Yellow .. "/storerecord weapon damageSlash 0 2\n" ..
        color.Yellow .. "/storerecord weapon damageThrust 0 1\n" ..
        color.White .. "Or, if you'd rather turn it into a throwable weapon, use this:\n" ..
        color.Yellow .. "/storerecord weapon subtype 11\n" ..
        color.White .. "Then, as always, use:\n" ..
        color.Yellow .. "/createrecord weapon",
    buttons = {
        { caption = "Back to examples page",
            destinations = { menuHelper.destinations.setDefault("help record examples") }
        },
        { caption = "Exit", destinations = nil }
    }
}
