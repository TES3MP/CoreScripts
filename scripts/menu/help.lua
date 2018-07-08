Menus["help player"] = {
    text = color.Orange .. "Player command list:\n" ..
        color.Yellow .. "/message <pid> <text> " .. color.White .. "- Send a private message to a player (/msg)\n" ..
        color.Yellow .. "/me <text> " .. color.White .. "- Send a message written in the third person\n" ..
        color.Yellow .. "/local <text> " .. color.White .. "- Send a message that only players in your area can read (/l)\n" ..
        color.Yellow .. "/list " .. color.White .. "- List all players on the server\n" ..
        color.Yellow .. "/anim <animation> " .. color.White .. "- Play an animation on yourself, with a list of valid " ..
            "inputs being provided if you use an invalid one (/a)\n" ..
        color.Yellow .. "/speech <type> <index> " .. color.White .. "- Play a certain speech on yourself, with a list of " ..
            "valid inputs being provided if you use invalid ones (/s)\n" ..
        color.Yellow .. "/craft " .. color.White .. "- Open up a small crafting menu used as a scripting example\n" ..
        color.Yellow .. "/help " .. color.White .. "- Get the list of available commands",
    buttons = {
        { caption = "Admin help",
            destinations = {
                menuHelper.destinations.setDefault("help admin")
            }
        },
        { caption = "Moderator help",
            destinations = {
                menuHelper.destinations.setDefault("help moderator")
            }
        },
        { caption = "Exit", destinations = nil }
    }
}

-- Handle commands that only exist based on config options
if config.allowSuicideCommand == true then
    Menus["help player"].text = Menus["help player"].text .. "\n" .. color.Yellow .. "/suicide " ..
        color.White .. "- Commit suicide"
end

if config.allowFixmeCommand == true then
    Menus["help player"].text = Menus["help player"].text .. "\n" .. color.Yellow .. "/fixme " ..
        color.White .. "- Get unstuck from your current location; can only be used once every " ..
        config.fixmeInterval .. " seconds"
end

Menus["help moderator"] = {
    text = color.Orange .. "Moderator command list:\n" ..
        color.Yellow .. "/kick <pid> " .. color.White .. "- Kick player\n" ..
        color.Yellow .. "/ban ip <ip> " .. color.White .. "- Ban an IP address\n" ..
        color.Yellow .. "/ban name <name> " .. color.White .. "- Ban a player and all IP addresses stored for them\n" ..
        color.Yellow .. "/ban <pid> " .. color.White .. "- Same as above, but using a pid as the argument\n" ..
        color.Yellow .. "/unban ip <ip> " .. color.White .. "- Unban an IP address\n" ..
        color.Yellow .. "/unban name <name> " .. color.White .. "- Unban a player name and all IP addresses stored for them\n" ..
        color.Yellow .. "/banlist ips/names " .. color.White .. "- Print all banned IPs or all banned player names\n" ..
        color.Yellow .. "/ipaddresses <name> " .. color.White .. "- Print all the IP addresses used by a player (/ips)\n" ..
        color.Yellow .. "/confiscate <pid> " .. color.White .. "- Open up a window where you can confiscate an item from " ..
            "a player\n" ..
        color.Yellow .. "/sethour <value> " .. color.White .. "- Set the current hour in the world's time\n" ..
        color.Yellow .. "/setday <value> " .. color.White .. "- Set the current day of the month in the world's time\n" ..
        color.Yellow .. "/setmonth <value> " .. color.White .. "- Set the current month in the world's time\n" ..
        color.Yellow .. "/settimescale <value> " .. color.White .. "- Set the timescale in the world's time" ..
            "(30 by default, which is 120 real seconds per ingame hour)\n" ..
        color.Yellow .. "/teleport <pid>/all " .. color.White .. "- Teleport another player to your position (/tp)\n" ..
        color.Yellow .. "/teleportto <pid> " .. color.White .. "- Teleport yourself to another player (/tpto)\n" ..
        color.Yellow .. "/cells " .. color.White .. "- List all loaded cells on the server\n" ..
        color.Yellow .. "/getpos <pid> " .. color.White .. "- Get player position and cell\n" ..
        color.Yellow .. "/setattr <pid> <attribute> <value> " .. color.White .. "- Set a player's attribute to a" ..
            "certain value\n" ..
        color.Yellow .. "/setskill <pid> <skill> <value> " .. color.White .. "- Set a player's skill to a certain value\n" ..
        color.Yellow .. "/setmomentum <pid> <x> <y> <z> " .. color.White .. "- Set a player's momentum to certain values\n" ..
        color.Yellow .. "/setauthority <pid> <cell> " .. color.White .. "- Forcibly set a certain player as the authority" ..
            "of a cell (/setauth)",
    buttons = {
        { caption = "Admin help",
            destinations = {
                menuHelper.destinations.setDefault("help admin")
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

Menus["help admin"] = {
    text = color.Orange .. "Admin command list:\n" ..
        color.Yellow .. "/setai <refIndex> <action> (<pid>/<refIndex>) " .. color.White .. "- Set an AI action for " ..
            "the actor with a certain refIndex, with an optional target at the end\n" ..
        color.Yellow .. "/setrace <pid> <race> " .. color.White .. "- Change a player's race\n" ..
        color.Yellow .. "/sethead <pid> <body part id> " .. color.White .. "- Change a player's head\n" ..
        color.Yellow .. "/sethair <pid> <body part id> " .. color.White .. "- Change a player's hairstyle\n" ..
        color.Yellow .. "/disguise <pid> <refId> " .. color.White .. "- Set a player's creature disguise, or remove " ..
            "it by using an invalid refId\n" ..
        color.Yellow .. "/usecreaturename <pid> on/off " .. color.White .. "- Set whether a player disguised as a " ..
            "creature shows up as having that creature's name when hovered over\n" ..
        color.Yellow .. "/addmoderator <pid> " .. color.White .. "- Promote player to moderator\n" ..
        color.Yellow .. "/removemoderator <pid> " .. color.White .. "- Demote player from moderator\n" ..
        color.Yellow .. "/setdifficulty <pid> <value>/default " .. color.White .. "- Set the difficulty for a " ..
            "particular player\n" ..
        color.Yellow .. "/setconsole <pid> on/off/default " .. color.White .. "- Enable/disable in-game console " ..
            "for player\n" ..
        color.Yellow .. "/setbedrest <pid> on/off/default " .. color.White .. "- Enable/disable bed resting for player\n" ..
        color.Yellow .. "/setwildrest <pid> on/off/default " .. color.White .. "- Enable/disable wilderness resting " ..
            "for player\n" ..
        color.Yellow .. "/setwait <pid> on/off/default " .. color.White .. "- Enable/disable waiting for player\n" ..
        color.Yellow .. "/setscale <pid> <value> " .. color.White .. "- Sets a player's scale",
    buttons = {
        { caption = "Admin help page 2",
            destinations = {
                menuHelper.destinations.setDefault("help admin page 2")
            }
        },
        { caption = "Moderator help",
            destinations = {
                menuHelper.destinations.setDefault("help moderator")
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
        color.Yellow .. "/setwerewolf <pid> on/off " .. color.White .. "- Set the werewolf state of a particular " ..
            "player\n" ..
        color.Yellow .. "/storeconsole <pid> <command> " .. color.White .. "- Store a certain console command for " ..
            "a player\n" ..
        color.Yellow .. "/runconsole <pid> (<count>) (<interval>) " .. color.White .. "- Run a stored console command " ..
            "on a player, with optional count and interval\n" ..
        color.Yellow .. "/placeat <pid> <refId> (<count>) (<interval>) " .. color.White .. "- Place a certain object " ..
            "at a player's location, with optional count and interval\n" ..
        color.Yellow .. "/spawnat <pid> <refId> (<count>) (<interval>) " .. color.White .. "- Spawn a certain creature " ..
            "or NPC at a player's location, with optional count and interval\n" ..
        color.Yellow .. "/setloglevel <pid> <value>/default " .. color.White .. "- Set the enforced log level for a " ..
            "particular player\n" ..
        color.Yellow .. "/setphysicsfps <pid> <value>/default " .. color.White .. "- Set the physics framerate for a " ..
            "particular player\n" ..
        color.Yellow .. "/setcollision <category> on/off (on/off) " .. color.White .. "- Set the collision state for " ..
            "an object category (PLAYER, ACTOR or PLACED_OBJECT), with the third optional argument affecting whether " ..
            "placed objects use actor-like collision",
    buttons = {
        { caption = "Admin help page 1",
            destinations = {
                menuHelper.destinations.setDefault("help admin")
            }
        },
        { caption = "Moderator help",
            destinations = {
                menuHelper.destinations.setDefault("help moderator")
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
