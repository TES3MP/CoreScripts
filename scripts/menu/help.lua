Menus["help player"] = {
    text = "Player command list:\
        /message <pid> <text> - Send a private message to a player (/msg)\
        /me <text> - Send a message written in the third person\
        /local <text> - Send a message that only players in your area can read (/l)\
        /list - List all players on the server\
        /anim <animation> - Play an animation on yourself, with a list of valid inputs being provided if you use an invalid one (/a)\
        /speech <type> <index> - Play a certain speech on yourself, with a list of valid inputs being provided if you use invalid ones (/s)\
        /craft - Open up a small crafting menu used as a scripting example\
        /help - Get the list of available commands",
    buttons = {
        { caption = "Moderator help",
            destinations = {
                menuHelper.destinations.setDefault("help moderator")
            }
        },
        { caption = "Admin help",
            destinations = {
                menuHelper.destinations.setDefault("help admin")
            }
        },
        { caption = "Exit", destinations = nil }
    }
}

-- Handle commands that only exist based on config options
if config.allowSuicideCommand == true then
    Menus["help player"].text = Menus["help player"].text .. "\n/suicide - Commit suicide"
end

if config.allowFixmeCommand == true then
    Menus["help player"].text = Menus["help player"].text .. "\n/fixme - Get unstuck from your current location; can only be used once every " .. config.fixmeInterval .. " seconds"
end

Menus["help moderator"] = {
    text = "Moderators command list:\
        /kick <pid> - Kick player\
        /ban ip <ip> - Ban an IP address\
        /ban name <name> - Ban a player and all IP addresses stored for them\
        /ban <pid> - Same as above, but using a pid as the argument\
        /unban ip <ip> - Unban an IP address\
        /unban name <name> - Unban a player name and all IP addresses stored for them\
        /banlist ips/names - Print all banned IPs or all banned player names\
        /ipaddresses <name> - Print all the IP addresses used by a player (/ips)\
        /confiscate <pid> - Open up a window where you can confiscate an item from a player\
        /sethour <value> - Set the current hour in the world's time\
        /setday <value> - Set the current day of the month in the world's time\
        /setmonth <value> - Set the current month in the world's time\
        /settimescale <value> - Set the timescale in the world's time (30 by default, which is 120 real seconds per ingame hour)\
        /teleport <pid>/all - Teleport another player to your position (/tp)\
        /teleportto <pid> - Teleport yourself to another player (/tpto)\
        /cells - List all loaded cells on the server\
        /getpos <pid> - Get player position and cell\
        /setattr <pid> <attribute> <value> - Set a player's attribute to a certain value\
        /setskill <pid> <skill> <value> - Set a player's skill to a certain value\
        /setmomentum <pid> <x> <y> <z> - Set a player's momentum to certain values\
        /setauthority <pid> <cell> - Forcibly set a certain player as the authority of a cell (/setauth)",
    buttons = {
        { caption = "Player help",
            destinations = {
                menuHelper.destinations.setDefault("help player")
            }
        },
        { caption = "Admin help",
            destinations = {
                menuHelper.destinations.setDefault("help admin")
            }
        },
        { caption = "Exit", destinations = nil }
    }
}

Menus["help admin"] = {
    text = "Admin command list:\
        /setai <refIndex> <action> (<pid>/<refIndex>) - Set an AI action for the actor with a certain refIndex, with an optional target at the end\
        /setrace <pid> <race> - Change a player's race\
        /sethead <pid> <body part id> - Change a player's head\
        /sethair <pid> <body part id> - Change a player's hairstyle\
        /disguise <pid> <refId> - Set a player's creature disguise, or remove it by using an invalid refId\
        /usecreaturename <pid> on/off - Set whether a player disguised as a creature shows up as having that creature's name when hovered over\
        /addmoderator <pid> - Promote player to moderator\
        /removemoderator <pid> - Demote player from moderator\
        /setdifficulty <pid> <value>/default - Set the difficulty for a particular player\
        /setconsole <pid> on/off/default - Enable/disable in-game console for player\
        /setbedrest <pid> on/off/default - Enable/disable bed resting for player\
        /setwildrest <pid> on/off/default - Enable/disable wilderness resting for player\
        /setwait <pid> on/off/default - Enable/disable waiting for player\
        /setscale <pid> <value> - Sets a player's scale\
        /setwerewolf <pid> on/off - Set the werewolf state of a particular player\
        /storeconsole <pid> <command> - Store a certain console command for a player\
        /runconsole <pid> (<count>) (<interval>) - Run a stored console command on a player, with optional count and interval\
        /placeat <pid> <refId> (<count>) (<interval>) - Place a certain object at a player's location, with optional count and interval\
        /spawnat <pid> <refId> (<count>) (<interval>) - Spawn a certain creature or NPC at a player's location, with optional count and interval\
        /setloglevel <pid> <value>/default - Set the enforced log level for a particular player\
        /setphysicsfps <pid> <value>/default - Set the physics framerate for a particular player\
        /setcollision <category> on/off (on/off) - Set the collision state for an object category (PLAYER, ACTOR or PLACED_OBJECT), with the third optional argument affecting whether placed objects use actor-like collision",
    buttons = {
        { caption = "Player help",
            destinations = {
                menuHelper.destinations.setDefault("help player")
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
