Menus["advanced example origin"] = {
    text = {
        color.Orange .. "Welcome, " .. color.Yellow,
        menuHelper.variables.currentPlayerVariable("data.login.name"),
        color.Orange .. "! This is an example of an advanced menu. Use it as a starting point for your own.\n\n" ..
            color.White .. "Select what kind of functions you want to run."
    },
    buttons = {
        { caption = "Player functions",
            destinations = { menuHelper.destinations.setDefault("advanced example player") }
        },
        { caption = "World instance functions",
            destinations = { menuHelper.destinations.setDefault("advanced example world") }
        },
        { caption = "logicHandler functions",
            destinations = { menuHelper.destinations.setDefault("advanced example logichandler") }
        },
        { caption = "Global functions",
            destinations = { menuHelper.destinations.setDefault("advanced example global") }
        },
        { caption = "Exit", destinations = nil }
    }
}

Menus["advanced example player"] = {
    text = color.Orange .. "Select a function to run on this player.",
    buttons = {
        { caption = "Save()",
            destinations = {
                menuHelper.destinations.setDefault(nil,
                {
                    menuHelper.effects.runPlayerFunction("Save")
                })
            }
        },
        { caption = "Message(\"This is a test\n\")",
            destinations = {
                menuHelper.destinations.setDefault(nil,
                {
                    menuHelper.effects.runPlayerFunction("Message", {"This is a test\n"})
                })
            }
        },
        { caption = "Back", destinations = { menuHelper.destinations.setFromCustomVariable("previousCustomMenu") } },
        { caption = "Exit", destinations = nil }
    }
}

Menus["advanced example world"] = {
    text = {
        color.Orange .. "The world time is set to year " .. color.Yellow,
        menuHelper.variables.globalVariable("WorldInstance", "data.time.year"),
        color.Orange .. ", month " .. color.Yellow,
        menuHelper.variables.globalVariable("WorldInstance", "data.time.month"),
        color.Orange .. " and day " .. color.Yellow,
        menuHelper.variables.globalVariable("WorldInstance", "data.time.day"),
        color.Orange .. ". Select a function to run on this world."
    },
    buttons = {
        { caption = "IncrementDay() and LoadTime(nil, true)",
            destinations = {
                menuHelper.destinations.setDefault(nil,
                {
                    menuHelper.effects.runGlobalFunction("WorldInstance", "IncrementDay"),
                    menuHelper.effects.runGlobalFunction("WorldInstance", "LoadTime",
                        {menuHelper.variables.currentPid(), true})
                })
            }
        },
        { caption = "Back", destinations = { menuHelper.destinations.setFromCustomVariable("previousCustomMenu") } },
        { caption = "Exit", destinations = nil }
    }
}

Menus["advanced example logichandler"] = {
    text = color.Orange .. "Select a function to run on the logicHandler.",
    buttons = {
        { caption = "CreateObjectAtPlayer(menuHelper.variables.currentPid(), \"rat\", \"spawn\")",
            destinations = {
                menuHelper.destinations.setDefault(nil,
                {
                    menuHelper.effects.runGlobalFunction("logicHandler", "CreateObjectAtPlayer",
                        {menuHelper.variables.currentPid(), "rat", "spawn"})
                })
            }
        },
        { caption = "Back", destinations = { menuHelper.destinations.setFromCustomVariable("previousCustomMenu") } },
        { caption = "Exit", destinations = nil }
    }
}

Menus["advanced example global"] = {
    text = color.Orange .. "Select a global function to run.",
    buttons = {
        { caption = "OnPlayerSendMessage(menuHelper.variables.currentPid(), \"This is a test chat message\")",
            destinations = {
                menuHelper.destinations.setDefault(nil,
                {
                    menuHelper.effects.runGlobalFunction(nil, "OnPlayerSendMessage",
                        {menuHelper.variables.currentPid(), "This is a test chat message"})
                })
            }
        },
        { caption = "Back", destinations = { menuHelper.destinations.setFromCustomVariable("previousCustomMenu") } },
        { caption = "Exit", destinations = nil }
    }
}
